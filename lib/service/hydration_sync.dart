import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:health/health.dart';
import 'package:rxdart/rxdart.dart';

enum HydrationStatus { disabled, syncing, synced, pending, unavailable }

enum HydrationPermission { unknown, granted, denied, unavailable }

abstract class HydrationHealth {
  bool get supported;
  Future<bool> authorize();
  Future<HydrationPermission> permission();
  Future<void> write(String id, int version, double ml, DateTime time);
  Future<void> remove(String id);
}

class DeviceHydrationHealth implements HydrationHealth {
  final _health = Health();
  static const _channel = MethodChannel('gymbro/hydration');
  bool _configured = false;
  @override
  bool get supported => Platform.isIOS || Platform.isAndroid;
  Future<void> configure() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
  }

  @override
  Future<HydrationPermission> permission() async {
    if (!supported) return HydrationPermission.unavailable;
    if (Platform.isIOS) {
      final value = await _channel.invokeMethod<String>('permission');
      return HydrationPermission.values.firstWhere(
        (p) => p.name == value,
        orElse: () => HydrationPermission.unavailable,
      );
    }
    await configure();
    if (!await _health.isHealthConnectAvailable()) {
      return HydrationPermission.unavailable;
    }
    final granted = await _health.hasPermissions(
      [HealthDataType.WATER],
      permissions: [HealthDataAccess.WRITE],
    );
    return granted == true
        ? HydrationPermission.granted
        : HydrationPermission.unknown;
  }

  @override
  Future<bool> authorize() async {
    if (!supported) return false;
    if (Platform.isIOS) {
      return await _channel.invokeMethod<bool>('authorize') ?? false;
    }
    await configure();
    return _health.requestAuthorization(
      [HealthDataType.WATER],
      permissions: [HealthDataAccess.WRITE],
    );
  }

  @override
  Future<void> write(String id, int version, double ml, DateTime time) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('write', {
        'id': id,
        'version': version,
        'ml': ml,
        'time': time.millisecondsSinceEpoch,
      });
    } else {
      await configure();
      final ok = await _health.writeHealthData(
        value: ml / 1000,
        type: HealthDataType.WATER,
        unit: HealthDataUnit.LITER,
        startTime: time,
        endTime: time.add(const Duration(milliseconds: 1)),
        clientRecordId: id,
        clientRecordVersion: version.toDouble(),
        recordingMethod: RecordingMethod.manual,
      );
      if (!ok) throw StateError('Water export failed');
    }
  }

  @override
  Future<void> remove(String id) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('delete', {'id': id});
    } else {
      await configure();
      if (!await _health.deleteByClientRecordId(
        dataTypeKey: HealthDataType.WATER,
        clientRecordId: id,
      )) {
        throw StateError('Water deletion failed');
      }
    }
  }
}

/// Persist the intended export before calling the platform. Repeating a write
/// uses the same identifier/version, including after a crash or a lost reply.
class HydrationSync {
  HydrationSync(this.db, {HydrationHealth? health})
    : health = health ?? DeviceHydrationHealth();
  final GTDatabase db;
  final HydrationHealth health;
  final status = BehaviorSubject<HydrationStatus>.seeded(
    HydrationStatus.disabled,
  );
  final permissionStatus = BehaviorSubject<HydrationPermission>.seeded(
    HydrationPermission.unknown,
  );
  Future<void>? _authorization;
  bool _busy = false;
  bool _again = false;
  bool _disposed = false;
  String get ownerKey =>
      db.currentUserId == null ? 'guest' : 'user:${db.currentUserId}';
  void emit(HydrationStatus value) {
    if (!_disposed) status.add(value);
  }

  void _emitPermission(HydrationPermission value) {
    if (!_disposed) permissionStatus.add(value);
  }

  Future<void> _activate(String owner) async {
    if (_disposed || ownerKey != owner) return;
    final old = await (db.select(
      db.hydrationSettings,
    )..where((t) => t.owner.equals(owner))).getSingleOrNull();
    if (_disposed || ownerKey != owner) return;
    final now = DateTime.now();
    await db
        .into(db.hydrationSettings)
        .insertOnConflictUpdate(
          HydrationSettingsCompanion.insert(
            owner: owner,
            enabledSince:
                old?.enabledSince ?? DateTime.utc(now.year, now.month, now.day),
            enabled: const Value(true),
          ),
        );
    if (!_disposed && ownerKey == owner) await process();
  }

  /// Refreshes OS permission without prompting. The first diary visit can request
  /// it once; subsequent visits/resumes only pick up changes made in Settings.
  Future<HydrationPermission> connectAutomatically({
    bool requestPermission = false,
  }) async {
    final owner = ownerKey;
    try {
      var permission = await health.permission();
      if (permission == HydrationPermission.unknown &&
          (permissionStatus.value == HydrationPermission.denied ||
              permissionStatus.value == HydrationPermission.granted)) {
        permission = HydrationPermission.denied;
      }
      if (_disposed || ownerKey != owner) return HydrationPermission.unknown;
      _emitPermission(permission);
      if (permission == HydrationPermission.granted) {
        await _activate(owner);
      } else if (permission == HydrationPermission.unknown &&
          requestPermission) {
        await enable();
        return permissionStatus.value;
      } else {
        emit(
          permission == HydrationPermission.unavailable
              ? HydrationStatus.unavailable
              : HydrationStatus.pending,
        );
      }
      return permission;
    } catch (_) {
      if (!_disposed && ownerKey == owner) emit(HydrationStatus.unavailable);
      return HydrationPermission.unavailable;
    }
  }

  Future<void> enable() =>
      _authorization ??= _enable().whenComplete(() => _authorization = null);

  Future<void> _enable() async {
    final owner = ownerKey;
    if (!health.supported) {
      _emitPermission(HydrationPermission.unavailable);
      emit(HydrationStatus.unavailable);
      return;
    }
    try {
      final granted = await health.authorize();
      if (_disposed || ownerKey != owner) return;
      _emitPermission(
        granted ? HydrationPermission.granted : HydrationPermission.denied,
      );
      if (!granted) {
        emit(HydrationStatus.pending);
        return;
      }
      await _activate(owner);
    } on UnsupportedError {
      _emitPermission(HydrationPermission.unavailable);
      emit(HydrationStatus.unavailable);
    } on PlatformException catch (error) {
      emit(
        error.code == 'unavailable'
            ? HydrationStatus.unavailable
            : HydrationStatus.pending,
      );
    } catch (_) {
      emit(HydrationStatus.pending);
    }
  }

  Future<void> disable() async {
    final owner = ownerKey;
    await (db.update(db.hydrationSettings)..where((t) => t.owner.equals(owner)))
        .write(const HydrationSettingsCompanion(enabled: Value(false)));
    emit(HydrationStatus.disabled);
  }

  Future<void> process() async {
    if (_disposed) return;
    if (_busy) {
      _again = true;
      return;
    }
    _busy = true;
    try {
      do {
        _again = false;
        await _processOwner();
      } while (_again && !_disposed);
    } catch (_) {
      emit(HydrationStatus.pending);
    } finally {
      _busy = false;
    }
  }

  Future<void> _processOwner() async {
    final owner = ownerKey;
    final user = db.currentUserId;
    bool active() => !_disposed && ownerKey == owner;
    final settings = await (db.select(
      db.hydrationSettings,
    )..where((t) => t.owner.equals(owner))).getSingleOrNull();
    if (!active()) return;
    if (settings == null || !settings.enabled) {
      emit(HydrationStatus.disabled);
      return;
    }
    if (!health.supported) {
      emit(HydrationStatus.unavailable);
      return;
    }
    Expression<bool> owned(TextColumn c) =>
        user == null ? c.isNull() : c.equals(user);
    final logs =
        await (db.select(db.waterLogs)..where(
              (t) =>
                  owned(t.userId) &
                  t.deleted.equals(false) &
                  t.referenceDate.isBiggerOrEqualValue(settings.enabledSince),
            ))
            .get();
    final foods =
        await (db.select(db.foods)..where(
              (t) =>
                  owned(t.userId) &
                  t.deleted.equals(false) &
                  t.referenceDate.isBiggerOrEqualValue(settings.enabledSince),
            ))
            .get();
    if (!active()) return;
    final desired = <String, (double, DateTime)>{};
    for (final row in logs) {
      final entry = WaterEntry.fromRow(row);
      desired['gymbro:$owner:water:${row.id}'] = (
        entry.milliliters,
        entry.time,
      );
    }
    for (final row in foods) {
      final food = Food.fromJson(jsonDecode(row.jsonData));
      final ml = food.nutritionalValues.water ?? 0;
      if (!ml.isFinite || ml <= 0) continue;
      final day = row.referenceDate.toUtc();
      final added = row.dateAdded.toLocal();
      final time =
          added.year == day.year &&
              added.month == day.month &&
              added.day == day.day
          ? added
          : DateTime(day.year, day.month, day.day, 12);
      desired['gymbro:$owner:food:${row.id}'] = (ml, time);
    }
    final exports = await (db.select(
      db.hydrationExports,
    )..where((t) => t.owner.equals(owner))).get();
    if (!active()) return;
    final previous = {for (final row in exports) row.recordId: row};
    final ids = {...desired.keys, ...previous.keys};
    var failed = false;
    emit(HydrationStatus.syncing);
    for (final id in ids) {
      if (!active()) return;
      final value = desired[id];
      // Future diary items are exported only when their time is reached.
      if (value != null && value.$2.isAfter(DateTime.now())) continue;
      final fingerprint = value == null
          ? 'deleted'
          : jsonEncode([value.$1, value.$2.millisecondsSinceEpoch]);
      final old = previous[id];
      if (old?.fingerprint == fingerprint && !old!.pending) continue;
      final version = old?.fingerprint == fingerprint
          ? old!.version
          : math.max(
              DateTime.now().millisecondsSinceEpoch,
              (old?.version ?? 0) + 1,
            );
      await db
          .into(db.hydrationExports)
          .insertOnConflictUpdate(
            HydrationExportsCompanion.insert(
              owner: owner,
              recordId: id,
              fingerprint: fingerprint,
              version: version,
              pending: const Value(true),
            ),
          );
      if (!active()) return;
      // Check opt-out again immediately before each external write.
      final enabled = await (db.select(
        db.hydrationSettings,
      )..where((t) => t.owner.equals(owner))).getSingleOrNull();
      if (!active() || enabled?.enabled != true) return;
      try {
        if (value == null) {
          await health.remove(id);
        } else {
          await health.write(id, version, value.$1, value.$2);
        }
        if (!active()) return;
        await (db.update(db.hydrationExports)
              ..where((t) => t.owner.equals(owner) & t.recordId.equals(id)))
            .write(const HydrationExportsCompanion(pending: Value(false)));
      } catch (_) {
        failed = true;
      }
    }
    if (active()) {
      emit(failed ? HydrationStatus.pending : HydrationStatus.synced);
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(status.close());
    unawaited(permissionStatus.close());
  }
}

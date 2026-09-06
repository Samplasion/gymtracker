import 'dart:async';

import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_status.g.dart';

enum SyncState { syncing, notSyncing, error }

class SyncStatus {
  final SyncState state;
  final DateTime? lastSync;

  const SyncStatus({required this.state, this.lastSync});

  bool get isSyncing => state == SyncState.syncing;
  bool get hasError => state == SyncState.error;

  SyncStatus copyWith({SyncState? state, DateTime? lastSync}) {
    return SyncStatus(
      state: state ?? this.state,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatus &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          lastSync == other.lastSync;

  @override
  int get hashCode => state.hashCode ^ (lastSync?.hashCode ?? 0);

  @override
  String toString() => 'SyncStatus(state: $state, lastSync: $lastSync)';
}

@Riverpod(keepAlive: true)
class SyncStatusNotifier extends _$SyncStatusNotifier {
  SharedPreferences? _prefs;
  Timer? _pollingTimer;
  DateTime? _lastSync;

  static const String _lastSyncKeyPrefix = 'gymtracker_last_sync_';

  @override
  SyncStatus build() {
    final eventBus = ref.watch(eventBusProvider);
    final account = ref.watch(onlineProvider).value;

    final startSub = eventBus.on<GBSyncStartedEvent>().listen((_) {
      state = state.copyWith(state: SyncState.syncing);
      _startPollingIfNeeded();
    });
    final finishSub = eventBus.on<GBSyncFinishedEvent>().listen((event) {
      if (event.lastSync != null) {
        _lastSync = event.lastSync;
        _saveLastSync(event.lastSync!);
        state = state.copyWith(
          state: SyncState.notSyncing,
          lastSync: _lastSync,
        );
      } else {
        if (state.state != SyncState.error) {
          state = state.copyWith(state: SyncState.notSyncing);
        }
      }
      _stopPolling();
    });
    final errorSub = eventBus.on<GBSyncErrorEvent>().listen((event) {
      logger.e(
        "Sync failed: ${event.error}",
        error: event.error,
        stackTrace: event.stackTrace,
      );
      Sentry.captureException(event.error, stackTrace: event.stackTrace);
      state = state.copyWith(state: SyncState.error);
      _stopPolling();
    });
    final timestampSub = eventBus.on<GBSyncTimestampUpdatedEvent>().listen((
      event,
    ) {
      final local = event.timestamp.toLocal();
      _lastSync = local;
      _saveLastSync(local);
      state = state.copyWith(lastSync: local);
    });

    ref.onDispose(() {
      startSub.cancel();
      finishSub.cancel();
      errorSub.cancel();
      timestampSub.cancel();
      _stopPolling();
    });

    if (account?.id != null) {
      _loadPrefsAndInitialState(account!.id);
    }

    final isSyncing = _checkIsSyncing();
    if (isSyncing) {
      _startPollingIfNeeded();
    }

    return SyncStatus(
      state: isSyncing ? SyncState.syncing : SyncState.notSyncing,
      lastSync: stateOrNull?.lastSync ?? _lastSync,
    );
  }

  bool _checkIsSyncing() {
    try {
      final online = ref.read(onlineProvider.notifier);
      if (online.isInit) {
        return online.syncManager.isSyncingAny;
      }
    } catch (_) {}
    return false;
  }

  void _startPollingIfNeeded() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final isSyncing = _checkIsSyncing();
      if (!isSyncing && state.isSyncing) {
        state = state.copyWith(state: SyncState.notSyncing);
        _stopPolling();
      } else if (isSyncing && !state.isSyncing) {
        state = state.copyWith(state: SyncState.syncing);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _loadPrefsAndInitialState(String userId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final timestampMs = _prefs?.getInt('$_lastSyncKeyPrefix$userId');
    if (timestampMs != null) {
      final loadedDate = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      _lastSync = loadedDate;
      state = state.copyWith(lastSync: loadedDate);
    }
  }

  Future<void> _saveLastSync(DateTime timestamp) async {
    _prefs ??= await SharedPreferences.getInstance();
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await _prefs?.setInt(
        '$_lastSyncKeyPrefix$userId',
        timestamp.millisecondsSinceEpoch,
      );
    }
  }

  Future<bool> sync({bool force = false}) async {
    if (state.isSyncing) return false;
    final lastSync = state.lastSync;
    if (!force &&
        lastSync != null &&
        DateTime.now().difference(lastSync) < const Duration(minutes: 1)) {
      return false;
    }
    final online = ref.read(onlineProvider.notifier);
    try {
      await online.sync();
      return true;
    } catch (e, s) {
      logger.e("Sync failed: $e", error: e, stackTrace: s);
      return false;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

class ProtocolBackend {
  final rows = <String, Map<String, dynamic>>{};
  final changes = <Map<String, dynamic>>[];
  final receipts = <String, Map<String, dynamic>>{};
  int calls = 0, pushes = 0;
  bool loseResponse = false;
  final invalidIds = <String>{};
  int pulls = 0;
  int? failPull;
  Future<void> Function()? duringPush;
  late final client = SupabaseClient(
    'https://unit.test',
    'key',
    httpClient: MockClient(handle),
  );
  void put(Map<String, dynamic> payload) {
    final row = {...payload, 'revision': changes.length + 1};
    rows[payload['id'] as String] = row;
    changes.add({
      'revision': row['revision'],
      'entity': 'nutrition_goals',
      'payload': row,
    });
  }

  Future<http.Response> handle(http.Request request) async {
    calls++;
    final params = jsonDecode(request.body) as Map<String, dynamic>;
    Object result;
    if (request.url.path.endsWith('sync_push_v2')) {
      pushes++;
      await duringPush?.call();
      duringPush = null;
      result = [
        for (final raw in params['operations'] as List)
          apply(Map<String, dynamic>.from(raw as Map)),
      ];
      if (loseResponse) {
        loseResponse = false;
        throw const SocketException('Response lost after server commit');
      }
    } else {
      pulls++;
      if (pulls == failPull)
        throw const SocketException('Download interrupted');
      final cursor = params['cursor'] as int;
      final horizon = params['horizon'] as int? ?? changes.length;
      final page = changes
          .where(
            (r) =>
                (r['revision'] as int) > cursor &&
                (r['revision'] as int) <= horizon,
          )
          .take(500)
          .toList();
      final next = page.isEmpty ? cursor : page.last['revision'] as int;
      result = {
        'changes': page,
        'horizon': horizon,
        'cursor': next,
        'has_more': next < horizon,
      };
    }
    return http.Response(
      jsonEncode(result),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }

  Map<String, dynamic> apply(Map<String, dynamic> op) {
    final operation = op['operation_id'] as String;
    if (invalidIds.contains(op['record_id']))
      return {
        'operation_id': operation,
        'status': 'error',
        'code': '23514',
        'revision': 0,
        'payload': <String, dynamic>{},
      };
    if (receipts.containsKey(operation)) return receipts[operation]!;
    final row = rows[op['record_id']];
    final conflict = (row?['revision'] ?? 0) != op['base_revision'];
    if (!conflict) put(Map<String, dynamic>.from(op['payload'] as Map));
    return receipts[operation] = {
      'operation_id': operation,
      'status': conflict ? 'conflict' : 'applied',
      'revision': rows[op['record_id']]?['revision'] ?? 0,
      'payload': rows[op['record_id']] ?? <String, dynamic>{},
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = 'owner-A';
  late GTDatabaseImpl db;
  late ProtocolBackend backend;
  late SyncManager<GTDatabase> manager;
  Future<void> local(double calories) => db
      .into(db.nutritionGoals)
      .insertOnConflictUpdate(
        NutritionGoalsCompanion.insert(
          id: const Value('day'),
          userId: const Value(owner),
          referenceDate: DateTime.utc(2026, 10, 20),
          calories: calories,
          fat: 50,
          carbs: 200,
          protein: 100,
          updatedAt: Value(DateTime.utc(2026, 10, 20)),
        ),
      );
  SyncManager<GTDatabase> engine() {
    final m = SyncManager<GTDatabase>(
      localDatabase: db,
      supabaseClient: backend.client,
      useProtocolV2: true,
      syncInterval: const Duration(hours: 1),
    );
    m.registerSyncable<DBNutritionGoal>(
      backendTable: 'nutrition_goals',
      fromJson: DBNutritionGoal.fromJson,
      companionConstructor: NutritionGoalsCompanion.new,
    );
    m.setUserId(owner);
    m.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
    return m;
  }

  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    db.setCurrentUserId(owner);
    backend = ProtocolBackend();
    manager = engine();
  });
  tearDown(() async {
    await manager.close();
    await db.close();
    await backend.client.dispose();
  });

  test('domain change and outbox roll back together', () async {
    await expectLater(
      db.transaction(() async {
        await local(1800);
        throw StateError('abort');
      }),
      throwsStateError,
    );
    expect(await SyncV2Store.pending(db, owner), 0);
    expect(
      await (db.select(
        db.nutritionGoals,
      )..where((t) => t.userId.equals(owner))).get(),
      isEmpty,
    );
  });
  test(
    'an operation survives engine restart and a lost server response',
    () async {
      await local(1800);
      backend.loseResponse = true;
      manager.enableSync();
      await expectLater(manager.syncTables(), throwsA(isA<SocketException>()));
      expect(await SyncV2Store.pending(db, owner), 1);
      await manager.close();
      manager = engine();
      manager.enableSync();
      await manager.syncTables();
      expect(await SyncV2Store.pending(db, owner), 0);
      expect(backend.receipts.length, 1);
      expect(backend.rows['day']!['calories'], 1800);
    },
  );
  test('a receipt cannot acknowledge a newer edit to the same row', () async {
    await local(1800);
    backend.duringPush = () => local(2100);
    manager.enableSync();
    await manager.syncTables();
    expect(await SyncV2Store.pending(db, owner), 0);
    expect(backend.rows['day']!['calories'], 2100);
    expect(backend.receipts.length, 2);
  });
  test(
    'conflicting offline edit is preserved and explicitly recoverable',
    () async {
      await local(1800);
      final row = (await (db.select(
        db.nutritionGoals,
      )..where((t) => t.userId.equals(owner))).getSingle()).toJson();
      backend.put({...row, 'calories': 2200});
      manager.enableSync();
      await manager.syncTables();
      expect(manager.lastResult!.outcome, SyncOutcome.partial);
      final conflict = await db
          .customSelect('SELECT * FROM sync_conflicts WHERE resolved=0')
          .getSingle();
      expect(
        jsonDecode(conflict.read<String>('local_payload'))['calories'],
        1800,
      );
      expect(backend.rows['day']!['calories'], 2200);
      await manager.resolveConflict(
        conflict.read<String>('operation_id'),
        useLocal: true,
      );
      await manager.syncTables();
      expect(backend.rows['day']!['calories'], 1800);
      expect(await SyncV2Store.pending(db, owner), 0);
    },
  );
  test(
    'a validation error blocks only its record and can be retried',
    () async {
      await local(1800);
      await db
          .into(db.nutritionGoals)
          .insert(
            NutritionGoalsCompanion.insert(
              id: const Value('bad'),
              userId: const Value(owner),
              referenceDate: DateTime.utc(2026, 10, 20),
              calories: 2000,
              fat: 50,
              carbs: 200,
              protein: 100,
            ),
          );
      backend.invalidIds.add('bad');
      manager.enableSync();
      await manager.syncTables();
      expect(backend.rows['day'], isNotNull);
      expect(backend.rows['bad'], isNull);
      expect(manager.lastResult!.outcome, SyncOutcome.partial);
      final pending = await db
          .customSelect('SELECT * FROM sync_outbox')
          .getSingle();
      expect(pending.read<String>('error'), '23514');
      backend.invalidIds.clear();
      await manager.retryPending();
      expect(await SyncV2Store.pending(db, owner), 0);
    },
  );
  test(
    'choosing server after a newer pull never restores an old conflict version',
    () async {
      await local(1800);
      final initial = (await (db.select(
        db.nutritionGoals,
      )..where((t) => t.userId.equals(owner))).getSingle()).toJson();
      backend.put({...initial, 'calories': 2200});
      manager.enableSync();
      await manager.syncTables();
      final conflict = await db
          .customSelect('SELECT operation_id FROM sync_conflicts')
          .getSingle();
      backend.put({...initial, 'calories': 2400});
      await manager.syncTables();
      await manager.resolveConflict(
        conflict.read<String>('operation_id'),
        useLocal: false,
      );
      expect(
        (await (db.select(
          db.nutritionGoals,
        )..where((t) => t.userId.equals(owner))).getSingle()).calories,
        2400,
      );
      await manager.restoreConflictVersion(
        conflict.read<String>('operation_id'),
        useLocal: true,
      );
      await manager.syncTables();
      expect(backend.rows['day']!['calories'], 1800);
    },
  );
  test('a restarted bootstrap resumes its persisted snapshot cursor', () async {
    final payload = DBNutritionGoal(
      id: 'template',
      userId: owner,
      referenceDate: DateTime.utc(2026, 10, 20),
      calories: 2000,
      fat: 50,
      carbs: 200,
      protein: 100,
      updatedAt: DateTime.utc(2026, 10, 20),
      deleted: false,
    ).toJson();
    for (var i = 0; i < 1001; i++) {
      backend.put({...payload, 'id': 'remote-$i'});
    }
    backend.failPull = 2;
    manager.enableSync();
    await expectLater(manager.syncTables(), throwsA(isA<SocketException>()));
    final saved = await db
        .customSelect(
          'SELECT reconcile_cursor FROM sync_cursors WHERE owner=?',
          variables: [const Variable(owner)],
        )
        .getSingle();
    expect(saved.read<int>('reconcile_cursor'), 500);
    await manager.close();
    manager = engine();
    backend.failPull = null;
    manager.enableSync();
    await manager.syncTables();
    expect(backend.pulls, 4);
    expect(
      await (db.select(
        db.nutritionGoals,
      )..where((t) => t.userId.equals(owner))).get(),
      hasLength(1001),
    );
  });

  test('idle ticks make no HTTP request', () async {
    manager.enableSync();
    await manager.syncTables();
    final calls = backend.calls;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(backend.calls, calls);
  });
}

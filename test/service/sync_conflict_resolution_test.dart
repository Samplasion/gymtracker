import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/service/sync_conflict_resolution.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late SupabaseClient client;
  late SyncManager<GTDatabase> manager;
  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('owner');
    client = SupabaseClient(
      'https://sync.test',
      'key',
      httpClient: MockClient((_) async => throw StateError('No HTTP expected')),
    );
    manager = SyncManager<GTDatabase>(
      localDatabase: db,
      supabaseClient: client,
      useProtocolV2: true,
    );
    manager.registerSyncable<DBNutritionGoal>(
      backendTable: 'nutrition_goals',
      fromJson: DBNutritionGoal.fromJson,
      companionConstructor: NutritionGoalsCompanion.new,
    );
    manager.setUserId('owner');
  });
  tearDown(() async {
    await manager.close();
    await db.close();
    await client.dispose();
  });

  Future<String> conflict(String id, {String owner = 'owner'}) async {
    await db
        .into(db.nutritionGoals)
        .insert(
          NutritionGoalsCompanion.insert(
            id: Value(id),
            userId: Value(owner),
            referenceDate: DateTime.utc(2026, 10, 31),
            calories: 1800,
            fat: 50,
            carbs: 200,
            protein: 100,
          ),
        );
    final op = await db
        .customSelect(
          'SELECT * FROM sync_outbox WHERE record_id=?',
          variables: [Variable(id)],
        )
        .getSingle();
    final row = (await (db.select(
      db.nutritionGoals,
    )..where((t) => t.id.equals(id))).getSingle()).toJson();
    final remote = {...row, 'calories': 2200.0};
    await db.customStatement(
      'UPDATE sync_outbox SET blocked=1 WHERE record_id=?',
      [id],
    );
    await db.customStatement(
      '''INSERT INTO sync_conflicts
      (operation_id,owner,entity,record_id,local_payload,server_payload,server_revision)
      VALUES (?,?,'nutrition_goals',?,?,?,1)''',
      [
        op.read<String>('operation_id'),
        owner,
        id,
        jsonEncode(row),
        jsonEncode(remote),
      ],
    );
    return op.read<String>('operation_id');
  }

  for (final useLocal in [false, true]) {
    test(
      'bulk choice useLocal=$useLocal preserves history and isolates owners and unselected rows',
      () async {
        final ids = {await conflict('one'), await conflict('two')};
        final other = await conflict('other', owner: 'another-owner');
        await conflict('unselected');
        final progress = <int>[];
        final count = await resolveSelectedSyncConflicts(
          db: db,
          manager: manager,
          owner: 'owner',
          operationIds: {...ids, other},
          useLocal: useLocal,
          onProgress: (completed, total) {
            progress.add(completed);
            expect(total, 2);
          },
        );
        expect(count, 2);
        expect(progress, [1, 2]);
        final rows = await (db.select(
          db.nutritionGoals,
        )..where((t) => t.id.isIn(['one', 'two']))).get();
        expect(
          rows.map((r) => r.calories),
          everyElement(useLocal ? 1800.0 : 2200.0),
        );
        final history = await db
            .customSelect("SELECT * FROM sync_conflicts WHERE resolved=1")
            .get();
        expect(history, hasLength(2));
        for (final row in history) {
          expect(
            jsonDecode(row.read<String>('local_payload'))['calories'],
            1800,
          );
          expect(
            jsonDecode(row.read<String>('server_payload'))['calories'],
            2200,
          );
        }
        final unresolved = await db
            .customSelect('SELECT * FROM sync_conflicts WHERE resolved=0')
            .get();
        expect(unresolved.map((r) => r.read<String>('record_id')).toSet(), {
          'other',
          'unselected',
        });
        final outgoing = await db
            .customSelect(
              "SELECT * FROM sync_outbox WHERE record_id IN ('one','two')",
            )
            .get();
        expect(outgoing, hasLength(useLocal ? 2 : 0));
        if (useLocal) {
          expect(
            outgoing.map((r) => r.read<int>('base_revision')),
            everyElement(1),
          );
        }
        expect(manager.syncingEnabled, isFalse);
      },
    );
  }

  test(
    'failure rolls back the whole batch and keeps all pending snapshots',
    () async {
      final ids = {await conflict('one'), await conflict('two')};
      await db.customStatement(
        "UPDATE sync_conflicts SET server_payload='{\"user_id\":\"owner\",\"id\":\"two\"}'  WHERE record_id='two'",
      );
      await expectLater(
        resolveSelectedSyncConflicts(
          db: db,
          manager: manager,
          owner: 'owner',
          operationIds: ids,
          useLocal: false,
        ),
        throwsA(anything),
      );
      expect(
        (await db.select(db.nutritionGoals).get()).map((r) => r.calories),
        everyElement(1800),
      );
      expect(
        await db
            .customSelect('SELECT * FROM sync_conflicts WHERE resolved=1')
            .get(),
        isEmpty,
      );
      expect(await SyncV2Store.pending(db, 'owner'), 2);
    },
  );

  test(
    'changed accounts cannot resolve the previous owner conflicts',
    () async {
      final id = await conflict('one');
      db.setCurrentUserId('new-owner');
      await expectLater(
        resolveSelectedSyncConflicts(
          db: db,
          manager: manager,
          owner: 'owner',
          operationIds: {id},
          useLocal: false,
        ),
        throwsStateError,
      );
      expect(await SyncV2Store.pending(db, 'owner'), 1);
    },
  );
}

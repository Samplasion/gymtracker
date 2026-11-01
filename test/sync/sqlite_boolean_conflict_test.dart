import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';

import 'durable_protocol_test.dart' show ProtocolBackend;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final deleted in [false, true]) {
    test(
      'SQLite deleted=${deleted ? 1 : 0} equals server deleted=$deleted',
      () async {
        final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
        final backend = ProtocolBackend();
        db.setCurrentUserId('owner');
        final manager = SyncManager<GTDatabase>(
          localDatabase: db,
          supabaseClient: backend.client,
          useProtocolV2: true,
          syncInterval: const Duration(hours: 1),
        );
        manager.registerSyncable<DBNutritionGoal>(
          backendTable: 'nutrition_goals',
          fromJson: DBNutritionGoal.fromJson,
          companionConstructor: NutritionGoalsCompanion.new,
        );
        manager.setUserId('owner');
        manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
        addTearDown(() async {
          await manager.close();
          await db.close();
          await backend.client.dispose();
        });
        await db
            .into(db.nutritionGoals)
            .insert(
              NutritionGoalsCompanion.insert(
                id: const Value('day'),
                userId: const Value('owner'),
                referenceDate: DateTime.utc(2026, 10, 31),
                calories: 2000,
                fat: 50,
                carbs: 200,
                protein: 100,
                deleted: Value(deleted),
              ),
            );
        final snapshot =
            jsonDecode(
                  (await db
                          .customSelect('SELECT payload FROM sync_outbox')
                          .getSingle())
                      .read<String>('payload'),
                )
                as Map;
        expect(snapshot['deleted'], deleted ? 1 : 0);
        final remote = (await db.select(db.nutritionGoals).getSingle())
            .toJson();
        expect(remote['deleted'], deleted);
        backend.put(remote);
        manager.enableSync();
        await manager.syncTables();
        expect(manager.lastResult!.outcome, SyncOutcome.completed);
        expect(await SyncV2Store.pending(db, 'owner'), 0);
        expect(
          await db.customSelect('SELECT * FROM sync_conflicts').get(),
          isEmpty,
        );
        expect(backend.pushes, 0);
      },
    );
  }
}

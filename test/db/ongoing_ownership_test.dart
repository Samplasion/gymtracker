import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';

Map<String, dynamic> workout(String name) => {
  'name': name,
  'exercises': <dynamic>[],
  'time': 1792310400000,
  'parentID': null,
  'infobox': null,
};

void main() {
  late GTDatabaseImpl db;
  setUp(() => db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('workouts survive A, guest, B, A transitions independently', () async {
    for (final user in ['A', null, 'B']) {
      db.setCurrentUserId(user);
      await db.setOngoing(workout(user ?? 'Guest'));
    }
    for (final user in ['A', null, 'B', 'A']) {
      db.setCurrentUserId(user);
      expect(await db.watchOngoing().first, workout(user ?? 'Guest'));
    }
    // Closing A's old controller after switching to B must only remove A.
    db.setCurrentUserId('B');
    await db.deleteOngoingForUser('A');
    expect(await db.watchOngoing().first, workout('B'));
  });

  test(
    'legacy recovery is explicit and cannot overwrite an existing workout',
    () async {
      final legacy = workout('Legacy');
      await db
          .into(db.ongoingData)
          .insert(OngoingDataCompanion(data: Value(jsonEncode(legacy))));
      db.setCurrentUserId('A');
      expect(await db.watchOngoing().first, isNull);
      await db.setOngoing(workout('Current A'));
      await expectLater(db.recoverLegacyOngoing(), throwsStateError);
      expect(await db.watchLegacyOngoing().first, legacy);
      expect(await db.watchOngoing().first, workout('Current A'));
      await db.deleteOngoing();
      await db.recoverLegacyOngoing();
      expect(await db.watchOngoing().first, legacy);
      expect(await db.watchLegacyOngoing().first, isNull);
      db.setCurrentUserId('B');
      expect(await db.watchOngoing().first, isNull);
    },
  );

  test(
    'migration from v17 preserves old save without assigning an owner',
    () async {
      await db.close();
      final schema = jsonDecode(
        File('drift_schemas/drift_schema_v17.json').readAsStringSync(),
      );
      final legacy = workout('Before upgrade');
      db = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            for (final entry in schema['fixed_sql'] as List) {
              final sql =
                  (entry['sql'] as List).firstWhere(
                        (s) => s['dialect'] == 'sqlite',
                      )['sql']
                      as String;
              raw.execute(sql);
            }
            raw.execute('INSERT INTO ongoing_data(data) VALUES (?)', [
              jsonEncode(legacy),
            ]);
            raw.execute('PRAGMA user_version = 17');
          },
        ),
      );
      expect(await db.watchLegacyOngoing().first, legacy);
      expect(await db.watchOngoing().first, isNull);
      db.setCurrentUserId('A');
      expect(await db.watchOngoing().first, isNull);
      await db.recoverLegacyOngoing();
      expect(await db.watchOngoing().first, legacy);
    },
  );
}

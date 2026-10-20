import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';

void main() {
  test(
    'v19 upgrade preserves account and guest data and installs durable sync',
    () async {
      final schema = jsonDecode(
        File('drift_schemas/drift_schema_v19.json').readAsStringSync(),
      );
      final db = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            for (final entry in schema['fixed_sql'] as List) {
              for (final statement in entry['sql'] as List) {
                if (statement['dialect'] == 'sqlite') {
                  raw.execute(statement['sql'] as String);
                }
              }
            }
            for (final account in ['A', 'B', null]) {
              raw.execute(
                '''
            INSERT INTO routines
              (id, name, infobox, weight_unit, distance_unit, sort_order, user_id)
            VALUES ('same-id', 'Existing routine', '', 'kg', 'km', 0, ?)
          ''',
                [account],
              );
            }
            raw.execute('PRAGMA user_version = 19');
          },
        ),
      );
      addTearDown(db.close);

      await db.validateDatabaseSchema();
      final rows = await db.customSelect('SELECT * FROM routines').get();
      expect(rows, hasLength(3));
      expect(
        rows.map((row) => row.data['user_id']),
        unorderedEquals(['A', 'B', null]),
      );
      expect(
        rows.every((row) => row.data['name'] == 'Existing routine'),
        isTrue,
      );
      expect(await db.select(db.syncOutbox).get(), isEmpty);

      // Existing rows are reconciled separately; a new local edit must be captured.
      await db.customStatement("""
      UPDATE routines SET name = 'Edited after upgrade' WHERE user_id = 'A'
    """);
      final operations = await db.select(db.syncOutbox).get();
      expect(operations, hasLength(1));
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data['user_version'],
        DATABASE_VERSION,
      );
    },
  );
}

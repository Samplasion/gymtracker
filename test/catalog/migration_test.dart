import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  test(
    'v21 upgrade preserves Food JSON and starts with an empty publication queue',
    () async {
      final schema = jsonDecode(
        File('drift_schemas/drift_schema_v21.json').readAsStringSync(),
      );
      final snapshot = jsonEncode(
        Food(
          name: 'Historical OFF food',
          amount: 125,
          downloadedFromOFF: true,
          barcode: '00123456',
          nutritionalValuesPer100g: NutritionValues.zero,
        ).toJson(),
      );
      final db = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            for (final entry in schema['fixed_sql'] as List) {
              for (final sql in entry['sql'] as List) {
                if (sql['dialect'] == 'sqlite') {
                  raw.execute(sql['sql'] as String);
                }
              }
            }
            raw.execute(
              'INSERT INTO foods(id,user_id,date_added,reference_date,json_data) VALUES(?,?,?,?,?)',
              ['historical', 'A', 0, 0, snapshot],
            );
            raw.execute('PRAGMA user_version=21');
          },
        ),
      );
      addTearDown(db.close);
      await db.validateDatabaseSchema();
      final stored =
          (await db.customSelect('SELECT json_data FROM foods').getSingle())
              .data['json_data'];
      expect(stored, snapshot);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        22,
      );
      expect(await db.select(db.catalogSubmissions).get(), isEmpty);
    },
  );
}

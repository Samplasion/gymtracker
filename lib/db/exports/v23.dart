import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v21.dart';

class VersionedJsonExportV23 extends VersionedJsonExportV21 {
  const VersionedJsonExportV23();
  @override
  int get version => 23;
  @override
  Future<Map<String, dynamic>> export(GTDatabase db) {
    final owner = db.currentUserId;
    return db.transaction(() async {
      final json = await super.export(db);
      final rows = await db
          .customSelect(
            'SELECT * FROM water_logs WHERE user_id IS ? AND deleted=0',
            variables: [Variable(owner)],
          )
          .get();
      json['waterLogs'] = [
        for (final row in rows)
          {
            'id': row.read<String>('id'),
            ...Map<String, dynamic>.from(
              jsonDecode(row.read<String>('json_data')),
            ),
            'updated_at': row
                .readWithType<DateTime>(DriftSqlType.dateTime, 'updated_at')
                .toUtc()
                .toIso8601String(),
          },
      ];
      final goals = await db
          .customSelect(
            'SELECT id,water FROM nutrition_goals WHERE user_id IS ? AND deleted=0',
            variables: [Variable(owner)],
          )
          .get();
      final water = {
        for (final row in goals)
          row.read<String>('id'): row.readNullable<double>('water'),
      };
      for (final goal in json['nutritionGoals'] as List) {
        (goal['goal'] as Map)['dailyWater'] = water[goal['id']];
      }
      if (db.currentUserId != owner) {
        throw StateError('Account changed during export');
      }
      return json;
    });
  }
}

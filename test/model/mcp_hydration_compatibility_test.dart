import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/mcp_hydration.json').readAsStringSync())
          as Map<String, dynamic>;
  test(
    'MCP water payload survives the actual Flutter database and repository',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final json = fixture['row'] as Map<String, dynamic>;
      final row = DBWaterLog.fromJson(json);
      db.setCurrentUserId(row.userId);
      await db.into(db.waterLogs).insert(row);
      final entries = await HydrationRepository(db).watch(row.userId).first;
      final water = entries.single;
      final api = fixture['api'] as Map<String, dynamic>;
      expect(water.id, api['id']);
      expect(water.milliliters, api['milliliters']);
      expect(water.time.toUtc(), DateTime.parse(api['time'] as String));
      expect(row.referenceDate, DateTime.parse('${api['date']}T00:00:00Z'));
      expect(
        await HydrationRepository(db).watch('another-account').first,
        isEmpty,
      );
      final restored = DBWaterLog.fromJson(row.toJson());
      expect(WaterEntry.fromRow(restored).milliliters, 500.25);
    },
  );
  test(
    'MCP hydration total matches food snapshots and drinking water in the app',
    () {
      final water = WaterEntry.fromRow(
        DBWaterLog.fromJson(fixture['row'] as Map<String, dynamic>),
      );
      final food = Food.fromJson(fixture['food'] as Map<String, dynamic>);
      expect(food.nutritionalValues.water, 27);
      expect(
        water.milliliters + food.nutritionalValues.water!,
        fixture['knownTotalWaterMl'],
      );
      final unknownJson = food.toJson();
      (unknownJson['nutritionalValuesPer100g'] as Map).remove('water');
      final unknown = Food.fromJson(unknownJson);
      expect(unknown.nutritionalValues.water, isNull);
    },
  );
}

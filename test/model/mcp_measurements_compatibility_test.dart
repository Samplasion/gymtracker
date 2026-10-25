import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/data/weights.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/mcp_measurements.json').readAsStringSync())
          as Map<String, dynamic>;
  test(
    'MCP weight rows retain original units and the UTC measurement instant',
    () {
      final weight = WeightMeasurement.fromJson(
        fixture['weight'] as Map<String, dynamic>,
      );
      expect(weight.weightUnit, Weights.lb);
      expect(weight.weight, 154);
      expect(weight.time, DateTime.utc(2026, 10, 23, 22));
      expect(weight.convertedWeightTo(Weights.kg), closeTo(69.85, 0.01));
      expect(WeightMeasurement.fromJson(weight.toJson()).weight, weight.weight);
    },
  );
  test('MCP body rows retain type, value and Flutter units', () {
    final rows = (fixture['body'] as List)
        .map((r) => BodyMeasurement.fromJson(r as Map<String, dynamic>))
        .toList();
    expect(rows[0].type, BodyMeasurementPart.waist);
    expect(rows[0].type.unit, 'cm');
    expect(rows[0].value, 85);
    expect(rows[1].type.unit, '%');
    expect(rows[1].value, 15.5);
    for (final row in rows) {
      expect(BodyMeasurement.fromJson(row.toJson()).type, row.type);
    }
    final schema = File('supabase/functions/mcp/schemas.ts').readAsStringSync();
    for (final part in BodyMeasurementPart.values) {
      expect(schema, contains('"${part.name}"'));
    }
  });
}

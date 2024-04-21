import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'measurements.g.dart';

abstract class GTMeasurement {
  const GTMeasurement();

  factory GTMeasurement.fromJson(Map<String, dynamic> json) =>
      _internalFromJson(json);

  static GTMeasurement _internalFromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'weight':
        return WeightMeasurement.fromJson(json);
      default:
        throw Exception('Invalid type ${json["type"]}');
    }
  }

  Map<String, dynamic> toJson();

  String get type;
}

@CopyWith()
@JsonSerializable()
class WeightMeasurement extends GTMeasurement
    implements Insertable<WeightMeasurement> {
  @override
  final String type = "weight";

  final String id;
  final double weight;
  final DateTime time;
  final Weights weightUnit;

  double get convertedWeight => Weights.convert(
        value: weight,
        from: weightUnit,
        to: settingsController.weightUnit.value,
      );

  const WeightMeasurement({
    required this.id,
    required this.weight,
    required this.time,
    required this.weightUnit,
  });

  WeightMeasurement.generateID({
    required this.weight,
    required this.time,
    required this.weightUnit,
  }) : id = const Uuid().v4();

  factory WeightMeasurement.fromJson(Map<String, dynamic> json) =>
      _$WeightMeasurementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WeightMeasurementToJson(this);

  @override
  String toString() =>
      """WeightMeasurement($weight ${weightUnit.name}, measured at $time, ID: $id)""";

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return WeightMeasurementsCompanion(
      id: Value(id),
      weight: Value(weight),
      time: Value(time),
      weightUnit: Value(weightUnit),
    ).toColumns(nullToAbsent);
  }
}

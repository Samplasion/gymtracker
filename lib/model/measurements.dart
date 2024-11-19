import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'measurements.g.dart';

abstract class GenericMeasurement {
  String get id;
  double get value;
  DateTime get time;
}

class PredictedWeightMeasurement {
  final String type = "weight";

  final double weight;
  final DateTime time;
  final Weights weightUnit;

  const PredictedWeightMeasurement({
    required this.weight,
    required this.time,
    required this.weightUnit,
  });

  Map<String, dynamic> toJson() => throw UnimplementedError();

  @override
  String toString() =>
      """PredictedWeightMeasurement($weight ${weightUnit.name}, predicted at $time)""";
}

@CopyWith()
@JsonSerializable()
class WeightMeasurement extends PredictedWeightMeasurement
    implements Insertable<WeightMeasurement>, GenericMeasurement {
  @override
  final String id;

  @override
  double get value => weight;

  double get convertedWeight => Weights.convert(
        value: weight,
        from: weightUnit,
        to: settingsController.weightUnit.value,
      );

  const WeightMeasurement({
    required this.id,
    required super.weight,
    required super.time,
    required super.weightUnit,
  });

  WeightMeasurement.generateID({
    required super.weight,
    required super.time,
    required super.weightUnit,
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

enum BodyMeasurementPart {
  waist("cm"),
  bodyFat("%"),
  neck("cm"),
  shoulder("cm"),
  chest("cm"),
  leftBicep("cm"),
  rightBicep("cm"),
  leftForearm("cm"),
  rightForearm("cm"),
  abdomen("cm"),
  hips("cm"),
  leftThigh("cm"),
  rightThigh("cm"),
  leftCalf("cm"),
  rightCalf("cm");

  const BodyMeasurementPart(this.unit);

  final String unit;
}

class BodyMeasurement implements Insertable<BodyMeasurement>, GenericMeasurement { 
  @override
  final String id;
  @override
  final double value;
  @override
  final DateTime time;
  final BodyMeasurementPart type;

  const BodyMeasurement({
    required this.id,
    required this.value,
    required this.time,
    required this.type,
  });

  BodyMeasurement.generateID({
    required this.value,
    required this.time,
    required this.type,
  }) : id = const Uuid().v4();

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is String) {
      return BodyMeasurement(
        id: json['id'],
        value: json['value'],
        time: DateTime.parse(json['time']),
        type: BodyMeasurementPart.values.byName(type),
      );
    } else {
      throw Exception('Invalid type $type');
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'time': time.toIso8601String(),
        'type': type.name,
      };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      value: Value(value),
      time: Value(time),
      type: Value(type),
    ).toColumns(nullToAbsent);
  }

  @override
  String toString() =>
      """BodyMeasurement($value ${type.unit}, measured at $time, ID: $id)""";
}

class BodySnapshot {
  final DateTime time;
  final double weight;
  final Weights weightUnit;
  final double? waist;
  final double? bodyFat;
  final double? neck;
  final double? shoulder;
  final double? chest;
  final double? leftBicep;
  final double? rightBicep;
  final double? leftForearm;
  final double? rightForearm;
  final double? abdomen;
  final double? hips;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;

  const BodySnapshot({
    required this.time,
    required this.weight,
    required this.weightUnit,
    required this.waist,
    required this.bodyFat,
    required this.neck,
    required this.shoulder,
    required this.chest,
    required this.leftBicep,
    required this.rightBicep,
    required this.leftForearm,
    required this.rightForearm,
    required this.abdomen,
    required this.hips,
    required this.leftThigh,
    required this.rightThigh,
    required this.leftCalf,
    required this.rightCalf,
  });
}
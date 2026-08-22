import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:syncable/syncable.dart';
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
    implements Insertable<WeightMeasurement>, GenericMeasurement, Syncable {
  @override
  final String id;

  @override
  double get value => weight;

  double get convertedWeight => Weights.convert(
    value: weight,
    from: weightUnit,
    to: settingsController.weightUnit.value,
  );

  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  WeightMeasurement({
    required this.id,
    required super.weight,
    required super.time,
    required super.weightUnit,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  WeightMeasurement.generateID({
    required super.weight,
    required super.time,
    required super.weightUnit,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : id = const Uuid().v4(),
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  factory WeightMeasurement.fromJson(Map<String, dynamic> json) {
    return WeightMeasurement(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
      weightUnit: Weights.values.byName(
        json['weightUnit'] as String? ?? json['weight_unit'] as String? ?? 'kg',
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ??
            json['updated_at'] as String? ??
            DateTime.utc(2000).toIso8601String(),
      ),
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'time': time.toUtc().toIso8601String(),
    'weight_unit': weightUnit.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

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
      updatedAt: Value(updatedAt.toUtc()),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  WeightMeasurementsCompanion toCompanion() {
    return WeightMeasurementsCompanion(
      id: Value(id),
      weight: Value(weight),
      time: Value(time),
      weightUnit: Value(weightUnit),
      updatedAt: Value(updatedAt.toUtc()),
      deleted: Value(deleted),
      userId: Value(userId),
    );
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

class BodyMeasurement
    implements Insertable<BodyMeasurement>, GenericMeasurement, Syncable {
  @override
  final String id;
  @override
  final double value;
  @override
  final DateTime time;
  final BodyMeasurementPart type;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  BodyMeasurement({
    required this.id,
    required this.value,
    required this.time,
    required this.type,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  BodyMeasurement.generateID({
    required this.value,
    required this.time,
    required this.type,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : id = const Uuid().v4(),
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is String) {
      return BodyMeasurement(
        id: json['id'],
        value: json['value'] is num ? json['value'].toDouble() : json['value'],
        time: DateTime.parse(json['time']),
        type: BodyMeasurementPart.values.byName(type),
        updatedAt: DateTime.parse(
          json['updatedAt'] ??
              json['updated_at'] ??
              DateTime.utc(2000).toIso8601String(),
        ),
        deleted: json['deleted'] as bool? ?? false,
        userId: json['user_id'] as String?,
      );
    } else {
      throw Exception('Invalid type $type');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'time': time.toUtc().toIso8601String(),
    'type': type.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      value: Value(value),
      time: Value(time),
      type: Value(type),
      updatedAt: Value(updatedAt.toUtc()),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  BodyMeasurementsCompanion toCompanion() {
    return BodyMeasurementsCompanion(
      id: Value(id),
      value: Value(value),
      time: Value(time),
      type: Value(type),
      updatedAt: Value(updatedAt.toUtc()),
      deleted: Value(deleted),
      userId: Value(userId),
    );
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

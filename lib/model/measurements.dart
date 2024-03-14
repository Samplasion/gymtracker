import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'measurements.g.dart';

abstract class GTMeasurement {
  GTMeasurement();

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
class WeightMeasurement extends GTMeasurement {
  @override
  final String type = "weight";

  String id;
  double weight;
  DateTime time;
  Weights weightUnit;

  double get convertedWeight => Weights.convert(
        value: weight,
        from: weightUnit,
        to: settingsController.weightUnit.value!,
      );

  WeightMeasurement({
    String? id,
    required this.weight,
    required this.time,
    required this.weightUnit,
  }) : id = id ?? const Uuid().v4();

  factory WeightMeasurement.fromJson(Map<String, dynamic> json) =>
      _$WeightMeasurementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WeightMeasurementToJson(this);

  @override
  String toString() =>
      """WeightMeasurement($weight ${weightUnit.name}, measured at $time, ID: $id)""";
}

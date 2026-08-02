// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightMeasurementCWProxy {
  WeightMeasurement id(String id);

  WeightMeasurement weight(double weight);

  WeightMeasurement time(DateTime time);

  WeightMeasurement weightUnit(Weights weightUnit);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WeightMeasurement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WeightMeasurement(...).copyWith(id: 12, name: "My name")
  /// ```
  WeightMeasurement call({
    String id,
    double weight,
    DateTime time,
    Weights weightUnit,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWeightMeasurement.copyWith(...)` or call `instanceOfWeightMeasurement.copyWith.fieldName(value)` for a single field.
class _$WeightMeasurementCWProxyImpl implements _$WeightMeasurementCWProxy {
  const _$WeightMeasurementCWProxyImpl(this._value);

  final WeightMeasurement _value;

  @override
  WeightMeasurement id(String id) => call(id: id);

  @override
  WeightMeasurement weight(double weight) => call(weight: weight);

  @override
  WeightMeasurement time(DateTime time) => call(time: time);

  @override
  WeightMeasurement weightUnit(Weights weightUnit) =>
      call(weightUnit: weightUnit);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WeightMeasurement(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WeightMeasurement(...).copyWith(id: 12, name: "My name")
  /// ```
  WeightMeasurement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? weightUnit = const $CopyWithPlaceholder(),
  }) {
    return WeightMeasurement(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      weight: weight == const $CopyWithPlaceholder() || weight == null
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double,
      time: time == const $CopyWithPlaceholder() || time == null
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as DateTime,
      weightUnit:
          weightUnit == const $CopyWithPlaceholder() || weightUnit == null
          ? _value.weightUnit
          // ignore: cast_nullable_to_non_nullable
          : weightUnit as Weights,
    );
  }
}

extension $WeightMeasurementCopyWith on WeightMeasurement {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWeightMeasurement.copyWith(...)` or `instanceOfWeightMeasurement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightMeasurementCWProxy get copyWith =>
      _$WeightMeasurementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightMeasurement _$WeightMeasurementFromJson(Map<String, dynamic> json) =>
    WeightMeasurement(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
      weightUnit: $enumDecode(_$WeightsEnumMap, json['weightUnit']),
    );

Map<String, dynamic> _$WeightMeasurementToJson(WeightMeasurement instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'time': instance.time.toIso8601String(),
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'id': instance.id,
    };

const _$WeightsEnumMap = {Weights.kg: 'kg', Weights.lb: 'lb'};

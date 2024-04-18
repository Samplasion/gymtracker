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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightMeasurement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightMeasurement(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightMeasurement call({
    String? id,
    double? weight,
    DateTime? time,
    Weights? weightUnit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightMeasurement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightMeasurement.copyWith.fieldName(...)`
class _$WeightMeasurementCWProxyImpl implements _$WeightMeasurementCWProxy {
  const _$WeightMeasurementCWProxyImpl(this._value);

  final WeightMeasurement _value;

  @override
  WeightMeasurement id(String id) => this(id: id);

  @override
  WeightMeasurement weight(double weight) => this(weight: weight);

  @override
  WeightMeasurement time(DateTime time) => this(time: time);

  @override
  WeightMeasurement weightUnit(Weights weightUnit) =>
      this(weightUnit: weightUnit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightMeasurement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightMeasurement(...).copyWith(id: 12, name: "My name")
  /// ````
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
  /// Returns a callable class that can be used as follows: `instanceOfWeightMeasurement.copyWith(...)` or like so:`instanceOfWeightMeasurement.copyWith.fieldName(...)`.
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
      'id': instance.id,
      'weight': instance.weight,
      'time': instance.time.toIso8601String(),
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
    };

const _$WeightsEnumMap = {
  Weights.kg: 'kg',
  Weights.lb: 'lb',
};

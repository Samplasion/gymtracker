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

  WeightMeasurement updatedAt(DateTime? updatedAt);

  WeightMeasurement deleted(bool? deleted);

  WeightMeasurement userId(String? userId);

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
    DateTime? updatedAt,
    bool? deleted,
    String? userId,
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
  WeightMeasurement updatedAt(DateTime? updatedAt) =>
      call(updatedAt: updatedAt);

  @override
  WeightMeasurement deleted(bool? deleted) => call(deleted: deleted);

  @override
  WeightMeasurement userId(String? userId) => call(userId: userId);

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
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? deleted = const $CopyWithPlaceholder(),
    Object? userId = const $CopyWithPlaceholder(),
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
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      deleted: deleted == const $CopyWithPlaceholder()
          ? _value.deleted
          // ignore: cast_nullable_to_non_nullable
          : deleted as bool?,
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String?,
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
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deleted: json['deleted'] as bool?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$WeightMeasurementToJson(WeightMeasurement instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'time': instance.time.toIso8601String(),
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'id': instance.id,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deleted': instance.deleted,
      'userId': instance.userId,
    };

const _$WeightsEnumMap = {Weights.kg: 'kg', Weights.lb: 'lb'};

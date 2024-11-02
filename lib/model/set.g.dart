// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GTSetCWProxy {
  GTSet id(String? id);

  GTSet kind(GTSetKind kind);

  GTSet parameters(GTSetParameters parameters);

  GTSet reps(int? reps);

  GTSet weight(double? weight);

  GTSet time(Duration? time);

  GTSet distance(double? distance);

  GTSet done(bool done);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTSet(...).copyWith(id: 12, name: "My name")
  /// ````
  GTSet call({
    String? id,
    GTSetKind? kind,
    GTSetParameters? parameters,
    int? reps,
    double? weight,
    Duration? time,
    double? distance,
    bool? done,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTSet.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTSet.copyWith.fieldName(...)`
class _$GTSetCWProxyImpl implements _$GTSetCWProxy {
  const _$GTSetCWProxyImpl(this._value);

  final GTSet _value;

  @override
  GTSet id(String? id) => this(id: id);

  @override
  GTSet kind(GTSetKind kind) => this(kind: kind);

  @override
  GTSet parameters(GTSetParameters parameters) => this(parameters: parameters);

  @override
  GTSet reps(int? reps) => this(reps: reps);

  @override
  GTSet weight(double? weight) => this(weight: weight);

  @override
  GTSet time(Duration? time) => this(time: time);

  @override
  GTSet distance(double? distance) => this(distance: distance);

  @override
  GTSet done(bool done) => this(done: done);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTSet(...).copyWith(id: 12, name: "My name")
  /// ````
  GTSet call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
  }) {
    return GTSet(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      kind: kind == const $CopyWithPlaceholder() || kind == null
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as GTSetKind,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              ? _value.parameters
              // ignore: cast_nullable_to_non_nullable
              : parameters as GTSetParameters,
      reps: reps == const $CopyWithPlaceholder()
          ? _value.reps
          // ignore: cast_nullable_to_non_nullable
          : reps as int?,
      weight: weight == const $CopyWithPlaceholder()
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double?,
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as Duration?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      done: done == const $CopyWithPlaceholder() || done == null
          ? _value.done
          // ignore: cast_nullable_to_non_nullable
          : done as bool,
    );
  }
}

extension $GTSetCopyWith on GTSet {
  /// Returns a callable class that can be used as follows: `instanceOfGTSet.copyWith(...)` or like so:`instanceOfGTSet.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTSetCWProxy get copyWith => _$GTSetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GTSet _$GTSetFromJson(Map<String, dynamic> json) => GTSet(
      id: json['id'] as String?,
      kind: $enumDecode(_$GTSetKindEnumMap, json['kind']),
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      reps: (json['reps'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      time: json['time'] == null
          ? null
          : Duration(microseconds: (json['time'] as num).toInt()),
      distance: (json['distance'] as num?)?.toDouble(),
      done: json['done'] as bool? ?? false,
    );

Map<String, dynamic> _$GTSetToJson(GTSet instance) => <String, dynamic>{
      'id': instance.id,
      'kind': _$GTSetKindEnumMap[instance.kind]!,
      'parameters': _$GTSetParametersEnumMap[instance.parameters]!,
      'reps': instance.reps,
      'weight': instance.weight,
      'time': instance.time?.inMicroseconds,
      'distance': instance.distance,
      'done': instance.done,
    };

const _$GTSetKindEnumMap = {
  GTSetKind.warmUp: 'warmUp',
  GTSetKind.normal: 'normal',
  GTSetKind.drop: 'drop',
  GTSetKind.failure: 'failure',
  GTSetKind.failureStripping: 'failureStripping',
};

const _$GTSetParametersEnumMap = {
  GTSetParameters.repsWeight: 'repsWeight',
  GTSetParameters.timeWeight: 'timeWeight',
  GTSetParameters.freeBodyReps: 'freeBodyReps',
  GTSetParameters.time: 'time',
  GTSetParameters.distance: 'distance',
  GTSetParameters.setless: 'setless',
};

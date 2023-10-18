// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExSetCWProxy {
  ExSet id(String? id);

  ExSet kind(SetKind kind);

  ExSet parameters(SetParameters parameters);

  ExSet reps(int? reps);

  ExSet weight(double? weight);

  ExSet time(Duration? time);

  ExSet distance(double? distance);

  ExSet done(bool done);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExSet(...).copyWith(id: 12, name: "My name")
  /// ````
  ExSet call({
    String? id,
    SetKind? kind,
    SetParameters? parameters,
    int? reps,
    double? weight,
    Duration? time,
    double? distance,
    bool? done,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExSet.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExSet.copyWith.fieldName(...)`
class _$ExSetCWProxyImpl implements _$ExSetCWProxy {
  const _$ExSetCWProxyImpl(this._value);

  final ExSet _value;

  @override
  ExSet id(String? id) => this(id: id);

  @override
  ExSet kind(SetKind kind) => this(kind: kind);

  @override
  ExSet parameters(SetParameters parameters) => this(parameters: parameters);

  @override
  ExSet reps(int? reps) => this(reps: reps);

  @override
  ExSet weight(double? weight) => this(weight: weight);

  @override
  ExSet time(Duration? time) => this(time: time);

  @override
  ExSet distance(double? distance) => this(distance: distance);

  @override
  ExSet done(bool done) => this(done: done);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExSet(...).copyWith(id: 12, name: "My name")
  /// ````
  ExSet call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? done = const $CopyWithPlaceholder(),
  }) {
    return ExSet(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      kind: kind == const $CopyWithPlaceholder() || kind == null
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as SetKind,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              ? _value.parameters
              // ignore: cast_nullable_to_non_nullable
              : parameters as SetParameters,
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

extension $ExSetCopyWith on ExSet {
  /// Returns a callable class that can be used as follows: `instanceOfExSet.copyWith(...)` or like so:`instanceOfExSet.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExSetCWProxy get copyWith => _$ExSetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExSet _$ExSetFromJson(Map<String, dynamic> json) => ExSet(
      id: json['id'] as String?,
      kind: $enumDecode(_$SetKindEnumMap, json['kind']),
      parameters: $enumDecode(_$SetParametersEnumMap, json['parameters']),
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      time: json['time'] == null
          ? null
          : Duration(microseconds: json['time'] as int),
      distance: (json['distance'] as num?)?.toDouble(),
      done: json['done'] as bool? ?? false,
    );

Map<String, dynamic> _$ExSetToJson(ExSet instance) => <String, dynamic>{
      'id': instance.id,
      'kind': _$SetKindEnumMap[instance.kind]!,
      'parameters': _$SetParametersEnumMap[instance.parameters]!,
      'reps': instance.reps,
      'weight': instance.weight,
      'time': instance.time?.inMicroseconds,
      'distance': instance.distance,
      'done': instance.done,
    };

const _$SetKindEnumMap = {
  SetKind.warmUp: 'warmUp',
  SetKind.normal: 'normal',
  SetKind.drop: 'drop',
};

const _$SetParametersEnumMap = {
  SetParameters.repsWeight: 'repsWeight',
  SetParameters.timeWeight: 'timeWeight',
  SetParameters.freeBodyReps: 'freeBodyReps',
  SetParameters.time: 'time',
  SetParameters.distance: 'distance',
};

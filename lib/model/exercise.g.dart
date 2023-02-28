// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseCWProxy {
  Exercise id(String? id);

  Exercise name(String name);

  Exercise parameters(SetParameters parameters);

  Exercise sets(List<ExSet> sets);

  Exercise primaryMuscleGroup(MuscleGroup primaryMuscleGroup);

  Exercise secondaryMuscleGroups(Set<MuscleGroup> secondaryMuscleGroups);

  Exercise restTime(Duration restTime);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Exercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Exercise(...).copyWith(id: 12, name: "My name")
  /// ````
  Exercise call({
    String? id,
    String? name,
    SetParameters? parameters,
    List<ExSet>? sets,
    MuscleGroup? primaryMuscleGroup,
    Set<MuscleGroup>? secondaryMuscleGroups,
    Duration? restTime,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExercise.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExercise.copyWith.fieldName(...)`
class _$ExerciseCWProxyImpl implements _$ExerciseCWProxy {
  const _$ExerciseCWProxyImpl(this._value);

  final Exercise _value;

  @override
  Exercise id(String? id) => this(id: id);

  @override
  Exercise name(String name) => this(name: name);

  @override
  Exercise parameters(SetParameters parameters) => this(parameters: parameters);

  @override
  Exercise sets(List<ExSet> sets) => this(sets: sets);

  @override
  Exercise primaryMuscleGroup(MuscleGroup primaryMuscleGroup) =>
      this(primaryMuscleGroup: primaryMuscleGroup);

  @override
  Exercise secondaryMuscleGroups(Set<MuscleGroup> secondaryMuscleGroups) =>
      this(secondaryMuscleGroups: secondaryMuscleGroups);

  @override
  Exercise restTime(Duration restTime) => this(restTime: restTime);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Exercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Exercise(...).copyWith(id: 12, name: "My name")
  /// ````
  Exercise call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
    Object? primaryMuscleGroup = const $CopyWithPlaceholder(),
    Object? secondaryMuscleGroups = const $CopyWithPlaceholder(),
    Object? restTime = const $CopyWithPlaceholder(),
  }) {
    return Exercise(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          // ignore: unnecessary_non_null_assertion
          ? _value.name!
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              // ignore: unnecessary_non_null_assertion
              ? _value.parameters!
              // ignore: cast_nullable_to_non_nullable
              : parameters as SetParameters,
      sets: sets == const $CopyWithPlaceholder() || sets == null
          // ignore: unnecessary_non_null_assertion
          ? _value.sets!
          // ignore: cast_nullable_to_non_nullable
          : sets as List<ExSet>,
      primaryMuscleGroup: primaryMuscleGroup == const $CopyWithPlaceholder() ||
              primaryMuscleGroup == null
          // ignore: unnecessary_non_null_assertion
          ? _value.primaryMuscleGroup!
          // ignore: cast_nullable_to_non_nullable
          : primaryMuscleGroup as MuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups == const $CopyWithPlaceholder() ||
                  secondaryMuscleGroups == null
              // ignore: unnecessary_non_null_assertion
              ? _value.secondaryMuscleGroups!
              // ignore: cast_nullable_to_non_nullable
              : secondaryMuscleGroups as Set<MuscleGroup>,
      restTime: restTime == const $CopyWithPlaceholder() || restTime == null
          // ignore: unnecessary_non_null_assertion
          ? _value.restTime!
          // ignore: cast_nullable_to_non_nullable
          : restTime as Duration,
    );
  }
}

extension $ExerciseCopyWith on Exercise {
  /// Returns a callable class that can be used as follows: `instanceOfExercise.copyWith(...)` or like so:`instanceOfExercise.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseCWProxy get copyWith => _$ExerciseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String?,
      name: json['name'] as String,
      parameters: $enumDecode(_$SetParametersEnumMap, json['parameters']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => ExSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          $enumDecode(_$MuscleGroupEnumMap, json['primaryMuscleGroup']),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$MuscleGroupEnumMap, e))
              .toSet() ??
          const <MuscleGroup>{},
      restTime: Duration(microseconds: json['restTime'] as int),
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parameters': _$SetParametersEnumMap[instance.parameters]!,
      'sets': instance.sets,
      'primaryMuscleGroup': _$MuscleGroupEnumMap[instance.primaryMuscleGroup]!,
      'secondaryMuscleGroups': instance.secondaryMuscleGroups
          .map((e) => _$MuscleGroupEnumMap[e]!)
          .toList(),
      'restTime': instance.restTime.inMicroseconds,
    };

const _$SetParametersEnumMap = {
  SetParameters.repsWeight: 'repsWeight',
  SetParameters.timeWeight: 'timeWeight',
  SetParameters.freeBodyReps: 'freeBodyReps',
  SetParameters.time: 'time',
  SetParameters.distance: 'distance',
};

const _$MuscleGroupEnumMap = {
  MuscleGroup.abductors: 'abductors',
  MuscleGroup.abs: 'abs',
  MuscleGroup.adductors: 'adductors',
  MuscleGroup.calves: 'calves',
  MuscleGroup.chest: 'chest',
  MuscleGroup.biceps: 'biceps',
  MuscleGroup.forearm: 'forearm',
  MuscleGroup.glutes: 'glutes',
  MuscleGroup.hamstrings: 'hamstrings',
  MuscleGroup.lats: 'lats',
  MuscleGroup.lowerBack: 'lowerBack',
  MuscleGroup.none: 'none',
  MuscleGroup.other: 'other',
  MuscleGroup.quadriceps: 'quadriceps',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.traps: 'traps',
  MuscleGroup.triceps: 'triceps',
  MuscleGroup.upperBack: 'upperBack',
};

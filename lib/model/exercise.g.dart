// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseCWProxy {
  Exercise id(String? id);

  Exercise name(String name);

  Exercise parameters(GTSetParameters parameters);

  Exercise sets(List<GTSet> sets);

  Exercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup);

  Exercise secondaryMuscleGroups(Set<GTMuscleGroup> secondaryMuscleGroups);

  Exercise restTime(Duration restTime);

  Exercise parentID(String? parentID);

  Exercise notes(String notes);

  Exercise standard(bool standard);

  Exercise supersetID(String? supersetID);

  Exercise workoutID(String? workoutID);

  Exercise supersedesID(String? supersedesID);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Exercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Exercise(...).copyWith(id: 12, name: "My name")
  /// ````
  Exercise call({
    String? id,
    String? name,
    GTSetParameters? parameters,
    List<GTSet>? sets,
    GTMuscleGroup? primaryMuscleGroup,
    Set<GTMuscleGroup>? secondaryMuscleGroups,
    Duration? restTime,
    String? parentID,
    String? notes,
    bool? standard,
    String? supersetID,
    String? workoutID,
    String? supersedesID,
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
  Exercise parameters(GTSetParameters parameters) =>
      this(parameters: parameters);

  @override
  Exercise sets(List<GTSet> sets) => this(sets: sets);

  @override
  Exercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup) =>
      this(primaryMuscleGroup: primaryMuscleGroup);

  @override
  Exercise secondaryMuscleGroups(Set<GTMuscleGroup> secondaryMuscleGroups) =>
      this(secondaryMuscleGroups: secondaryMuscleGroups);

  @override
  Exercise restTime(Duration restTime) => this(restTime: restTime);

  @override
  Exercise parentID(String? parentID) => this(parentID: parentID);

  @override
  Exercise notes(String notes) => this(notes: notes);

  @override
  Exercise standard(bool standard) => this(standard: standard);

  @override
  Exercise supersetID(String? supersetID) => this(supersetID: supersetID);

  @override
  Exercise workoutID(String? workoutID) => this(workoutID: workoutID);

  @override
  Exercise supersedesID(String? supersedesID) =>
      this(supersedesID: supersedesID);

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
    Object? parentID = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? standard = const $CopyWithPlaceholder(),
    Object? supersetID = const $CopyWithPlaceholder(),
    Object? workoutID = const $CopyWithPlaceholder(),
    Object? supersedesID = const $CopyWithPlaceholder(),
  }) {
    return Exercise.raw(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              ? _value.parameters
              // ignore: cast_nullable_to_non_nullable
              : parameters as GTSetParameters,
      sets: sets == const $CopyWithPlaceholder() || sets == null
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<GTSet>,
      primaryMuscleGroup: primaryMuscleGroup == const $CopyWithPlaceholder() ||
              primaryMuscleGroup == null
          ? _value.primaryMuscleGroup
          // ignore: cast_nullable_to_non_nullable
          : primaryMuscleGroup as GTMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups == const $CopyWithPlaceholder() ||
                  secondaryMuscleGroups == null
              ? _value.secondaryMuscleGroups
              // ignore: cast_nullable_to_non_nullable
              : secondaryMuscleGroups as Set<GTMuscleGroup>,
      restTime: restTime == const $CopyWithPlaceholder() || restTime == null
          ? _value.restTime
          // ignore: cast_nullable_to_non_nullable
          : restTime as Duration,
      parentID: parentID == const $CopyWithPlaceholder()
          ? _value.parentID
          // ignore: cast_nullable_to_non_nullable
          : parentID as String?,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
      standard: standard == const $CopyWithPlaceholder() || standard == null
          ? _value.standard
          // ignore: cast_nullable_to_non_nullable
          : standard as bool,
      supersetID: supersetID == const $CopyWithPlaceholder()
          ? _value.supersetID
          // ignore: cast_nullable_to_non_nullable
          : supersetID as String?,
      workoutID: workoutID == const $CopyWithPlaceholder()
          ? _value.workoutID
          // ignore: cast_nullable_to_non_nullable
          : workoutID as String?,
      supersedesID: supersedesID == const $CopyWithPlaceholder()
          ? _value.supersedesID
          // ignore: cast_nullable_to_non_nullable
          : supersedesID as String?,
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

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise.raw(
      id: json['id'] as String?,
      name: json['name'] as String,
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => GTSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          $enumDecode(_$GTMuscleGroupEnumMap, json['primaryMuscleGroup']),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GTMuscleGroupEnumMap, e))
              .toSet() ??
          const <GTMuscleGroup>{},
      restTime: Duration(microseconds: json['restTime'] as int),
      parentID: json['parentID'] as String?,
      notes: json['notes'] as String? ?? '',
      standard: json['standard'] as bool? ?? false,
      supersetID: json['supersetID'] as String?,
      workoutID: json['workoutID'] as String?,
      supersedesID: json['supersedesID'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parameters': _$GTSetParametersEnumMap[instance.parameters]!,
      'sets': instance.sets,
      'primaryMuscleGroup':
          _$GTMuscleGroupEnumMap[instance.primaryMuscleGroup]!,
      'secondaryMuscleGroups': instance.secondaryMuscleGroups
          .map((e) => _$GTMuscleGroupEnumMap[e]!)
          .toList(),
      'restTime': instance.restTime.inMicroseconds,
      'parentID': instance.parentID,
      'notes': instance.notes,
      'supersetID': instance.supersetID,
      'workoutID': instance.workoutID,
      'standard': instance.standard,
      'supersedesID': instance.supersedesID,
    };

const _$GTSetParametersEnumMap = {
  GTSetParameters.repsWeight: 'repsWeight',
  GTSetParameters.timeWeight: 'timeWeight',
  GTSetParameters.freeBodyReps: 'freeBodyReps',
  GTSetParameters.time: 'time',
  GTSetParameters.distance: 'distance',
};

const _$GTMuscleGroupEnumMap = {
  GTMuscleGroup.abductors: 'abductors',
  GTMuscleGroup.abs: 'abs',
  GTMuscleGroup.adductors: 'adductors',
  GTMuscleGroup.biceps: 'biceps',
  GTMuscleGroup.calves: 'calves',
  GTMuscleGroup.chest: 'chest',
  GTMuscleGroup.forearm: 'forearm',
  GTMuscleGroup.glutes: 'glutes',
  GTMuscleGroup.hamstrings: 'hamstrings',
  GTMuscleGroup.lats: 'lats',
  GTMuscleGroup.lowerBack: 'lowerBack',
  GTMuscleGroup.none: 'none',
  GTMuscleGroup.other: 'other',
  GTMuscleGroup.quadriceps: 'quadriceps',
  GTMuscleGroup.shoulders: 'shoulders',
  GTMuscleGroup.traps: 'traps',
  GTMuscleGroup.triceps: 'triceps',
  GTMuscleGroup.upperBack: 'upperBack',
  GTMuscleGroup.thighs: 'thighs',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OldModelWorkout _$OldModelWorkoutFromJson(Map<String, dynamic> json) =>
    _OldModelWorkout(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) =>
              _OldModelWorkoutExercisable.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      startingDate: json['startingDate'] == null
          ? null
          : DateTime.parse(json['startingDate'] as String),
      parentID: json['parentID'] as String?,
      infobox: json['infobox'] as String?,
      completedBy: json['completedBy'] as String?,
      completes: json['completes'] as String?,
      weightUnit: $enumDecode(_$WeightsEnumMap, json['weightUnit']),
      distanceUnit: $enumDecode(_$DistanceEnumMap, json['distanceUnit']),
    );

Map<String, dynamic> _$OldModelWorkoutToJson(_OldModelWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'exercises': instance.exercises,
      'duration': instance.duration?.inMicroseconds,
      'startingDate': instance.startingDate?.toIso8601String(),
      'infobox': instance.infobox,
      'parentID': instance.parentID,
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'distanceUnit': _$DistanceEnumMap[instance.distanceUnit]!,
      'completedBy': instance.completedBy,
      'completes': instance.completes,
    };

const _$WeightsEnumMap = {
  Weights.kg: 'kg',
  Weights.lb: 'lb',
};

const _$DistanceEnumMap = {
  Distance.km: 'km',
  Distance.mi: 'mi',
};

_OldModelSet _$OldModelSetFromJson(Map<String, dynamic> json) => _OldModelSet(
      id: json['id'] as String,
      kind: $enumDecode(_$GTSetKindEnumMap, json['kind']),
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      time: json['time'] == null
          ? null
          : Duration(microseconds: json['time'] as int),
      distance: (json['distance'] as num?)?.toDouble(),
      done: json['done'] as bool,
    );

Map<String, dynamic> _$OldModelSetToJson(_OldModelSet instance) =>
    <String, dynamic>{
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
};

_OldModelExercise _$OldModelExerciseFromJson(Map<String, dynamic> json) =>
    _OldModelExercise(
      id: json['id'] as String,
      name: json['name'] as String,
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => _OldModelSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          $enumDecode(_$GTMuscleGroupEnumMap, json['primaryMuscleGroup']),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>)
          .map((e) => $enumDecode(_$GTMuscleGroupEnumMap, e))
          .toSet(),
      restTime: Duration(microseconds: json['restTime'] as int),
      parentID: json['parentID'] as String?,
      notes: json['notes'] as String? ?? '',
      standard: json['standard'] as bool? ?? false,
    );

Map<String, dynamic> _$OldModelExerciseToJson(_OldModelExercise instance) =>
    <String, dynamic>{
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
      'standard': instance.standard,
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
};

_OldModelSuperset _$OldModelSupersetFromJson(Map<String, dynamic> json) =>
    _OldModelSuperset(
      id: json['id'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => _OldModelExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: Duration(microseconds: json['restTime'] as int),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$OldModelSupersetToJson(_OldModelSuperset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercises': instance.exercises,
      'restTime': instance.restTime.inMicroseconds,
      'notes': instance.notes,
    };

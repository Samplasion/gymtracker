import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'v1.g.dart';

class VersionedJsonImportV1 extends VersionedJsonImportBase {
  @override
  int get version => 1;

  const VersionedJsonImportV1();

  @override
  DatabaseSnapshot process(Map<String, dynamic> json) {
    List<_OldModelExercise> oldModelCustomExercises = [];
    if (json['exercise'] is List) {
      oldModelCustomExercises = [
        for (final json in json['exercise']) _OldModelExercise.fromJson(json),
      ];
    }

    List<_OldModelWorkout> oldModelRoutines = [];
    if (json['routines'] is List) {
      oldModelRoutines = [
        for (final json in json['routines']) _OldModelWorkout.fromJson(json),
      ];
    }

    List<_OldModelWorkout> oldModelHistory = [];
    if (json['workouts'] is List) {
      oldModelHistory = [
        for (final json in json['workouts']) _OldModelWorkout.fromJson(json),
      ];
    }

    final Map<String, int> oldModelExerciseIDs = {
      for (int i = 1; i <= oldModelCustomExercises.length; i++)
        oldModelCustomExercises[i - 1].id: i,
    };

    final Map<String, int> oldModelRoutineIDs = {
      for (int i = 1; i <= oldModelRoutines.length; i++)
        oldModelRoutines[i - 1].id: i,
    };

    final Map<String, int> oldModelHistoryIDs = {
      for (int i = 1; i <= oldModelHistory.length; i++)
        oldModelHistory[i - 1].id: i,
    };

    // New models
    final newModelExercises = [
      for (final omex in oldModelCustomExercises)
        GTLibraryExercise(
          id: oldModelExerciseIDs[omex.id]!,
          name: omex.name,
          parameters: omex.parameters,
          primaryMuscleGroup: omex.primaryMuscleGroup,
          secondaryMuscleGroups: omex.secondaryMuscleGroups,
        ),
    ];

    final newModelRoutines = <GTRoutine>[];
    int _exIDCounter = 1;
    for (int i = 0; i < oldModelRoutines.length; i++) {
      final omr = oldModelRoutines[i];
      int exerciseSortOrder = 0;
      newModelRoutines.add(
        GTRoutine(
          id: oldModelRoutineIDs[omr.id]!,
          name: omr.name,
          notes: omr.infobox ?? "",
          weightUnit: omr.weightUnit,
          distanceUnit: omr.distanceUnit,
          exercises: [
            for (final ex in omr.exercises)
              ex.map(
                exercise: (omex) {
                  return _oldToNewRoutineExercise(
                    omr,
                    omex,
                    _exIDCounter++,
                    oldModelRoutineIDs: oldModelRoutineIDs,
                    oldModelExerciseIDs: oldModelExerciseIDs,
                    oldModelExercises: oldModelCustomExercises,
                    isInSuperset: false,
                    supersetID: null,
                    sortOrder: exerciseSortOrder++,
                  );
                },
                superset: (omss) {
                  final ssID = _exIDCounter++;
                  int ssExerciseSortOrder = 0;
                  return GTSuperset(
                    id: ssID,
                    parentID: oldModelRoutineIDs[omr.id]!,
                    name: "",
                    restTime: omss.restTime,
                    notes: omss.notes,
                    sortOrder: exerciseSortOrder++,
                    exercises: [
                      for (final ex in omss.exercises)
                        ex.map(
                          exercise: (omex) {
                            return _oldToNewRoutineExercise(
                              omr,
                              omex,
                              _exIDCounter++,
                              oldModelRoutineIDs: oldModelRoutineIDs,
                              oldModelExerciseIDs: oldModelExerciseIDs,
                              oldModelExercises: oldModelCustomExercises,
                              isInSuperset: true,
                              supersetID: ssID,
                              sortOrder: ssExerciseSortOrder++,
                            );
                          },
                          superset: (omss) {
                            throw Exception(
                                "Supersets in supersets not supported");
                          },
                        ),
                    ],
                  );
                },
              ),
          ],
          sortOrder: i,
        ),
      );
    }

    final newModelHistory = <GTHistoryWorkout>[];
    int _hexIDCounter = 1;
    for (int i = 0; i < oldModelHistory.length; i++) {
      final omr = oldModelHistory[i];
      int exerciseSortOrder = 0;
      newModelHistory.add(
        GTHistoryWorkout(
          id: oldModelHistoryIDs[omr.id]!,
          name: omr.name,
          notes: omr.infobox ?? "",
          weightUnit: omr.weightUnit,
          distanceUnit: omr.distanceUnit,
          exercises: [
            for (final ex in omr.exercises)
              ex.map(
                exercise: (omex) {
                  return _oldToNewRoutineExercise(
                    omr,
                    omex,
                    _hexIDCounter++,
                    oldModelRoutineIDs: oldModelHistoryIDs,
                    oldModelExerciseIDs: oldModelExerciseIDs,
                    oldModelExercises: oldModelCustomExercises,
                    isInSuperset: false,
                    supersetID: null,
                    sortOrder: exerciseSortOrder++,
                  );
                },
                superset: (omss) {
                  final ssID = _hexIDCounter++;
                  int ssExerciseSortOrder = 0;
                  return GTSuperset(
                    id: ssID,
                    parentID: oldModelHistoryIDs[omr.id]!,
                    name: "",
                    restTime: omss.restTime,
                    notes: omss.notes,
                    sortOrder: exerciseSortOrder++,
                    exercises: [
                      for (final ex in omss.exercises)
                        ex.map(
                          exercise: (omex) {
                            return _oldToNewRoutineExercise(
                              omr,
                              omex,
                              _hexIDCounter++,
                              oldModelRoutineIDs: oldModelHistoryIDs,
                              oldModelExerciseIDs: oldModelExerciseIDs,
                              oldModelExercises: oldModelCustomExercises,
                              isInSuperset: true,
                              supersetID: ssID,
                              sortOrder: ssExerciseSortOrder++,
                            );
                          },
                          superset: (omss) {
                            throw Exception(
                                "Supersets in supersets not supported");
                          },
                        ),
                    ],
                  );
                },
              ),
          ],
          startingDate: omr.startingDate!,
          duration: omr.duration!,
          parentID: oldModelHistoryIDs[omr.parentID],
          completedByID: omr.completedBy == null
              ? null
              : oldModelHistoryIDs[omr.completedBy!]!,
          completesID: omr.completes == null
              ? null
              : oldModelHistoryIDs[omr.completes!]!,
          sortOrder: i,
        ),
      );
    }

    return DatabaseSnapshot(
      customExercises: newModelExercises,
      routines: newModelRoutines,
      routineExercises: _flat([
        for (final routine in newModelRoutines)
          ...routine.exercises.map(
            (e) => e.map(
                exercise: (ex) => [ex],
                superset: (ss) => [ss, ...ss.exercises]),
          ),
      ]),
      historyWorkouts: newModelHistory,
      historyWorkoutExercises: _flat([
        for (final routine in newModelHistory)
          ...routine.exercises.map(
            (e) => e.map(
                exercise: (ex) => [ex],
                superset: (ss) => [ss, ...ss.exercises]),
          ),
      ]),
    );
  }

  List<T> _flat<T>(List<List<T>> deep) {
    final res = <T>[];
    for (final el in deep) {
      res.addAll(el);
    }
    return res;
  }

  GTExercise _oldToNewRoutineExercise(
    _OldModelWorkout omr,
    _OldModelExercise omex,
    int exIDCounter, {
    required Map<String, int> oldModelRoutineIDs,
    required Map<String, int> oldModelExerciseIDs,
    required List<_OldModelExercise> oldModelExercises,
    required bool isInSuperset,
    required int? supersetID,
    required int sortOrder,
  }) {
    // logger.d("${omr.id} => ${oldModelRoutineIDs[omr.id]}");
    return GTExercise(
      id: exIDCounter,
      parentID: oldModelRoutineIDs[omr.id]!,
      name: omex.name,
      parameters: omex.parameters,
      sets: [
        for (final set in omex.sets)
          GTSet(
            reps: set.reps,
            weight: set.weight,
            distance: set.distance,
            time: set.time,
            kind: set.kind,
            parameters: set.parameters,
            done: set.done,
          ),
      ],
      primaryMuscleGroup: omex.primaryMuscleGroup,
      secondaryMuscleGroups: omex.secondaryMuscleGroups,
      restTime: omex.restTime,
      libraryExerciseID: omex.isCustom ? null : omex.parentID,
      customExerciseID: (omex.isCustom
          ? (oldModelExerciseIDs[omex.parentID] ??
              oldModelExerciseIDs[oldModelExercises
                  .firstWhere((element) => element.name == omex.name)
                  .id])
          : null),
      isCustom: omex.isCustom,
      notes: omex.notes,
      inSuperset: isInSuperset,
      supersetID: supersetID,
      sortOrder: sortOrder,
    );
  }
}

// Database version 1 models

@JsonSerializable()
class _OldModelWorkout {
  String id;
  final String name;
  final List<_OldModelWorkoutExercisable> exercises;
  final Duration? duration;
  final DateTime? startingDate;
  final String? infobox;
  String? parentID;
  Weights weightUnit;
  Distance distanceUnit;
  bool get isConcrete => duration != null;
  String? completedBy;
  String? completes;

  _OldModelWorkout({
    required this.id,
    required this.name,
    required this.exercises,
    required this.duration,
    required this.startingDate,
    required this.parentID,
    required this.infobox,
    required this.completedBy,
    required this.completes,
    required this.weightUnit,
    required this.distanceUnit,
  }) : assert(() {
          if (completedBy == null && completes == null) return true;
          return (completedBy == null) != (completes == null);
        }(),
            "Both completedBy and completes cannot be defined at the same time.");

  factory _OldModelWorkout.fromJson(Map<String, dynamic> json) =>
      _$OldModelWorkoutFromJson(json);

  Map<String, dynamic> toJson() => {
        ..._$OldModelWorkoutToJson(this),
        'exercises': [for (final exercise in exercises) exercise.toJson()],
      };
}

abstract class _OldModelWorkoutExercisable {
  _OldModelWorkoutExercisable();

  factory _OldModelWorkoutExercisable.fromJson(Map<String, dynamic> json) =>
      _internalFromJson(json);

  static _OldModelWorkoutExercisable _internalFromJson(
      Map<String, dynamic> json) {
    switch (json['type']) {
      case 'exercise':
      case null:
        return _OldModelExercise.fromJson(json);
      case 'superset':
        return _OldModelSuperset.fromJson(json);
      default:
        throw Exception('Invalid type ${json["type"]}');
    }
  }

  Map<String, dynamic> toJson();

  String get id;
  Duration get restTime;
  String get notes;

  T map<T>({
    required T Function(_OldModelExercise) exercise,
    required T Function(_OldModelSuperset) superset,
  }) {
    if (this is _OldModelExercise) {
      return exercise(this as _OldModelExercise);
    } else if (this is _OldModelSuperset) {
      return superset(this as _OldModelSuperset);
    }
    throw TypeError();
  }
}

@JsonSerializable()
class _OldModelSet {
  String id;
  GTSetKind kind;
  final GTSetParameters parameters;

  int? reps;
  double? weight;
  Duration? time;
  double? distance;
  bool done;

  _OldModelSet({
    required this.id,
    required this.kind,
    required this.parameters,
    required this.reps,
    required this.weight,
    required this.time,
    required this.distance,
    required this.done,
  }) : assert(_validateParameters(
          parameters: parameters,
          reps: reps,
          weight: weight,
          time: time,
          distance: distance,
        ));

  static bool _validateParameters({
    required GTSetParameters parameters,
    required int? reps,
    required double? weight,
    required Duration? time,
    required double? distance,
  }) {
    switch (parameters) {
      case GTSetParameters.repsWeight:
        return reps != null && weight != null;
      case GTSetParameters.timeWeight:
        return time != null && weight != null;
      case GTSetParameters.freeBodyReps:
        return reps != null;
      case GTSetParameters.time:
        return time != null;
      case GTSetParameters.distance:
        return distance != null;
    }
  }

  factory _OldModelSet.fromJson(Map<String, dynamic> json) =>
      _$OldModelSetFromJson(json);

  Map<String, dynamic> toJson() => _$OldModelSetToJson(this);
}

@JsonSerializable()
class _OldModelExercise extends _OldModelWorkoutExercisable {
  @override
  String id;
  final String name;
  final GTSetParameters parameters;
  final List<_OldModelSet> sets;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  @override
  Duration restTime;

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  String? parentID;

  @JsonKey(defaultValue: "")
  @override
  String notes;

  @JsonKey(defaultValue: false)
  final bool standard;

  bool get isCustom => !standard;

  _OldModelExercise({
    required this.id,
    required this.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.restTime,
    required this.parentID,
    required this.notes,
    required this.standard,
  })  : assert(sets.isEmpty || parameters == sets[0].parameters,
            "The parameters must not change between the Exercise and its Sets"),
        assert(
            sets.isEmpty || sets.map((e) => e.parameters).toSet().length == 1,
            "The sets must have the same parameters.");

  factory _OldModelExercise.fromJson(Map<String, dynamic> json) =>
      _$OldModelExerciseFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$OldModelExerciseToJson(this),
        'sets': [for (final set in sets) set.toJson()],
        'type': 'exercise',
      };
}

@JsonSerializable()
class _OldModelSuperset extends _OldModelWorkoutExercisable {
  @override
  String id;
  final List<_OldModelExercise> exercises;
  @override
  Duration restTime;

  @JsonKey(defaultValue: "")
  @override
  String notes;

  _OldModelSuperset({
    required this.id,
    required this.exercises,
    required this.restTime,
    required this.notes,
  });

  factory _OldModelSuperset.fromJson(Map<String, dynamic> json) =>
      _$OldModelSupersetFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$OldModelSupersetToJson(this),
        'exercises': [for (final exercise in exercises) exercise.toJson()],
        'type': 'superset',
      };
}

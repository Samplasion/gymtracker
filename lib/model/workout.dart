import 'dart:math';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart' hide min, max;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'workout.g.dart';

class GTRoutineFolder {
  final String id;
  final String name;
  final int sortOrder;

  const GTRoutineFolder({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  GTRoutineFolder.generate({
    required this.name,
  })  : id = const Uuid().v4(), // Is overridden by the database
        sortOrder = 9999999;

  factory GTRoutineFolder.fromJson(Map<String, dynamic> json) {
    return GTRoutineFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return 'GTRoutineFolder[$name] ${toJson()}';
  }

  GTRoutineFolder copyWith({
    String? id,
    String? name,
    int? sortOrder,
  }) {
    return GTRoutineFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GTRoutineFolder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sortOrder.hashCode;
}

@CopyWith()
@JsonSerializable()

/// Represents a workout, that is, a named sequence of exercises.
///
/// A workout can be concrete. A concrete workout represent the
/// actual exercises that have been done in a set time, stored in
/// [duration]. If the [duration] is null, then the workout is
/// not concrete and represents a routine.
class Workout {
  final String id;
  final String name;
  final List<WorkoutExercisable> exercises;
  final Duration? duration;
  final DateTime? startingDate;
  final String? infobox;

  bool get shouldShowInfobox => shouldShowAsInfobox(infobox);

  static bool shouldShowAsInfobox(String? candidate) =>
      candidate != null && !candidate.asQuillDocument().isEmpty();

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  final String? parentID;

  /// The unit of weight used in this workout.
  final Weights weightUnit;

  /// The unit of distance used in this workout.
  final Distance distanceUnit;

  /// Whether this is a concrete workout.
  bool get isConcrete => duration != null;

  /// Whether this workout is complete (or a routine)
  bool get isComplete => !isConcrete || allSets.every((set) => set.done);

  /// Whether this workout can be continued by another
  bool get isContinuable =>
      !isComplete && completedBy == null && completes == null;

  /// Whether this workout completes another
  bool get isContinuation => completes != null;

  /// If this workout is not complete, and a workout completing this exists,
  /// the ID referencing the [Workout] that completes [this].
  ///
  /// {@template gymtracker_workout_completion}
  /// A workout can be complete, that is, every set in the workout has been done.
  /// If that's not the case, [isComplete] is false, and the user has the option
  /// to continue it with another concrete workout, with only the sets that they
  /// haven't done. When that happens, the new workout gets a field [completes]
  /// that is bound to this workout's [id], and this workout gets a field
  /// [completedBy] that is bound to the new workout's [id].
  ///
  /// It is an error to define both [completedBy] and [completes].
  /// {@endtemplate}
  final String? completedBy;

  /// {@macro gymtracker_workout_completion}
  final String? completes;

  /// The folder this workout is in.
  /// If null, the workout is not in a folder.
  ///
  /// It is an error to define [folder] if [isConcrete] is true (ie. [duration] is not null).
  final GTRoutineFolder? folder;

  DateTime? get endingDate => (duration != null && startingDate != null)
      ? startingDate!.add(duration!)
      : null;

  List<GTSet> get allSets => [for (final ex in exercises) ...ex.sets];
  List<GTSet> get doneSets => [
        for (final set in allSets)
          if (set.done) set
      ];

  double get progress => allSets.isEmpty
      ? 0
      : allSets.where((set) => set.done).length / allSets.length;
  int get reps =>
      doneSets.fold(0, (value, element) => value + (element.reps ?? 0));
  double get liftedWeight => doneSets.fold(0.0,
      (value, element) => value + (element.weight ?? 0) * (element.reps ?? 1));
  double get distanceRun =>
      doneSets.fold(0.0, (value, element) => value + (element.distance ?? 0));

  int get displayExerciseCount => exercises
      .map((e) => e is Superset ? e.exercises.length : 1)
      .fold(0, (a, b) => a + b);

  bool get isSupersedence =>
      completes != null && exercises.any((element) => element.isSupersedence);

  double get exertion => (doneSets.fold(
          0.0,
          (a, b) =>
              a +
              Weights.convert(
                value: b.weight?.toDouble() ?? 0,
                from: weightUnit,
                to: Weights.kg,
              )) /
      max(1, duration!.inMinutes));

  Workout({
    String? id,
    required this.name,
    required this.exercises,
    this.duration,
    this.startingDate,
    this.parentID,
    this.infobox,
    this.completedBy,
    this.completes,
    this.weightUnit = Weights.kg,
    this.distanceUnit = Distance.km,
    this.folder,
  })  : id = id ?? const Uuid().v4(),
        assert(() {
          if (completedBy == null && completes == null) return true;
          return (completedBy == null) != (completes == null);
        }(),
            "Both completedBy and completes cannot be defined at the same time."),
        assert(() {
          if (folder != null) return duration == null;
          return true;
        }(), "A concrete workout cannot be in a folder.");

  static bool canCombine(Workout workout1, Workout workout2) {
    return workout1.isConcrete == workout2.isConcrete && !workout1.isConcrete ||
        (workout1.completedBy == workout2.id &&
            workout2.completes == workout1.id &&
            workout1.startingDate!.isBefore(workout2.startingDate!));
  }

  static Workout combine(Workout workout1, Workout workout2) {
    assert(workout1.isConcrete == workout2.isConcrete,
        "Both workouts must be concrete or not concrete.");
    if (workout1.isConcrete) {
      assert(
          workout1.completedBy == workout2.id &&
              workout2.completes == workout1.id &&
              workout1.completedBy != null &&
              workout2.completes != null,
          "Workout 1 must be completed by workout 2.");
      assert(workout1.startingDate!.isBefore(workout2.startingDate!),
          "Workout 1 must start before workout 2.");
    }

    // NOTE: We don't care about IDs in this method since they get fixed
    // just before the data is saved to the database.

    var exercises = getExercisesLinearly(
      workout1,
      workout2,
      overrideSupersedencesWithNull: true,
    );

    final result = Workout(
      name: workout1.name,
      exercises: exercises,
      duration: (workout1.duration ?? Duration.zero) +
          (workout2.duration ?? Duration.zero),
      startingDate: workout1.startingDate,
      weightUnit: workout1.weightUnit,
      distanceUnit: workout1.distanceUnit,
      parentID:
          workout1.parentID == workout2.parentID ? workout1.parentID : null,
      infobox: workout1.infobox?.richCombine(workout2.infobox ?? "") ??
          workout2.infobox,
    );

    assert(result.id != workout1.id && result.id != workout2.id);

    return result;
  }

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => {
        ..._$WorkoutToJson(this),
        'exercises': [for (final exercise in exercises) exercise.toJson()],
        'folder': folder?.toJson(),
      };

  Map<String, dynamic> shareWorkout() => {
        ...toJson(),
        'folder': null,
      };

  @override
  String toString() {
    return 'Workout[$name] ${toJson()}';
  }

  Workout clone() => Workout.fromJson(toJson());

  /// Returns a version of this workout that is a routine.
  ///
  /// If [routineID] is not provided, a new ID is generated. Otherwise, the
  /// provided ID is used.
  Workout toRoutine({
    String? routineID,
  }) {
    final newRoutineID = routineID ?? const Uuid().v4();
    return copyWith(
      duration: null,
      startingDate: null,
      id: newRoutineID,
      exercises: [
        for (final exercise in exercises)
          exercise.map(
            superset: (superset) {
              final newSupersetID = const Uuid().v4();
              return superset.copyWith(
                id: newSupersetID,
                workoutID: newRoutineID,
                exercises: [
                  for (final exercise in superset.exercises)
                    exercise.copyWith(
                      id: const Uuid().v4(),
                      workoutID: newRoutineID,
                      supersetID: newSupersetID,
                      supersedesID: null,
                      sets: [
                        for (final set in exercise.sets)
                          set.copyWith(done: false),
                      ],
                    ),
                ],
              );
            },
            exercise: (single) => single.copyWith(
              id: const Uuid().v4(),
              supersedesID: null,
              sets: [
                for (final set in single.sets)
                  set.copyWith(
                    id: const Uuid().v4(),
                    done: false,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Workout regenerateID() => copyWith(id: const Uuid().v4());

  Workout withFilters({
    bool Function(WorkoutExercisable)? exerciseFilter,
    bool Function(WorkoutExercisable, GTSet)? setFilter,
  }) {
    return copyWith(
      exercises: [
        for (final exercise in exercises)
          if (exerciseFilter?.call(exercise) ?? true)
            exercise.map(
              superset: (superset) => superset.copyWith(
                exercises: [
                  for (final exercise in superset.exercises)
                    if (exerciseFilter?.call(exercise) ?? true)
                      exercise.copyWith(
                        sets: [
                          for (final set in exercise.sets)
                            if (setFilter?.call(exercise, set) ?? true) set,
                        ],
                      ),
                ],
              ),
              exercise: (single) => single.copyWith(
                sets: [
                  for (final set in single.sets)
                    if (setFilter?.call(single, set) ?? true) set,
                ],
              ),
            ),
      ],
    );
  }

  Workout withRegeneratedExerciseIDs({required bool superseding}) {
    final newExercises = <WorkoutExercisable>[];
    for (final exercise in exercises) {
      newExercises.add(exercise.map(
        superset: (superset) {
          final newSupersetID = const Uuid().v4();
          return superset.copyWith(
            exercises: [
              for (final exercise in superset.exercises)
                exercise.copyWith(
                  id: const Uuid().v4(),
                  supersetID: newSupersetID,
                  supersedesID: superseding ? exercise.id : null,
                ),
            ],
            id: newSupersetID,
            supersedesID: superseding ? superset.id : null,
          );
        },
        exercise: (single) => single.copyWith(
          id: const Uuid().v4(),
          supersedesID: superseding ? single.id : null,
        ),
      ));
    }
    return copyWith(exercises: newExercises);
  }

  bool isCompletionOf(Workout base) {
    return base.completedBy != null &&
        completes != null &&
        base.completedBy == id &&
        completes == base.id;
  }

  bool hasExercise(Exercise exercise) {
    if (exercise.parentID == null) {
      return exercises.where((e) => e.isExercise).any((e) {
        return e.asExercise.parentID == exercise.id;
      });
    } else {
      final parent = exercise.getParent();
      if (parent == null) {
        return false;
      }
      return hasExercise(parent);
    }
  }

  bool isChildOf(Workout workout) {
    return workout.id == parentID;
  }

  static bool deepEquality(Workout a, Workout b) {
    return a.id == b.id &&
        a.name == b.name &&
        a.exercises.length == b.exercises.length &&
        [
          for (int i = 0; i < a.exercises.length; i++)
            WorkoutExercisable.deepEquality(a.exercises[i], b.exercises[i])
        ].every((element) => element) &&
        a.duration == b.duration &&
        a.startingDate == b.startingDate &&
        a.infobox == b.infobox &&
        a.parentID == b.parentID &&
        a.weightUnit == b.weightUnit &&
        a.distanceUnit == b.distanceUnit &&
        a.completedBy == b.completedBy &&
        a.completes == b.completes &&
        a.folder == b.folder;
  }
}

class SynthesizedWorkoutMethodException implements Exception {
  final String method;

  SynthesizedWorkoutMethodException(this.method);

  @override
  String toString() {
    return "Cannot call method `$method` on a synthesized workout.";
  }
}

class SynthesizedWorkout implements Workout {
  final List<Workout> components;

  SynthesizedWorkout(this.components)
      : assert(components.isNotEmpty),
        assert(components.every((wo) => wo is! SynthesizedWorkout),
            "Cannot nest synthesized workouts"),
        assert(
            components.every((e) => e.isConcrete) ||
                components.every((e) => !e.isConcrete),
            "All components must be either routines or concrete");

  @override
  String? get completedBy => null;

  @override
  String? get completes => null;

  @override
  Distance get distanceUnit => components.first.distanceUnit;

  @override
  String get id => components.first.id;

  @override
  String? get parentID => components.first.parentID;

  @override
  Weights get weightUnit => components.first.weightUnit;

  @override
  List<GTSet> get allSets => exercises.expand((e) => e.sets).toList();

  @override
  Workout clone() {
    throw SynthesizedWorkoutMethodException("clone");
  }

  @override
  int get displayExerciseCount =>
      components.fold(0, (a, b) => a + b.displayExerciseCount);

  @override
  double get distanceRun => components.fold(0.0, (a, b) => a + b.distanceRun);

  @override
  List<GTSet> get doneSets => allSets.where((s) => s.done).toList();

  @override
  Duration get duration => components.fold(
      Duration.zero, (a, b) => a + (b.duration ?? Duration.zero));

  @override
  DateTime get endingDate => startingDate!.add(duration);

  @override
  List<WorkoutExercisable> get exercises {
    // If we have two components, account for the possibility that the second
    // workout completes the first.
    if (components.length == 2) {
      return getExercisesLinearly(
        components.first,
        components.last,
      );
    }
    return components
        .expand((w) => [
              for (final e in w.exercises)
                e.changeUnits(
                  fromWeightUnit: w.weightUnit,
                  toWeightUnit: weightUnit,
                  fromDistanceUnit: w.distanceUnit,
                  toDistanceUnit: distanceUnit,
                )
            ])
        .toList();
  }

  @override
  double get exertion =>
      components.fold(0.0, (a, b) => a + b.exertion) / components.length;

  @override
  GTRoutineFolder? get folder => null;

  @override
  String? get infobox => components.first.infobox;

  @override
  bool isChildOf(Workout workout) {
    return workout.id == parentID;
  }

  @override
  bool get isComplete => components.every((e) => e.isComplete);

  @override
  bool isCompletionOf(Workout base) => false;

  @override
  bool get isConcrete => components.first.isConcrete;

  @override
  bool get isContinuable => false;

  @override
  bool get isContinuation => false;

  @override
  bool get isSupersedence => false;

  @override
  double get liftedWeight => components.fold(
      0.0,
      (a, b) =>
          a +
          Weights.convert(
            value: b.liftedWeight,
            from: b.weightUnit,
            to: weightUnit,
          ));

  @override
  String get name => components.first.name;

  @override
  double get progress =>
      // Average progress
      components.fold(0.0, (a, b) => a + b.progress) / components.length;

  @override
  Workout regenerateID() {
    throw SynthesizedWorkoutMethodException("regenerateID");
  }

  @override
  int get reps => components.fold(0, (a, b) => a + b.reps);

  @override
  bool get shouldShowInfobox => components.first.shouldShowInfobox;

  @override
  DateTime? get startingDate => components.first.startingDate;

  @override
  Map<String, dynamic> toJson() {
    return {
      "components": components.map((e) => e.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Workout toRoutine({String? routineID}) {
    throw SynthesizedWorkoutMethodException("toRoutine");
  }

  @override
  Workout withFilters(
      {bool Function(WorkoutExercisable p1)? exerciseFilter,
      bool Function(WorkoutExercisable p1, GTSet p2)? setFilter}) {
    throw SynthesizedWorkoutMethodException("withFilters");
  }

  @override
  Workout withRegeneratedExerciseIDs({required bool superseding}) {
    throw SynthesizedWorkoutMethodException("withRegeneratedExerciseIDs");
  }

  @override
  bool hasExercise(Exercise exercise) {
    throw SynthesizedWorkoutMethodException("hasExercise");
  }

  @override
  Map<String, dynamic> shareWorkout() {
    throw SynthesizedWorkoutMethodException("shareWorkout");
  }
}

class WorkoutDifference {
  final int addedExercises, removedExercises, changedExercises;

  bool get isEmpty =>
      addedExercises == 0 && removedExercises == 0 && changedExercises == 0;

  @visibleForTesting
  const WorkoutDifference.raw({
    required this.addedExercises,
    required this.removedExercises,
    required this.changedExercises,
  });

  factory WorkoutDifference.fromWorkouts({
    required Workout oldWorkout,
    required Workout newWorkout,
  }) {
    final oldExercises = oldWorkout.exercises;
    final newExercises = newWorkout.exercises;

    int changedExercises = 0;

    for (int i = 0; i < min(oldExercises.length, newExercises.length); i++) {
      final oldCandidate = oldExercises[i];
      final newCandidate = newExercises[i];

      bool isDifferent = false;
      isDifferent |= oldCandidate.notes != newCandidate.notes;
      isDifferent |= oldCandidate.restTime != newCandidate.restTime;
      isDifferent |= oldCandidate.sets.length != newCandidate.sets.length;
      // If either is a superset and the other is not
      isDifferent |= (oldCandidate is Superset) != (newCandidate is Superset);
      if (oldCandidate is Superset && newCandidate is Superset) {
        isDifferent |=
            oldCandidate.exercises.length != newCandidate.exercises.length;
      }

      for (int j = 0;
          j < min(oldCandidate.sets.length, newCandidate.sets.length);
          j++) {
        final oldSet = oldCandidate.sets[j];
        final newSet = newCandidate.sets[j];

        isDifferent |= oldSet.distance != newSet.distance;
        // Don't cound failure and stripping sets as changed since we're erasing
        // them anyway when instantiating the routine.
        // It doesn't really matter whether we use oldSet or newSet here;
        // If they aren't equal, the set is considered changed anyway.
        if (newSet.kind.shouldKeepInRoutine) {
          isDifferent |= oldSet.reps != newSet.reps;
        }
        isDifferent |= !doubleEquality(
          Weights.convert(
            value: oldSet.weight ?? 0,
            from: oldWorkout.weightUnit,
            to: newWorkout.weightUnit,
          ),
          newSet.weight ?? 0,
          epsilon: 0.001,
        );
        isDifferent |= oldSet.time != newSet.time;
        isDifferent |= oldSet.kind != newSet.kind;
      }

      if (isDifferent) changedExercises++;
    }

    final addedExercises = max(0, newExercises.length - oldExercises.length);
    final removedExercises = max(0, oldExercises.length - newExercises.length);

    return WorkoutDifference.raw(
      addedExercises: addedExercises,
      removedExercises: removedExercises,
      changedExercises: changedExercises,
    );
  }

  @override
  String toString() {
    return 'WorkoutDifference[+$addedExercises, -$removedExercises, ~$changedExercises]';
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkoutDifference &&
        other.addedExercises == addedExercises &&
        other.removedExercises == removedExercises &&
        other.changedExercises == changedExercises;
  }

  @override
  int get hashCode =>
      addedExercises.hashCode ^
      removedExercises.hashCode ^
      changedExercises.hashCode;
}

bool linearExercisesUseNewAlgorithm(Workout base, Workout cont) {
  globalLogger.w('[linearExercisesUseNewAlgorithm] usesNewAlgorithm: ${(
    cont.isSupersedence,
    cont.isCompletionOf(base)
  )}');
  return cont.isSupersedence && cont.isCompletionOf(base);
}

// Weird name for a function that returns exercises, overriding superseded exercises.
/// Returns the user-expected exercises in a workout, accounting for
/// continued workouts if the workouts are related.
///
/// How this works is:
/// - If the two workouts are not related*, the exercises are simply concatenated.
/// - If the two workouts continue each other:
///   - Lay out the exercises in the base workout.
///   - Append the exercises in the continuation that are *not* superseded (i.e.
///     any exercise that may have been added in the continuation).
///   - Replace the exercises in the base workout that *are* superseded with the
///     corresponding exercises in the continuation.
///
/// Superseding supersets are copied in bulk. Exercises in the superset that
/// supersede other exercises carry the superseded exercises' id, as usual,
/// but no other edge case is handled.
///
/// \*Two workouts are related if the continuation completes the base; that is,
/// the continuation has the base's ID in its `completes` field, and the base
/// has the continuation's ID in its `completedBy` field.
///
/// The resulting workout is something like this (B - base exercise,
/// C - continuation exercise, S - superseded):
///
/// ```
/// Workout(
///   exercises: [
///     B1,
///     B2,
///     S3,
///     B4,
///     S5,
///     C1,
///     C2,
///     C3,
///   ],
/// );
/// ```
List<WorkoutExercisable> getExercisesLinearly(
  Workout base,
  Workout cont, {
  bool overrideSupersedencesWithNull = false,
}) {
  if (linearExercisesUseNewAlgorithm(base, cont)) {
    globalLogger.d("[getExercisesLinearly] ${("base", base.exercises.length)}");
    final exercises = <WorkoutExercisable>[];
    final ids = [
      ...base.exercises.map((e) => e.id),
      ...cont.exercises.where((e) => !e.isSupersedence).map((e) => e.id),
    ];
    globalLogger.d('[getExercisesLinearly] ids: $ids');
    final exerciseMap = <String, WorkoutExercisable>{
      for (final id in base.exercises.map((e) => e.id))
        id: base.exercises.firstWhere((e) => e.id == id),
      for (final id
          in cont.exercises.where((e) => !e.isSupersedence).map((e) => e.id))
        id: cont.exercises.firstWhere((e) => e.id == id).changeUnits(
              fromWeightUnit: cont.weightUnit,
              toWeightUnit: base.weightUnit,
              fromDistanceUnit: cont.distanceUnit,
              toDistanceUnit: base.distanceUnit,
            ),
    };

    for (final exercise in cont.exercises) {
      if (exercise.isSupersedence) {
        final newExercise = exercise
            .changeUnits(
              fromWeightUnit: cont.weightUnit,
              toWeightUnit: base.weightUnit,
              fromDistanceUnit: cont.distanceUnit,
              toDistanceUnit: base.distanceUnit,
            )
            .map(
              exercise: (ex) => ex.copyWith(
                id: ex.supersedesID,
                supersedesID: null,
              ),
              superset: (superset) {
                final exercises = [
                  for (final exercise in superset.exercises)
                    exercise.copyWith(
                      id: exercise.isSupersedence
                          ? exercise.supersedesID
                          : exercise.id,
                      supersetID: superset.id,
                      supersedesID: null,
                    ),
                ];
                final result = superset.copyWith(
                  id: superset.supersedesID,
                  supersedesID: null,
                  exercises: exercises,
                );
                return result;
              },
            );
        exerciseMap[newExercise.id] = newExercise;
      }
    }

    for (final id in ids) {
      final exercise = exerciseMap[id]!;

      if (overrideSupersedencesWithNull) {
        exercises.add(exercise.map(exercise: (ex) {
          return ex.copyWith.supersedesID(null);
        }, superset: (s) {
          return s.copyWith(
            supersedesID: null,
            exercises:
                s.exercises.map((e) => e.copyWith.supersedesID(null)).toList(),
          );
        }));
      } else {
        exercises.add(exercise);
      }
    }

    return exercises;
  } else {
    return [
      ...base.exercises,
      for (final exercise in cont.exercises)
        exercise.changeUnits(
          fromWeightUnit: cont.weightUnit,
          toWeightUnit: base.weightUnit,
          fromDistanceUnit: cont.distanceUnit,
          toDistanceUnit: base.distanceUnit,
        ),
    ];
  }
}

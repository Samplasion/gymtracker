import 'dart:math';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'workout.g.dart';

@CopyWith()
@JsonSerializable()

/// Represents a workout, that is, a named sequence of exercises.
///
/// A workout can be concrete. A concrete workout represent the
/// actual exercises that have been done in a set time, stored in
/// [duration]. If the [duration] is null, then the workout is
/// not concrete and represents a routine.
class Workout {
  String id;
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
  String? parentID;

  /// The unit of weight used in this workout.
  Weights weightUnit;

  /// The unit of distance used in this workout.
  Distance distanceUnit;

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
  String? completedBy;

  /// {@macro gymtracker_workout_completion}
  String? completes;

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
  })  : id = id ?? const Uuid().v4(),
        assert(() {
          if (completedBy == null && completes == null) return true;
          return (completedBy == null) != (completes == null);
        }(),
            "Both completedBy and completes cannot be defined at the same time.");

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

    final result = Workout(
      name: workout1.name,
      exercises: [
        ...workout1.exercises,
        for (final exercise in workout2.exercises)
          exercise.changeUnits(
            fromWeightUnit: workout2.weightUnit,
            toWeightUnit: workout1.weightUnit,
            fromDistanceUnit: workout2.distanceUnit,
            toDistanceUnit: workout1.distanceUnit,
          ),
      ],
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
      };

  @override
  String toString() {
    return 'Workout[$name] ${toJson()}';
  }

  Workout clone() => Workout.fromJson(toJson());

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
}

class SynthesizedWorkoutSetterException implements Exception {
  final String field;

  SynthesizedWorkoutSetterException(this.field);

  @override
  String toString() {
    return "Cannot set field `$field` on a synthesized workout.";
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
  set completedBy(String? v) =>
      throw SynthesizedWorkoutSetterException("completedBy");

  @override
  String? get completes => null;
  @override
  set completes(String? v) =>
      throw SynthesizedWorkoutSetterException("completes");

  @override
  Distance get distanceUnit => components.first.distanceUnit;
  @override
  set distanceUnit(Distance v) =>
      throw SynthesizedWorkoutSetterException("distanceUnit");

  @override
  String get id => components.first.id;
  @override
  set id(String v) => throw SynthesizedWorkoutSetterException("id");

  @override
  String? get parentID => null;
  @override
  set parentID(String? v) =>
      throw SynthesizedWorkoutSetterException("parentID");

  @override
  Weights get weightUnit => components.first.weightUnit;
  @override
  set weightUnit(Weights v) =>
      throw SynthesizedWorkoutSetterException("weightUnit");

  @override
  List<GTSet> get allSets => components.expand((e) => e.allSets).toList();

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
  List<GTSet> get doneSets => components.expand((e) => e.doneSets).toList();

  @override
  Duration get duration => components.fold(
      Duration.zero, (a, b) => a + (b.duration ?? Duration.zero));

  @override
  DateTime get endingDate => startingDate!.add(duration);

  @override
  List<WorkoutExercisable> get exercises => components
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

  @override
  String? get infobox => components.first.infobox;

  @override
  bool get isComplete => components.every((e) => e.isComplete);

  @override
  bool get isConcrete => components.first.isConcrete;

  @override
  bool get isContinuable => false;

  @override
  bool get isContinuation => false;

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

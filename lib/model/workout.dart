import 'dart:math';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
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
      candidate != null && candidate.trim().isNotEmpty;

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  String? parentID;

  /// The unit of weight used in this workout.
  Weights weightUnit;

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

  List<ExSet> get allSets => [for (final ex in exercises) ...ex.sets];
  List<ExSet> get doneSets => [
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
  })  : id = id ?? const Uuid().v4(),
        assert(() {
          if (completedBy == null && completes == null) return true;
          return (completedBy == null) != (completes == null);
        }(),
            "Both completedBy and completes cannot be defined at the same time.");

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => {
        ..._$WorkoutToJson(this),
        'exercises': [for (final exercise in exercises) exercise.toJson()],
      };

  Workout clone() => Workout.fromJson(toJson());

  Workout toRoutine() =>
      copyWith(duration: null, startingDate: null, id: const Uuid().v4());

  Workout regenerateID() => copyWith(id: const Uuid().v4());
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

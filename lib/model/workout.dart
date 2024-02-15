import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
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
}

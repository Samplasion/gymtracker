import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
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

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  String? parentID;

  /// Whether this is a concrete workout.
  bool get isConcrete => duration != null;

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

  Workout({
    String? id,
    required this.name,
    required this.exercises,
    this.duration,
    this.startingDate,
    this.parentID,
    this.infobox,
  }) : id = id ?? const Uuid().v4();

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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'superset.g.dart';

@JsonSerializable()
@CopyWith()
class Superset extends WorkoutExercisable {
  @override
  final String id;
  final List<Exercise> exercises;
  @override
  final Duration restTime;
  @JsonKey(defaultValue: "")
  @override
  final String notes;
  @override
  final String? workoutID;
  @override
  final String? supersedesID;

  Superset({
    String? id,
    required List<Exercise> exercises,
    required this.restTime,
    this.notes = "",
    required this.workoutID,
    this.supersedesID,
  })  : id = id ?? const Uuid().v4(),
        exercises = [
          for (final exercise in exercises)
            exercise.copyWith(workoutID: workoutID, supersetID: id),
        ];

  factory Superset.empty() {
    return Superset(
      exercises: [],
      restTime: const Duration(seconds: 0),
      workoutID: null,
      supersedesID: null,
    );
  }

  factory Superset.fromJson(Map<String, dynamic> json) =>
      _$SupersetFromJson(json);

  @override
  List<GTSet> get sets => [
        for (final ex in exercises) ...ex.sets,
      ];

  @override
  Map<String, dynamic> toJson() => {
        ..._$SupersetToJson(this),
        'exercises': [for (final exercise in exercises) exercise.toJson()],
        'type': 'superset',
      };

  @override
  String toString() {
    return 'Superset${toJson()}';
  }

  @override
  Superset clone() => Superset.fromJson(toJson());

  void withRegenerateID() => copyWith.id(const Uuid().v4());

  @override
  Superset changeUnits(
      {required Weights fromWeightUnit,
      required Weights toWeightUnit,
      required Distance fromDistanceUnit,
      required Distance toDistanceUnit}) {
    return copyWith(
      exercises: [
        for (final exercise in exercises)
          exercise.changeUnits(
            fromWeightUnit: fromWeightUnit,
            toWeightUnit: toWeightUnit,
            fromDistanceUnit: fromDistanceUnit,
            toDistanceUnit: toDistanceUnit,
          ),
      ],
    );
  }

  static bool deepEquality(Superset a, Superset b) {
    if (a.id != b.id) return false;
    if (a.restTime != b.restTime) return false;
    if (a.notes != b.notes) return false;
    if (a.workoutID != b.workoutID) return false;
    if (a.supersedesID != b.supersedesID) return false;
    if (a.exercises.length != b.exercises.length) return false;
    for (var i = 0; i < a.exercises.length; i++) {
      if (!Exercise.deepEquality(a.exercises[i], b.exercises[i])) return false;
    }
    return true;
  }
}

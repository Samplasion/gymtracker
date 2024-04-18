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
  String id;
  final List<Exercise> exercises;
  @override
  Duration restTime;

  @JsonKey(defaultValue: "")
  @override
  String notes;

  @override
  String? workoutID;

  Superset({
    String? id,
    required this.exercises,
    required this.restTime,
    this.notes = "",
    required this.workoutID,
  }) : id = id ?? const Uuid().v4();

  factory Superset.empty() {
    return Superset(
      exercises: [],
      restTime: const Duration(seconds: 0),
      workoutID: null,
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

  Superset clone() => Superset.fromJson(toJson());

  void regenerateID() => id = const Uuid().v4();

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
}

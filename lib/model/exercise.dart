import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'set.dart';

part 'exercise.g.dart';

enum MuscleGroup {
  abductors,
  abs,
  adductors,
  biceps,
  calves,
  chest,
  forearm,
  glutes,
  hamstrings,
  lats,
  lowerBack,

  /// Or cardio
  none,
  other,
  quadriceps,
  shoulders,
  traps,
  triceps,
  upperBack,
}

@JsonSerializable()
@CopyWith()
class Exercise {
  String id;
  final String name;
  final SetParameters parameters;
  final List<ExSet> sets;
  final MuscleGroup primaryMuscleGroup;
  final Set<MuscleGroup> secondaryMuscleGroups;
  Duration restTime;

  Exercise({
    String? id,
    required this.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const <MuscleGroup>{},
    required this.restTime,
  })  : id = id ?? const Uuid().v4(),
        assert(sets.isEmpty || parameters == sets[0].parameters,
            "The parameters must not change between the Exercise and its Sets"),
        assert(
            sets.isEmpty || sets.map((e) => e.parameters).toSet().length == 1,
            "The sets must have the same parameters.");

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$ExerciseToJson(this),
        'sets': [for (final set in sets) set.toJson()],
      };

  Exercise clone() => Exercise.fromJson(toJson());

  void regenerateID() => id = const Uuid().v4();
}

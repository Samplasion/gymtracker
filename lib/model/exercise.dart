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

@JsonSerializable(constructor: "_")
@CopyWith(constructor: "_")
class Exercise {
  String id;
  final String name;
  final SetParameters parameters;
  final List<ExSet> sets;
  final MuscleGroup primaryMuscleGroup;
  final Set<MuscleGroup> secondaryMuscleGroups;
  Duration restTime;

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  String? parentID;

  @JsonKey(defaultValue: "")
  String notes;

  @JsonKey(defaultValue: false)
  final bool standard;

  bool get isCustom => !standard;

  Exercise._({
    String? id,
    required this.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const <MuscleGroup>{},
    required this.restTime,
    this.parentID,
    required this.notes,
    required this.standard,
  })  : id = id ?? const Uuid().v4(),
        assert(sets.isEmpty || parameters == sets[0].parameters,
            "The parameters must not change between the Exercise and its Sets"),
        assert(
            sets.isEmpty || sets.map((e) => e.parameters).toSet().length == 1,
            "The sets must have the same parameters.");

  factory Exercise.custom({
    String? id,
    required String name,
    required SetParameters parameters,
    required List<ExSet> sets,
    required MuscleGroup primaryMuscleGroup,
    Set<MuscleGroup> secondaryMuscleGroups = const <MuscleGroup>{},
    required Duration restTime,
    String? parentID,
    required String notes,
  }) =>
      Exercise._(
        name: name,
        parameters: parameters,
        sets: sets,
        primaryMuscleGroup: primaryMuscleGroup,
        secondaryMuscleGroups: secondaryMuscleGroups,
        restTime: restTime,
        parentID: parentID,
        notes: notes,
        standard: false,
      );

  factory Exercise.standard({
    required String id,
    required String name,
    required SetParameters parameters,
    required MuscleGroup primaryMuscleGroup,
    Set<MuscleGroup> secondaryMuscleGroups = const <MuscleGroup>{},
  }) {
    return Exercise._(
      id: id,
      name: name,
      parameters: parameters,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      sets: [ExSet.empty(kind: SetKind.normal, parameters: parameters)],
      restTime: Duration.zero,
      notes: "",
      standard: true,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$ExerciseToJson(this),
        'sets': [for (final set in sets) set.toJson()],
      };

  Exercise clone() => Exercise.fromJson(toJson());

  void regenerateID() => id = const Uuid().v4();

  /// Returns true if [other] is [this] or an instance of [this]
  /// (ie. [other.parentID] == [id].)
  bool isTheSameAs(Exercise other) => other.id == id || other.parentID == id;
}

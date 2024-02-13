import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'exercise.g.dart';

bool _defaultSetFilter(set) => true;

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
class Exercise extends WorkoutExercisable {
  @override
  String id;
  final String name;
  final SetParameters parameters;
  @override
  final List<ExSet> sets;
  final MuscleGroup primaryMuscleGroup;
  final Set<MuscleGroup> secondaryMuscleGroups;
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

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$ExerciseToJson(this),
        'sets': [for (final set in sets) set.toJson()],
        'type': 'exercise',
      };

  Exercise clone() => Exercise.fromJson(toJson());

  void regenerateID() => id = const Uuid().v4();

  /// Returns true if [other] is [this] or an instance of [this]
  /// (ie. [other.parentID] == [id].)
  bool isTheSameAs(Exercise other) => other.id == id || other.parentID == id;

  Exercise instantiate({
    required Workout workout,
    bool Function(ExSet set)? setFilter = _defaultSetFilter,
  }) =>
      copyWith(
        sets: ([
          for (final set in sets)
            set.copyWith(
              done: false,
              reps:
                  [SetKind.failure, SetKind.failureStripping].contains(set.kind)
                      ? 0
                      : set.reps,
            ),
        ]),
        // If we're redoing a previous workout,
        // we want to inherit the previous parent ID,
        // ie. the original routine's ID
        // But we also want to keep it if we're cloning
        // a built-in exercise, so that the translated name is kept.
        parentID: workout.isConcrete || standard ? parentID : id,
        id: const Uuid().v4(),
      );
}

extension Display on Exercise {
  String get displayName {
    if (isCustom) return name;
    final candidate = parentID ?? id;
    if (candidate.existsAsTranslationKey) return candidate.t;
    name.printError(info: "No translation found");
    return name;
  }
}

extension Utils on List<Exercise> {
  int? findExerciseIndex(Exercise ex) {
    for (var i = 0; i < length; i++) {
      if (this[i].id == ex.id) return i;
    }
    return null;
  }
}

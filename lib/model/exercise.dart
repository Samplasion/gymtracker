import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'exercise.g.dart';

bool _defaultSetFilter(set) => true;

enum MuscleCategory {
  arms,
  back,
  chest,
  core,
  legs,
  shoulders,
}

enum MuscleGroup {
  abductors(MuscleCategory.legs),
  abs(MuscleCategory.core),
  adductors(MuscleCategory.legs),
  biceps(MuscleCategory.arms),
  calves(MuscleCategory.legs),
  chest(MuscleCategory.chest),
  forearm(MuscleCategory.arms),
  glutes(MuscleCategory.legs),
  hamstrings(MuscleCategory.legs),
  lats(MuscleCategory.legs),
  lowerBack(MuscleCategory.back),

  /// Or cardio
  none,
  other,
  quadriceps(MuscleCategory.legs),
  shoulders(MuscleCategory.shoulders),
  traps(MuscleCategory.back),
  triceps(MuscleCategory.arms),
  upperBack(MuscleCategory.back);

  const MuscleGroup([this.category]);

  final MuscleCategory? category;
}

@JsonSerializable(constructor: "raw")
@CopyWith(constructor: "raw")
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

  Exercise.raw({
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
      Exercise.raw(
        id: id,
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
    return Exercise.raw(
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

  /// Returns true if [other] is a sibling of [this]
  bool isSiblingOf(Exercise other) => other.parentID == parentID;

  /// Returns true if [other] is a child of [this]
  bool isParentOf(Exercise other) => other.parentID == id;

  /// This function already calls [makeSibling] internally.
  Exercise instantiate({
    required Workout workout,
    bool Function(ExSet set)? setFilter = _defaultSetFilter,
  }) {
    // We want to keep the parent ID of the exercise in the library (custom
    // or not) as to avoid a "linked list" type situation
    final base = makeSibling();
    return base.copyWith(
      sets: ([
        for (final set in sets)
          set.copyWith(
            done: false,
            reps: set.kind.shouldKeepInRoutine ? set.reps : 0,
          ),
      ]),
    );
  }

  Exercise makeSibling() {
    return clone()..regenerateID();
  }

  Exercise makeChild() {
    final child = clone()
      ..parentID = id
      ..regenerateID();
    logger.t(
        "Making child of [id: $id, pid: $parentID] with ID [id: ${child.id}, pid: ${child.parentID}]");
    return child;
  }

  static Exercise replaced({required Exercise from, required Exercise to}) {
    return to.copyWith(
      notes: from.notes,
      restTime: from.restTime,
      sets: to.parameters == from.parameters
          ? [for (final set in from.sets) set.copyWith()]
          : [
              for (final set in from.sets)
                ExSet(
                  parameters: to.parameters,
                  kind: set.kind,
                  reps: 0,
                  weight: 0,
                  time: Duration.zero,
                  distance: 0,
                ),
            ],
    );
  }

  @override
  String toString() {
    return "Exercise${toJson()}";
  }

  @override
  Exercise changeUnits({
    required Weights fromWeightUnit,
    required Weights toWeightUnit,
    required Distance fromDistanceUnit,
    required Distance toDistanceUnit,
  }) {
    return copyWith(
      sets: [
        for (final set in sets)
          set.copyWith(
            weight: set.weight == null
                ? null
                : Weights.convert(
                    value: set.weight!,
                    from: fromWeightUnit,
                    to: toWeightUnit,
                  ),
            distance: set.distance == null
                ? null
                : Distance.convert(
                    value: set.distance!,
                    from: fromDistanceUnit,
                    to: toDistanceUnit,
                  ),
          ),
      ],
    );
  }
}

extension Display on Exercise {
  String get displayName {
    if (isCustom) return name;
    final candidate = parentID ?? id;
    if (candidate.existsAsTranslationKey) return candidate.t;
    name.logger.e("No translation found");
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

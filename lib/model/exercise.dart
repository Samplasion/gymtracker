import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
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

enum GTMuscleCategory {
  arms,
  back,
  chest,
  core,
  legs,
  shoulders,
}

enum GTMuscleGroup {
  abductors(GTMuscleCategory.legs),
  abs(GTMuscleCategory.core),
  adductors(GTMuscleCategory.legs),
  biceps(GTMuscleCategory.arms),
  calves(GTMuscleCategory.legs),
  chest(GTMuscleCategory.chest),
  forearm(GTMuscleCategory.arms),
  glutes(GTMuscleCategory.legs),
  hamstrings(GTMuscleCategory.legs),
  lats(GTMuscleCategory.legs),
  lowerBack(GTMuscleCategory.back),

  /// Or cardio
  none,
  other,
  quadriceps(GTMuscleCategory.legs),
  shoulders(GTMuscleCategory.shoulders),
  traps(GTMuscleCategory.back),
  triceps(GTMuscleCategory.arms),
  upperBack(GTMuscleCategory.back),

  // Added later: keep sorted by added date and don't rename
  thighs(GTMuscleCategory.legs);

  const GTMuscleGroup([this.category]);

  final GTMuscleCategory? category;
}

@JsonSerializable(constructor: "raw")
@CopyWith(constructor: "raw")
class Exercise extends WorkoutExercisable {
  @override
  final String id;
  final String name;
  final GTSetParameters parameters;
  @override
  final List<GTSet> sets;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  @override
  final Duration restTime;

  /// The ID of the non-concrete (ie. part of a routine) exercise
  /// this concrete exercise should be categorized under.
  final String? parentID;
  @JsonKey(defaultValue: "")
  @override
  final String notes;
  final String? supersetID;
  @override
  final String? workoutID;
  @JsonKey(defaultValue: false)
  final bool standard;

  @override
  final String? supersedesID;

  bool get isCustom => !standard;
  bool get isInSuperset => supersetID != null;
  bool get isOrphan => parentID == null;
  bool get isAbstract => workoutID == null;
  bool get isStandardLibraryExercise {
    final query = isAbstract ? id : parentID;
    return getStandardExerciseByID(query!) != null;
  }

  List<GTSet> get doneSets => [
        for (final set in sets)
          if (set.done) set
      ];
  double? get liftedWeight {
    if (parameters != GTSetParameters.repsWeight &&
        parameters != GTSetParameters.timeWeight) return null;

    return doneSets.fold(0.0,
        (value, element) => value! + (element.weight ?? 0) * (element.reps!));
  }

  double? get distanceRun {
    if (parameters != GTSetParameters.distance) return null;
    return doneSets.fold(0.0, (value, element) => value! + (element.distance!));
  }

  Duration? get time {
    if (parameters != GTSetParameters.time &&
        parameters != GTSetParameters.timeWeight) return null;
    return doneSets.fold(
        Duration.zero, (value, element) => value! + (element.time!));
  }

  int? get reps {
    if (parameters != GTSetParameters.repsWeight &&
        parameters != GTSetParameters.freeBodyReps) return null;
    return doneSets.fold(0, (value, element) => value! + (element.reps ?? 0));
  }

  Exercise.raw({
    String? id,
    required this.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const <GTMuscleGroup>{},
    required this.restTime,
    this.parentID,
    required this.notes,
    required this.standard,
    required this.supersetID,
    required this.workoutID,
    required this.supersedesID,
  })  : id = id ?? const Uuid().v4(),
        assert(sets.isEmpty || parameters == sets[0].parameters,
            "The parameters must not change between the Exercise and its Sets"),
        assert(
            sets.isEmpty || sets.map((e) => e.parameters).toSet().length == 1,
            "The sets must have the same parameters.");

  factory Exercise.custom({
    String? id,
    required String name,
    required GTSetParameters parameters,
    required List<GTSet> sets,
    required GTMuscleGroup primaryMuscleGroup,
    Set<GTMuscleGroup> secondaryMuscleGroups = const <GTMuscleGroup>{},
    required Duration restTime,
    String? parentID,
    required String notes,
    required String? supersetID,
    required String? workoutID,
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
        supersetID: supersetID,
        workoutID: workoutID,
        supersedesID: null,
      );

  factory Exercise.standard({
    required String id,
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    Set<GTMuscleGroup> secondaryMuscleGroups = const <GTMuscleGroup>{},
  }) {
    return Exercise.raw(
      id: id,
      name: name,
      parameters: parameters,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      sets: [GTSet.empty(kind: GTSetKind.normal, parameters: parameters)],
      restTime: Duration.zero,
      notes: "",
      standard: true,
      supersetID: null,
      workoutID: null,
      supersedesID: null,
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

  @override
  Exercise clone() => Exercise.fromJson(toJson());

  Exercise _withRegeneratedID() => copyWith.id(const Uuid().v4());

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
    bool Function(GTSet set)? setFilter = _defaultSetFilter,
    bool isSupersedence = false,
  }) {
    // We want to keep the parent ID of the exercise in the library (custom
    // or not) as to avoid a "linked list" type situation
    final base = makeSibling();
    return base.copyWith(
      workoutID: workout.id,
      sets: ([
        for (final set in sets)
          if (setFilter?.call(set) ?? true)
            if (isSupersedence)
              set.copyWith()
            else
              set.copyWith(
                done: false,
                reps: set.kind.shouldKeepInRoutine ? set.reps : 0,
              ),
      ]),
    );
  }

  Exercise makeSibling() {
    return _withRegeneratedID();
  }

  Exercise makeChild() {
    final child = _withRegeneratedID().copyWith(parentID: id);
    logger.t(
        "Making child of [id: $id, pid: $parentID] with ID [id: ${child.id}, pid: ${child.parentID}]");
    return child;
  }

  static Exercise replaced({required Exercise from, required Exercise to}) {
    return to.copyWith(
      workoutID: from.workoutID,
      supersetID: from.supersetID,
      notes: from.notes,
      restTime: from.restTime,
      sets: to.parameters == from.parameters
          ? [for (final set in from.sets) set.copyWith()]
          : [
              for (final set in from.sets)
                GTSet(
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
    return "Exercise${{...toJson(), 'isAbstract': isAbstract}}";
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

    final candidate = isAbstract ? id : parentID!;

    if (candidate.existsAsTranslationKey) return candidate.t;
    if (!isOrphan && parentID!.existsAsTranslationKey) return parentID!.t;
    name.logger.e(
        "No translation found for exercise $candidate which ${isAbstract ? "is" : "is not"} abstract");
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

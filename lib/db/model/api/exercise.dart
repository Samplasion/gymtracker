// ignore_for_file: overridden_fields

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:json_annotation/json_annotation.dart';

export 'package:gymtracker/db/model/tables/exercise.dart'
    show GTMuscleCategory, GTMuscleGroup;

part 'exercise.g.dart';

@JsonSerializable()
@CopyWith()
class GTLibraryExercise {
  final int id;
  final String? libraryID;
  final String name;
  final GTSetParameters parameters;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  final bool isCustom;

  const GTLibraryExercise({
    required this.id,
    this.libraryID,
    required this.name,
    required this.parameters,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    this.isCustom = true,
  }) : assert(id < 0 ? !isCustom : true, "ID must be negative for custom.");

  const GTLibraryExercise.library({
    this.libraryID,
    required this.name,
    required this.parameters,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
  })  : id = -1,
        isCustom = false;

  @override
  String toString() {
    return "GTLibraryExercise${toJson()}";
  }

  factory GTLibraryExercise.fromJson(Map<String, dynamic> json) =>
      _$GTLibraryExerciseFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$GTLibraryExerciseToJson(this),
        'type': 'exercise',
      };

  factory GTLibraryExercise.fromData(CustomExercise row) {
    return GTLibraryExercise(
      id: row.id,
      name: row.name,
      parameters: row.parameters,
      primaryMuscleGroup: row.primaryMuscleGroup,
      secondaryMuscleGroups: row.secondaryMuscleGroups,
    );
  }

  Insertable<CustomExercise> toInsertable() {
    assert(isCustom);
    assert(id >= 0);

    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      parameters: Value(parameters),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
    );
  }
}

enum GTExerciseType {
  exercise,
  superset,
}

@JsonSerializable(
  createFactory: false,
  createToJson: false,
)
abstract class GTExerciseOrSuperset {
  final int id;
  final int parentID;
  final String name;
  final GTSetParameters? parameters;
  final List<GTSet>? sets;
  final GTMuscleGroup? primaryMuscleGroup;
  final Set<GTMuscleGroup>? secondaryMuscleGroups;
  final Duration? restTime;
  final String? libraryExerciseID;
  final int? customExerciseID;
  final bool isCustom;
  final String notes;
  final bool inSuperset;
  final int? supersetID;
  final GTExerciseType type;
  final int sortOrder;

  const GTExerciseOrSuperset({
    required this.id,
    required this.name,
    required this.parentID,
    this.parameters,
    this.sets,
    this.primaryMuscleGroup,
    this.secondaryMuscleGroups,
    this.restTime,
    this.libraryExerciseID,
    this.customExerciseID,
    required this.isCustom,
    required this.notes,
    required this.inSuperset,
    required this.supersetID,
    required this.type,
    required this.sortOrder,
  });

  when({
    void Function(GTExercise)? exercise,
    void Function(GTSuperset)? superset,
    void Function()? other,
  }) {
    assert([exercise, superset, other].any((el) => el != null),
        "At least one callback must be provided.");
    if (this is GTExercise && exercise != null) {
      exercise(asExercise);
      return;
    } else if (this is GTSuperset && superset != null) {
      superset(asSuperset);
      return;
    }
    other?.call();
  }

  T map<T>({
    required T Function(GTExercise) exercise,
    required T Function(GTSuperset) superset,
  }) {
    if (this is GTExercise) {
      return exercise(asExercise);
    } else if (this is GTSuperset) {
      return superset(asSuperset);
    }
    throw TypeError();
  }

  GTExercise get asExercise => this as GTExercise;
  GTSuperset get asSuperset => this as GTSuperset;

  Map<String, dynamic> toJson();
  factory GTExerciseOrSuperset.fromJson(Map<String, dynamic> json) =>
      _customFromJson(json);

  static GTExerciseOrSuperset _customFromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'exercise':
        return GTExercise.fromJson(json);
      case 'superset':
        return GTSuperset.fromJson(json);
      default:
        throw Exception('Invalid type ${json["type"]}');
    }
  }

  factory GTExerciseOrSuperset.fromDatabaseRoutineExercise(
      RoutineExercise data) {
    if (data.isSuperset) {
      return GTSuperset(
        id: data.id,
        parentID: data.routineId,
        name: data.name,
        restTime: Duration(seconds: data.restTime!),
        notes: data.notes ?? "",
        sortOrder: data.sortOrder,
        exercises: [],
      );
    } else {
      return GTExercise(
        id: data.id,
        parentID: data.routineId,
        name: data.name,
        restTime:
            data.restTime == null ? null : Duration(seconds: data.restTime!),
        notes: data.notes ?? "",
        sortOrder: data.sortOrder,
        parameters: data.parameters!,
        sets: data.sets!,
        primaryMuscleGroup: data.primaryMuscleGroup!,
        secondaryMuscleGroups: data.secondaryMuscleGroups!,
        libraryExerciseID: data.libraryExerciseId,
        customExerciseID: data.customExerciseId,
        isCustom: data.isCustom,
        inSuperset: data.isInSuperset,
        supersetID: data.supersetId,
      );
    }
  }

  factory GTExerciseOrSuperset.fromDatabaseHistoryWorkoutExercise(
      HistoryWorkoutExercise data) {
    if (data.isSuperset) {
      return GTSuperset(
        id: data.id,
        parentID: data.routineId,
        name: data.name,
        restTime: Duration(seconds: data.restTime!),
        notes: data.notes ?? "",
        sortOrder: data.sortOrder,
        exercises: [],
      );
    } else {
      return GTExercise(
        id: data.id,
        parentID: data.routineId,
        name: data.name,
        restTime:
            data.restTime == null ? null : Duration(seconds: data.restTime!),
        notes: data.notes ?? "",
        sortOrder: data.sortOrder,
        parameters: data.parameters!,
        sets: data.sets!,
        primaryMuscleGroup: data.primaryMuscleGroup!,
        secondaryMuscleGroups: data.secondaryMuscleGroups!,
        libraryExerciseID: data.libraryExerciseId,
        customExerciseID: data.customExerciseId,
        isCustom: data.isCustom,
        inSuperset: data.isInSuperset,
        supersetID: data.supersetId,
      );
    }
  }

  Insertable<RoutineExercise> toRoutineExercise() {
    return RoutineExercisesCompanion(
      id: Value(id),
      routineId: Value(parentID),
      name: Value(name),
      restTime: Value(restTime?.inSeconds),
      notes: Value(notes),
      sortOrder: Value(sortOrder),
      parameters: Value(parameters),
      sets: Value(sets),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      libraryExerciseId: Value(libraryExerciseID),
      customExerciseId: Value(customExerciseID),
      isCustom: Value(isCustom),
      isSuperset: Value(type == GTExerciseType.superset),
      isInSuperset: Value(inSuperset),
      supersetId: Value(supersetID),
    );
  }

  Insertable<HistoryWorkoutExercise> toHistoryWorkoutExercise() {
    return HistoryWorkoutExercisesCompanion(
      id: Value(id),
      routineId: Value(parentID),
      name: Value(name),
      restTime: Value(restTime?.inSeconds),
      notes: Value(notes),
      sortOrder: Value(sortOrder),
      parameters: Value(parameters),
      sets: Value(sets),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      libraryExerciseId: Value(libraryExerciseID),
      customExerciseId: Value(customExerciseID),
      isCustom: Value(isCustom),
      isSuperset: Value(type == GTExerciseType.superset),
      isInSuperset: Value(inSuperset),
      supersetId: Value(supersetID),
    );
  }
}

@JsonSerializable()
@CopyWith()
class GTSuperset extends GTExerciseOrSuperset {
  @override
  final Duration restTime;

  final List<GTExercise> exercises;

  const GTSuperset({
    required super.id,
    required super.parentID,
    required super.name,
    required this.restTime,
    required super.notes,
    required super.sortOrder,
    required this.exercises,
  }) : super(
          isCustom: false,
          inSuperset: false,
          supersetID: null,
          type: GTExerciseType.superset,
        );

  @override
  String toString() {
    return "GTSuperset${toJson()}";
  }

  factory GTSuperset.fromJson(Map<String, dynamic> json) =>
      _$GTSupersetFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$GTSupersetToJson(this),
        'type': 'superset',
      };
}

@JsonSerializable()
@CopyWith()
class GTExercise extends GTExerciseOrSuperset {
  @override
  final GTSetParameters parameters;
  @override
  final List<GTSet> sets;
  @override
  final GTMuscleGroup primaryMuscleGroup;
  @override
  final Set<GTMuscleGroup> secondaryMuscleGroups;

  const GTExercise({
    required super.id,
    required super.parentID,
    required super.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required super.restTime,
    required super.libraryExerciseID,
    required super.customExerciseID,
    required super.isCustom,
    required super.notes,
    required super.inSuperset,
    required super.supersetID,
    required super.sortOrder,
  }) : super(type: GTExerciseType.exercise);

  @override
  String toString() {
    return "GTExercise${toJson()}";
  }

  factory GTExercise.fromJson(Map<String, dynamic> json) =>
      _$GTExerciseFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ..._$GTExerciseToJson(this),
        'type': 'exercise',
      };
}

List<GTExerciseOrSuperset> databaseRoutineExercisesToExercises(
    List<RoutineExercise> data) {
  final exercises = data
      .map((e) => GTExerciseOrSuperset.fromDatabaseRoutineExercise(e))
      .toList();
  final mapped = {
    for (var exercise in exercises)
      if (!exercise.inSuperset) exercise.id: exercise,
  };
  for (final exerciseInSuperset in exercises.where((e) => e.inSuperset)) {
    final superset =
        mapped[exerciseInSuperset.asExercise.supersetID!] as GTSuperset;
    superset.exercises.add(exerciseInSuperset.asExercise);
  }
  final entries = mapped.values.toList();
  entries.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return entries;
}

List<GTExerciseOrSuperset> databaseHistoryWorkoutExercisesToExercises(
    List<HistoryWorkoutExercise> data) {
  final exercises = data
      .map((e) => GTExerciseOrSuperset.fromDatabaseHistoryWorkoutExercise(e))
      .toList();
  final mapped = {
    for (var exercise in exercises)
      if (!exercise.inSuperset) exercise.id: exercise,
  };
  for (final exerciseInSuperset in exercises.where((e) => e.inSuperset)) {
    final superset =
        mapped[exerciseInSuperset.asExercise.supersetID!] as GTSuperset;
    superset.exercises.add(exerciseInSuperset.asExercise);
  }
  final entries = mapped.values.toList();
  entries.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return entries;
}

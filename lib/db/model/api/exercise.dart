// ignore_for_file: overridden_fields

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/db/model/api/set.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

@JsonSerializable()
@CopyWith()
class GTLibraryExercise {
  final int id;
  final String name;
  final GTSetParameters parameters;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;

  const GTLibraryExercise({
    required this.id,
    required this.name,
    required this.parameters,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
  });

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
}

@JsonSerializable()
@CopyWith()
class GTSuperset extends GTExerciseOrSuperset {
  @override
  final Duration restTime;

  const GTSuperset({
    required super.id,
    required super.parentID,
    required super.name,
    required this.restTime,
    required super.notes,
    required super.sortOrder,
  }) : super(
          isCustom: false,
          inSuperset: false,
          supersetID: null,
          type: GTExerciseType.superset,
        );

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

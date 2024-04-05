import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/src/runtime/data_class.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/api/exercise.dart';
import 'package:json_annotation/json_annotation.dart';

part 'routine.g.dart';

@JsonSerializable()
@CopyWith()
class GTRoutine {
  final int id;
  final String name;
  final String notes;
  final Weights weightUnit;
  final Distance distanceUnit;
  final List<GTExerciseOrSuperset> exercises;
  final int sortOrder;

  bool get isConcrete => false;

  const GTRoutine({
    required this.id,
    required this.name,
    required this.notes,
    required this.weightUnit,
    required this.distanceUnit,
    required this.exercises,
    required this.sortOrder,
  });

  factory GTRoutine.fromJson(Map<String, dynamic> json) => json['concrete']
      ? _$GTHistoryWorkoutFromJson(json)
      : _$GTRoutineFromJson(json);

  Map<String, dynamic> toJson() => {
        ..._$GTRoutineToJson(this),
        'concrete': isConcrete,
      };

  @override
  String toString() {
    return "GTRoutine${toJson()}";
  }

  Insertable toInsertable() {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(notes),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      sortOrder: Value(sortOrder),
    );
  }
}

@JsonSerializable()
@CopyWith()
class GTHistoryWorkout extends GTRoutine {
  final DateTime startingDate;
  final Duration duration;
  final int? parentID;
  final int? completedByID;
  final int? completesID;

  @override
  bool get isConcrete => true;

  const GTHistoryWorkout({
    required super.id,
    required super.name,
    required super.notes,
    required super.weightUnit,
    required super.distanceUnit,
    required super.exercises,
    required super.sortOrder,
    required this.startingDate,
    required this.duration,
    required this.parentID,
    required this.completedByID,
    required this.completesID,
  });

  factory GTHistoryWorkout.fromJson(Map<String, dynamic> json) =>
      _$GTHistoryWorkoutFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        ..._$GTHistoryWorkoutToJson(this),
        'concrete': isConcrete,
      };

  @override
  Insertable<HistoryWorkout> toInsertable() {
    return HistoryWorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(notes),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      sortOrder: Value(sortOrder),
      startingDate: Value(startingDate),
      duration: Value(duration.inSeconds),
      parentId: Value(parentID),
      completedBy: Value(completedByID),
      completes: Value(completesID),
    );
  }
}

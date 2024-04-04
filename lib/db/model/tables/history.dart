import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/routines.dart';

class HistoryWorkouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get infobox => text().nullable()();
  IntColumn get duration => integer()();
  Column<DateTime> get startingDate => dateTime()();
  IntColumn get parentId => integer().references(Routines, #id)();
  IntColumn get completedBy => integer().references(HistoryWorkouts, #id)();
  IntColumn get completes => integer().references(HistoryWorkouts, #id)();
  TextColumn get weightUnit => textEnum<Weights>()();
  TextColumn get distanceUnit => textEnum<Distance>()();
  IntColumn get sortOrder => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {completedBy, completes}
      ];
}

class HistoryWorkoutExercises extends LinkedExerciseBase {
  @override
  IntColumn get routineId => integer().references(HistoryWorkouts, #id)();

  @override
  IntColumn get supersetId =>
      integer().nullable().references(HistoryWorkoutExercises, #id)();
}

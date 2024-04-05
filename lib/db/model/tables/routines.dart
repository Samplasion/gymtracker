import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get infobox => text()();
  TextColumn get weightUnit => textEnum<Weights>()();
  TextColumn get distanceUnit => textEnum<Distance>()();
  IntColumn get sortOrder => integer()();
}

class RoutineExercises extends LinkedExerciseBase {
  @override
  IntColumn get routineId => integer().references(Routines, #id)();

  @override
  IntColumn get supersetId =>
      integer().nullable().references(RoutineExercises, #id)();
}

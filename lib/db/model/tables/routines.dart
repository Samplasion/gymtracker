import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Routines extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get infobox => text()();
  TextColumn get weightUnit => textEnum<Weights>()();
  TextColumn get distanceUnit => textEnum<Distance>()();
  IntColumn get sortOrder => integer()();
}

@UseRowClass(ConcreteExercise)
class RoutineExercises extends LinkedExerciseBase {
  @override
  TextColumn get routineId => text().references(Routines, #id)();

  @override
  TextColumn get supersetId =>
      text().nullable().references(RoutineExercises, #id)();

  @override
  TextColumn get supersedesId =>
      text().nullable().references(RoutineExercises, #id)();
}

import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class HistoryWorkouts extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get infobox => text().nullable()();
  IntColumn get duration => integer()();
  Column<DateTime> get startingDate => dateTime()();
  TextColumn get parentId => text().nullable().references(Routines, #id)();
  TextColumn get completedBy =>
      text().nullable().references(HistoryWorkouts, #id)();
  TextColumn get completes =>
      text().nullable().references(HistoryWorkouts, #id)();
  TextColumn get weightUnit => textEnum<Weights>()();
  TextColumn get distanceUnit => textEnum<Distance>()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {completedBy, completes}
      ];
}

@UseRowClass(ConcreteExercise)
class HistoryWorkoutExercises extends LinkedExerciseBase {
  @override
  TextColumn get routineId => text().references(HistoryWorkouts, #id)();

  @override
  TextColumn get supersetId =>
      text().nullable().references(HistoryWorkoutExercises, #id)();

  @override
  TextColumn get supersedesId =>
      text().nullable().references(HistoryWorkoutExercises, #id)();
}

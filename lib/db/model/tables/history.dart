import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/model/history.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@UseRowClass(HistoryWorkout)
class HistoryWorkouts extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
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
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {completedBy, completes},
  ];
}

@UseRowClass(HistoryWorkoutExercise)
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

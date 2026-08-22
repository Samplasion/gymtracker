import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@UseRowClass(RoutineFolder)
class RoutineFolders extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  // Max: 100 000 to account for JSON data caused by the rich notes format
  // The actual limit is far less
  TextColumn get notes => text().nullable().withLength(max: 100000)();
  @override
  DateTimeColumn get updatedAt => dateTime().nullable()();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

@UseRowClass(Routine)
class Routines extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get infobox => text()();
  TextColumn get weightUnit => textEnum<Weights>()();
  TextColumn get distanceUnit => textEnum<Distance>()();
  IntColumn get sortOrder => integer()();
  TextColumn get folderId =>
      text().nullable().references(RoutineFolders, #id)();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

@UseRowClass(RoutineExercise)
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

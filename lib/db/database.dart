import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/history.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/exercisable.dart' as model;
import 'package:gymtracker/model/exercise.dart' as model;
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart' as model;
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/service/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

// Used in the generated code
const _uuid = Uuid();

const DATABASE_VERSION = 2;

@DriftDatabase(tables: [
  CustomExercises,
  HistoryWorkouts,
  HistoryWorkoutExercises,
  Routines,
  RoutineExercises,
])
class GTDatabase extends _$GTDatabase {
  GTDatabase() : super(_openConnection());

  @override
  int get schemaVersion => DATABASE_VERSION;

  Stream<List<model.Workout>> getAllRoutines() {
    logger.d("Getting all routines");

    final query = select(routines)
      ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]);
    final cartStream = query.watch();

    return cartStream.switchMap((routines) {
      final idToRoutine = {for (var routine in routines) routine.id: routine};
      final ids = idToRoutine.keys;

      final entryQuery = select(routineExercises)
        ..where((routineExercises) => routineExercises.routineId.isIn(ids));

      return entryQuery.watch().map((rows) {
        final idToItems = <String, List<RoutineExercise>>{};

        for (final row in rows) {
          idToItems.putIfAbsent(row.routineId, () => []).add(row);
        }

        return [
          for (var id in ids)
            _workoutFromRoutineData(idToRoutine[id]!, idToItems[id] ?? []),
        ];
      });
    });
  }

  Future<model.Workout> getRoutine(String id) async {
    final routine =
        await (select(routines)..where((tbl) => tbl.id.equals(id))).getSingle();

    final rawExercises = await (select(routineExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return _workoutFromRoutineData(routine, rawExercises);
  }

  Future<void> insertRoutine(model.Workout routine) async {
    return batch((batch) {
      batch.insert(
        routines,
        routine.toRoutineInsertable(),
      );
      batch.insertAll(
        routineExercises,
        routine.exercises.toSortedRoutineExerciseInsertables(),
      );
    });
  }

  Future<void> deleteRoutine(String id) async {
    await (delete(routines)..where((tbl) => tbl.id.equals(id))).go();
    await (delete(routineExercises)..where((tbl) => tbl.routineId.equals(id)))
        .go();
  }

  Future<void> updateRoutine(model.Workout routine) async {
    return batch((batch) {
      batch.replace(
        routines,
        routine.toRoutineInsertable(),
      );
      batch.deleteWhere(
          routineExercises, (tbl) => tbl.routineId.equals(routine.id));
      batch.insertAll(
        routineExercises,
        routine.exercises.toSortedRoutineExerciseInsertables(),
      );
    });
  }

  Stream<List<model.Workout>> getAllHistoryWorkouts() {
    logger.d("Getting all history workouts");

    final query = select(historyWorkouts)
      ..orderBy([
        (r) => OrderingTerm(expression: r.startingDate, mode: OrderingMode.desc)
      ]);
    final historyStream = query.watch();

    return historyStream.switchMap((history) {
      final idToWorkout = {for (var workout in history) workout.id: workout};
      final ids = idToWorkout.keys;

      final entryQuery = select(historyWorkoutExercises)
        ..where((tbl) => tbl.routineId.isIn(ids));

      return entryQuery.watch().map((rows) {
        final idToItems = <String, List<HistoryWorkoutExercise>>{};

        for (final row in rows) {
          idToItems.putIfAbsent(row.routineId, () => []).add(row);
        }
        return [
          for (var id in ids)
            _historyWorkoutFromData(idToWorkout[id]!, idToItems[id] ?? []),
        ];
      });
    });
  }

  Future<List<model.Workout>> getAllHistoryWorkoutsFuture() =>
      getAllHistoryWorkouts().first;

  Future<model.Workout> getHistoryWorkout(String id) async {
    final workout = await (select(historyWorkouts)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    final rawExercises = await (select(historyWorkoutExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return _historyWorkoutFromData(workout, rawExercises);
  }

  Future<void> insertHistoryWorkout(model.Workout workout) async {
    return batch((batch) {
      batch.insert(
        historyWorkouts,
        workout.toHistoryWorkoutInsertable(),
      );
      batch.insertAll(
        historyWorkoutExercises,
        workout.exercises.toSortedHistoryWorkoutInsertables(),
      );
    });
  }

  Future<void> deleteHistoryWorkout(String id) async {
    await (delete(historyWorkouts)..where((tbl) => tbl.id.equals(id))).go();
    await (delete(historyWorkoutExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .go();
  }

  Future<void> updateHistoryWorkout(model.Workout workout) async {
    return batch((batch) {
      batch.replace(
        historyWorkouts,
        workout.toHistoryWorkoutInsertable(),
      );
      batch.deleteWhere(
          historyWorkoutExercises, (tbl) => tbl.routineId.equals(workout.id));
      batch.insertAll(
        historyWorkoutExercises,
        workout.exercises.toSortedHistoryWorkoutInsertables(),
      );
    });
  }

  Stream<List<model.Exercise>> getAllCustomExercises() {
    logger.d("Getting all custom exercises");
    return select(customExercises).watch().map((rows) {
      return [for (final row in rows) exerciseFromData(row)];
    });
  }

  Future<void> insertCustomExercise(model.Exercise exercise) async {
    await into(customExercises).insert(exercise.toInsertable());
  }

  Future<void> deleteCustomExercise(String id) async {
    await (delete(customExercises)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateCustomExercise(model.Exercise exercise) async {
    await (update(customExercises).replace(exercise.toInsertable()));
  }

  model.Workout _workoutFromRoutineData(
      Routine routine, List<RoutineExercise> rawExercises) {
    final entries = databaseRoutineExercisesToExercises(rawExercises);

    return model.Workout(
      id: routine.id,
      name: routine.name,
      exercises: entries,
      duration: null,
      startingDate: null,
      parentID: null,
      infobox: routine.infobox,
      completedBy: null,
      completes: null,
      weightUnit: routine.weightUnit,
      distanceUnit: routine.distanceUnit,
    );
  }

  model.Workout _historyWorkoutFromData(
      HistoryWorkout routine, List<HistoryWorkoutExercise> rawExercises) {
    final entries = databaseHistoryWorkoutExercisesToExercises(rawExercises);

    return model.Workout(
      id: routine.id,
      name: routine.name,
      exercises: entries,
      duration: Duration(seconds: routine.duration),
      startingDate: routine.startingDate,
      parentID: routine.parentId,
      infobox: routine.infobox,
      completedBy: routine.completedBy,
      completes: routine.completes,
      weightUnit: routine.weightUnit,
      distanceUnit: routine.distanceUnit,
    );
  }

  Future clearTheWholeThingIAmAbsolutelySureISwear() async {
    await customExercises.deleteAll();
    await routines.deleteAll();
    await routineExercises.deleteAll();
    await historyWorkouts.deleteAll();
    await historyWorkoutExercises.deleteAll();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    globalLogger.d("[GTDatabase] Opening database at ${file.path}");

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    globalLogger.d("[GTDatabase] Temporary directory: $cachebase");

    return NativeDatabase.createInBackground(file);
  });
}

model.Exercise exerciseFromData(CustomExercise row) {
  return model.Exercise.raw(
    id: row.id,
    name: row.name,
    parameters: row.parameters,
    primaryMuscleGroup: row.primaryMuscleGroup,
    secondaryMuscleGroups: row.secondaryMuscleGroups,
    standard: false,
    parentID: null,
    supersetID: null,
    restTime: Duration.zero,
    notes: "",
    sets: [],
    workoutID: null,
  );
}

extension WorkoutListDatabaseUtils on List<model.Workout> {
  List<RoutinesCompanion> toSortedRoutineInsertables() {
    return [
      for (int i = 0; i < length; i++)
        this[i].toRoutineInsertable().copyWith(sortOrder: Value(i)),
    ];
  }

  List<HistoryWorkoutsCompanion> toSortedHistoryWorkoutInsertables() {
    return [
      for (int i = 0; i < length; i++) this[i].toHistoryWorkoutInsertable(),
    ];
  }
}

extension WorkoutDatabaseUtils on model.Workout {
  RoutinesCompanion toRoutineInsertable() {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(infobox ?? ""),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
    );
  }

  HistoryWorkoutsCompanion toHistoryWorkoutInsertable() {
    return HistoryWorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(infobox ?? ""),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      startingDate: Value(startingDate!),
      duration: Value(duration!.inSeconds),
      parentId: Value(parentID),
      completedBy: Value(completedBy),
      completes: Value(completes),
    );
  }
}

extension WorkoutExercisableListDatabaseUtils
    on List<model.WorkoutExercisable> {
  List<RoutineExercisesCompanion> toSortedRoutineExerciseInsertables() {
    return [
      for (int i = 0; i < length; i++)
        this[i].toRoutineExercise().copyWith(sortOrder: Value(i)),
    ];
  }

  List<HistoryWorkoutExercisesCompanion> toSortedHistoryWorkoutInsertables() {
    return [
      for (int i = 0; i < length; i++)
        this[i].toHistoryWorkoutExercise().copyWith(sortOrder: Value(i)),
    ];
  }
}

extension WorkoutExercisableDatabaseUtils on model.WorkoutExercisable {
  RoutineExercisesCompanion toRoutineExercise() {
    return RoutineExercisesCompanion(
      id: Value(id),
      routineId: Value(workoutID!),
      name: this is model.Exercise ? Value(asExercise.name) : const Value(""),
      parameters: this is model.Exercise
          ? Value(asExercise.parameters)
          : const Value.absent(),
      sets: Value(sets),
      primaryMuscleGroup: this is model.Exercise
          ? Value(asExercise.primaryMuscleGroup)
          : const Value.absent(),
      secondaryMuscleGroups: this is model.Exercise
          ? Value(asExercise.secondaryMuscleGroups)
          : const Value.absent(),
      restTime: Value(restTime.inSeconds),
      isCustom: this is model.Exercise
          ? Value(asExercise.isCustom)
          : const Value(false),
      libraryExerciseId: this is model.Exercise && asExercise.standard
          ? Value(asExercise.parentID)
          : const Value.absent(),
      customExerciseId: this is model.Exercise && !asExercise.standard
          ? Value(asExercise.id)
          : const Value.absent(),
      notes: Value(notes),
      isSuperset: Value(this is model.Superset),
      isInSuperset: this is model.Exercise
          ? Value(asExercise.isInSuperset)
          : const Value(false),
      supersetId: this is model.Exercise
          ? Value(asExercise.supersetID)
          : const Value.absent(),
    );
  }

  HistoryWorkoutExercisesCompanion toHistoryWorkoutExercise() {
    return HistoryWorkoutExercisesCompanion(
      id: Value(id),
      routineId: Value(workoutID!),
      name: this is model.Exercise ? Value(asExercise.name) : const Value(""),
      parameters: this is model.Exercise
          ? Value(asExercise.parameters)
          : const Value.absent(),
      sets: Value(sets),
      primaryMuscleGroup: this is model.Exercise
          ? Value(asExercise.primaryMuscleGroup)
          : const Value.absent(),
      secondaryMuscleGroups: this is model.Exercise
          ? Value(asExercise.secondaryMuscleGroups)
          : const Value.absent(),
      restTime: Value(restTime.inSeconds),
      isCustom: this is model.Exercise
          ? Value(asExercise.isCustom)
          : const Value(false),
      libraryExerciseId: this is model.Exercise && asExercise.standard
          ? Value(asExercise.parentID)
          : const Value.absent(),
      customExerciseId: this is model.Exercise && !asExercise.standard
          ? Value(asExercise.id)
          : const Value.absent(),
      notes: Value(notes),
      isSuperset: Value(this is model.Superset),
      isInSuperset: this is model.Exercise
          ? Value(asExercise.isInSuperset)
          : const Value(false),
      supersetId: this is model.Exercise
          ? Value(asExercise.supersetID)
          : const Value.absent(),
    );
  }
}

extension ExerciseDatabaseUtils on model.Exercise {
  CustomExercisesCompanion toInsertable() {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      parameters: Value(parameters),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
    );
  }
}

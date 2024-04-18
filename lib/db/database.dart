import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/history.dart';
import 'package:gymtracker/db/model/tables/measurements.dart';
import 'package:gymtracker/db/model/tables/ongoing.dart';
import 'package:gymtracker/db/model/tables/preferences.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/exercisable.dart' as model;
import 'package:gymtracker/model/exercise.dart' as model;
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart' as model;
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
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
  Preferences,
  OngoingData,
  WeightMeasurements,
])
class GTDatabase extends _$GTDatabase {
  GTDatabase.prod() : super(_openConnection());

  @visibleForTesting
  GTDatabase.withQueryExecutor(super.e);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(preferences).insert(Prefs.defaultValue);
        },
      );

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
        final idToItems = <String, List<ConcreteExercise>>{};

        for (final row in rows) {
          idToItems.putIfAbsent(row.routineId, () => []).add(row);
        }

        return [
          for (var id in ids)
            _workoutFromDatabase(idToRoutine[id]!, idToItems[id] ?? []),
        ];
      });
    });
  }

  Future<List<model.Workout>> getAllRoutinesFuture() => getAllRoutines().first;

  Future<model.Workout> getRoutine(String id) async {
    final routine =
        await (select(routines)..where((tbl) => tbl.id.equals(id))).getSingle();

    final rawExercises = await (select(routineExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return _workoutFromDatabase(routine, rawExercises);
  }

  Future<void> insertRoutine(model.Workout routine) async {
    final newSortOrder = await routines.count().getSingle();
    return batch((batch) {
      batch.insert(
        routines,
        routine.toRoutineInsertable().copyWith(sortOrder: Value(newSortOrder)),
      );
      batch.insertAll(
        routineExercises,
        routine.flattenedExercises.toSortedInsertables(),
      );
    });
  }

  Future<void> deleteRoutine(String id) async {
    final remainingIDs = (await (select(routines)
          ..where((tbl) => tbl.id.isNotValue(id))
          ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
        .get());
    final idToSortOrder = {
      for (int i = 0; i < remainingIDs.length; i++) remainingIDs[i].id: i
    };
    return batch((batch) {
      batch.deleteWhere(routines, (tbl) => tbl.id.equals(id));
      batch.deleteWhere(routineExercises, (tbl) => tbl.routineId.equals(id));
      for (final entry in idToSortOrder.entries) {
        batch.update(
          routines,
          RoutinesCompanion(sortOrder: Value(entry.value)),
          where: (tbl) => tbl.id.equals(entry.key),
        );
      }
    });
  }

  Future<void> updateRoutine(model.Workout routine) async {
    final sortOrder = (await (select(routines)
              ..where((tbl) => tbl.id.equals(routine.id)))
            .getSingle())
        .sortOrder;
    return batch((batch) {
      // batch.deleteWhere(routines, (tbl) => tbl.id.equals(routine.id));
      batch.replace(
        routines,
        routine.toRoutineInsertable().copyWith(sortOrder: Value(sortOrder)),
      );
      batch.deleteWhere(
          routineExercises, (tbl) => tbl.routineId.equals(routine.id));
      batch.insertAll(
        routineExercises,
        routine.flattenedExercises.toSortedInsertables(),
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
        final idToItems = <String, List<ConcreteExercise>>{};

        for (final row in rows) {
          idToItems.putIfAbsent(row.routineId, () => []).add(row);
        }
        return [
          for (var id in ids)
            _historyWorkoutFromDatabase(idToWorkout[id]!, idToItems[id] ?? []),
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

    return _historyWorkoutFromDatabase(workout, rawExercises);
  }

  Future<void> insertHistoryWorkout(model.Workout workout) async {
    logger.e(workout);
    logger.e(workout.toHistoryWorkoutInsertable());
    logger.e(workout.flattenedExercises.toSortedInsertables());
    return batch((batch) {
      batch.insert(
        historyWorkouts,
        workout.toHistoryWorkoutInsertable(),
      );
      batch.insertAll(
        historyWorkoutExercises,
        workout.flattenedExercises.toSortedInsertables(),
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
        workout.flattenedExercises.toSortedInsertables(),
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

  model.Workout _workoutFromDatabase(
      Routine routine, List<ConcreteExercise> rawExercises) {
    final entries = databaseExercisesToExercises(rawExercises);

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

  model.Workout _historyWorkoutFromDatabase(
      HistoryWorkout routine, List<ConcreteExercise> rawExercises) {
    final entries = databaseExercisesToExercises(rawExercises);

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

  Stream<Prefs> watchPreferences() {
    return select(preferences)
        .watch()
        .map((l) => l.isEmpty ? Prefs.defaultValue : Prefs.fromDatabase(l[0]));
  }

  Future<void> setPreferences(Prefs prefs) {
    return transaction(() async {
      await delete(preferences).go();
      await into(preferences).insert(prefs);
    });
  }

  Stream<Map<String, dynamic>?> watchOngoing() {
    return select(ongoingData).watch().map((l) {
      if (l.isEmpty) return null;
      return jsonDecode(l[0].data);
    });
  }

  Future<void> setOngoing(Map<String, dynamic> ongoing) {
    return transaction(() async {
      await deleteOngoing();
      await into(ongoingData)
          .insert(OngoingDataCompanion(data: Value(jsonEncode(ongoing))));
    });
  }

  Future deleteOngoing() {
    return delete(ongoingData).go();
  }

  Stream<List<WeightMeasurement>> watchWeightMeasurements() {
    final query = select(weightMeasurements)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
    return query.watch();
  }

  Future<void> insertWeightMeasurement(WeightMeasurement measurement) {
    return into(weightMeasurements).insert(measurement);
  }

  Future<void> deleteWeightMeasurement(String id) {
    return (delete(weightMeasurements)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateWeightMeasurement(WeightMeasurement measurement) {
    return (update(weightMeasurements).replace(measurement));
  }

  Future<void> setWeightMeasurements(List<WeightMeasurement> measurements) {
    return transaction(() async {
      await delete(weightMeasurements).go();
      await batch((batch) {
        for (final measurement in measurements) {
          batch.insert(weightMeasurements, measurement);
        }
      });
    });
  }

  Future clearTheWholeThingIAmAbsolutelySureISwear() async {
    for (var table in allTables) {
      await table.deleteAll();
    }
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
  List<UpdateCompanion<ConcreteExercise>> toSortedInsertables() {
    return [
      for (int i = 0; i < length; i++)
        this[i].toInsertable().copyWith(sortOrder: Value(i)),
    ];
  }
}

extension WorkoutExercisableDatabaseUtils on model.WorkoutExercisable {
  HistoryWorkoutExercisesCompanion toInsertable() {
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
          ? Value(asExercise.parentID)
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
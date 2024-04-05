import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/api/exercise.dart';
import 'package:gymtracker/db/model/api/routine.dart';
import 'package:gymtracker/db/model/api/set.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/history.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

export 'package:gymtracker/db/model/api/exercise.dart';
export 'package:gymtracker/db/model/api/routine.dart';
export 'package:gymtracker/db/model/api/set.dart';

part 'database.g.dart';

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

  Stream<List<GTRoutine>> getAllRoutines() {
    // start by watching all carts
    final cartStream = select(routines).watch();

    return cartStream.switchMap((routines) {
      // this method is called whenever the list of carts changes. For each
      // cart, now we want to load all the items in it.
      // (we create a map from id to cart here just for performance reasons)
      final idToRoutine = {for (var routine in routines) routine.id: routine};
      final ids = idToRoutine.keys;

      // select all entries that are included in any cart that we found
      final entryQuery = select(routineExercises)
        ..where((routineExercises) => routineExercises.routineId.isIn(ids));

      return entryQuery.watch().map((rows) {
        // Store the list of entries for each cart, again using maps for faster
        // lookups.
        final idToItems = <int, List<RoutineExercise>>{};

        // for each entry (row) that is included in a cart, put it in the map
        // of items.
        for (final row in rows) {
          idToItems.putIfAbsent(row.routineId, () => []).add(row);
        }

        // finally, all that's left is to merge the map of carts with the map of
        // entries
        return [
          for (var id in ids)
            _routineFromData(idToRoutine[id]!, idToItems[id] ?? []),
        ];
      });
    });
  }

  Future<GTRoutine> getRoutine(int id) async {
    final routine =
        await (select(routines)..where((tbl) => tbl.id.equals(id))).getSingle();

    final rawExercises = await (select(routineExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return _routineFromData(routine, rawExercises);
  }

  Future<void> insertRoutine(GTRoutine routine) async {
    return batch((batch) {
      batch.insert(
        routines,
        routine.toInsertable(),
      );
      batch.insertAll(
        routineExercises,
        [for (final ex in routine.exercises) ex.toRoutineExercise()],
      );
    });
  }

  Future<void> deleteRoutine(int id) async {
    await (delete(routines)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateRoutine(GTRoutine routine) async {
    return batch((batch) {
      batch.update(
        routines,
        routine.toInsertable(),
      );
      for (final ex in routine.exercises) {
        batch.update(
          routineExercises,
          ex.toRoutineExercise(),
        );
      }
    });
  }

  Stream<List<GTHistoryWorkout>> getAllHistoryWorkouts() {
    final cartStream = select(historyWorkouts).watch();

    return cartStream.switchMap((workout) {
      final idToWorkout = {for (var workout in workout) workout.id: workout};
      final ids = idToWorkout.keys;

      final entryQuery = select(historyWorkoutExercises)
        ..where((tbl) => tbl.routineId.isIn(ids));

      return entryQuery.watch().map((rows) {
        final idToItems = <int, List<HistoryWorkoutExercise>>{};

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

  Future<GTHistoryWorkout> getHistoryWorkout(int id) async {
    final workout = await (select(historyWorkouts)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    final rawExercises = await (select(historyWorkoutExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return _historyWorkoutFromData(workout, rawExercises);
  }

  Future<void> insertHistoryWorkout(GTHistoryWorkout workout) async {
    return batch((batch) {
      batch.insert(
        historyWorkouts,
        workout.toInsertable(),
      );
      batch.insertAll(
        historyWorkoutExercises,
        [for (final ex in workout.exercises) ex.toHistoryWorkoutExercise()],
      );
    });
  }

  Future<void> deleteHistoryWorkout(int id) async {
    await (delete(historyWorkouts)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateHistoryWorkout(GTHistoryWorkout workout) async {
    return batch((batch) {
      batch.update(
        historyWorkouts,
        workout.toInsertable(),
      );
      for (final ex in workout.exercises) {
        batch.update(
          historyWorkoutExercises,
          ex.toHistoryWorkoutExercise(),
        );
      }
    });
  }

  Stream<List<GTLibraryExercise>> getAllCustomExercises() {
    return select(customExercises).watch().map((rows) {
      return [for (final row in rows) GTLibraryExercise.fromData(row)];
    });
  }

  Future<void> insertCustomExercise(GTLibraryExercise exercise) async {
    await into(customExercises).insert(exercise.toInsertable());
  }

  Future<void> deleteCustomExercise(int id) async {
    await (delete(customExercises)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateCustomExercise(GTLibraryExercise exercise) async {
    await (update(customExercises).replace(exercise.toInsertable()));
  }

  GTRoutine _routineFromData(
      Routine routine, List<RoutineExercise> rawExercises) {
    final entries = databaseRoutineExercisesToExercises(rawExercises);

    return GTRoutine(
      id: routine.id,
      name: routine.name,
      exercises: entries,
      notes: routine.infobox,
      weightUnit: routine.weightUnit,
      distanceUnit: routine.distanceUnit,
      sortOrder: routine.sortOrder,
    );
  }

  GTHistoryWorkout _historyWorkoutFromData(
      HistoryWorkout routine, List<HistoryWorkoutExercise> rawExercises) {
    final entries = databaseHistoryWorkoutExercisesToExercises(rawExercises);

    return GTHistoryWorkout(
      id: routine.id,
      name: routine.name,
      notes: routine.infobox ?? '',
      weightUnit: routine.weightUnit,
      distanceUnit: routine.distanceUnit,
      exercises: entries,
      sortOrder: routine.sortOrder,
      startingDate: routine.startingDate,
      duration: Duration(seconds: routine.duration),
      parentID: routine.parentId,
      completedByID: routine.completedBy,
      completesID: routine.completes,
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

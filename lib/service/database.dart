import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/adapters/builtin.dart' as builtin_adapters;
import 'package:gymtracker/adapters/distance.dart';
import 'package:gymtracker/adapters/exercise.dart';
import 'package:gymtracker/adapters/measurements.dart';
import 'package:gymtracker/adapters/set.dart';
import 'package:gymtracker/adapters/superset.dart';
import 'package:gymtracker/adapters/weights.dart';
import 'package:gymtracker/adapters/workout.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService extends GetxService with ChangeNotifier {
  late final GTDatabase db;

  final exercises$ = BehaviorSubject<List<Exercise>>.seeded([]);
  final routines$ = BehaviorSubject<List<Workout>>.seeded([]);
  final history$ = BehaviorSubject<List<Workout>>.seeded([]);

  late final Box<dynamic> settingsBox;
  late final Box<String> ongoingBox;
  late final Box<WeightMeasurement> weightMeasurementsBox;

  writeSetting<T>(String key, T value) {
    settingsBox.put(key, value);
    notifyListeners();
  }

  readSetting<T>(String key) {
    return settingsBox.get(key) as T?;
  }

  @override
  onInit() {
    super.onInit();

    db = GTDatabase();

    db.getAllRoutines()
      ..pipe(routines$)
      ..listen((_) => onServiceChange("routines")());
    db.getAllCustomExercises()
      ..pipe(exercises$)
      ..listen((_) => onServiceChange("exercises")());
    db.getAllHistoryWorkouts()
      ..pipe(history$)
      ..listen((_) => onServiceChange("history")());

    onServiceChange("main")();
    settingsBox.listenable().addListener(onServiceChange("settings"));
    ongoingBox.listenable().addListener(onServiceChange("ongoing"));
    weightMeasurementsBox
        .listenable()
        .addListener(onServiceChange("weightMeasurements"));
  }

  Future ensureInitialized() async {
    await Hive.initFlutter();
    if (kDebugMode) {
      final appDir = await getApplicationDocumentsDirectory();
      logger.i("Loaded Hive in $appDir");
    }

    return _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    builtin_adapters.registerAll();
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(MuscleGroupAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(SupersetAdapter());
    Hive.registerAdapter(SetKindAdapter());
    Hive.registerAdapter(SetParametersAdapter());
    Hive.registerAdapter(ExSetAdapter());
    Hive.registerAdapter(WeightsAdapter());
    Hive.registerAdapter(WeightMeasurementAdapter());
    Hive.registerAdapter(DistanceAdapter());

    settingsBox = await Hive.openBox("settings");
    ongoingBox = await Hive.openBox<String>("ongoing");
    weightMeasurementsBox =
        await Hive.openBox<WeightMeasurement>("weightMeasurements");
  }

  @visibleForTesting
  Future ensureInitializedForTests() async {
    await Hive.initFlutter("test");
    await _ensureInitialized();
  }

  @visibleForTesting
  Future teardown() async {
    logger.t("!!! Tearing down");
    await settingsBox.clear();
    await ongoingBox.clear();
    // ignore: invalid_use_of_visible_for_testing_member
    Hive.resetAdapters();
  }

  void Function() onServiceChange(String service) {
    return () {
      logger.d("$service service updated");
    };
  }

  @override
  notifyListeners() {
    super.notifyListeners();
    logger.d("Notified listeners");
  }

  List<Exercise> get exercises {
    return exercises$.value;
  }

  @visibleForTesting
  writeExercises(List<Exercise> exercises) {
    db.batch((batch) {
      batch.logger.i("Importing exercises");
      batch.deleteAll(db.customExercises);
      batch.insertAll(
        db.customExercises,
        [for (final ex in exercises) ex.toInsertable()],
      );
    });
  }

  setExercise(Exercise exercise) {
    if (exercises.any((element) => element.id == exercise.id)) {
      db.updateCustomExercise(exercise);
    } else {
      db.insertCustomExercise(exercise);
    }
  }

  removeExercise(Exercise exercise) {
    db.deleteCustomExercise(exercise.id);
  }

  List<Workout> get routines {
    return routines$.value;
  }

  _writeRoutines(List<Workout> routines) {
    db.batch((batch) {
      batch.logger.i("Importing routines");
      batch.deleteAll(db.routines);
      batch.insertAll(
        db.routines,
        routines.toSortedRoutineInsertables(),
      );

      final allExercises = routines
          .expand((r) => r.exercises)
          .map((e) => e.map(
                exercise: (ex) => [ex],
                superset: (ss) => [ss, ...ss.exercises],
              ))
          .expand((e) => e)
          .toList();

      batch.deleteAll(db.routineExercises);
      batch.insertAll(
        db.routineExercises,
        allExercises.toSortedRoutineExerciseInsertables(),
      );
    });
  }

  setAllRoutines(List<Workout> routines) {
    _writeRoutines(routines);
    notifyListeners();
  }

  setRoutine(Workout routine) {
    if (routines.any((element) => element.id == routine.id)) {
      fixWorkout(routine);
      db.updateRoutine(routine);
    } else {
      fixWorkout(routine);
      db.insertRoutine(routine);
    }
  }

  removeRoutine(Workout routine) {
    db.deleteRoutine(routine.id);
  }

  bool hasRoutine(String id) {
    return routines.any((element) => element.id == id);
  }

  List<Workout> get workoutHistory {
    return history$.value;
  }

  writeAllHistory(List<Workout> history) {
    db.batch((batch) {
      batch.logger.i("Importing routines");
      batch.deleteAll(db.historyWorkouts);
      batch.insertAll(
        db.historyWorkouts,
        routines.toSortedHistoryWorkoutInsertables(),
      );

      final allExercises = routines
          .expand((r) => r.exercises)
          .map((e) => e.map(
                exercise: (ex) => [ex],
                superset: (ss) => [ss, ...ss.exercises],
              ))
          .expand((e) => e)
          .toList();

      batch.deleteAll(db.historyWorkoutExercises);
      batch.insertAll(
        db.historyWorkoutExercises,
        allExercises.toSortedHistoryWorkoutInsertables(),
      );
    });
  }

  Future setHistoryWorkout(Workout workout) async {
    if (workoutHistory.any((element) => element.id == workout.id)) {
      fixWorkout(workout);
      await db.updateHistoryWorkout(workout);
    } else {
      fixWorkout(workout);
      await db.insertHistoryWorkout(workout);
    }
  }

  removeHistoryWorkout(Workout workout) {
    removeHistoryWorkoutById(workout.id);
  }

  Future removeHistoryWorkoutById(String id) async {
    await db.deleteHistoryWorkout(id);
  }

  Workout? getHistoryWorkout(String id) {
    return workoutHistory.firstWhereOrNull((element) => element.id == id);
  }

  bool hasHistoryWorkout(String id) {
    return workoutHistory.any((element) => element.id == id);
  }

  _writeWeightMeasurements(List<WeightMeasurement> weightMeasurements) {
    weightMeasurementsBox.clear().then((_) {
      weightMeasurementsBox.putAll({
        for (final measurement in weightMeasurements)
          measurement.id: measurement,
      }).then((value) => notifyListeners());
    });
  }

  getWeightMeasurement(String measurementID) {
    return weightMeasurementsBox.get(measurementID);
  }

  setWeightMeasurement(WeightMeasurement measurement) {
    weightMeasurementsBox
        .put(measurement.id, measurement)
        .then((value) => notifyListeners());
  }

  removeWeightMeasurement(WeightMeasurement measurement) {
    weightMeasurementsBox
        .delete(measurement.id)
        .then((value) => notifyListeners());
  }

  toJson() {
    final converter = getConverter(DATABASE_VERSION);

    return converter.export(DatabaseSnapshot(
      customExercises: exercises,
      routines: routines,
      routineExercises: routines.flattenedExercises,
      historyWorkouts: workoutHistory,
      historyWorkoutExercises: workoutHistory.flattenedExercises,
    ));
  }

  Future fromJson(Map<String, dynamic> json) async {
    final previousJson = toJson();

    if (json['version'] is int && (json['version'] as int) > DATABASE_VERSION) {
      throw DatabaseImportVersionMismatch((json['version'] as int? ?? -1));
    }

    Future innerImportJson(Map<String, dynamic> json) async {
      final converter =
          getConverter(json['version'] as int? ?? DATABASE_VERSION);
      final snapshot = converter.process(json);

      await db.transaction(() async {
        await db.clearTheWholeThingIAmAbsolutelySureISwear();

        logger.i("Created import transaction");
        await db.batch(
          (batch) {
            batch.logger.i("Importing exercises");
            batch.insertAll(
              db.customExercises,
              [for (final ex in snapshot.customExercises) ex.toInsertable()],
            );
          },
        );

        await db.batch((batch) {
          batch.logger.i("Importing routines");
          batch.insertAll(
            db.routines,
            snapshot.routines.toSortedRoutineInsertables(),
          );

          batch.insertAll(
            db.routineExercises,
            snapshot.routineExercises.toSortedRoutineExerciseInsertables(),
          );
        });

        await db.batch((batch) {
          batch.logger.i("Importing history");

          batch.insertAll(
            db.historyWorkouts,
            snapshot.historyWorkouts.toSortedHistoryWorkoutInsertables(),
          );

          batch.insertAll(
            db.historyWorkoutExercises,
            snapshot.historyWorkoutExercises
                .toSortedHistoryWorkoutInsertables(),
          );
        });
      });
    }

    try {
      await innerImportJson(json);
    } catch (_) {
      await innerImportJson(previousJson);
      rethrow;
    }
  }

  void writeToOngoing(Map<String, dynamic> data) {
    logger.i("Requested write of ongoing workout data");
    logger.d("Ongoing data: ${jsonEncode(data)}");
    ongoingBox.put("data", jsonEncode(data));
  }

  Map<String, dynamic>? getOngoingData() {
    if (!hasOngoing) return null;
    return jsonDecode(ongoingBox.get("data") ?? "null");
  }

  void deleteOngoing() {
    logger.i("Requested deletion of ongoing workout data");
    ongoingBox.delete("data");
  }

  bool get hasOngoing => ongoingBox.containsKey("data");

  void transaction<T>(Future<T> Function() action) async {
    await db.transaction(action);
  }
}

class DatabaseImportVersionMismatch implements Exception {
  final int version;

  DatabaseImportVersionMismatch(this.version);

  @override
  String toString() {
    return "Trying to import a newer version of the database: $version (current version: $DATABASE_VERSION)";
  }
}

void fixWorkout(Workout workout) {
  for (final exercise in workout.exercises) {
    exercise.when(exercise: (ex) {
      ex.workoutID = workout.id;
      ex.supersetID = null;
    }, superset: (ss) {
      ss.workoutID = workout.id;
      for (final ex in ss.exercises) {
        ex.workoutID = workout.id;
        ex.supersetID = ss.id;
      }
    });
  }
}

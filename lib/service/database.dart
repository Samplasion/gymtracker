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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService extends GetxService with ChangeNotifier {
  late final GTDatabase db;

  late final Box<Exercise> exerciseBox;
  late final Box<Workout> routinesBox;
  late final Box<Workout> historyBox;
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

    db.getAllRoutines().listen((routines) {
      logger.e(routines);
    });

    onServiceChange("main")();
    exerciseBox.listenable().addListener(onServiceChange("exercises"));
    routinesBox.listenable().addListener(onServiceChange("routines"));
    historyBox.listenable().addListener(onServiceChange("history"));
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

    exerciseBox = await Hive.openBox<Exercise>("exercises");
    routinesBox = await Hive.openBox<Workout>("routines");
    historyBox = await Hive.openBox<Workout>("history");
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
    await exerciseBox.clear();
    await routinesBox.clear();
    await historyBox.clear();
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
    return exerciseBox.values.toList();
  }

  _writeExercises(List<Exercise> exercises) {
    exerciseBox.clear().then((_) {
      exerciseBox.putAll({
        for (final exercise in exercises) exercise.id: exercise,
      }).then((value) => notifyListeners());
    });
  }

  setExercise(Exercise exercise) {
    exerciseBox.put(exercise.id, exercise).then((value) => notifyListeners());
  }

  removeExercise(Exercise exercise) {
    exerciseBox.delete(exercise.id).then((value) => notifyListeners());
  }

  List<Workout> get routines {
    return routinesBox.values.toList();
  }

  _writeRoutines(List<Workout> routines) {
    routinesBox.clear().then((_) {
      routinesBox.addAll(routines).then((value) => notifyListeners());
    });
  }

  setAllRoutines(List<Workout> routines) {
    _writeRoutines(routines);
    notifyListeners();
  }

  setRoutine(Workout routine) {
    final idx = [...routinesBox.values].indexWhere((r) => r.id == routine.id);
    if (idx >= 0) {
      routinesBox.putAt(idx, routine).then((value) => notifyListeners());
    } else {
      routinesBox.add(routine).then((value) => notifyListeners());
    }
  }

  removeRoutine(Workout routine) {
    final idx = [...routinesBox.values].indexWhere((r) => r.id == routine.id);
    if (idx >= 0) {
      routinesBox.deleteAt(idx).then((value) => notifyListeners());
    }
  }

  bool hasRoutine(String id) {
    return [...routinesBox.values].indexWhere((r) => r.id == id) >= 0;
  }

  List<Workout> get workoutHistory {
    return historyBox.values.toList();
  }

  writeAllHistory(List<Workout> history) {
    historyBox.clear().then((_) {
      historyBox.putAll({
        for (final workout in history) workout.id: workout,
      }).then((value) => notifyListeners());
    });
  }

  setHistoryWorkout(Workout workout) {
    historyBox.put(workout.id, workout).then((value) => notifyListeners());
  }

  removeHistoryWorkout(Workout workout) {
    removeHistoryWorkoutById(workout.id);
  }

  removeHistoryWorkoutById(String id) {
    historyBox.delete(id).then((value) => notifyListeners());
  }

  Workout? getHistoryWorkout(String id) {
    return historyBox.get(id);
  }

  bool hasHistoryWorkout(String id) {
    return historyBox.containsKey(id);
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
      customExercises: [],
      routines: [],
      routineExercises: [],
      historyWorkouts: [],
      historyWorkoutExercises: [],
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
            [for (final rt in snapshot.routines) rt.toInsertable()],
          );

          batch.insertAll(
            db.routineExercises,
            [
              for (final ex in snapshot.routineExercises) ex.toRoutineExercise()
            ],
          );
        });

        await db.batch((batch) {
          batch.logger.i("Importing history");

          batch.insertAll(
            db.historyWorkouts,
            [for (final rt in snapshot.historyWorkouts) rt.toInsertable()],
          );

          batch.insertAll(
            db.historyWorkoutExercises,
            [
              for (final ex in snapshot.historyWorkoutExercises)
                ex.toHistoryWorkoutExercise()
            ],
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
}

class DatabaseImportVersionMismatch implements Exception {
  final int version;

  DatabaseImportVersionMismatch(this.version);

  @override
  String toString() {
    return "Trying to import a newer version of the database: $version (current version: $DATABASE_VERSION)";
  }
}

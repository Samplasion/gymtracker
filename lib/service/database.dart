import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';

import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart' hide NutritionGoal;
import 'package:gymtracker/struct/nutrition.dart' as gtn;
import 'package:gymtracker/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

const _kMaxBackups = 10;
const _kPeriodicBackupInterval = Duration(days: 1);

class DatabaseService extends GetxService with ChangeNotifier {
  late GTDatabase _db;
  GTDatabase get db => _db;

  final exercises$ = BehaviorSubject<List<Exercise>>.seeded([]);
  final routines$ = BehaviorSubject<List<Workout>>.seeded([]);
  final history$ = BehaviorSubject<List<Workout>>.seeded([]);
  final prefs$ = BehaviorSubject<Prefs>.seeded(Prefs.defaultValue);
  final ongoing$ = BehaviorSubject<Map<String, dynamic>?>.seeded(null);
  final weightMeasurements$ =
      BehaviorSubject<List<WeightMeasurement>>.seeded([]);
  final folders$ = BehaviorSubject<List<GTRoutineFolder>>.seeded([]);
  final foods$ = BehaviorSubject<List<TaggedFood>>.seeded([]);
  final nutritionGoals$ = BehaviorSubject<List<TaggedNutritionGoal>>.seeded([
    TaggedNutritionGoal(
      date: DateTime.now().startOfDay,
      value: gtn.NutritionGoal.defaultGoal,
    ),
  ]);
  final customBarcodeFoods$ = BehaviorSubject<Map<String, Food>>.seeded({});
  final favoriteFoods$ = BehaviorSubject<List<Food>>.seeded([]);
  final nutritionCategories$ =
      BehaviorSubject<DateSequence<Map<String, NutritionCategory>>>.seeded(
          DateSequence.empty());
  final completions$ = BehaviorSubject<List<AchievementCompletion>>.seeded([]);
  final bodyMeasurements$ =
      BehaviorSubject<List<BodyMeasurement>>.seeded([]);

  final backups = _DatabaseBackups();
  BehaviorSubject<List<DatabaseBackup>> get _backups$ => BehaviorSubject();

  eraseAllSubjects() {
    exercises$.add([]);
    routines$.add([]);
    history$.add([]);
    prefs$.add(Prefs.defaultValue);
    ongoing$.add(null);
    weightMeasurements$.add([]);
    folders$.add([]);
    foods$.add([]);
    nutritionGoals$.add([
      TaggedNutritionGoal(
        date: DateTime.now().startOfDay,
        value: gtn.NutritionGoal.defaultGoal,
      ),
    ]);
    customBarcodeFoods$.add({});
    favoriteFoods$.add([]);
    nutritionCategories$.add(DateSequence.empty());
    completions$.add([]);
    bodyMeasurements$.add([]);
  }

  writeSettings(Prefs prefs) {
    _db.setPreferences(prefs);
    notifyListeners();
  }

  @override
  onInit() async {
    super.onInit();

    onDatabaseUpdated("main")();
  }

  Future ensureInitialized({
    Function()? onDone,
    bool overrideInitializationCheck = false,
  }) async {
    _db = GTDatabaseImpl.prod();

    return _innerEnsureInitialized(
      onDone: onDone,
      overrideInitializationCheck: overrideInitializationCheck,
    );
  }

  bool _isInit = false;
  Future<void> _innerEnsureInitialized({
    Function()? onDone,
    bool overrideInitializationCheck = false,
  }) async {
    await backups.init();

    final initialized = [
      "achievements",
      "exercises",
      "routines",
      "history",
      "prefs",
      "ongoing",
      "weightMeasurements",
      "folders",
      "foods",
      "nutritionGoals",
      "customBarcodeFoods",
      "favoriteFoods",
      "nutritionCategories",
      "bodyMeasurements",
    ].map((element) => false).toList();
    check() {
      final shouldCall = !_isInit || overrideInitializationCheck;
      if (initialized.every((element) => element) && shouldCall) {
        _isInit = true;
        onDone?.call();
      }
    }

    Future.microtask(() {
      final b = backups.list();
      _backups$.add(b);
    });

    db.watchAchievementCompletions().listen((event) {
      completions$.add(event);
      onDatabaseUpdated("nutrition categories")();
      initialized[0] = true;
      check();
    });
    _db.getAllCustomExercises().listen((event) {
      exercises$.add(event);
      onDatabaseUpdated("exercises")();
      initialized[1] = true;
      check();
    }, onError: (e, s) {
      logger.e("Error loading exercises", error: e, stackTrace: s);
    });
    _db.getAllRoutines().listen((event) {
      routines$.add(event);
      onDatabaseUpdated("routines")();
      initialized[2] = true;
      check();
    });
    _db.getAllHistoryWorkouts().listen((event) {
      history$.add(event);
      onDatabaseUpdated("history")();
      initialized[3] = true;
      check();
    });
    _db.watchPreferences().listen((prefs) {
      prefs$.add(prefs);
      notifyListeners();
      onDatabaseUpdated("preferences")();
      initialized[4] = true;
      check();
      prefs.logger.i("Changed.");
    });
    _db.watchOngoing().listen((event) {
      ongoing$.add(event);
      onDatabaseUpdated("ongoing")();
      initialized[5] = true;
    });
    _db.watchWeightMeasurements().listen((event) {
      weightMeasurements$.add(event);
      onDatabaseUpdated("weight measurements")();
      initialized[6] = true;
      check();
    });
    _db.watchRoutineFolders().listen((event) {
      folders$.add(event);
      onDatabaseUpdated("folders")();
      initialized[7] = true;
      check();
    });
    _db.watchFoods().listen((event) {
      foods$.add(event);
      onDatabaseUpdated("foods")();
      initialized[8] = true;
      check();
    });
    _db
        .watchNutritionGoals()
        .map((event) => DateSequence.normalized(event).values.toList())
        .listen((event) {
      nutritionGoals$.add(event);
      onDatabaseUpdated("nutrition goals")();
      initialized[9] = true;
      check();
    });
    _db.watchCustomBarcodeFoods().listen((event) {
      customBarcodeFoods$.add(event);
      onDatabaseUpdated("custom barcode foods")();
      initialized[10] = true;
      check();
    });
    _db.watchFavoriteFoods().listen((event) {
      favoriteFoods$.add(event);
      onDatabaseUpdated("favorite foods")();
      initialized[11] = true;
      check();
    });
    _db
        .watchNutritionCategories()
        .map((event) => DateSequence.fromDatesAndValues(event).normalize())
        .listen((event) {
      nutritionCategories$.add(event);
      onDatabaseUpdated("nutrition categories")();
      initialized[12] = true;
      check();
    });
    _db.watchBodyMeasurements().listen((event) {
      bodyMeasurements$.add(event);
      onDatabaseUpdated("body measurements")();
      initialized[13] = true;
      check();
    });
    backups.watch().listen((event) {
      _backups$.add(event);
      logger.i("Backups updated: ${event.length}");
    });
  }

  @visibleForTesting
  Future ensureInitializedForTests(QueryExecutor e) async {
    // We're inside a @visibleForTesting method, so it's fine
    // ignore: invalid_use_of_visible_for_testing_member
    _db = GTDatabaseImpl.withQueryExecutor(e);

    await _innerEnsureInitialized();
  }

  @visibleForTesting
  Future teardown() async {
    logger.t("!!! Tearing down");
    await _db.clearTheWholeThingIAmAbsolutelySureISwear();
  }

  void Function() onDatabaseUpdated(String service) {
    return () {
      logger.t("$service service updated");
    };
  }

  @override
  notifyListeners() {
    super.notifyListeners();
    logger.i("Notified listeners");
  }

  List<Exercise> get exercises {
    return exercises$.value;
  }

  /// This method is only public for testing purposes.
  @visibleForTesting
  Future<void> writeExercises(List<Exercise> exercises) {
    return _db.writeAllCustomExercises(exercises);
  }

  Future<void> setExercise(Exercise exercise) {
    if (exercises.any((element) => element.id == exercise.id)) {
      return _db.updateCustomExercise(exercise);
    } else {
      return _db.insertCustomExercise(exercise);
    }
  }

  Future<void> addExercises(List<Exercise> customExercises) async {
    if (customExercises.isEmpty) return;

    final allExercises = exercises + customExercises;
    return writeExercises(allExercises);
  }

  removeExercise(Exercise exercise) {
    _db.deleteCustomExercise(exercise.id);
  }

  List<Workout> get routines {
    return routines$.value;
  }

  Future _writeRoutines(List<Workout> routines) {
    return _db.writeAllRoutines(routines);
  }

  setAllRoutines(List<Workout> routines) {
    return _writeRoutines(routines).then((_) => notifyListeners());
  }

  setRoutine(Workout routine) async {
    logger.i("Setting routine");
    logger.d(
        "Do we have it already? ${routines.any((element) => element.id == routine.id)}");
    if (routines.any((element) => element.id == routine.id)) {
      await _db.updateRoutine(fixWorkout(routine));
    } else {
      await _db.insertRoutine(fixWorkout(routine));
    }
    if (routine.folder != null) {
      logger.i("Routine has a folder: ${routine.folder}");
      final oldFolder = folders$.value
          .firstWhereOrNull((element) => element.id == routine.folder!.id);
      logger.d("Do we have it already? ${oldFolder != null} ($oldFolder)");
      if (oldFolder == null) {
        addFolder(routine.folder!);
      } else {
        updateFolder(routine.folder!);
      }
    }
  }

  removeRoutine(Workout routine) {
    _db.deleteRoutine(routine.id);
  }

  bool hasRoutine(String id) {
    return routines.any((element) => element.id == id);
  }

  List<Workout> get workoutHistory {
    return history$.value;
  }

  Future<void> writeAllHistory(List<Workout> history) {
    return _db.writeAllHistoryWorkouts(history);
  }

  Future setHistoryWorkout(Workout workout) async {
    logger.i("Setting history workout");
    if (workoutHistory.any((element) => element.id == workout.id)) {
      await _db.updateHistoryWorkout(fixWorkout(workout));
    } else {
      await _db.insertHistoryWorkout(fixWorkout(workout));
    }
  }

  Future<void> addHistoryWorkouts(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final allWorkouts = workoutHistory + workouts;
    return writeAllHistory(allWorkouts);
  }

  removeHistoryWorkout(Workout workout) {
    removeHistoryWorkoutById(workout.id);
  }

  Future removeHistoryWorkoutById(String id) async {
    await _db.deleteHistoryWorkout(id);
  }

  Workout? getHistoryWorkout(String id) {
    return workoutHistory.firstWhereOrNull((element) => element.id == id);
  }

  bool hasHistoryWorkout(String id) {
    return workoutHistory.any((element) => element.id == id);
  }

  Future _writeWeightMeasurements(List<WeightMeasurement> weightMeasurements) {
    return _db.setWeightMeasurements(weightMeasurements);
  }

  Future<void> addWeightMeasurements(
      List<WeightMeasurement> measurements) async {
    if (measurements.isEmpty) return;

    final allMeasurements = weightMeasurements$.value + measurements;
    return _writeWeightMeasurements(allMeasurements);
  }

  getWeightMeasurement(String measurementID) {
    return weightMeasurements$.value
        .firstWhereOrNull((element) => element.id == measurementID);
  }

  setWeightMeasurement(WeightMeasurement measurement) {
    if (getWeightMeasurement(measurement.id) == null) {
      _db.insertWeightMeasurement(measurement);
    } else {
      _db.updateWeightMeasurement(measurement);
    }
  }

  removeWeightMeasurement(WeightMeasurement measurement) {
    _db.deleteWeightMeasurement(measurement.id);
  }

  addFolder(GTRoutineFolder folder) {
    _db.insertRoutineFolder(folder);
  }

  removeFolder(GTRoutineFolder folder) {
    _db.deleteRoutineFolder(folder.id);
  }

  updateFolder(GTRoutineFolder folder) {
    _db.updateRoutineFolder(folder);
  }

  addFood(TaggedFood food) {
    _db.insertFoods(food);
  }

  removeFood(TaggedFood food) {
    _db.deleteFoods(food.value.id!);
  }

  updateFood(TaggedFood food) {
    _db.updateFoods(food);
  }

  addNutritionGoal(TaggedNutritionGoal goal) {
    final newGoals = nutritionGoals$.value;
    newGoals.add(goal);

    _db.setNutritionGoals(DateSequence.normalized(newGoals).values.toList());
  }

  removeNutritionGoal(TaggedNutritionGoal goal) {
    _db.deleteNutritionGoal(goal.date.startOfDay);
  }

  updateNutritionGoal(TaggedNutritionGoal goal) {
    _db.updateNutritionGoal(goal);
  }

  addCustomBarcodeFood(String barcode, Food food) {
    _db.insertCustomBarcodeFood(barcode, food);
  }

  removeCustomBarcodeFood(String barcode) {
    _db.deleteCustomBarcodeFood(barcode);
  }

  addFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be favorited");
    }

    _db.insertFavoriteFood(food.id!);
  }

  removeFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be unfavorited");
    }

    _db.deleteFavoriteFood(food.id!);
  }

  void setNutritionCategoriesForDay(
      DateTime date, Map<String, NutritionCategory> map) async {
    final values = nutritionCategories$.value.toMap();
    _db.setNutritionCategories(DateSequence.fromDatesAndValues({
      ...values,
      date.startOfDay: map,
    }).normalize().toMap());
  }

  Future<void> insertAchievementCompletion(AchievementCompletion completion) =>
      db.insertAchievementCompletion(completion);
  Future<void> insertAchievementCompletions(
          List<AchievementCompletion> completions) =>
      db.insertAchievementCompletions(completions);
  Future<void> deleteAchievementCompletion(String achievementID, int level) =>
      db.deleteAchievementCompletion(achievementID, level);
  Future<void> setAchievementCompletions(
          List<AchievementCompletion> completions) =>
      db.setAchievementCompletions(completions);

  Future _writeBodyMeasurements(List<BodyMeasurement> measurements) {
    return _db.setBodyMeasurements(measurements);
  }

  Future<void> addBodyMeasurements(
      List<BodyMeasurement> measurements) async {
    if (measurements.isEmpty) return;

    final allMeasurements = bodyMeasurements$.value + measurements;
    return _writeBodyMeasurements(allMeasurements);
  }

  getBodyMeasurement(String measurementID) {
    return bodyMeasurements$.value
        .firstWhereOrNull((element) => element.id == measurementID);
  }

  setBodyMeasurement(BodyMeasurement measurement) {
    if (getBodyMeasurement(measurement.id) == null) {
      _db.insertBodyMeasurement(measurement);
    } else {
      _db.updateBodyMeasurement(measurement);
    }
  }

  removeBodyMeasurement(BodyMeasurement measurement) {
    _db.deleteBodyMeasurement(measurement.id);
  }

  DatabaseSnapshot get currentSnapshot => DatabaseSnapshot(
        customExercises: exercises,
        routines: routines,
        routineExercises: routines.flattenedExercises,
        historyWorkouts: workoutHistory,
        historyWorkoutExercises: workoutHistory.flattenedExercises,
        preferences: prefs$.value,
        weightMeasurements: weightMeasurements$.value,
        folders: folders$.value,
        foods: foods$.value,
        nutritionGoals: nutritionGoals$.value,
        customBarcodeFoods: customBarcodeFoods$.value,
        favoriteFoods:
            favoriteFoods$.value.map((f) => f.id).whereNotNull().toList(),
        foodCategories: Map.fromEntries(nutritionCategories$.value.map((map) {
          return MapEntry(map.date, map.value.values.toList());
        })),
        achievements: completions$.value,
        bodyMeasurements: bodyMeasurements$.value,
      );

  toJson() {
    final converter = getConverter(DATABASE_VERSION);

    return converter.export(currentSnapshot);
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

      try {
        converter.validate(snapshot);
      } catch (e, stackTrace) {
        logger.w("Validation failed", error: e, stackTrace: stackTrace);
        rethrow;
      }

      overrideDatabase(snapshot);
    }

    try {
      await innerImportJson(json);
    } catch (_) {
      await innerImportJson(previousJson);
      rethrow;
    }
  }

  void writeToOngoing(Map<String, dynamic> data) {
    logger.d("Writing ongoing workout data");
    _db.setOngoing(data);
  }

  Map<String, dynamic>? getOngoingData() {
    if (!hasOngoing) return null;
    return ongoing$.valueOrNull;
  }

  void deleteOngoing() {
    logger.i("Requested deletion of ongoing workout data");
    _db.deleteOngoing();
  }

  bool get hasOngoing => ongoing$.valueOrNull != null;

  void transaction<T>(Future<T> Function() action) async {
    await _db.transaction(action);
  }

  Future<void> applyExerciseModificationToHistory(Exercise exercise) {
    final newHistory = history$.value.toList();
    for (int i = 0; i < newHistory.length; i++) {
      final workout = newHistory[i];

      final res = workout.exercises.toList();
      for (int i = 0; i < res.length; i++) {
        res[i].when(
          exercise: (e) {
            if (exercise.isParentOf(e)) {
              res[i] = Exercise.replaced(from: e, to: exercise).copyWith(
                id: e.id,
                parentID: e.parentID,
              );
            }
          },
          superset: (superset) {
            for (int j = 0; j < superset.exercises.length; j++) {
              if (exercise.isParentOf(superset.exercises[j])) {
                (res[i] as Superset).exercises[j] =
                    Exercise.replaced(from: superset.exercises[j], to: exercise)
                        .copyWith(
                  id: superset.exercises[j].id,
                  parentID: superset.exercises[j].parentID,
                );
              }
            }
          },
        );
      }
      newHistory[i] = workout.copyWith.exercises(res);
    }

    return writeAllHistory(newHistory);
  }

  Future<void> applyExerciseModificationToRoutines(Exercise exercise) {
    final newRoutines = routines$.value.toList();
    for (int i = 0; i < newRoutines.length; i++) {
      final workout = newRoutines[i];

      final res = workout.exercises.toList();
      for (int i = 0; i < res.length; i++) {
        res[i].when(
          exercise: (e) {
            if (exercise.isParentOf(e)) {
              res[i] = Exercise.replaced(from: e, to: exercise).copyWith(
                id: e.id,
                parentID: e.parentID,
              );
            }
          },
          superset: (superset) {
            for (int j = 0; j < superset.exercises.length; j++) {
              if (exercise.isParentOf(superset.exercises[j])) {
                (res[i] as Superset).exercises[j] =
                    Exercise.replaced(from: superset.exercises[j], to: exercise)
                        .copyWith(
                  id: superset.exercises[j].id,
                  parentID: superset.exercises[j].parentID,
                );
              }
            }
          },
        );
      }
      newRoutines[i] = workout.copyWith.exercises(res);
    }

    return setAllRoutines(newRoutines);
  }

  bool get canExportRaw => true;
  Future<File> exportRaw() => _db.path;

  Future<void> createBackup() {
    return backups.store(_db);
  }

  Stream<List<DatabaseBackup>> listBackups() {
    return backups.watch();
  }

  Future<void> restoreBackup(DatabaseBackup backup) async {
    Completer c = Completer();
    final p = (await _db.path);
    await _db.close();
    await backup.file.copy(p.absolute.path);
    await ensureInitialized(
      onDone: () {
        if (!c.isCompleted) {
          c.complete();
        }
      },
      overrideInitializationCheck: true,
    );

    Future.delayed(const Duration(seconds: 60), () {
      try {
        if (!c.isCompleted) {
          c.completeError("Initialization took too long");
        }
      } catch (_) {
        // Do nothing.
      }
    });

    return c.future;
  }

  deleteBackup(DatabaseBackup backup) {
    return backups.delete(backup);
  }

  void schedulePeriodicBackup() {
    final list = backups.list();
    bool shouldCreate = list.isEmpty ||
        list.first.date.isBefore(
          DateTime.now().subtract(_kPeriodicBackupInterval),
        );

    if (shouldCreate) {
      logger.i("Creating periodic backup");
      createBackup();
    } else {
      logger.i("No need to create a backup");
    }
  }

  Future<void> overrideDatabase(DatabaseSnapshot snapshot) async {
    await _db.transaction(() async {
      await _db.clearTheWholeThingIAmAbsolutelySureISwear();

      logger.i("Created import transaction");
      // Keep this above other calls to prevent double computation of
      // achievements
      await setAchievementCompletions(snapshot.achievements);
      await writeExercises(snapshot.customExercises);
      await _writeRoutines(snapshot.routines);
      await _db.overwriteAllRoutineExercises(snapshot.routineExercises);
      await writeAllHistory(snapshot.historyWorkouts);
      await _db.overwriteAllHistoryWorkoutExercises(
          snapshot.historyWorkoutExercises);
      await _db.setPreferences(snapshot.preferences);
      await _writeWeightMeasurements(snapshot.weightMeasurements);
      await _db.writeAllRoutineFolders(snapshot.folders);
      await _db.setFoods(snapshot.foods);
      await _db.setNutritionGoals(snapshot.nutritionGoals);
      await _db.setCustomBarcodeFoods(snapshot.customBarcodeFoods);
      await _db.setFavoriteFoods(snapshot.favoriteFoods);
      await _db.setNutritionCategories({
        for (final entry in snapshot.foodCategories.entries)
          entry.key:
              Map.fromEntries(entry.value.map((e) => MapEntry(e.name, e))),
      });
      await _writeBodyMeasurements(snapshot.bodyMeasurements);

      logger.i("Imported database snapshot");
    });
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

Workout fixWorkout(Workout workout) {
  final newExercises = <WorkoutExercisable>[];
  for (final exercise in workout.exercises) {
    newExercises.add(exercise.map(exercise: (ex) {
      return ex.copyWith(
        workoutID: workout.id,
        supersetID: null,
      );
    }, superset: (ss) {
      return ss.copyWith(
        workoutID: workout.id,
        exercises: ss.exercises
            .map((e) => e.copyWith(workoutID: workout.id, supersetID: ss.id))
            .toList(),
      );
    }));
  }

  return workout.copyWith(exercises: newExercises);
}

class DatabaseBackup {
  final DateTime date;
  final File file;
  final int size;

  const DatabaseBackup(this.date, this.file, [this.size = 0]);
}

class _DatabaseBackups {
  late Directory _backupDir;
  final BehaviorSubject<List<DatabaseBackup>> _backups$ = BehaviorSubject();

  Future<void> init() async {
    final root = await getApplicationDocumentsDirectory();
    _backupDir = Directory("${root.path}/backups");
    await _backupDir.create();
    _backups$.add(list());
    if (!(Platform.isIOS || Platform.isAndroid)) {
      _backupDir.watch().listen((event) {
        _backups$.add(list());
      });
    }
  }

  Future<DatabaseBackup?> store(GTDatabase _db) async {
    try {
      final now = DateTime.now();
      final path = "${_backupDir.path}/${now.millisecondsSinceEpoch}.db";
      await (await _db.path).copy(path);

      // Delete old backups
      final backups = list();
      if (backups.length > _kMaxBackups) {
        final toDelete = (backups..sort((a, b) => a.date.compareTo(b.date)))
            .sublist(0, backups.length - _kMaxBackups);
        for (final backup in toDelete) {
          await backup.file.delete();
        }
      }
      _backups$.add(list());

      final file = File(path);
      final size = await file.length();

      return DatabaseBackup(now, file, size);
    } on PathNotFoundException catch (e, s) {
      logger.e("Path not found", error: e, stackTrace: s);
    }
  }

  List<DatabaseBackup> list() {
    return _backupDir
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith(".db"))
        .map((e) {
      return DatabaseBackup(
        DateTime.fromMillisecondsSinceEpoch(
            int.parse(e.path.split("/").last.split(".").first)),
        e,
        e.lengthSync(),
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Stream<List<DatabaseBackup>> watch() {
    return _backups$.stream;
  }

  Future<void> delete(DatabaseBackup backup) async {
    await backup.file.delete();
    _backups$.add(list());
  }
}

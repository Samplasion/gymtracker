import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v24.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/db/sync_diagnostics.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart' as gtn;
import 'package:gymtracker/struct/nutrition.dart' hide NutritionGoal;
import 'package:gymtracker/struct/recipe.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:syncable/syncable.dart';

const _kMaxBackups = 50;
const _kPeriodicBackupInterval = Duration(days: 1);

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  ref.onDispose(service.dispose);
  return service;
});

class DatabaseService extends ChangeNotifier with LoggerConfigurationMixin {
  DatabaseService() : _db = GTDatabaseImpl.prod();

  @visibleForTesting
  DatabaseService.withDatabase(GTDatabase database) : _db = database;

  @override
  int get loggerMethodCount => 0;

  late GTDatabase _db;
  GTDatabase get db => _db;

  Future<void> Function()? beforeUserChange;
  Future<void> Function()? afterUserChange;
  Future<void> _userTransition = Future.value();
  Future<void> Function(Future<void> Function() action)? runWithSyncPaused;

  final exercises$ = BehaviorSubject<List<Exercise>>.seeded([]);
  final routines$ = BehaviorSubject<List<Workout>>.seeded([]);
  final history$ = BehaviorSubject<List<Workout>>.seeded([]);
  final prefs$ = BehaviorSubject<Prefs>.seeded(Prefs.defaultValue);
  final ongoing$ = BehaviorSubject<Map<String, dynamic>?>.seeded(null);
  final weightMeasurements$ = BehaviorSubject<List<WeightMeasurement>>.seeded(
    [],
  );
  final folders$ = BehaviorSubject<List<GTRoutineFolder>>.seeded([]);
  final recipes$ = BehaviorSubject<List<Recipe>>.seeded([]);
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
        DateSequence.empty(),
      );
  final completions$ = BehaviorSubject<List<AchievementCompletion>>.seeded([]);
  final bodyMeasurements$ = BehaviorSubject<List<BodyMeasurement>>.seeded([]);

  bool _disposed = false;
  final _databaseSubscriptions = <StreamSubscription<dynamic>>[];

  void _listenTo<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
  }) {
    _databaseSubscriptions.add(
      stream.listen((value) {
        if (!_disposed) onData(value);
      }, onError: onError),
    );
  }

  Future<void> _cancelDatabaseSubscriptions() async {
    await Future.wait(_databaseSubscriptions.map((s) => s.cancel()));
    _databaseSubscriptions.clear();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_cancelDatabaseSubscriptions());
    unawaited(backups.dispose());
    for (final subject in <Subject<dynamic>>[
      exercises$,
      routines$,
      history$,
      prefs$,
      ongoing$,
      weightMeasurements$,
      folders$,
      recipes$,
      foods$,
      nutritionGoals$,
      customBarcodeFoods$,
      favoriteFoods$,
      nutritionCategories$,
      completions$,
      bodyMeasurements$,
      _backups$,
    ]) {
      unawaited(subject.close());
    }
    unawaited(_db.close());
    super.dispose();
  }

  final backups = _DatabaseBackups();
  final _backups$ = BehaviorSubject<List<DatabaseBackup>>();

  void eraseAllSubjects({bool includeDeviceState = true}) {
    logger.i(
      "[DatabaseService.eraseAllSubjects] Erasing all subjects; "
      "prefs\$ reset to Prefs.defaultValue (onboardingComplete=${Prefs.defaultValue.onboardingComplete})",
    );
    exercises$.add([]);
    routines$.add([]);
    history$.add([]);
    if (includeDeviceState) {
      prefs$.add(
        Prefs.defaultValue.copyWith(
          onboardingComplete: prefs$.value.onboardingComplete,
        ),
      );
      ongoing$.add(null);
    }
    weightMeasurements$.add([]);
    folders$.add([]);
    recipes$.add([]);
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

  Future<void> writeSettings(Prefs prefs) async {
    logger.i(
      "[DatabaseService.writeSettings] Writing settings to DB: "
      "onboardingComplete=${prefs.onboardingComplete}, "
      "currentUserId=${_db.currentUserId}",
    );
    await _db.setPreferences(prefs);
    notifyListeners();
  }

  Future<void> ensureInitialized({
    Function()? onDone,
    bool overrideInitializationCheck = false,
  }) async {
    return _innerEnsureInitialized(
      onDone: onDone,
      overrideInitializationCheck: overrideInitializationCheck,
    );
  }

  bool _isInit = false;
  bool get isInitialized => _isInit;
  Future<void> _innerEnsureInitialized({
    Function()? onDone,
    bool overrideInitializationCheck = false,
  }) async {
    await _cancelDatabaseSubscriptions();
    await backups.init();
    if (_disposed) return;

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
      "recipes",
    ].map((element) => false).toList();
    check() {
      final shouldCall = !_isInit || overrideInitializationCheck;
      if (initialized.every((element) => element) && shouldCall) {
        _isInit = true;
        onDone?.call();
      }
    }

    Future.microtask(() {
      if (_disposed) return;
      final b = backups.list();
      _backups$.add(b);
    });

    _listenTo(db.watchAchievementCompletions(), (event) {
      completions$.add(event);
      onDatabaseUpdated("nutrition categories")();
      initialized[0] = true;
      check();
    });
    _listenTo(
      _db.getAllCustomExercises(),
      (event) {
        exercises$.add(event);
        onDatabaseUpdated("exercises")();
        initialized[1] = true;
        check();
      },
      onError: (e, s) {
        logger.e("Error loading exercises", error: e, stackTrace: s);
      },
    );
    _listenTo(_db.getAllRoutines(), (event) {
      routines$.add(event);
      onDatabaseUpdated("routines")();
      initialized[2] = true;
      check();
    });
    _listenTo(_db.getAllHistoryWorkouts(), (event) {
      history$.add(event);
      onDatabaseUpdated("history")();
      initialized[3] = true;
      check();
    });
    _listenTo(_db.watchPreferences(), (prefs) {
      logger.i(
        "[DatabaseService.watchPreferences] Emitted preferences from DB: "
        "onboardingComplete=${prefs.onboardingComplete}, "
        "currentUserId=${_db.currentUserId}",
      );
      prefs$.add(prefs);
      notifyListeners();
      onDatabaseUpdated("preferences")();
      initialized[4] = true;
      check();
      prefs.logger.i("Changed.");
    });
    _listenTo(_db.watchOngoing(), (event) {
      ongoing$.add(event);
      onDatabaseUpdated("ongoing")();
      initialized[5] = true;
      check();
    });
    _listenTo(_db.watchWeightMeasurements(), (event) {
      weightMeasurements$.add(event);
      onDatabaseUpdated("weight measurements")();
      initialized[6] = true;
      check();
    });
    _listenTo(_db.watchRoutineFolders(), (event) {
      folders$.add(event);
      onDatabaseUpdated("folders")();
      initialized[7] = true;
      check();
    });
    _listenTo(_db.watchFoods(), (event) {
      foods$.add(event);
      onDatabaseUpdated("foods")();
      initialized[8] = true;
      check();
    });
    _listenTo(
      _db.watchNutritionGoals().map(
        (event) => DateSequence.normalized(event).values.toList(),
      ),
      (event) {
        nutritionGoals$.add(event);
        onDatabaseUpdated("nutrition goals")();
        initialized[9] = true;
        check();
      },
    );
    _listenTo(_db.watchCustomBarcodeFoods(), (event) {
      customBarcodeFoods$.add(event);
      onDatabaseUpdated("custom barcode foods")();
      initialized[10] = true;
      check();
    });
    _listenTo(_db.watchFavoriteFoods(), (event) {
      favoriteFoods$.add(event);
      onDatabaseUpdated("favorite foods")();
      initialized[11] = true;
      check();
    });
    _listenTo(
      _db.watchNutritionCategories().map(
        (event) => DateSequence.fromDatesAndValues(event).normalize(),
      ),
      (event) {
        nutritionCategories$.add(event);
        onDatabaseUpdated("nutrition categories")();
        initialized[12] = true;
        check();
      },
    );
    _listenTo(_db.watchBodyMeasurements(), (event) {
      bodyMeasurements$.add(event);
      onDatabaseUpdated("body measurements")();
      initialized[13] = true;
      check();
    });
    _listenTo(_db.watchRecipes(), (event) {
      recipes$.add(event);
      onDatabaseUpdated("recipes")();
      initialized[14] = true;
      check();
    });
    _listenTo(backups.watch(), (event) {
      _backups$.add(event);
      logger.i("Backups updated: ${event.length}");
    });
  }

  @visibleForTesting
  Future ensureInitializedForTests(
    QueryExecutor e,
    OnlineService? onlineService,
  ) async {
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
    if (_disposed) return;
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

    final allExercises = {
      for (final e in await _db.getAllCustomExercises().first) e.id: e,
      for (final e in customExercises) e.id: e,
    }.values.toList();
    return writeExercises(allExercises);
  }

  Future<void> removeExercise(Exercise exercise) async {
    await _db.deleteCustomExercise(exercise.id);
  }

  List<Workout> get routines {
    return routines$.value;
  }

  Future _writeRoutines(List<Workout> routines) {
    return _db.writeAllRoutines(routines);
  }

  Future<void> setAllRoutines(List<Workout> routines) {
    return _writeRoutines(routines).then((_) => notifyListeners());
  }

  Future<void> setRoutine(Workout routine) async {
    logger.i("Setting routine");
    logger.d(
      "Do we have it already? ${routines.any((element) => element.id == routine.id)}",
    );
    if (routines.any((element) => element.id == routine.id)) {
      await _db.updateRoutine(fixWorkout(routine));
    } else {
      await _db.insertRoutine(fixWorkout(routine));
    }
    if (routine.folder != null) {
      logger.i("Routine has a folder: ${routine.folder}");
      final oldFolder = folders$.value.firstWhereOrNull(
        (element) => element.id == routine.folder!.id,
      );
      logger.d("Do we have it already? ${oldFolder != null} ($oldFolder)");
      if (oldFolder == null) {
        await addFolder(routine.folder!);
      } else {
        await updateFolder(routine.folder!);
      }
    }
  }

  Future<void> removeRoutine(Workout routine) async {
    await _db.deleteRoutine(routine.id);
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

  void Function()? onSocialDataSaved;

  Future setHistoryWorkout(Workout workout) async {
    logger.i("Setting history workout");
    if (workoutHistory.any((element) => element.id == workout.id)) {
      await _db.updateHistoryWorkout(fixWorkout(workout));
    } else {
      await _db.insertHistoryWorkout(fixWorkout(workout));
    }
    onSocialDataSaved?.call();
  }

  Future<void> addHistoryWorkouts(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final allWorkouts = {
      for (final w in await _db.getAllHistoryWorkoutsFuture()) w.id: w,
      for (final w in workouts) w.id: w,
    }.values.toList();
    return writeAllHistory(allWorkouts);
  }

  Future<void> removeHistoryWorkout(Workout workout) async {
    await removeHistoryWorkoutById(workout.id);
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
    List<WeightMeasurement> measurements,
  ) async {
    if (measurements.isEmpty) return;

    final allMeasurements = {
      for (final m in await _db.watchWeightMeasurements().first) m.id: m,
      for (final m in measurements) m.id: m,
    }.values.toList();
    return _writeWeightMeasurements(allMeasurements);
  }

  WeightMeasurement? getWeightMeasurement(String measurementID) {
    return weightMeasurements$.value.firstWhereOrNull(
      (element) => element.id == measurementID,
    );
  }

  Future<void> setWeightMeasurement(WeightMeasurement measurement) async {
    if (getWeightMeasurement(measurement.id) == null) {
      await _db.insertWeightMeasurement(measurement);
    } else {
      await _db.updateWeightMeasurement(measurement);
    }
  }

  Future<void> removeWeightMeasurement(WeightMeasurement measurement) async {
    await _db.deleteWeightMeasurement(measurement.id);
  }

  Future<void> addFolder(GTRoutineFolder folder) async {
    await _db.insertRoutineFolder(folder);
  }

  Future<void> removeFolder(GTRoutineFolder folder) async {
    await _db.deleteRoutineFolder(folder.id);
  }

  Future<void> updateFolder(GTRoutineFolder folder) async {
    await _db.updateRoutineFolder(folder);
  }

  Future<void> addFood(TaggedFood food) => _db.insertFoods(food);
  Future<void> removeFood(TaggedFood food) => _db.deleteFoods(food.value.id!);
  Future<void> updateFood(TaggedFood food) => _db.updateFoods(food);
  Future<void> addNutritionGoal(TaggedNutritionGoal goal) =>
      _db.updateNutritionGoal(goal);
  Future<void> removeNutritionGoal(TaggedNutritionGoal goal) =>
      _db.deleteNutritionGoal(goal.date.startOfDay);
  Future<void> updateNutritionGoal(TaggedNutritionGoal goal) =>
      _db.updateNutritionGoal(goal);
  Future<void> addCustomBarcodeFood(String barcode, Food food) =>
      _db.insertCustomBarcodeFood(barcode, food);
  Future<void> removeCustomBarcodeFood(String barcode) =>
      _db.deleteCustomBarcodeFood(barcode);
  Future<void> addFavoriteFood(Food food) async {
    if (food.id == null) throw StateError('Food must have an ID');
    await _db.insertFavoriteFood(food.id!);
  }

  Future<void> removeFavoriteFood(Food food) async {
    if (food.id == null) throw StateError('Food must have an ID');
    await _db.deleteFavoriteFood(food.id!);
  }

  Future<void> setNutritionCategoriesForDay(
    DateTime date,
    Map<String, NutritionCategory> categories,
  ) => _db.setNutritionCategoriesForDay(date, categories);

  Future<void> insertAchievementCompletion(AchievementCompletion completion) =>
      db.insertAchievementCompletion(completion);
  Future<void> insertAchievementCompletions(
    List<AchievementCompletion> completions,
  ) async {
    await db.insertAchievementCompletions(completions);
    onSocialDataSaved?.call();
  }

  Future<void> deleteAchievementCompletion(String achievementID, int level) =>
      db.deleteAchievementCompletion(achievementID, level);
  Future<void> setAchievementCompletions(
    List<AchievementCompletion> completions,
  ) => db.setAchievementCompletions(completions);

  Future _writeBodyMeasurements(List<BodyMeasurement> measurements) {
    return _db.setBodyMeasurements(measurements);
  }

  Future<void> addBodyMeasurements(List<BodyMeasurement> measurements) async {
    if (measurements.isEmpty) return;

    final allMeasurements = {
      for (final m in await _db.watchBodyMeasurements().first) m.id: m,
      for (final m in measurements) m.id: m,
    }.values.toList();
    return _writeBodyMeasurements(allMeasurements);
  }

  BodyMeasurement? getBodyMeasurement(String measurementID) {
    return bodyMeasurements$.value.firstWhereOrNull(
      (element) => element.id == measurementID,
    );
  }

  Future<void> setBodyMeasurement(BodyMeasurement measurement) async {
    if (getBodyMeasurement(measurement.id) == null) {
      await _db.insertBodyMeasurement(measurement);
    } else {
      await _db.updateBodyMeasurement(measurement);
    }
  }

  Future<void> removeBodyMeasurement(BodyMeasurement measurement) async {
    await _db.deleteBodyMeasurement(measurement.id);
  }

  DatabaseSnapshot get currentSnapshot => DatabaseSnapshot(
    recipes: recipes$.value,
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
    favoriteFoods: favoriteFoods$.value.map((f) => f.id).nonNulls.toList(),
    foodCategories: Map.fromEntries(
      nutritionCategories$.value.map((map) {
        return MapEntry(map.date, map.value.values.toList());
      }),
    ),
    achievements: completions$.value,
    bodyMeasurements: bodyMeasurements$.value,
  );

  /// Version 20 is export-only; legacy import converters remain separate.
  Future<Map<String, dynamic>> exportJson() =>
      const VersionedJsonExportV24().export(_db);

  Map<String, dynamic> toJson() {
    return currentSnapshot.toJson();
  }

  Future fromJson(Map<String, dynamic> json) async {
    final previousJson = toJson();

    if (json['version'] is int && (json['version'] as int) > DATABASE_VERSION) {
      throw DatabaseImportVersionMismatch((json['version'] as int? ?? -1));
    }

    Future innerImportJson(Map<String, dynamic> json) async {
      final converter = getConverter(
        json['version'] as int? ?? DATABASE_VERSION,
      );
      final snapshot = converter.process(json);

      try {
        converter.validate(snapshot);
      } catch (e, stackTrace) {
        logger.w("Validation failed", error: e, stackTrace: stackTrace);
        rethrow;
      }

      await overrideDatabase(snapshot);
    }

    try {
      await innerImportJson(json);
    } catch (_) {
      await innerImportJson(previousJson);
      rethrow;
    }
  }

  Future<void> writeToOngoing(Map<String, dynamic> data) {
    logger.t("Writing ongoing workout data");
    return _db.setOngoing(data);
  }

  Map<String, dynamic>? getOngoingData() {
    if (!hasOngoing) return null;
    return ongoing$.valueOrNull;
  }

  void deleteOngoing() {
    logger.d("Requested deletion of ongoing workout data");
    _db.deleteOngoing();
  }

  bool get hasOngoing => ongoing$.valueOrNull != null;

  Future<T> transaction<T>(Future<T> Function() action) {
    final userId = _db.currentUserId;
    return _db.transaction(() async {
      final result = await action();
      if (_db.currentUserId != userId) {
        throw StateError('The account changed during the transaction');
      }
      return result;
    });
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
              res[i] = Exercise.replaced(
                from: e,
                to: exercise,
              ).copyWith(id: e.id, parentID: e.parentID);
            }
          },
          superset: (superset) {
            for (int j = 0; j < superset.exercises.length; j++) {
              if (exercise.isParentOf(superset.exercises[j])) {
                (res[i] as Superset).exercises[j] =
                    Exercise.replaced(
                      from: superset.exercises[j],
                      to: exercise,
                    ).copyWith(
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
      if (_db.cachedTrainerState.controls.contains(workout.id)) continue;

      final res = workout.exercises.toList();
      for (int i = 0; i < res.length; i++) {
        res[i].when(
          exercise: (e) {
            if (exercise.isParentOf(e)) {
              res[i] = Exercise.replaced(
                from: e,
                to: exercise,
              ).copyWith(id: e.id, parentID: e.parentID);
            }
          },
          superset: (superset) {
            for (int j = 0; j < superset.exercises.length; j++) {
              if (exercise.isParentOf(superset.exercises[j])) {
                (res[i] as Superset).exercises[j] =
                    Exercise.replaced(
                      from: superset.exercises[j],
                      to: exercise,
                    ).copyWith(
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

  Future<void> restoreBackup(
    DatabaseBackup backup, {
    RestoreMode mode = RestoreMode.merge,
  }) async {
    final barrier = runWithSyncPaused;
    if (barrier == null) throw StateError('Synchronization is not initialized');
    final owner = _db.currentUserId;
    final prepared = await PreparedDatabaseRestore.load(backup.file, owner);
    await barrier(() {
      final restore = _userTransition.then((_) async {
        if (_db.currentUserId != owner) {
          throw StateError('Account changed before restore');
        }
        await beforeUserChange?.call();
        try {
          // A failed safety backup must abort the replacement.
          final saved = await backups.store(_db);
          if (saved == null) throw StateError('Unable to create safety backup');
          await prepared.apply(_db, mode: mode);
        } finally {
          await afterUserChange?.call();
        }
      });
      _userTransition = restore.catchError((Object _) {});
      return restore;
    });
  }

  Future<void> deleteBackup(DatabaseBackup backup) {
    return backups.delete(backup);
  }

  void schedulePeriodicBackup() {
    final list = backups.list();
    bool shouldCreate =
        list.isEmpty ||
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
    final barrier = runWithSyncPaused;
    if (barrier == null) throw StateError('Synchronization is not initialized');
    await barrier(() => _overrideDatabase(snapshot));
  }

  Future<void> _overrideDatabase(DatabaseSnapshot snapshot) async {
    final userId = _db.currentUserId;
    await _db.transaction(() async {
      for (final table in _db.allTables.where(
        (t) => t.asDslTable is SyncableTable,
      )) {
        await _db.customStatement(
          'UPDATE "${table.actualTableName}" SET deleted=1,updated_at=? WHERE user_id IS ? AND deleted=0',
          [DateTime.now().millisecondsSinceEpoch ~/ 1000, userId],
        );
        _db.notifyUpdates({TableUpdate.onTable(table)});
      }
      logger.i("Created import transaction");
      // Keep this above other calls to prevent double computation of
      // achievements
      await setAchievementCompletions(snapshot.achievements);
      await writeExercises(snapshot.customExercises);
      await _writeRoutines(snapshot.routines);
      await _db.overwriteAllRoutineExercises(snapshot.routineExercises);
      await writeAllHistory(snapshot.historyWorkouts);
      await _db.overwriteAllHistoryWorkoutExercises(
        snapshot.historyWorkoutExercises,
      );
      await _db.setPreferences(snapshot.preferences);
      await _writeWeightMeasurements(snapshot.weightMeasurements);
      await _db.writeAllRoutineFolders(snapshot.folders);
      await _db.setRecipes(snapshot.recipes);
      await _db.setFoods(snapshot.foods);
      await _db.setNutritionGoals(snapshot.nutritionGoals);
      await _db.setCustomBarcodeFoods(snapshot.customBarcodeFoods);
      await _db.setFavoriteFoods(snapshot.favoriteFoods);
      await _db.setNutritionCategories({
        for (final entry in snapshot.foodCategories.entries)
          entry.key: Map.fromEntries(
            entry.value.map((e) => MapEntry(e.name, e)),
          ),
      });
      await _writeBodyMeasurements(snapshot.bodyMeasurements);

      logger.i("Imported database snapshot");
    });
  }

  Future<void> setCurrentUserId(String? id) {
    final change = _userTransition.then((_) => _changeUser(id));
    _userTransition = change.catchError((Object _) {});
    return change;
  }

  Future<void> _changeUser(String? id) async {
    logger.i(
      "[DatabaseService.setCurrentUserId] Requested userId change: "
      "current='${_db.currentUserId}', new='$id'",
    );
    if (_db.currentUserId == id) {
      logger.i(
        "[DatabaseService.setCurrentUserId] userId unchanged, skipping reload",
      );
      return;
    }
    await beforeUserChange?.call();
    // Clear user data before the new queries can emit. Preferences are device-wide.
    eraseAllSubjects(includeDeviceState: false);
    ongoing$.add(null);
    _db.setCurrentUserId(id);
    await _db.trainerState();
    await afterUserChange?.call();
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
    newExercises.add(
      exercise.map(
        exercise: (ex) {
          return ex.copyWith(workoutID: workout.id, supersetID: null);
        },
        superset: (ss) {
          return ss.copyWith(
            workoutID: workout.id,
            exercises: ss.exercises
                .map(
                  (e) => e.copyWith(workoutID: workout.id, supersetID: ss.id),
                )
                .toList(),
          );
        },
      ),
    );
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
  bool _disposed = false;
  StreamSubscription<FileSystemEvent>? _directorySubscription;
  // Keep incident evidence until an explicit investigation outcome is recorded.
  bool preserveForInvestigation = true;
  late Directory _backupDir;
  final BehaviorSubject<List<DatabaseBackup>> _backups$ = BehaviorSubject();

  Future<void> init() async {
    await _directorySubscription?.cancel();
    final root = await getApplicationDocumentsDirectory();
    if (_disposed) return;
    _backupDir = Directory("${root.path}/backups");
    await _backupDir.create();
    if (_disposed) return;
    _backups$.add(list());
    if (!(Platform.isIOS || Platform.isAndroid)) {
      _directorySubscription = _backupDir.watch().listen((event) {
        if (!_disposed) _backups$.add(list());
      });
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _directorySubscription?.cancel();
    _directorySubscription = null;
    await _backups$.close();
  }

  Future<DatabaseBackup?> store(GTDatabase _db) async {
    try {
      final now = DateTime.now();
      final path = "${_backupDir.path}/${now.millisecondsSinceEpoch}.db";
      // VACUUM INTO includes committed WAL pages and creates a consistent snapshot.
      await _db.customStatement('VACUUM INTO ?', [path]);

      final saved = File(path);
      final check = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
      try {
        if (check.select('PRAGMA integrity_check').single.values.single != 'ok')
          throw StateError('Backup integrity check failed');
      } finally {
        check.close();
      }
      final counts = SyncDiagnostics.fileCounts(saved, _db);
      var active = 0;
      for (final groups in counts.values) {
        for (final group in groups as List) {
          if (group['user_id'] == _db.currentUserId && group['deleted'] == 0)
            active += (group['count'] as int);
        }
      }
      await File('$path.json').writeAsString(
        jsonEncode({
          'schema': _db.schemaVersion,
          'owner': _db.currentUserId,
          'created_at': now.toUtc().toIso8601String(),
          'sha256': (await sha256.bind(saved.openRead()).first).toString(),
          'active_records': active,
          'counts': counts,
        }),
      );
      // Protect the newest verified non-empty snapshot of each account.
      final protected = <String>{};
      final owners = <String>{};
      for (final backup in list()) {
        final manifest = File('${backup.file.path}.json');
        if (!await manifest.exists()) {
          protected.add(backup.file.path);
          continue;
        }
        final metadata = jsonDecode(await manifest.readAsString()) as Map;
        final owner = metadata['owner']?.toString() ?? 'guest';
        if ((metadata['active_records'] as int? ?? 0) > 0 && owners.add(owner))
          protected.add(backup.file.path);
      }
      // Delete old backups
      final backups = list();
      if (!preserveForInvestigation && backups.length > _kMaxBackups) {
        final toDelete = (backups..sort((a, b) => a.date.compareTo(b.date)))
            .sublist(0, backups.length - _kMaxBackups);
        for (final backup in toDelete) {
          if (protected.contains(backup.file.path)) continue;
          await backup.file.delete();
          final manifest = File('${backup.file.path}.json');
          if (await manifest.exists()) await manifest.delete();
        }
      }
      if (!_disposed) _backups$.add(list());

      final file = File(path);
      final size = await file.length();

      return DatabaseBackup(now, file, size);
    } on PathNotFoundException catch (e, s) {
      logger.e("Path not found", error: e, stackTrace: s);
    }
  }

  List<DatabaseBackup> list() {
    if (!_backupDir.existsSync()) return [];
    return _backupDir
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith(".db"))
        .map((e) {
          return DatabaseBackup(
            DateTime.fromMillisecondsSinceEpoch(
              int.parse(e.path.split("/").last.split(".").first),
            ),
            e,
            e.lengthSync(),
          );
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Stream<List<DatabaseBackup>> watch() {
    return _backups$.stream;
  }

  Future<void> delete(DatabaseBackup backup) async {
    await backup.file.delete();
    final manifest = File('${backup.file.path}.json');
    if (await manifest.exists()) await manifest.delete();
    _backups$.add(list());
  }
}

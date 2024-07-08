import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
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
import 'package:rxdart/rxdart.dart';

class DatabaseService extends GetxService with ChangeNotifier {
  late final GTDatabase db;

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

  writeSettings(Prefs prefs) {
    db.setPreferences(prefs);
    notifyListeners();
  }

  @override
  onInit() {
    super.onInit();

    onServiceChange("main")();
  }

  Future ensureInitialized() async {
    db = GTDatabase.prod();

    return _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    db.getAllRoutines()
      ..pipe(routines$)
      ..listen((_) => onServiceChange("routines")());
    db.getAllCustomExercises()
      ..pipe(exercises$)
      ..listen((_) => onServiceChange("exercises")());
    db.getAllHistoryWorkouts()
      ..pipe(history$)
      ..listen((_) => onServiceChange("history")());
    db.watchPreferences()
      ..pipe(prefs$)
      ..listen((prefs) {
        notifyListeners();
        onServiceChange("preferences")();
        prefs.logger.i("Changed.");
      });
    db.watchOngoing()
      ..pipe(ongoing$)
      ..listen((event) {
        onServiceChange("ongoing")();
      });
    db.watchWeightMeasurements()
      ..pipe(weightMeasurements$)
      ..listen((_) => onServiceChange("weight measurements")());
    db.watchRoutineFolders()
      ..pipe(folders$)
      ..listen((_) => onServiceChange("folders")());
    db.watchFoods()
      ..pipe(foods$)
      ..listen((_) => onServiceChange("foods")());
    db
        .watchNutritionGoals()
        .map((event) => DateSequence.normalized(event).values.toList())
      ..pipe(nutritionGoals$)
      ..listen((_) => onServiceChange("nutrition goals")());
    db.watchCustomBarcodeFoods()
      ..pipe(customBarcodeFoods$)
      ..listen((_) => onServiceChange("custom barcode foods")());
    db.watchFavoriteFoods()
      ..pipe(favoriteFoods$)
      ..listen((_) => onServiceChange("favorite foods")());
  }

  @visibleForTesting
  Future ensureInitializedForTests(QueryExecutor e) async {
    // We're inside a @visibleForTesting method, so it's fine
    // ignore: invalid_use_of_visible_for_testing_member
    db = GTDatabase.withQueryExecutor(e);

    await _ensureInitialized();
  }

  @visibleForTesting
  Future teardown() async {
    logger.t("!!! Tearing down");
    await db.clearTheWholeThingIAmAbsolutelySureISwear();
  }

  void Function() onServiceChange(String service) {
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
  writeExercises(List<Exercise> exercises) {
    return db.batch((batch) {
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

  Future _writeRoutines(List<Workout> routines) {
    return db.transaction(() async {
      await db.batch((batch) {
        batch.logger.i("Importing routines");
        batch.deleteAll(db.routines);
        batch.insertAll(
          db.routines,
          routines.toSortedRoutineInsertables(),
        );
      });
      await _writeRoutineExercises(routines.flattenedExercises);
    });
  }

  Future _writeRoutineExercises(
      List<WorkoutExercisable> routineExercises) async {
    final routineExerciseInsertables = routineExercises
        .fold(
          <String, List<WorkoutExercisable>>{},
          (m, r) {
            return m..putIfAbsent(r.workoutID!, () => []).add(r);
          },
        )
        .values
        .expand((list) => list.toSortedInsertables());
    await db.delete(db.routineExercises).go();
    await db.batch(
        (b) => b.insertAll(db.routineExercises, routineExerciseInsertables));
  }

  setAllRoutines(List<Workout> routines) {
    return _writeRoutines(routines).then((_) => notifyListeners());
  }

  setRoutine(Workout routine) async {
    logger.i("Setting routine");
    logger.d(
        "Do we have it already? ${routines.any((element) => element.id == routine.id)}");
    if (routines.any((element) => element.id == routine.id)) {
      await db.updateRoutine(fixWorkout(routine));
    } else {
      await db.insertRoutine(fixWorkout(routine));
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
    db.deleteRoutine(routine.id);
  }

  bool hasRoutine(String id) {
    return routines.any((element) => element.id == id);
  }

  List<Workout> get workoutHistory {
    return history$.value;
  }

  Future writeAllHistory(List<Workout> history) {
    return db.transaction(() async {
      await db.batch((batch) {
        batch.logger.i("Importing routines");
        batch.deleteAll(db.historyWorkouts);
        batch.insertAll(
          db.historyWorkouts,
          history.toSortedHistoryWorkoutInsertables(),
        );
      });
      await _writeHistoryExercises(history.flattenedExercises);
    });
  }

  Future _writeHistoryExercises(
      List<WorkoutExercisable> historyWorkoutExercises) async {
    final historyExerciseInsertables = historyWorkoutExercises
        .fold(
          <String, List<WorkoutExercisable>>{},
          (m, r) {
            return m..putIfAbsent(r.workoutID!, () => []).add(r);
          },
        )
        .values
        .expand((list) => list.toSortedInsertables());
    await db.delete(db.historyWorkoutExercises).go();
    await db.batch((b) =>
        b.insertAll(db.historyWorkoutExercises, historyExerciseInsertables));
  }

  Future setHistoryWorkout(Workout workout) async {
    logger.i("Setting history workout");
    if (workoutHistory.any((element) => element.id == workout.id)) {
      await db.updateHistoryWorkout(fixWorkout(workout));
    } else {
      await db.insertHistoryWorkout(fixWorkout(workout));
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

  Future _writeWeightMeasurements(List<WeightMeasurement> weightMeasurements) {
    return db.setWeightMeasurements(weightMeasurements);
  }

  getWeightMeasurement(String measurementID) {
    return weightMeasurements$.value
        .firstWhereOrNull((element) => element.id == measurementID);
  }

  setWeightMeasurement(WeightMeasurement measurement) {
    if (getWeightMeasurement(measurement.id) == null) {
      db.insertWeightMeasurement(measurement);
    } else {
      db.updateWeightMeasurement(measurement);
    }
  }

  removeWeightMeasurement(WeightMeasurement measurement) {
    db.deleteWeightMeasurement(measurement.id);
  }

  addFolder(GTRoutineFolder folder) {
    db.insertRoutineFolder(folder);
  }

  removeFolder(GTRoutineFolder folder) {
    db.deleteRoutineFolder(folder.id);
  }

  updateFolder(GTRoutineFolder folder) {
    db.updateRoutineFolder(folder);
  }

  addFood(TaggedFood food) {
    db.insertFoods(food);
  }

  removeFood(TaggedFood food) {
    db.deleteFoods(food.value.id!);
  }

  updateFood(TaggedFood food) {
    db.updateFoods(food);
  }

  addNutritionGoal(TaggedNutritionGoal goal) {
    final newGoals = nutritionGoals$.value;
    newGoals.add(goal);

    db.setNutritionGoals(DateSequence.normalized(newGoals).values.toList());
  }

  removeNutritionGoal(TaggedNutritionGoal goal) {
    db.deleteNutritionGoal(goal.date.startOfDay);
  }

  updateNutritionGoal(TaggedNutritionGoal goal) {
    db.updateNutritionGoal(goal);
  }

  addCustomBarcodeFood(String barcode, Food food) {
    db.insertCustomBarcodeFood(barcode, food);
  }

  removeCustomBarcodeFood(String barcode) {
    db.deleteCustomBarcodeFood(barcode);
  }

  addFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be favorited");
    }

    db.insertFavoriteFood(food.id!);
  }

  removeFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be unfavorited");
    }

    db.deleteFavoriteFood(food.id!);
  }

  toJson() {
    final converter = getConverter(DATABASE_VERSION);

    return converter.export(DatabaseSnapshot(
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

      try {
        converter.validate(snapshot);
      } catch (e, stackTrace) {
        logger.w("Validation failed", error: e, stackTrace: stackTrace);
        rethrow;
      }

      await db.transaction(() async {
        await db.clearTheWholeThingIAmAbsolutelySureISwear();

        logger.i("Created import transaction");
        await writeExercises(snapshot.customExercises);
        await _writeRoutines(snapshot.routines);
        await _writeRoutineExercises(snapshot.routineExercises);
        await writeAllHistory(snapshot.historyWorkouts);
        await _writeHistoryExercises(snapshot.historyWorkoutExercises);
        await db.setPreferences(snapshot.preferences);
        await _writeWeightMeasurements(snapshot.weightMeasurements);
        await db.writeAllRoutineFolders(snapshot.folders);
        await db.setFoods(snapshot.foods);
        await db.setNutritionGoals(snapshot.nutritionGoals);
        await db.setCustomBarcodeFoods(snapshot.customBarcodeFoods);
        await db.setFavoriteFoods(snapshot.favoriteFoods);
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
    logger.d("Writing ongoing workout data");
    db.setOngoing(data);
  }

  Map<String, dynamic>? getOngoingData() {
    if (!hasOngoing) return null;
    return ongoing$.valueOrNull;
  }

  void deleteOngoing() {
    logger.i("Requested deletion of ongoing workout data");
    db.deleteOngoing();
  }

  bool get hasOngoing => ongoing$.valueOrNull != null;

  void transaction<T>(Future<T> Function() action) async {
    await db.transaction(action);
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
  Future<File> exportRaw() => db.path;
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

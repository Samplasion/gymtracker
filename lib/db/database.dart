import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/model/tables/achievements.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/foods.dart';
import 'package:gymtracker/db/model/tables/history.dart';
import 'package:gymtracker/db/model/tables/measurements.dart';
import 'package:gymtracker/db/model/tables/nutrition_categories.dart';
import 'package:gymtracker/db/model/tables/nutrition_goals.dart';
import 'package:gymtracker/db/model/tables/ongoing.dart';
import 'package:gymtracker/db/model/tables/preferences.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:gymtracker/db/schema_versions.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart' as model;
import 'package:gymtracker/model/exercise.dart' as model;
import 'package:gymtracker/model/exercise.dart' show GTGymEquipment;
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart' as model;
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart' as model hide NutritionGoal;
import 'package:gymtracker/struct/nutrition.dart' as model_nutrition
    show NutritionGoal;
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

const DATABASE_VERSION = 11;

abstract class GTDatabase {
  Future<T> transaction<T>(Future<T> Function() action, {bool requireNew});

  Stream<List<model.Workout>> getAllRoutines();
  Future<List<model.Workout>> getAllRoutinesFuture();
  Future<model.Workout> getRoutine(String id);
  Future<void> insertRoutine(model.Workout routine);
  Future<void> deleteRoutine(String id);
  Future<void> updateRoutine(model.Workout routine);
  Future<void> writeAllRoutines(List<model.Workout> routines);
  Future<void> overwriteAllRoutineExercises(
      List<model.WorkoutExercisable> routineExercises);

  Stream<List<model.GTRoutineFolder>> watchRoutineFolders();
  Future<void> insertRoutineFolder(model.GTRoutineFolder folder);
  Future<void> deleteRoutineFolder(String id);
  Future<void> updateRoutineFolder(model.GTRoutineFolder folder);
  Future writeAllRoutineFolders(List<model.GTRoutineFolder> folders);

  Stream<List<model.Workout>> getAllHistoryWorkouts();
  Future<List<model.Workout>> getAllHistoryWorkoutsFuture();
  Future<model.Workout> getHistoryWorkout(String id);
  Future<void> insertHistoryWorkout(model.Workout workout);
  Future<void> deleteHistoryWorkout(String id);
  Future<void> updateHistoryWorkout(model.Workout workout);
  Future<void> writeAllHistoryWorkouts(List<model.Workout> routines);
  Future<void> overwriteAllHistoryWorkoutExercises(
      List<model.WorkoutExercisable> historyWorkoutExercises);

  Stream<List<model.Exercise>> getAllCustomExercises();
  Future<void> insertCustomExercise(model.Exercise exercise);
  Future<void> deleteCustomExercise(String id);
  Future<void> updateCustomExercise(model.Exercise exercise);
  Future<void> writeAllCustomExercises(List<model.Exercise> exercises);

  Stream<Prefs> watchPreferences();
  Future<void> setPreferences(Prefs prefs);

  Stream<Map<String, dynamic>?> watchOngoing();
  Future<void> setOngoing(Map<String, dynamic> ongoing);
  Future deleteOngoing();

  Stream<List<WeightMeasurement>> watchWeightMeasurements();
  Future<void> insertWeightMeasurement(WeightMeasurement measurement);
  Future<void> deleteWeightMeasurement(String id);
  Future<void> updateWeightMeasurement(WeightMeasurement measurement);
  Future<void> setWeightMeasurements(List<WeightMeasurement> measurements);

  Stream<List<model.TaggedFood>> watchFoods();
  Future<void> insertFoods(model.TaggedFood food);
  Future<void> deleteFoods(String id);
  Future<void> updateFoods(model.TaggedFood food);
  Future<void> setFoods(List<model.TaggedFood> foods);

  Stream<List<model.TaggedNutritionGoal>> watchNutritionGoals();
  Future<void> insertNutritionGoal(model.TaggedNutritionGoal goal);
  Future<void> deleteNutritionGoal(DateTime date);
  Future<void> updateNutritionGoal(model.TaggedNutritionGoal goal);
  Future<void> setNutritionGoals(List<model.TaggedNutritionGoal> goals);

  Stream<Map<String, model.Food>> watchCustomBarcodeFoods();
  Future<void> insertCustomBarcodeFood(String barcode, model.Food food);
  Future<void> deleteCustomBarcodeFood(String barcode);
  Future<void> setCustomBarcodeFoods(Map<String, model.Food> foods);

  Stream<List<model.Food>> watchFavoriteFoods();
  Future<void> insertFavoriteFood(String id);
  Future<void> deleteFavoriteFood(String id);
  Future<void> setFavoriteFoods(List<String> ids);

  Stream<Map<DateTime, Map<String, model.NutritionCategory>>>
      watchNutritionCategories();
  Future<void> insertNutritionCategories(
      DateTime date, Map<String, model.NutritionCategory> categories);
  Future<void> deleteNutritionCategories(DateTime date);
  Future<void> setNutritionCategories(
      Map<DateTime, Map<String, model.NutritionCategory>> categories);

  Stream<List<AchievementCompletion>> watchAchievementCompletions();
  Future<void> insertAchievementCompletion(AchievementCompletion completion);
  Future<void> insertAchievementCompletions(
      List<AchievementCompletion> completions);
  Future<void> deleteAchievementCompletion(String achievementID, int level);
  Future<void> setAchievementCompletions(
      List<AchievementCompletion> completions);

  Stream<List<BodyMeasurement>> watchBodyMeasurements();
  Future<void> insertBodyMeasurement(BodyMeasurement measurement);
  Future<void> deleteBodyMeasurement(String id);
  Future<void> updateBodyMeasurement(BodyMeasurement measurement);
  Future<void> setBodyMeasurements(List<BodyMeasurement> measurements);

  Future clearTheWholeThingIAmAbsolutelySureISwear();
  Future<File> get path;
  Future<void> close();
}

@DriftDatabase(tables: [
  CustomExercises,
  HistoryWorkouts,
  HistoryWorkoutExercises,
  RoutineFolders,
  Routines,
  RoutineExercises,
  Preferences,
  OngoingData,
  WeightMeasurements,
  BodyMeasurements,
  Foods,
  NutritionGoals,
  CustomBarcodeFoods,
  FavoriteFoods,
  NutritionCategories,
  Achievements,
])
class GTDatabaseImpl extends _$GTDatabaseImpl implements GTDatabase {
  GTDatabaseImpl.prod() : super(_openConnection());

  @visibleForTesting
  GTDatabaseImpl.withQueryExecutor(super.e);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(preferences).insert(Prefs.defaultValue);
          await into(nutritionGoals).insert(model.TaggedNutritionGoal(
            date: DateTime.now(),
            value: model_nutrition.NutritionGoal.defaultGoal,
          ).toInsertable());
        },
        onUpgrade: (m, from, to) async {
          // Run migration steps without foreign keys and re-enable them later
          // (https://drift.simonbinder.eu/docs/advanced-features/migrations/#tips)
          // await customStatement('PRAGMA foreign_keys = OFF');

          globalLogger.w("[GTDatabase] Running migration [$from->$to]");

          await m.runMigrationSteps(
            from: from,
            to: to,
            steps: migrationSteps(
              from2To3: (m, schema) async {
                await m.addColumn(
                  schema.routineExercises,
                  schema.routineExercises.supersedesId,
                );
                await m.addColumn(
                  schema.historyWorkoutExercises,
                  schema.historyWorkoutExercises.supersedesId,
                );
              },
              from3To4: (m, schema) async {
                await m.createTable(schema.routineFolders);
                await m.addColumn(schema.routines, schema.routines.folderId);
              },
              from4To5: (m, schema) async {
                await m.addColumn(
                  schema.routineExercises,
                  schema.routineExercises.rpe,
                );
                await m.addColumn(
                  schema.historyWorkoutExercises,
                  schema.historyWorkoutExercises.rpe,
                );
              },
              from5To6: (m, schema) async {
                await m.createTable(schema.foods);
                await m.createTable(schema.nutritionGoals);
              },
              from6To7: (m, schema) async {
                await m.createTable(schema.customBarcodeFoods);
                await m.createTable(schema.favoriteFoods);
              },
              from7To8: (m, schema) async {
                await m.createTable(schema.nutritionCategories);
              },
              from8To9: (m, schema) async {
                await m.addColumn(
                  schema.customExercises,
                  schema.customExercises.equipment,
                );
                await m.addColumn(
                  schema.historyWorkoutExercises,
                  schema.historyWorkoutExercises.equipment,
                );
                await m.addColumn(
                  schema.routineExercises,
                  schema.routineExercises.equipment,
                );

                // Update existing exercises with equipment
                await m.database.transaction(() async {
                  for (final exercise in exerciseStandardLibraryAsList) {
                    await (m.database.update((m.database as GTDatabaseImpl)
                            .historyWorkoutExercises)
                          ..where((tbl) =>
                              tbl.libraryExerciseId.equals(exercise.id)))
                        .write(HistoryWorkoutExercisesCompanion(
                            // ignore: deprecated_member_use_from_same_package
                            equipment: Value(exercise.equipment)));
                    await (m.database.update(
                            (m.database as GTDatabaseImpl).routineExercises)
                          ..where((tbl) =>
                              tbl.libraryExerciseId.equals(exercise.id)))
                        .write(RoutineExercisesCompanion(
                            // ignore: deprecated_member_use_from_same_package
                            equipment: Value(exercise.equipment)));
                  }
                });
              },
              from9To10: (m, schema) async {
                await m.createTable(schema.achievements);
              },
              from10To11: (m, schema) async {
                await m.createTable(schema.bodyMeasurements);
              },
            ),
          );

          // if (kDebugMode) {
          //   // Fail if the migration broke foreign keys
          //   final wrongForeignKeys =
          //       await customSelect('PRAGMA foreign_key_check').get();
          //   assert(wrongForeignKeys.isEmpty,
          //       '${wrongForeignKeys.map((e) => e.data).toList()}');
          // }

          // await customStatement('PRAGMA foreign_keys = ON;');
        },
        beforeOpen: (details) async {
          final nutritionGoalCount = await (select(nutritionGoals)).get();
          if (nutritionGoalCount.isEmpty) {
            await into(nutritionGoals).insert(model.TaggedNutritionGoal(
              date: DateTime.now(),
              value: model_nutrition.NutritionGoal.defaultGoal,
            ).toInsertable());
          }

          final nutritionCategoriesCount =
              await (select(nutritionCategories)).get();
          if (nutritionCategoriesCount.isEmpty) {
            await into(nutritionCategories).insert(NutritionCategoriesCompanion(
              referenceDate: Value(DateTime.now()),
              jsonData: Value(jsonEncode([])),
            ));
          }

          if (kDebugMode) {
            await validateDatabaseSchema();
          }
        },
      );

  @override
  int get schemaVersion => DATABASE_VERSION;

  @override
  Stream<List<model.Workout>> getAllRoutines() {
    logger.i("Getting all routines");

    final query = select(routines)
      ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]);
    final routineStream = query.watch();

    return routineStream.switchMap((routines) {
      final idToRoutine = {for (var routine in routines) routine.id: routine};
      final ids = idToRoutine.keys;

      final folderQuery = select(routineFolders);
      final folderStream = folderQuery.watch();

      return folderStream.switchMap((dbFolders) {
        final idToFolder = {
          for (var folder in dbFolders) folder.id: folder,
        };

        final exQuery = select(routineExercises)
          ..where((routineExercises) => routineExercises.routineId.isIn(ids));

        return exQuery.watch().map((rows) {
          final idToExs = <String, List<ConcreteExercise>>{};

          for (final row in rows) {
            idToExs.putIfAbsent(row.routineId, () => []).add(row);
          }

          return [
            for (var id in ids)
              workoutFromDatabase(idToRoutine[id]!, idToExs[id] ?? [],
                  dbFolder: idToFolder[idToRoutine[id]!.folderId]),
          ];
        });
      });
    });
  }

  @override
  Future<List<model.Workout>> getAllRoutinesFuture() => getAllRoutines().first;

  @override
  Future<model.Workout> getRoutine(String id) async {
    final routine =
        await (select(routines)..where((tbl) => tbl.id.equals(id))).getSingle();

    final rawExercises = await (select(routineExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    final folder = routine.folderId != null
        ? await (select(routineFolders)
              ..where((tbl) => tbl.id.equals(routine.folderId!)))
            .getSingle()
        : null;

    return workoutFromDatabase(routine, rawExercises, dbFolder: folder);
  }

  @override
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

  @override
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

  @override
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

  @override
  Future writeAllRoutines(List<model.Workout> routines) {
    return transaction(() async {
      await batch((batch) {
        batch.deleteAll(this.routines);
        batch.insertAll(
          this.routines,
          routines.toSortedRoutineInsertables(),
        );
      });
      await overwriteAllRoutineExercises(routines.flattenedExercises);
    });
  }

  @override
  Future<void> overwriteAllRoutineExercises(
      List<model.WorkoutExercisable> routineExercises) async {
    final routineExerciseInsertables = routineExercises
        .fold(
          <String, List<model.WorkoutExercisable>>{},
          (m, r) {
            return m..putIfAbsent(r.workoutID!, () => []).add(r);
          },
        )
        .values
        .expand((list) => list.toSortedInsertables());
    await delete(this.routineExercises).go();
    await batch(
        (b) => b.insertAll(this.routineExercises, routineExerciseInsertables));
  }

  @override
  Stream<List<model.GTRoutineFolder>> watchRoutineFolders() {
    return select(routineFolders)
        .watch()
        .map((l) => [for (final row in l) folderFromDatabase(row)]);
  }

  @override
  Future<void> insertRoutineFolder(model.GTRoutineFolder folder) async {
    await into(routineFolders).insert(folder.toInsertable());
    await _recomputeFolderSortOrders();
  }

  @override
  Future<void> deleteRoutineFolder(String id) async {
    final allRoutines = await (select(routines)
          ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
        .get();
    final routinesValues = allRoutines
        .where((element) => element.folderId == id)
        .toList(growable: false);

    await batch((batch) {
      batch.deleteWhere(routineFolders, (tbl) => tbl.id.equals(id));
      int counter = allRoutines.length;
      for (final routine in routinesValues) {
        batch.update(
          routines,
          RoutinesCompanion(
            folderId: const Value(null),
            sortOrder: Value(counter++),
          ),
          where: (tbl) => tbl.id.equals(routine.id),
        );
      }
    });

    await _recomputeFolderSortOrders();
  }

  @override
  Future<void> updateRoutineFolder(model.GTRoutineFolder folder) async {
    await (update(routineFolders).replace(folder.toInsertable()));
  }

  @override
  Future writeAllRoutineFolders(List<model.GTRoutineFolder> folders) {
    return batch((batch) {
      batch.deleteWhere(routineFolders, (_) => const Constant(true));
      batch.insertAll(routineFolders, folders.map((f) => f.toInsertable()));
    });
  }

  Future<void> _recomputeFolderSortOrders() async {
    // Recompute sort orders
    final query = select(routineFolders)
      ..orderBy([(r) => OrderingTerm.asc(r.sortOrder)]);
    final folders = await query.get();
    final idToSortOrder = {
      for (int i = 0; i < folders.length; i++) folders[i].id: i
    };
    return batch((batch) {
      for (final entry in idToSortOrder.entries) {
        batch.update(
          routineFolders,
          RoutineFoldersCompanion(sortOrder: Value(entry.value)),
          where: (tbl) => tbl.id.equals(entry.key),
        );
      }
    });
  }

  @override
  Stream<List<model.Workout>> getAllHistoryWorkouts() {
    logger.i("Getting all history workouts");

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
            historyWorkoutFromDatabase(idToWorkout[id]!, idToItems[id] ?? []),
        ];
      });
    });
  }

  @override
  Future<List<model.Workout>> getAllHistoryWorkoutsFuture() =>
      getAllHistoryWorkouts().first;

  @override
  Future<model.Workout> getHistoryWorkout(String id) async {
    final workout = await (select(historyWorkouts)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    final rawExercises = await (select(historyWorkoutExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .get();

    return historyWorkoutFromDatabase(workout, rawExercises);
  }

  @override
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

  @override
  Future<void> deleteHistoryWorkout(String id) async {
    await (delete(historyWorkouts)..where((tbl) => tbl.id.equals(id))).go();
    await (delete(historyWorkoutExercises)
          ..where((tbl) => tbl.routineId.equals(id)))
        .go();
  }

  @override
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

  @override
  Future writeAllHistoryWorkouts(List<model.Workout> historyWorkouts) {
    return transaction(() async {
      await batch((batch) {
        batch.deleteAll(this.historyWorkouts);
        batch.insertAll(
          this.historyWorkouts,
          historyWorkouts.toSortedHistoryWorkoutInsertables(),
        );
      });
      await overwriteAllHistoryWorkoutExercises(
          historyWorkouts.flattenedExercises);
    });
  }

  @override
  Future<void> overwriteAllHistoryWorkoutExercises(
      List<model.WorkoutExercisable> historyWorkoutExercises) async {
    final historyExerciseInsertables = historyWorkoutExercises
        .fold(
          <String, List<model.WorkoutExercisable>>{},
          (m, r) {
            return m..putIfAbsent(r.workoutID!, () => []).add(r);
          },
        )
        .values
        .expand((list) => list.toSortedInsertables());
    await delete(this.historyWorkoutExercises).go();
    await batch((b) =>
        b.insertAll(this.historyWorkoutExercises, historyExerciseInsertables));
  }

  @override
  Stream<List<model.Exercise>> getAllCustomExercises() {
    logger.i("Getting all custom exercises");
    return select(customExercises).watch().map((rows) {
      return [for (final row in rows) exerciseFromData(row)];
    });
  }

  @override
  Future<void> insertCustomExercise(model.Exercise exercise) async {
    await into(customExercises).insert(exercise.toInsertable());
  }

  @override
  Future<void> deleteCustomExercise(String id) async {
    await (delete(customExercises)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateCustomExercise(model.Exercise exercise) async {
    await (update(customExercises).replace(exercise.toInsertable()));
  }

  @override
  Future<void> writeAllCustomExercises(exercises) async {
    return batch((batch) {
      batch.deleteAll(customExercises);
      batch.insertAll(
        customExercises,
        [for (final ex in exercises) ex.toInsertable()],
      );
    });
  }

  @override
  Stream<Prefs> watchPreferences() {
    return select(preferences)
        .watch()
        .map((l) => l.isEmpty ? Prefs.defaultValue : Prefs.fromDatabase(l[0]));
  }

  @override
  Future<void> setPreferences(Prefs prefs) {
    return transaction(() async {
      await delete(preferences).go();
      await into(preferences).insert(prefs);
    });
  }

  @override
  Stream<Map<String, dynamic>?> watchOngoing() {
    return select(ongoingData).watch().map((l) {
      if (l.isEmpty) return null;
      return jsonDecode(l[0].data);
    });
  }

  @override
  Future<void> setOngoing(Map<String, dynamic> ongoing) {
    return transaction(() async {
      await deleteOngoing();
      await into(ongoingData)
          .insert(OngoingDataCompanion(data: Value(jsonEncode(ongoing))));
    });
  }

  @override
  Future deleteOngoing() {
    return delete(ongoingData).go();
  }

  @override
  Stream<List<WeightMeasurement>> watchWeightMeasurements() {
    final query = select(weightMeasurements)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
    return query.watch();
  }

  @override
  Future<void> insertWeightMeasurement(WeightMeasurement measurement) {
    return into(weightMeasurements).insert(measurement);
  }

  @override
  Future<void> deleteWeightMeasurement(String id) {
    return (delete(weightMeasurements)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateWeightMeasurement(WeightMeasurement measurement) {
    return (update(weightMeasurements).replace(measurement));
  }

  @override
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

  @override
  Stream<List<model.TaggedFood>> watchFoods() {
    final query = select(foods)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateAdded)]);
    return query.watch().map((foods) {
      return foods.map((food) => foodFromDatabase(food)).toList();
    });
  }

  @override
  Future<void> insertFoods(model.TaggedFood food) {
    return into(foods).insert(food.toInsertable(generateInsertionDate: true));
  }

  @override
  Future<void> deleteFoods(String id) {
    return (delete(foods)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateFoods(model.TaggedFood food) async {
    final oldFood = await (select(foods)
          ..where((tbl) => tbl.id.equals(food.value.id!)))
        .getSingle();
    await update(foods)
        .replace(food.toInsertable(generateInsertionDate: false).copyWith(
              dateAdded: Value(oldFood.dateAdded),
            ));
  }

  @override
  Future<void> setFoods(List<model.TaggedFood> foods) {
    return transaction(() async {
      await delete(this.foods).go();
      await batch((batch) {
        for (final food in foods) {
          final insertable = food.toInsertable(generateInsertionDate: false);
          batch.insert(this.foods,
              insertable.copyWith(dateAdded: insertable.referenceDate));
        }
      });
    });
  }

  @override
  Stream<List<model.TaggedNutritionGoal>> watchNutritionGoals() {
    final query = select(nutritionGoals)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.referenceDate)]);
    return query.watch().map((goals) {
      return goals.map((goal) => goalFromDatabase(goal)).toList();
    });
  }

  @override
  Future<void> insertNutritionGoal(model.TaggedNutritionGoal goal) {
    return into(nutritionGoals).insert(goal.toInsertable());
  }

  @override
  Future<void> deleteNutritionGoal(DateTime date) {
    return (delete(nutritionGoals)
          ..where((tbl) => tbl.id.equals(date.toIso8601String())))
        .go();
  }

  @override
  Future<void> updateNutritionGoal(model.TaggedNutritionGoal goal) async {
    await update(nutritionGoals).replace(goal.toInsertable());
  }

  @override
  Future<void> setNutritionGoals(List<model.TaggedNutritionGoal> goals) {
    return transaction(() async {
      await delete(nutritionGoals).go();
      await batch((batch) {
        for (final goal in goals) {
          batch.insert(nutritionGoals, goal.toInsertable());
        }
      });
    });
  }

  @override
  Stream<Map<String, model.Food>> watchCustomBarcodeFoods() {
    return select(customBarcodeFoods).watch().map((foods) {
      return {
        for (final food in foods)
          food.barcode: model.Food.fromJson(jsonDecode(food.jsonData))
      };
    });
  }

  @override
  Future<void> insertCustomBarcodeFood(String barcode, model.Food food) {
    return into(customBarcodeFoods).insert(CustomBarcodeFoodsCompanion(
      barcode: Value(barcode),
      jsonData: Value(jsonEncode(food.toJson())),
    ));
  }

  @override
  Future<void> deleteCustomBarcodeFood(String barcode) {
    return (delete(customBarcodeFoods)
          ..where((tbl) => tbl.barcode.equals(barcode)))
        .go();
  }

  @override
  Future<void> setCustomBarcodeFoods(Map<String, model.Food> foods) {
    return transaction(() async {
      await delete(customBarcodeFoods).go();
      await batch((batch) {
        for (final entry in foods.entries) {
          batch.insert(
            customBarcodeFoods,
            CustomBarcodeFoodsCompanion(
              barcode: Value(entry.key),
              jsonData: Value(jsonEncode(entry.value.toJson())),
            ),
          );
        }
      });
    });
  }

  @override
  Stream<List<model.Food>> watchFavoriteFoods() {
    return select(favoriteFoods).watch().switchMap((foodIDs) {
      final ids = foodIDs.map((e) => e.foodId).toList();
      return select(foods).watch().map((foods) => foods
          .where((f) => ids.contains(f.id))
          .map((dbfood) => model.Food.fromJson(jsonDecode(dbfood.jsonData)))
          .toList());
    });
  }

  @override
  Future<void> insertFavoriteFood(String id) {
    return into(favoriteFoods)
        .insert(FavoriteFoodsCompanion(foodId: Value(id)));
  }

  @override
  Future<void> deleteFavoriteFood(String id) {
    return (delete(favoriteFoods)..where((tbl) => tbl.foodId.equals(id))).go();
  }

  @override
  Future<void> setFavoriteFoods(List<String> ids) {
    return transaction(() async {
      await delete(favoriteFoods).go();
      await batch((batch) {
        for (final id in ids) {
          batch.insert(
              favoriteFoods, FavoriteFoodsCompanion(foodId: Value(id)));
        }
      });
    });
  }

  @override
  Stream<Map<DateTime, Map<String, model.NutritionCategory>>>
      watchNutritionCategories() {
    return select(nutritionCategories).watch().map((categories) {
      return {
        for (final category in categories)
          category.referenceDate: Map.fromEntries(
              (jsonDecode(category.jsonData) as List)
                  .map((e) => model.NutritionCategory.fromJson(e))
                  .map((c) => MapEntry(c.name, c))),
      };
    });
  }

  @override
  Future<void> insertNutritionCategories(
      DateTime date, Map<String, model.NutritionCategory> categories) {
    return into(nutritionCategories).insert(NutritionCategoriesCompanion(
      referenceDate: Value(date),
      jsonData:
          Value(jsonEncode(categories.values.map((e) => e.toJson()).toList())),
    ));
  }

  @override
  Future<void> deleteNutritionCategories(DateTime date) {
    return (delete(nutritionCategories)
          ..where((tbl) => tbl.referenceDate.equals(date)))
        .go();
  }

  @override
  Future<void> setNutritionCategories(
      Map<DateTime, Map<String, model.NutritionCategory>> categories) {
    return transaction(() async {
      await delete(nutritionCategories).go();
      await batch((batch) {
        for (final entry in categories.entries) {
          batch.insert(
            nutritionCategories,
            NutritionCategoriesCompanion(
              referenceDate: Value(entry.key),
              jsonData: Value(jsonEncode(
                  entry.value.values.map((e) => e.toJson()).toList())),
            ),
          );
        }
      });
    });
  }

  @override
  Stream<List<AchievementCompletion>> watchAchievementCompletions() {
    return select(achievements).watch();
  }

  @override
  Future<void> insertAchievementCompletion(AchievementCompletion completion) {
    return into(achievements).insert(
      AchievementsCompanion(
        achievementID: Value(completion.achievementID),
        level: Value(completion.level),
        completedAt: Value(completion.completedAt),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  @override
  Future<void> insertAchievementCompletions(
      List<AchievementCompletion> completions) {
    return batch((batch) async {
      batch.insertAll(
        achievements,
        completions
            .map(
              (completion) => AchievementsCompanion.insert(
                achievementID: completion.achievementID,
                level: completion.level,
                completedAt: completion.completedAt,
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  @override
  Future<void> deleteAchievementCompletion(String achievementID, int level) {
    return (delete(achievements)
          ..where((tbl) {
            return tbl.achievementID.equals(achievementID) &
                tbl.level.equals(level);
          }))
        .go();
  }

  @override
  Future<void> setAchievementCompletions(
      List<AchievementCompletion> completions) {
    return transaction(() async {
      await delete(achievements).go();
      await batch((batch) {
        batch.insertAll(
          achievements,
          completions
              .map(
                (completion) => AchievementsCompanion.insert(
                  achievementID: completion.achievementID,
                  level: completion.level,
                  completedAt: completion.completedAt,
                ),
              )
              .toList(),
          mode: InsertMode.insertOrIgnore,
        );
      });
    });
  }

  @override
  Stream<List<BodyMeasurement>> watchBodyMeasurements() {
    final query = select(bodyMeasurements)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
    return query.watch();
  }

  @override
  Future<void> insertBodyMeasurement(BodyMeasurement measurement) {
    return into(bodyMeasurements).insert(measurement);
  }

  @override
  Future<void> deleteBodyMeasurement(String id) {
    return (delete(bodyMeasurements)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateBodyMeasurement(BodyMeasurement measurement) {
    return (update(bodyMeasurements).replace(measurement));
  }

  @override
  Future<void> setBodyMeasurements(List<BodyMeasurement> measurements) {
    return transaction(() async {
      await delete(bodyMeasurements).go();
      await batch((batch) {
        for (final measurement in measurements) {
          batch.insert(bodyMeasurements, measurement);
        }
      });
    });
  }

  @override
  Future clearTheWholeThingIAmAbsolutelySureISwear() async {
    for (var table in allTables) {
      await table.deleteAll();
    }
  }

  @override
  Future<File> get path async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'db.sqlite'));
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
    supersedesID: null,
    rpe: null,
    equipment: row.equipment ?? GTGymEquipment.none,
  );
}

extension WorkoutListDatabaseUtils on List<model.Workout> {
  List<RoutinesCompanion> toSortedRoutineInsertables() {
    final Map<String?, int> counts = {};
    final List<RoutinesCompanion> insertables = [];
    for (int i = 0; i < length; i++) {
      counts.putIfAbsent(this[i].folder?.id, () => 0);
      insertables.add(this[i]
          .toRoutineInsertable()
          .copyWith(sortOrder: Value(counts[this[i].folder?.id]!)));
      counts[this[i].folder?.id] = counts[this[i].folder?.id]! + 1;
    }
    return insertables;
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
      folderId: Value(folder?.id),
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
      supersedesId: Value.absentIfNull(supersedesID),
      rpe:
          this is model.Exercise ? Value(asExercise.rpe) : const Value.absent(),
      equipment: this is model.Exercise
          ? Value(asExercise.gymEquipment)
          : const Value(GTGymEquipment.none),
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
      equipment: Value(gymEquipment),
    );
  }
}

extension FolderDatabaseUtils on model.GTRoutineFolder {
  RoutineFoldersCompanion toInsertable() {
    return RoutineFoldersCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }
}

extension on model.TaggedFood {
  FoodsCompanion toInsertable({
    required bool generateInsertionDate,
  }) {
    assert(value.id != null);
    return FoodsCompanion(
      id: Value(value.id!),
      referenceDate: Value(date),
      dateAdded:
          generateInsertionDate ? Value(DateTime.now()) : const Value.absent(),
      jsonData: Value(jsonEncode(value.toJson())),
    );
  }
}

extension on model.TaggedNutritionGoal {
  String get id => date.toIso8601String();

  NutritionGoalsCompanion toInsertable() {
    return NutritionGoalsCompanion(
      id: Value(id),
      referenceDate: Value(date),
      calories: Value(value.dailyCalories),
      fat: Value(value.dailyFat),
      carbs: Value(value.dailyCarbs),
      protein: Value(value.dailyProtein),
    );
  }
}

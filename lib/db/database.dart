import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations_native.dart';
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
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart' as model;
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart'
    as model_nutrition
    show NutritionGoal;
import 'package:gymtracker/struct/nutrition.dart' as model hide NutritionGoal;
import 'package:gymtracker/utils/extensions.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

export 'package:gymtracker/db/model/tables/foods.dart';
export 'package:gymtracker/db/model/tables/nutrition_categories.dart';
export 'package:gymtracker/db/model/tables/nutrition_goals.dart';

part 'database.g.dart';

// Used in the generated code
const _uuid = Uuid();

const DATABASE_VERSION = 16;

abstract class GTDatabase extends GeneratedDatabase with SyncableDatabase {
  GTDatabase(super.e);

  /// The currently logged-in user's ID, or null if no user is logged in.
  /// When set, all syncable-table queries filter by this user ID.
  String? get currentUserId;

  /// Sets the current user ID and refreshes all active syncable-table streams.
  void setCurrentUserId(String? id);

  Future<T> transaction<T>(Future<T> Function() action, {bool requireNew});

  Stream<List<model.Workout>> getAllRoutines();
  Future<List<model.Workout>> getAllRoutinesFuture();
  Future<model.Workout> getRoutine(String id);
  Future<void> insertRoutine(model.Workout routine);
  Future<void> deleteRoutine(String id);
  Future<void> updateRoutine(model.Workout routine);
  Future<void> writeAllRoutines(List<model.Workout> routines);
  Future<void> overwriteAllRoutineExercises(
    List<model.WorkoutExercisable> routineExercises,
  );

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
    List<model.WorkoutExercisable> historyWorkoutExercises,
  );

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
  Future<void> deleteNutritionCategories(DateTime date);
  Future<void> setNutritionCategories(
    Map<DateTime, Map<String, model.NutritionCategory>> categories,
  );

  Stream<List<AchievementCompletion>> watchAchievementCompletions();
  Future<void> insertAchievementCompletion(AchievementCompletion completion);
  Future<void> insertAchievementCompletions(
    List<AchievementCompletion> completions,
  );
  Future<void> deleteAchievementCompletion(String achievementID, int level);
  Future<void> setAchievementCompletions(
    List<AchievementCompletion> completions,
  );

  Stream<List<BodyMeasurement>> watchBodyMeasurements();
  Future<void> insertBodyMeasurement(BodyMeasurement measurement);
  Future<void> deleteBodyMeasurement(String id);
  Future<void> updateBodyMeasurement(BodyMeasurement measurement);
  Future<void> setBodyMeasurements(List<BodyMeasurement> measurements);

  Future<void> touchStaleTimestamps(String userId);

  Future clearTheWholeThingIAmAbsolutelySureISwear();
  Future<File> get path;
  Future<void> close();
}

@DriftDatabase(
  tables: [
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
  ],
)
class GTDatabaseImpl extends _$GTDatabaseImpl
    with SyncableDatabase
    implements GTDatabase {
  GTDatabaseImpl.prod() : super(_openConnection());

  @visibleForTesting
  GTDatabaseImpl.withQueryExecutor(super.e);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(preferences).insert(Prefs.defaultValue);
      await into(nutritionGoals).insert(
        model.TaggedNutritionGoal(
          date: DateTime.now(),
          value: model_nutrition.NutritionGoal.defaultGoal,
        ).toInsertable(),
      );
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
                await (m.database.update(
                      (m.database as GTDatabaseImpl).historyWorkoutExercises,
                    )..where(
                      (tbl) => tbl.libraryExerciseId.equals(exercise.id),
                    ))
                    .write(
                      HistoryWorkoutExercisesCompanion(
                        // ignore: deprecated_member_use_from_same_package
                        equipment: Value(exercise.equipment),
                      ),
                    );
                await (m.database.update(
                      (m.database as GTDatabaseImpl).routineExercises,
                    )..where(
                      (tbl) => tbl.libraryExerciseId.equals(exercise.id),
                    ))
                    .write(
                      RoutineExercisesCompanion(
                        // ignore: deprecated_member_use_from_same_package
                        equipment: Value(exercise.equipment),
                      ),
                    );
              }
            });
          },
          from9To10: (m, schema) async {
            await m.createTable(schema.achievements);
          },
          from10To11: (m, schema) async {
            await m.createTable(schema.bodyMeasurements);
          },
          from11To12: (m, schema) async {
            await m.addColumn(
              schema.preferences,
              schema.preferences.onboardingComplete,
            );
          },
          from12To13: (m, schema) async {
            await m.createTable(schema.achievementsV2);

            // Copy data from the old achievements table to the new one
            final achievementsCount = await m.database
                .customSelect("SELECT COUNT(*) as count FROM achievements")
                .getSingle();
            if (achievementsCount.readWithType(DriftSqlType.int, "count") > 0) {
              await m.database.transaction(() async {
                // NOTE: The old table doesn't have fields other than achievement_i_d, level and completed_at,
                // so we only copy those two fields and provide default values for the new fields.
                await m.database.customStatement('''
                  INSERT INTO achievements_v2 (achievement_id, level, completed_at, id, updated_at, deleted, user_id)
                  SELECT achievement_i_d, level, completed_at, lower(hex(randomblob(16))), completed_at as updated_at, 0, NULL
                  FROM achievements;
                ''');
                await m.database.customStatement('DROP TABLE achievements;');
              });
            }

            final columns = [
              (schema.customExercises, schema.customExercises.updatedAt),
              (schema.customExercises, schema.customExercises.deleted),
              (schema.customExercises, schema.customExercises.userId),

              (schema.historyWorkouts, schema.historyWorkouts.updatedAt),
              (schema.historyWorkouts, schema.historyWorkouts.deleted),
              (schema.historyWorkouts, schema.historyWorkouts.userId),

              (
                schema.historyWorkoutExercises,
                schema.historyWorkoutExercises.updatedAt,
              ),
              (
                schema.historyWorkoutExercises,
                schema.historyWorkoutExercises.deleted,
              ),
              (
                schema.historyWorkoutExercises,
                schema.historyWorkoutExercises.userId,
              ),

              (schema.routineFolders, schema.routineFolders.updatedAt),
              (schema.routineFolders, schema.routineFolders.deleted),
              (schema.routineFolders, schema.routineFolders.userId),

              (schema.routines, schema.routines.updatedAt),
              (schema.routines, schema.routines.deleted),
              (schema.routines, schema.routines.userId),

              (schema.routineExercises, schema.routineExercises.updatedAt),
              (schema.routineExercises, schema.routineExercises.deleted),
              (schema.routineExercises, schema.routineExercises.userId),
            ];

            for (final (table, column) in columns) {
              await m.addColumn(table, column);
            }
          },
          from13To14: (m, schema) async {
            final columns = [
              (schema.foods, schema.foods.updatedAt),
              (schema.foods, schema.foods.deleted),
              (schema.foods, schema.foods.userId),

              (schema.customBarcodeFoods, schema.customBarcodeFoods.updatedAt),
              (schema.customBarcodeFoods, schema.customBarcodeFoods.deleted),
              (schema.customBarcodeFoods, schema.customBarcodeFoods.userId),

              (schema.favoriteFoods, schema.favoriteFoods.updatedAt),
              (schema.favoriteFoods, schema.favoriteFoods.deleted),
              (schema.favoriteFoods, schema.favoriteFoods.userId),

              (schema.weightMeasurements, schema.weightMeasurements.updatedAt),
              (schema.weightMeasurements, schema.weightMeasurements.deleted),
              (schema.weightMeasurements, schema.weightMeasurements.userId),

              (schema.bodyMeasurements, schema.bodyMeasurements.updatedAt),
              (schema.bodyMeasurements, schema.bodyMeasurements.deleted),
              (schema.bodyMeasurements, schema.bodyMeasurements.userId),

              (schema.nutritionCategories, schema.nutritionCategories.id),
              (
                schema.nutritionCategories,
                schema.nutritionCategories.updatedAt,
              ),
              (schema.nutritionCategories, schema.nutritionCategories.deleted),
              (schema.nutritionCategories, schema.nutritionCategories.userId),

              (schema.nutritionGoals, schema.nutritionGoals.updatedAt),
              (schema.nutritionGoals, schema.nutritionGoals.deleted),
              (schema.nutritionGoals, schema.nutritionGoals.userId),
            ];

            for (final (table, column) in columns) {
              await m.addColumn(table, column);
            }
          },
          from14To15: (m, schema) async {
            await m.database.transaction(() async {
              // Update the primary key of nutrition_categories to the reference date ad midnight UTC
              final rows = await m.database
                  .select(schema.nutritionCategories)
                  .get();
              final mapped = rows.map(
                (row) => DBNutritionCategory(
                  id: row
                      .readWithType<DateTime>(
                        DriftSqlType.dateTime,
                        'reference_date',
                      )
                      .toUtc()
                      .toIso8601String(),
                  referenceDate: row.readWithType<DateTime>(
                    DriftSqlType.dateTime,
                    'reference_date',
                  ),
                  jsonData: row.readWithType<String>(
                    DriftSqlType.string,
                    'json_data',
                  ),
                  updatedAt: row.readWithType<DateTime>(
                    DriftSqlType.dateTime,
                    'updated_at',
                  ),
                  deleted: row.readWithType<bool>(DriftSqlType.bool, 'deleted'),
                  userId: row.readNullableWithType<String>(
                    DriftSqlType.string,
                    'user_id',
                  ),
                ),
              );
              await m.database.delete(schema.nutritionCategories).go();
              await batch((batch) {
                batch.insertAll(
                  schema.nutritionCategories,
                  mapped.map((e) {
                    return RawValuesInsertable<QueryRow>(
                      e.toCompanion().toColumns(false),
                    );
                  }),
                );
              });
              await m.database.customStatement("""
                WITH RankedRecords AS (
                    SELECT 
                        rowid,
                        ROW_NUMBER() OVER (
                            PARTITION BY id, user_id 
                            ORDER BY rowid DESC
                        ) AS rn
                    FROM nutrition_categories
                )
                DELETE FROM nutrition_categories
                WHERE rowid IN (
                    SELECT rowid 
                    FROM RankedRecords 
                    WHERE rn > 1
                );
              """);
            });
            await m.alterTable(TableMigration(schema.nutritionCategories));
          },
          from15To16: (m, schema) async {
            logger.f(
              "Current achievements: ${(await m.database.select(schema.achievementsV2).get()).length}",
            );
            await m.database.customStatement("""
                WITH RankedRecords AS (
                    SELECT 
                        rowid,
                        ROW_NUMBER() OVER (
                            PARTITION BY achievement_id, level, user_id 
                            ORDER BY completed_at ASC
                        ) AS rn
                    FROM achievements_v2
                )
                DELETE FROM achievements_v2
                WHERE rowid IN (
                    SELECT rowid 
                    FROM RankedRecords 
                    WHERE rn > 1
                );
              """);
            logger.f(
              "After deleting: ${(await m.database.select(schema.achievementsV2).get()).length}",
            );
            await m.alterTable(TableMigration(schema.achievementsV2));
            await m.alterTable(TableMigration(schema.customExercises));
            await m.alterTable(TableMigration(schema.foods));
            await m.alterTable(TableMigration(schema.customBarcodeFoods));
            await m.alterTable(TableMigration(schema.favoriteFoods));
            await m.alterTable(TableMigration(schema.historyWorkouts));
            await m.alterTable(TableMigration(schema.historyWorkoutExercises));
            await m.alterTable(TableMigration(schema.weightMeasurements));
            await m.alterTable(TableMigration(schema.bodyMeasurements));
            await m.alterTable(TableMigration(schema.nutritionGoals));
            await m.alterTable(TableMigration(schema.routineFolders));
            await m.alterTable(TableMigration(schema.routines));
            await m.alterTable(TableMigration(schema.routineExercises));
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
        await into(nutritionGoals).insert(
          model.TaggedNutritionGoal(
            date: DateTime.now(),
            value: model_nutrition.NutritionGoal.defaultGoal,
          ).toInsertable(),
        );
      }

      final nutritionCategoriesCount = await (select(
        nutritionCategories,
      )).get();
      if (nutritionCategoriesCount.isEmpty) {
        final utcNow = DateTime.now().toUtc();
        final utcDate = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);
        await into(nutritionCategories).insert(
          NutritionCategoriesCompanion(
            id: Value(utcDate.toIso8601String()),
            referenceDate: Value(utcDate),
            jsonData: const Value('[]'),
            updatedAt: Value(utcNow),
            deleted: const Value(false),
          ),
        );
      }

      if (kDebugMode) {
        await validateDatabaseSchema();
      }
    },
  );

  @override
  int get schemaVersion => DATABASE_VERSION;

  String? _currentUserId;

  @override
  String? get currentUserId => _currentUserId;

  @override
  void setCurrentUserId(String? id) {
    _currentUserId = id;
    // Force all syncable-table streams to re-evaluate their queries.
    notifyUpdates({
      TableUpdate.onTable(routines),
      TableUpdate.onTable(routineExercises),
      TableUpdate.onTable(routineFolders),
      TableUpdate.onTable(historyWorkouts),
      TableUpdate.onTable(historyWorkoutExercises),
      TableUpdate.onTable(customExercises),
      TableUpdate.onTable(achievements),
    });
  }

  /// Returns a filter expression for a `userId` column:
  /// - logged in  -> `userId IS NULL OR userId = currentUserId`
  /// - logged out -> `userId IS NULL`
  Expression<bool> _userIdPredicate(GeneratedColumn<String> col) {
    final uid = _currentUserId;
    if (uid != null) {
      return col.isNull() | col.equals(uid);
    }
    return col.isNull();
  }

  @override
  Stream<List<model.Workout>> getAllRoutines() {
    logger.i("Getting all routines");

    final query = select(routines)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]);
    final routineStream = query.watch();

    return routineStream.switchMap((routines) {
      final idToRoutine = {for (var routine in routines) routine.id: routine};
      final ids = idToRoutine.keys;

      final folderQuery = select(routineFolders)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        );
      final folderStream = folderQuery.watch();

      return folderStream.switchMap((dbFolders) {
        final idToFolder = {for (var folder in dbFolders) folder.id: folder};

        final exQuery = select(routineExercises)
          ..where(
            (tbl) =>
                tbl.routineId.isIn(ids) &
                tbl.deleted.equals(false) &
                _userIdPredicate(tbl.userId),
          );

        return exQuery.watch().map((rows) {
          final idToExs = <String, List<ConcreteExercise>>{};

          for (final row in rows) {
            idToExs.putIfAbsent(row.routineId, () => []).add(row);
          }

          return [
            for (var id in ids)
              workoutFromDatabase(
                idToRoutine[id]!,
                idToExs[id] ?? [],
                dbFolder: idToFolder[idToRoutine[id]!.folderId],
              ),
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
        await (select(routines)..where(
              (tbl) =>
                  tbl.id.equals(id) &
                  tbl.deleted.equals(false) &
                  _userIdPredicate(tbl.userId),
            ))
            .getSingle();

    final rawExercises =
        await (select(routineExercises)..where(
              (tbl) =>
                  tbl.routineId.equals(id) &
                  tbl.deleted.equals(false) &
                  _userIdPredicate(tbl.userId),
            ))
            .get();

    final folder = routine.folderId != null
        ? await (select(routineFolders)..where(
                (tbl) =>
                    tbl.id.equals(routine.folderId!) &
                    tbl.deleted.equals(false) &
                    _userIdPredicate(tbl.userId),
              ))
              .getSingleOrNull()
        : null;

    return workoutFromDatabase(routine, rawExercises, dbFolder: folder);
  }

  @override
  Future<void> insertRoutine(model.Workout routine) async {
    final newSortOrder =
        (await (select(routines)..where(
                  (tbl) =>
                      tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
                ))
                .get())
            .length;
    return batch((batch) {
      batch.insert(
        routines,
        routine
            .toRoutineInsertable(userId: currentUserId)
            .copyWith(sortOrder: Value(newSortOrder)),
      );
      batch.insertAll(
        routineExercises,
        routine.flattenedExercises.toSortedRoutineExerciseInsertables(
          userId: currentUserId,
        ),
      );
    });
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final now = DateTime.now().toUtc();
    final remainingIDs =
        (await (select(routines)
              ..where(
                (tbl) =>
                    tbl.id.isNotValue(id) &
                    tbl.deleted.equals(false) &
                    _userIdPredicate(tbl.userId),
              )
              ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
            .get());
    final idToSortOrder = {
      for (int i = 0; i < remainingIDs.length; i++) remainingIDs[i].id: i,
    };
    return batch((batch) {
      batch.update(
        routines,
        RoutinesCompanion(deleted: const Value(true), updatedAt: Value(now)),
        where: (tbl) => tbl.id.equals(id),
      );
      batch.update(
        routineExercises,
        RoutineExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (tbl) => tbl.routineId.equals(id),
      );
      for (final entry in idToSortOrder.entries) {
        batch.update(
          routines,
          RoutinesCompanion(
            sortOrder: Value(entry.value),
            updatedAt: Value(now),
          ),
          where: (tbl) => tbl.id.equals(entry.key),
        );
      }
    });
  }

  @override
  Future<void> updateRoutine(model.Workout routine) async {
    final now = DateTime.now().toUtc();
    final sortOrder =
        (await (select(routines)..where(
                  (tbl) =>
                      tbl.id.equals(routine.id) & tbl.deleted.equals(false),
                ))
                .getSingle())
            .sortOrder;
    return transaction(() async {
      final oldExercises =
          (await (select(
                routineExercises,
              )..where((tbl) => tbl.routineId.equals(routine.id))).get())
              .map((e) => e.id)
              .toSet();

      final newExerciseIds = routine.flattenedExercises
          .map((e) => e.id)
          .toSet();

      final removedExerciseIds = oldExercises
          .where((id) => !newExerciseIds.contains(id))
          .toList();
      final remainingExerciseIds = oldExercises
          .where((id) => newExerciseIds.contains(id))
          .toList();

      await batch((batch) {
        batch.deleteWhere(routines, (tbl) => tbl.id.equals(routine.id));
        batch.insert(
          routines,
          routine
              .toRoutineInsertable(userId: currentUserId)
              .copyWith(
                sortOrder: Value(sortOrder),
                updatedAt: Value(now),
                deleted: const Value(false),
              ),
        );

        if (removedExerciseIds.isNotEmpty) {
          batch.update(
            routineExercises,
            RoutineExercisesCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
            ),
            where: (tbl) =>
                tbl.id.isIn(removedExerciseIds) & tbl.deleted.equals(false),
          );
        }

        if (remainingExerciseIds.isNotEmpty) {
          batch.deleteWhere(
            routineExercises,
            (tbl) => tbl.id.isIn(remainingExerciseIds),
          );
        }

        batch.insertAll(
          routineExercises,
          routine.flattenedExercises.toSortedRoutineExerciseInsertables(
            userId: currentUserId,
          ),
        );
      });
    });
  }

  @override
  Future writeAllRoutines(List<model.Workout> routines) {
    final now = DateTime.now().toUtc();
    return transaction(() async {
      final oldRoutines =
          await (select(this.routines)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
              ))
              .get();
      // Split the routines into two categories: to delete, and to upsert.
      // The deleted routines are marked as deleted to sync them to the backend.
      // The others routines are inserted, replacing ones already present.
      final toDeleteIds = oldRoutines
          .where((r) => !routines.any((newR) => newR.id == r.id))
          .map((r) => r.id)
          .toList();

      await batch((batch) {
        batch.update(
          this.routines,
          RoutinesCompanion(deleted: const Value(true), updatedAt: Value(now)),
          where: (tbl) => tbl.id.isIn(toDeleteIds) & tbl.deleted.equals(false),
        );
        batch.insertAll(
          this.routines,
          routines.toSortedRoutineInsertables(userId: currentUserId),
          mode: .insertOrReplace,
        );
      });
      await overwriteAllRoutineExercises(routines.flattenedExercises);

      print("DONE OVERWRITING ALL ROUTINES");
    });
  }

  @override
  Future<void> overwriteAllRoutineExercises(
    List<model.WorkoutExercisable> routineExercises,
  ) async {
    final now = DateTime.now().toUtc();
    final routineExerciseInsertables = routineExercises
        .fold(<String, List<model.WorkoutExercisable>>{}, (m, r) {
          return m..putIfAbsent(r.workoutID!, () => []).add(r);
        })
        .values
        .expand(
          (list) =>
              list.toSortedRoutineExerciseInsertables(userId: currentUserId),
        );
    await transaction(() async {
      final oldExs =
          await (select(this.routineExercises)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
              ))
              .get();
      final toDeleteIds = oldExs
          .where((r) => !routineExercises.any((newR) => newR.id == r.id))
          .map((r) => r.id)
          .toList();
      final updatedExs = oldExs
          .where((r) => routineExercises.any((newR) => newR.id == r.id))
          .toList();
      final insertedExs = oldExs
          .where((newR) => !oldExs.any((r) => r.id == newR.id))
          .toList();
      await (update(
        this.routineExercises,
      )..where((tbl) => tbl.id.isIn(toDeleteIds))).write(
        RoutineExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch(
        (b) => b.insertAll(
          this.routineExercises,
          routineExerciseInsertables,
          mode: .insertOrReplace,
        ),
      );
    });
  }

  @override
  Stream<List<model.GTRoutineFolder>> watchRoutineFolders() {
    return (select(routineFolders)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch()
        .map((l) => [for (final row in l) folderFromDatabase(row)]);
  }

  @override
  Future<void> insertRoutineFolder(model.GTRoutineFolder folder) async {
    await into(
      routineFolders,
    ).insert(folder.toInsertable(userId: currentUserId));
    await _recomputeFolderSortOrders();
  }

  @override
  Future<void> deleteRoutineFolder(String id) async {
    final now = DateTime.now().toUtc();
    final allRoutines =
        await (select(routines)
              ..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
              )
              ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
            .get();
    final routinesValues = allRoutines
        .where((element) => element.folderId == id)
        .toList(growable: false);

    await batch((batch) {
      batch.update(
        routineFolders,
        RoutineFoldersCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (tbl) => tbl.id.equals(id) & _userIdPredicate(tbl.userId),
      );
      int counter = allRoutines.length;
      for (final routine in routinesValues) {
        batch.update(
          routines,
          RoutinesCompanion(
            folderId: const Value(null),
            sortOrder: Value(counter++),
            updatedAt: Value(now),
          ),
          where: (tbl) =>
              tbl.id.equals(routine.id) & _userIdPredicate(tbl.userId),
        );
      }
    });

    await _recomputeFolderSortOrders();
  }

  @override
  Future<void> updateRoutineFolder(model.GTRoutineFolder folder) async {
    await transaction(() async {
      await (delete(routineFolders)..where(
            (tbl) => tbl.id.equals(folder.id) & _userIdPredicate(tbl.userId),
          ))
          .go();
      await into(routineFolders).insert(
        folder
            .toInsertable(userId: currentUserId)
            .copyWith(
              updatedAt: Value(DateTime.now().toUtc()),
              deleted: const Value(false),
            ),
      );
    });
  }

  @override
  Future writeAllRoutineFolders(List<model.GTRoutineFolder> folders) {
    final now = DateTime.now().toUtc();
    return batch((batch) {
      batch.update(
        routineFolders,
        RoutineFoldersCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (_) => const Constant(true),
      );
      batch.insertAll(
        routineFolders,
        folders.map((f) => f.toInsertable(userId: currentUserId)),
      );
    });
  }

  Future<void> _recomputeFolderSortOrders() async {
    // Recompute sort orders
    final query = select(routineFolders)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(r) => OrderingTerm.asc(r.sortOrder)]);
    final folders = await query.get();
    final idToSortOrder = {
      for (int i = 0; i < folders.length; i++) folders[i].id: i,
    };
    return batch((batch) {
      for (final entry in idToSortOrder.entries) {
        batch.update(
          routineFolders,
          RoutineFoldersCompanion(
            sortOrder: Value(entry.value),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
          where: (tbl) => tbl.id.equals(entry.key),
        );
      }
    });
  }

  @override
  Stream<List<model.Workout>> getAllHistoryWorkouts() {
    logger.i("Getting all history workouts");

    final query = select(historyWorkouts)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([
        (r) =>
            OrderingTerm(expression: r.startingDate, mode: OrderingMode.desc),
      ]);
    final historyStream = query.watch();

    return historyStream.switchMap((history) {
      final idToWorkout = {for (var workout in history) workout.id: workout};
      final ids = idToWorkout.keys;

      final entryQuery = select(historyWorkoutExercises)
        ..where(
          (tbl) =>
              tbl.routineId.isIn(ids) &
              tbl.deleted.equals(false) &
              _userIdPredicate(tbl.userId),
        );

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
    final workout =
        await (select(historyWorkouts)..where(
              (tbl) =>
                  tbl.id.equals(id) &
                  tbl.deleted.equals(false) &
                  _userIdPredicate(tbl.userId),
            ))
            .getSingle();

    final rawExercises =
        await (select(historyWorkoutExercises)..where(
              (tbl) =>
                  tbl.routineId.equals(id) &
                  tbl.deleted.equals(false) &
                  _userIdPredicate(tbl.userId),
            ))
            .get();

    return historyWorkoutFromDatabase(workout, rawExercises);
  }

  Future<void> insertHistoryWorkout(model.Workout workout) async {
    logger.e(workout);
    logger.e(workout.toHistoryWorkoutInsertable(userId: currentUserId));
    logger.e(
      workout.flattenedExercises.toSortedInsertables(userId: currentUserId),
    );
    return batch((batch) {
      batch.insert(
        historyWorkouts,
        workout.toHistoryWorkoutInsertable(userId: currentUserId),
      );
      batch.insertAll(
        historyWorkoutExercises,
        workout.flattenedExercises.toSortedInsertables(userId: currentUserId),
      );
    });
  }

  @override
  Future<void> deleteHistoryWorkout(String id) async {
    final now = DateTime.now().toUtc();
    await (update(historyWorkouts)..where((tbl) => tbl.id.equals(id))).write(
      HistoryWorkoutsCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await (update(
      historyWorkoutExercises,
    )..where((tbl) => tbl.routineId.equals(id))).write(
      HistoryWorkoutExercisesCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateHistoryWorkout(model.Workout workout) async {
    final now = DateTime.now().toUtc();
    return transaction(() async {
      final oldExercises =
          (await (select(
                historyWorkoutExercises,
              )..where((tbl) => tbl.routineId.equals(workout.id))).get())
              .map((e) => e.id)
              .toSet();

      final newExerciseIds = workout.flattenedExercises
          .map((e) => e.id)
          .toSet();

      final removedExerciseIds = oldExercises
          .where((id) => !newExerciseIds.contains(id))
          .toList();
      final remainingExerciseIds = oldExercises
          .where((id) => newExerciseIds.contains(id))
          .toList();

      await batch((batch) {
        batch.deleteWhere(historyWorkouts, (tbl) => tbl.id.equals(workout.id));
        batch.insert(
          historyWorkouts,
          workout
              .toHistoryWorkoutInsertable(userId: currentUserId)
              .copyWith(updatedAt: Value(now), deleted: const Value(false)),
        );

        if (removedExerciseIds.isNotEmpty) {
          batch.update(
            historyWorkoutExercises,
            HistoryWorkoutExercisesCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
            ),
            where: (tbl) =>
                tbl.id.isIn(removedExerciseIds) & tbl.deleted.equals(false),
          );
        }

        if (remainingExerciseIds.isNotEmpty) {
          batch.deleteWhere(
            historyWorkoutExercises,
            (tbl) => tbl.id.isIn(remainingExerciseIds),
          );
        }

        batch.insertAll(
          historyWorkoutExercises,
          workout.flattenedExercises.toSortedInsertables(userId: currentUserId),
        );
      });
    });
  }

  @override
  Future writeAllHistoryWorkouts(List<model.Workout> historyWorkouts) {
    final now = DateTime.now().toUtc();
    return transaction(() async {
      await batch((batch) {
        batch.update(
          this.historyWorkouts,
          HistoryWorkoutsCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
        batch.insertAll(
          this.historyWorkouts,
          historyWorkouts.toSortedHistoryWorkoutInsertables(
            userId: currentUserId,
          ),
        );
      });
      await overwriteAllHistoryWorkoutExercises(
        historyWorkouts.flattenedExercises,
      );
    });
  }

  @override
  Future<void> overwriteAllHistoryWorkoutExercises(
    List<model.WorkoutExercisable> historyWorkoutExercises,
  ) async {
    final now = DateTime.now().toUtc();
    final historyExerciseInsertables = historyWorkoutExercises
        .fold(<String, List<model.WorkoutExercisable>>{}, (m, r) {
          return m..putIfAbsent(r.workoutID!, () => []).add(r);
        })
        .values
        .expand((list) => list.toSortedInsertables(userId: currentUserId));
    await (update(
      this.historyWorkoutExercises,
    )..where((_) => const Constant(true))).write(
      HistoryWorkoutExercisesCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    await batch(
      (b) =>
          b.insertAll(this.historyWorkoutExercises, historyExerciseInsertables),
    );
  }

  @override
  Stream<List<model.Exercise>> getAllCustomExercises() {
    logger.i("Getting all custom exercises");
    return (select(customExercises)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch()
        .map((rows) {
          return [for (final row in rows) exerciseFromData(row)];
        });
  }

  @override
  Future<void> insertCustomExercise(model.Exercise exercise) async {
    await into(
      customExercises,
    ).insert(exercise.toInsertable(userId: currentUserId));
  }

  @override
  Future<void> deleteCustomExercise(String id) async {
    final now = DateTime.now().toUtc();
    await (update(customExercises)..where((tbl) => tbl.id.equals(id))).write(
      CustomExercisesCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateCustomExercise(model.Exercise exercise) async {
    await (update(customExercises).replace(
      exercise
          .toInsertable(userId: currentUserId)
          .copyWith(
            updatedAt: Value(DateTime.now().toUtc()),
            deleted: const Value(false),
          ),
    ));
  }

  @override
  Future<void> writeAllCustomExercises(exercises) async {
    final now = DateTime.now().toUtc();
    return batch((batch) {
      batch.update(
        customExercises,
        CustomExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (_) => const Constant(true),
      );
      batch.insertAll(customExercises, [
        for (final ex in exercises) ex.toInsertable(userId: currentUserId),
      ]);
    });
  }

  @override
  Stream<Prefs> watchPreferences() {
    return select(preferences).watch().map(
      (l) => l.isEmpty ? Prefs.defaultValue : Prefs.fromDatabase(l[0]),
    );
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
      await into(
        ongoingData,
      ).insert(OngoingDataCompanion(data: Value(jsonEncode(ongoing))));
    });
  }

  @override
  Future deleteOngoing() {
    return delete(ongoingData).go();
  }

  @override
  Stream<List<WeightMeasurement>> watchWeightMeasurements() {
    final query = select(weightMeasurements)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
    return query.watch();
  }

  @override
  Future<void> insertWeightMeasurement(WeightMeasurement measurement) {
    return into(weightMeasurements).insert(
      measurement.toCompanion().copyWith(
        userId: Value(currentUserId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteWeightMeasurement(String id) {
    return (update(
      weightMeasurements,
    )..where((tbl) => tbl.id.equals(id))).write(
      WeightMeasurementsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> updateWeightMeasurement(WeightMeasurement measurement) {
    return (update(
      weightMeasurements,
    )..where((tbl) => tbl.id.equals(measurement.id))).write(
      measurement.toCompanion().copyWith(
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> setWeightMeasurements(List<WeightMeasurement> measurements) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        weightMeasurements,
      )..where((_) => const Constant(true))).write(
        WeightMeasurementsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final measurement in measurements) {
          batch.insert(
            weightMeasurements,
            measurement.toCompanion().copyWith(
              userId: Value(currentUserId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
          );
        }
      });
    });
  }

  @override
  Stream<List<model.TaggedFood>> watchFoods() {
    final query = select(foods)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateAdded)]);
    return query.watch().map((foods) {
      return foods.map((food) => foodFromDatabase(food)).toList();
    });
  }

  @override
  Future<void> insertFoods(model.TaggedFood food) {
    return into(foods).insert(
      food.toInsertable(generateInsertionDate: true, userId: currentUserId),
    );
  }

  @override
  Future<void> deleteFoods(String id) {
    return (update(foods)..where((tbl) => tbl.id.equals(id))).write(
      FoodsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> updateFoods(model.TaggedFood food) async {
    final oldFood = await (select(
      foods,
    )..where((tbl) => tbl.id.equals(food.value.id!))).getSingle();
    await update(foods).replace(
      food
          .toInsertable(generateInsertionDate: false, userId: currentUserId)
          .copyWith(
            dateAdded: Value(oldFood.dateAdded),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<void> setFoods(List<model.TaggedFood> foods) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(this.foods)..where((_) => const Constant(true))).write(
        FoodsCompanion(deleted: const Value(true), updatedAt: Value(now)),
      );
      await batch((batch) {
        for (final food in foods) {
          final insertable = food.toInsertable(
            generateInsertionDate: false,
            userId: currentUserId,
            updatedAt: now,
          );
          batch.insert(
            this.foods,
            insertable.copyWith(dateAdded: insertable.referenceDate),
          );
        }
      });
    });
  }

  @override
  Stream<List<model.TaggedNutritionGoal>> watchNutritionGoals() {
    final query = select(nutritionGoals)
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.referenceDate)]);
    return query.watch().map((goals) {
      return goals.map((goal) => goalFromDatabase(goal)).toList();
    });
  }

  @override
  Future<void> deleteNutritionGoal(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return (update(
      nutritionGoals,
    )..where((tbl) => tbl.id.equals(utcDate.toIso8601String()))).write(
      NutritionGoalsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> updateNutritionGoal(model.TaggedNutritionGoal goal) async {
    await update(
      nutritionGoals,
    ).replace(goal.toInsertable(userId: currentUserId));
  }

  @override
  Future<void> setNutritionGoals(List<model.TaggedNutritionGoal> goals) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(nutritionGoals)..where((_) => const Constant(true))).write(
        NutritionGoalsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final goal in goals) {
          batch.insert(
            nutritionGoals,
            goal.toInsertable(userId: currentUserId, updatedAt: now),
            mode: .insertOrReplace,
          );
        }
      });
    });
  }

  @override
  Stream<Map<String, model.Food>> watchCustomBarcodeFoods() {
    return (select(customBarcodeFoods)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch()
        .map((foods) {
          return {
            for (final food in foods)
              food.id: model.Food.fromJson(jsonDecode(food.jsonData)),
          };
        });
  }

  @override
  Future<void> insertCustomBarcodeFood(String barcode, model.Food food) {
    return into(customBarcodeFoods).insert(
      CustomBarcodeFoodsCompanion(
        id: Value(barcode),
        jsonData: Value(jsonEncode(food.toJson())),
        userId: Value(currentUserId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteCustomBarcodeFood(String barcode) {
    return (update(
      customBarcodeFoods,
    )..where((tbl) => tbl.id.equals(barcode))).write(
      CustomBarcodeFoodsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> setCustomBarcodeFoods(Map<String, model.Food> foods) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        customBarcodeFoods,
      )..where((_) => const Constant(true))).write(
        CustomBarcodeFoodsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final entry in foods.entries) {
          batch.insert(
            customBarcodeFoods,
            CustomBarcodeFoodsCompanion(
              id: Value(entry.key),
              jsonData: Value(jsonEncode(entry.value.toJson())),
              userId: Value(currentUserId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
          );
        }
      });
    });
  }

  @override
  Stream<List<model.Food>> watchFavoriteFoods() {
    return (select(favoriteFoods)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch()
        .switchMap((foodIDs) {
          final ids = foodIDs.map((e) => e.id).toList();
          return (select(foods)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
              ))
              .watch()
              .map(
                (foods) => foods
                    .where((f) => ids.contains(f.id))
                    .map(
                      (dbfood) =>
                          model.Food.fromJson(jsonDecode(dbfood.jsonData)),
                    )
                    .toList(),
              );
        });
  }

  @override
  Future<void> insertFavoriteFood(String id) {
    return into(favoriteFoods).insert(
      FavoriteFoodsCompanion(
        id: Value(id),
        userId: Value(currentUserId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteFavoriteFood(String id) {
    return (update(favoriteFoods)..where((tbl) => tbl.id.equals(id))).write(
      FavoriteFoodsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> setFavoriteFoods(List<String> ids) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(favoriteFoods)..where((_) => const Constant(true))).write(
        FavoriteFoodsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final id in ids) {
          batch.insert(
            favoriteFoods,
            FavoriteFoodsCompanion(
              id: Value(id),
              userId: Value(currentUserId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
          );
        }
      });
    });
  }

  @override
  Stream<Map<DateTime, Map<String, model.NutritionCategory>>>
  watchNutritionCategories() {
    return (select(nutritionCategories)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch()
        .map((categories) {
          return {
            for (final category in categories)
              databaseDateToLocalDay(category.referenceDate): Map.fromEntries(
                (jsonDecode(category.jsonData) as List)
                    .map((e) => model.NutritionCategory.fromJson(e))
                    .map((c) => MapEntry(c.name, c)),
              ),
          };
        });
  }

  @override
  Future<void> deleteNutritionCategories(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return (update(nutritionCategories)..where(
          (tbl) =>
              tbl.referenceDate.equals(utcDate) & _userIdPredicate(tbl.userId),
        ))
        .write(
          NutritionCategoriesCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> setNutritionCategories(
    Map<DateTime, Map<String, model.NutritionCategory>> categories,
  ) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        nutritionCategories,
      )..where((_) => const Constant(true))).write(
        NutritionCategoriesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final entry in categories.entries) {
          final utcDate = DateTime.utc(
            entry.key.year,
            entry.key.month,
            entry.key.day,
          );
          batch.insert(
            nutritionCategories,
            NutritionCategoriesCompanion(
              id: Value(utcDate.toIso8601String()),
              referenceDate: Value(utcDate),
              jsonData: Value(
                jsonEncode(entry.value.values.map((e) => e.toJson()).toList()),
              ),
              userId: Value(currentUserId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
            mode: .insertOrReplace,
          );
        }
      });
    });
  }

  @override
  Stream<List<AchievementCompletion>> watchAchievementCompletions() {
    return (select(achievements)..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        ))
        .watch();
  }

  @override
  Future<void> insertAchievementCompletion(AchievementCompletion completion) {
    return into(achievements).insert(
      AchievementsCompanion(
        achievementID: Value(completion.achievementID),
        level: Value(completion.level),
        completedAt: Value(completion.completedAt),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
        userId: Value(completion.userId ?? currentUserId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  @override
  Future<void> insertAchievementCompletions(
    List<AchievementCompletion> completions,
  ) {
    final now = DateTime.now().toUtc();
    return batch((batch) async {
      batch.insertAll(
        achievements,
        completions
            .map(
              (completion) => AchievementsCompanion.insert(
                achievementID: Value(completion.achievementID),
                level: completion.level,
                completedAt: completion.completedAt,
                updatedAt: Value(now),
                deleted: const Value(false),
                userId: Value(completion.userId ?? currentUserId),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  @override
  Future<void> deleteAchievementCompletion(String achievementID, int level) {
    final now = DateTime.now().toUtc();
    return (update(achievements)..where((tbl) {
          return tbl.achievementID.equals(achievementID) &
              tbl.level.equals(level);
        }))
        .write(
          AchievementsCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> setAchievementCompletions(
    List<AchievementCompletion> completions,
  ) {
    final now = DateTime.now().toUtc();
    return transaction(() async {
      await (update(achievements)..where((_) => const Constant(true))).write(
        AchievementsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        batch.insertAll(
          achievements,
          completions
              .map(
                (completion) => AchievementsCompanion.insert(
                  achievementID: Value(completion.achievementID),
                  level: completion.level,
                  completedAt: completion.completedAt,
                  updatedAt: Value(now),
                  deleted: const Value(false),
                  userId: Value(completion.userId ?? currentUserId),
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
      ..where((tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
    return query.watch();
  }

  @override
  Future<void> insertBodyMeasurement(BodyMeasurement measurement) {
    return into(bodyMeasurements).insert(
      measurement.toCompanion().copyWith(
        userId: Value(currentUserId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteBodyMeasurement(String id) {
    return (update(bodyMeasurements)..where((tbl) => tbl.id.equals(id))).write(
      BodyMeasurementsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> updateBodyMeasurement(BodyMeasurement measurement) {
    return (update(bodyMeasurements).replace(
      measurement.toCompanion().copyWith(
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    ));
  }

  @override
  Future<void> setBodyMeasurements(List<BodyMeasurement> measurements) {
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        bodyMeasurements,
      )..where((_) => const Constant(true))).write(
        BodyMeasurementsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        for (final measurement in measurements) {
          batch.insert(
            bodyMeasurements,
            measurement.toCompanion().copyWith(
              userId: Value(currentUserId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
          );
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

  /// Touches all timestamps that are null or equal to the epoch for the given user ID.
  @override
  Future<void> touchStaleTimestamps(String userId) async {
    final now = DateTime.now().toUtc();
    final epoch = DateTime.utc(0);
    await transaction(() async {
      await (update(routineFolders)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            RoutineFoldersCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(routines)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            RoutinesCompanion(userId: Value(userId), updatedAt: Value(now)),
          );

      await (update(historyWorkouts)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            HistoryWorkoutsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(customExercises)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            CustomExercisesCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(routineExercises)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            RoutineExercisesCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(historyWorkoutExercises)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            HistoryWorkoutExercisesCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(achievements)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            AchievementsCompanion(userId: Value(userId), updatedAt: Value(now)),
          );

      await (update(foods)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(FoodsCompanion(userId: Value(userId), updatedAt: Value(now)));

      await (update(customBarcodeFoods)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            CustomBarcodeFoodsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(favoriteFoods)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            FavoriteFoodsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(weightMeasurements)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            WeightMeasurementsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(bodyMeasurements)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            BodyMeasurementsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(nutritionCategories)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            NutritionCategoriesCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(nutritionGoals)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.equals(epoch)),
          ))
          .write(
            NutritionGoalsCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );
    });
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
    equipment: row.equipment,
  );
}

extension WorkoutListDatabaseUtils on List<model.Workout> {
  /// Returns a list of [RoutinesCompanion] where the [Routine.sortOrder]
  /// is changed based on the [Routine.folderId] and the order in this list.
  List<RoutinesCompanion> toSortedRoutineInsertables({String? userId}) {
    final Map<String?, int> counts = {};
    final List<RoutinesCompanion> insertables = [];
    for (int i = 0; i < length; i++) {
      counts.putIfAbsent(this[i].folder?.id, () => 0);
      insertables.add(
        this[i]
            .toRoutineInsertable(userId: userId)
            .copyWith(sortOrder: Value(counts[this[i].folder?.id]!)),
      );
      counts[this[i].folder?.id] = counts[this[i].folder?.id]! + 1;
    }
    return insertables;
  }

  List<HistoryWorkoutsCompanion> toSortedHistoryWorkoutInsertables({
    String? userId,
  }) {
    return [
      for (int i = 0; i < length; i++)
        this[i].toHistoryWorkoutInsertable(userId: userId),
    ];
  }
}

extension WorkoutDatabaseUtils on model.Workout {
  RoutinesCompanion toRoutineInsertable({String? userId}) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(infobox ?? ""),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      folderId: Value(folder?.id),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }

  HistoryWorkoutsCompanion toHistoryWorkoutInsertable({String? userId}) {
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
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }
}

extension WorkoutExercisableListDatabaseUtils
    on List<model.WorkoutExercisable> {
  List<HistoryWorkoutExercisesCompanion> toSortedInsertables({String? userId}) {
    return [
      for (int i = 0; i < length; i++)
        this[i].toInsertable(userId: userId).copyWith(sortOrder: Value(i)),
    ];
  }

  List<RoutineExercisesCompanion> toSortedRoutineExerciseInsertables({
    String? userId,
  }) {
    return [
      for (int i = 0; i < length; i++)
        this[i]
            .toRoutineExerciseInsertable(userId: userId)
            .copyWith(sortOrder: Value(i)),
    ];
  }
}

extension WorkoutExercisableDatabaseUtils on model.WorkoutExercisable {
  HistoryWorkoutExercisesCompanion toInsertable({String? userId}) {
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
      rpe: this is model.Exercise
          ? Value(asExercise.rpe)
          : const Value.absent(),
      equipment: this is model.Exercise
          ? Value(asExercise.gymEquipment)
          : const Value(GTGymEquipment.none),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }

  RoutineExercisesCompanion toRoutineExerciseInsertable({String? userId}) {
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
      rpe: this is model.Exercise
          ? Value(asExercise.rpe)
          : const Value.absent(),
      equipment: this is model.Exercise
          ? Value(asExercise.gymEquipment)
          : const Value(GTGymEquipment.none),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }
}

extension ExerciseDatabaseUtils on model.Exercise {
  CustomExercisesCompanion toInsertable({String? userId}) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      parameters: Value(parameters),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      equipment: Value(gymEquipment),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }
}

extension FolderDatabaseUtils on model.GTRoutineFolder {
  RoutineFoldersCompanion toInsertable({String? userId}) {
    return RoutineFoldersCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
      userId: Value(userId),
    );
  }
}

extension on model.TaggedFood {
  FoodsCompanion toInsertable({
    required bool generateInsertionDate,
    String? userId,
    DateTime? updatedAt,
  }) {
    assert(value.id != null);
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return FoodsCompanion(
      id: Value(value.id!),
      referenceDate: Value(utcDate),
      dateAdded: generateInsertionDate
          ? Value(DateTime.now().toUtc())
          : const Value.absent(),
      jsonData: Value(jsonEncode(value.toJson())),
      userId: Value(userId),
      updatedAt: Value(updatedAt ?? DateTime.now().toUtc()),
      deleted: const Value(false),
    );
  }
}

extension on model.TaggedNutritionGoal {
  String get id =>
      DateTime.utc(date.year, date.month, date.day).toIso8601String();

  NutritionGoalsCompanion toInsertable({String? userId, DateTime? updatedAt}) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return NutritionGoalsCompanion(
      id: Value(id),
      referenceDate: Value(utcDate),
      calories: Value(value.dailyCalories),
      fat: Value(value.dailyFat),
      carbs: Value(value.dailyCarbs),
      protein: Value(value.dailyProtein),
      userId: Value(userId),
      updatedAt: Value(updatedAt ?? DateTime.now().toUtc()),
      deleted: const Value(false),
    );
  }
}

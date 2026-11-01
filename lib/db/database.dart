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
import 'package:gymtracker/db/model/tables/catalog_submissions.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/foods.dart';
import 'package:gymtracker/db/model/tables/history.dart';
import 'package:gymtracker/db/model/tables/measurements.dart';
import 'package:gymtracker/db/model/tables/nutrition_categories.dart';
import 'package:gymtracker/db/model/tables/nutrition_goals.dart';
import 'package:gymtracker/db/model/tables/ongoing.dart';
import 'package:gymtracker/db/model/tables/preferences.dart';
import 'package:gymtracker/db/model/tables/recipes.dart';
import 'package:gymtracker/db/model/tables/routines.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:gymtracker/db/model/tables/sync.dart';
import 'package:gymtracker/db/model/tables/trainer.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/db/model/tables/water_logs.dart';
import 'package:gymtracker/db/schema_versions.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/db/wearable_training_store.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart' as model;
import 'package:gymtracker/model/exercise.dart' as model;
import 'package:gymtracker/model/exercise.dart' show GTGymEquipment;
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart' as model;
import 'package:gymtracker/model/workout.dart' as model;
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart' as model hide NutritionGoal;
import 'package:gymtracker/struct/recipe.dart';
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
export 'package:gymtracker/db/model/tables/recipes.dart';
export 'package:gymtracker/db/model/tables/water_logs.dart';

part 'database.g.dart';

// Used in the generated code
const _uuid = Uuid();

const DATABASE_VERSION = 25;

abstract class GTDatabase extends GeneratedDatabase with SyncableDatabase {
  GTDatabase(super.e);

  $CatalogSubmissionsTable get catalogSubmissions;
  $WaterLogsTable get waterLogs;
  $FoodsTable get foods;
  $HydrationExportsTable get hydrationExports;
  $HydrationSettingsTable get hydrationSettings;

  /// The currently logged-in user's ID, or null if no user is logged in.
  /// When set, all syncable-table queries filter by this user ID.
  String? get currentUserId;

  /// Emits every account transition, including guest sessions.
  Stream<String?> watchCurrentUserId();

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
  Future<void> updateRoutineSortOrders(
    List<String> ids, {
    required String? owner,
  });
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
  Future<void> deleteOngoingForUser(String? userId);
  Stream<Map<String, dynamic>?> watchLegacyOngoing();
  Future<void> recoverLegacyOngoing();

  Stream<List<WeightMeasurement>> watchWeightMeasurements();
  Future<void> insertWeightMeasurement(WeightMeasurement measurement);
  Future<void> deleteWeightMeasurement(String id);
  Future<void> updateWeightMeasurement(WeightMeasurement measurement);
  Future<void> setWeightMeasurements(List<WeightMeasurement> measurements);

  Stream<List<Recipe>> watchRecipes();
  Future<void> saveRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
  Future<void> setRecipes(List<Recipe> recipes);

  Stream<List<model.TaggedFood>> watchFoods();
  Future<void> insertFoods(model.TaggedFood food);
  Future<void> deleteFoods(String id);
  Future<void> updateFoods(model.TaggedFood food);
  Future<void> setFoods(List<model.TaggedFood> foods);

  Stream<List<model.TaggedNutritionGoal>> watchNutritionGoals();
  Future<void> deleteNutritionGoal(DateTime date);
  Future<void> updateNutritionGoal(model.TaggedNutritionGoal goal);
  Future<void> setNutritionGoals(List<model.TaggedNutritionGoal> goals);
  Future<void> setNutritionCategoriesForDay(
    DateTime date,
    Map<String, model.NutritionCategory> categories,
  );

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
  Future<void> mutateNutritionCategory(
    DateTime date, {
    model.NutritionCategory? category,
    String? oldName,
  });
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

  Future<void> clearUserData(String? userId);
  Future clearTheWholeThingIAmAbsolutelySureISwear();
  Future<File> get path;
  Future<void> close();
}

class _TrainerSnapshot {
  final String owner;
  final TrainerState state;
  _TrainerSnapshot(this.owner, this.state);
}

final _trainerSnapshots = Expando<_TrainerSnapshot>();

extension TrainerDatabase on GTDatabase {
  TrainerState get cachedTrainerState {
    final entry = _trainerSnapshots[this];
    return entry != null && entry.owner == currentUserId
        ? entry.state
        : TrainerState.empty;
  }

  Future<TrainerState> trainerState() async {
    final owner = currentUserId;
    if (owner == null) return TrainerState.empty;
    final row = await customSelect(
      'SELECT payload FROM trainer_caches WHERE owner = ?',
      variables: [Variable(owner)],
    ).getSingleOrNull();
    if (row == null) {
      _trainerSnapshots[this] = _TrainerSnapshot(owner, TrainerState.empty);
      return TrainerState.empty;
    }
    final result = TrainerState.fromJson(
      jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
    );
    if (currentUserId == owner) {
      _trainerSnapshots[this] = _TrainerSnapshot(owner, result);
    }
    return result;
  }

  Future<void> cacheTrainerState(
    String owner,
    Map<String, dynamic> payload,
  ) async {
    if (currentUserId != owner) return;
    await customStatement(
      'INSERT INTO trainer_caches(owner,payload,checked_at) VALUES(?,?,?) ON CONFLICT(owner) DO UPDATE SET payload=excluded.payload,checked_at=excluded.checked_at',
      [
        owner,
        jsonEncode(payload),
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ],
    );
    _trainerSnapshots[this] = _TrainerSnapshot(
      owner,
      TrainerState.fromJson(payload),
    );
    notifyUpdates({
      const TableUpdate('trainer_caches', kind: UpdateKind.update),
    });
  }

  Future<bool> isTrainerRoutine(String? id) async =>
      id != null && (await trainerState()).controls.contains(id);

  Future<void> requirePersonalRoutine(String? id) async {
    if (await isTrainerRoutine(id)) throw const TrainerControlledException();
  }
}

@DriftDatabase(
  tables: [
    TrainerCaches,
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
    SyncOutbox,
    SyncMetadata,
    SyncCursors,
    SyncConflicts,
    SyncContext,
    SyncQuarantine,
    CatalogSubmissions,
    Recipes,
    WaterLogs,
    HydrationExports,
    HydrationSettings,
  ],
)
class GTDatabaseImpl extends _$GTDatabaseImpl
    with SyncableDatabase
    implements GTDatabase {
  GTDatabaseImpl.prod() : super(_openConnection());

  GTDatabaseImpl.openBackup(File file) : super(NativeDatabase(file));

  @visibleForTesting
  GTDatabaseImpl.withQueryExecutor(super.e);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(preferences).insert(Prefs.defaultValue);
    },
    onUpgrade: (m, from, to) async {
      if (from > to) throw StateError('Database is newer than this app');
      // Run migration steps without foreign keys and re-enable them later
      // (https://drift.simonbinder.eu/docs/advanced-features/migrations/#tips)
      // await customStatement('PRAGMA foreign_keys = OFF');

      globalLogger.w("[GTDatabase] Running migration [$from->$to]");

      await m.runMigrationSteps(
        from: from,
        to: to,
        steps: migrationSteps(
          from24To25: (m, schema) async {
            await m.createTable(schema.trainerCaches);
          },
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
          from17To18: (m, schema) async {
            await m.alterTable(
              TableMigration(
                schema.ongoingData,
                newColumns: [schema.ongoingData.owner],
              ),
            );
          },
          from18To19: (m, schema) async {
            await m.addColumn(
              schema.routineExercises,
              schema.routineExercises.progression,
            );
            await m.addColumn(
              schema.historyWorkoutExercises,
              schema.historyWorkoutExercises.progression,
            );
          },
          from23To24: (m, schema) async {
            await m.createTable(schema.recipes);
          },
          from22To23: (m, schema) async {
            await m.createTable(schema.waterLogs);
            await m.createTable(schema.hydrationExports);
            await m.createTable(schema.hydrationSettings);
            await m.addColumn(
              schema.nutritionGoals,
              schema.nutritionGoals.water,
            );
          },
          from21To22: (m, schema) async {
            await m.createTable(schema.catalogSubmissions);
          },
          from20To21: (m, schema) async {
            await m.addColumn(
              schema.historyWorkouts,
              schema.historyWorkouts.visibility,
            );
            await m.addColumn(
              schema.historyWorkouts,
              schema.historyWorkouts.publicationManifest,
            );
            await m.addColumn(
              schema.historyWorkoutExercises,
              schema.historyWorkoutExercises.publicationVersion,
            );
          },
          from19To20: (m, schema) async {
            await m.createTable(schema.syncOutbox);
            await m.createTable(schema.syncMetadata);
            await m.createTable(schema.syncCursors);
            await m.createTable(schema.syncConflicts);
            await m.createTable(schema.syncContext);
            await m.createTable(schema.syncQuarantine);
          },
          from16To17: (m, schema) async {
            await m.addColumn(
              schema.routineFolders,
              schema.routineFolders.notes,
            );
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
      await SyncV2Store.install(this);
      await WearableTrainingStore.install(this);
      // Nutrition defaults are supplied by the providers until the user saves
      // them. Persisting defaults here would look like guest data at login.

      if (kDebugMode) {
        await validateDatabaseSchema();
      }
    },
  );

  @override
  int get schemaVersion => DATABASE_VERSION;

  String? _currentUserId;
  final _userIdChanges = BehaviorSubject<String?>.seeded(null);

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<String?> watchCurrentUserId() => _userIdChanges.distinct();

  @override
  void setCurrentUserId(String? id) {
    if (_currentUserId == id) return;
    _currentUserId = id;
    _userIdChanges.add(id);
  }

  Stream<T> _watchForCurrentUser<T>(Stream<T> Function() query) {
    // A separate input per subscriber also propagates pause/resume to switchMap.
    Stream<String?> identities() async* {
      yield* _userIdChanges;
    }

    return identities().distinct().switchMap(
      (userId) => query().where((_) => userId == _currentUserId),
    );
  }

  @override
  Future<void> close() async {
    await _userIdChanges.close();
    await super.close();
  }

  /// Returns a filter expression for a `userId` column:
  /// - logged in  -> `userId = currentUserId`
  /// - logged out -> `userId IS NULL`
  Expression<bool> _userIdPredicate(GeneratedColumn<String> col) {
    final uid = _currentUserId;
    if (uid != null) {
      return col.equals(uid);
    }
    return col.isNull();
  }

  Expression<bool> _ownedBy(GeneratedColumn<String> col, String? userId) {
    return userId == null ? col.isNull() : col.equals(userId);
  }

  @override
  Stream<List<model.Workout>> getAllRoutines() {
    return _watchForCurrentUser(() {
      logger.i("Getting all routines");

      final query = select(routines)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
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
    await requirePersonalRoutine(routine.id);
    final userId = currentUserId;
    final newSortOrder =
        (await (select(routines)..where(
                  (tbl) =>
                      tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
                ))
                .get())
            .length;
    return batch((batch) {
      batch.insert(
        routines,
        routine
            .toRoutineInsertable(userId: userId)
            .copyWith(sortOrder: Value(newSortOrder)),
      );
      batch.insertAll(
        routineExercises,
        routine.flattenedExercises.toSortedRoutineExerciseInsertables(
          userId: userId,
        ),
      );
    });
  }

  @override
  Future<void> deleteRoutine(String id) async {
    await requirePersonalRoutine(id);
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    final remainingIDs =
        (await (select(routines)
              ..where(
                (tbl) =>
                    tbl.id.isNotValue(id) &
                    tbl.deleted.equals(false) &
                    _ownedBy(tbl.userId, userId),
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
        where: (tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId)),
      );
      batch.update(
        routineExercises,
        RoutineExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (tbl) =>
            (tbl.routineId.equals(id) & _ownedBy(tbl.userId, userId)),
      );
      for (final entry in idToSortOrder.entries) {
        batch.update(
          routines,
          RoutinesCompanion(
            sortOrder: Value(entry.value),
            updatedAt: Value(now),
          ),
          where: (tbl) =>
              (tbl.id.equals(entry.key) & _ownedBy(tbl.userId, userId)),
        );
      }
    });
  }

  @override
  Future<void> updateRoutine(model.Workout routine) async {
    await requirePersonalRoutine(routine.id);
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    if (routine.id.isEmpty) {
      throw ArgumentError("Routine ID cannot be empty");
    }
    final sortOrder =
        (await (select(routines)..where(
                  (tbl) =>
                      (tbl.id.equals(routine.id) &
                          _ownedBy(tbl.userId, userId)) &
                      tbl.deleted.equals(false),
                ))
                .getSingle())
            .sortOrder;
    return transaction(() async {
      final oldExercises =
          (await (select(routineExercises)..where(
                    (tbl) =>
                        (tbl.routineId.equals(routine.id) &
                        _ownedBy(tbl.userId, userId)),
                  ))
                  .get())
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
        batch.deleteWhere(
          routines,
          (tbl) => (tbl.id.equals(routine.id) & _ownedBy(tbl.userId, userId)),
        );
        batch.insert(
          routines,
          routine
              .toRoutineInsertable(userId: userId)
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
                (tbl.id.isIn(removedExerciseIds) &
                    _ownedBy(tbl.userId, userId)) &
                tbl.deleted.equals(false),
          );
        }

        if (remainingExerciseIds.isNotEmpty) {
          batch.deleteWhere(
            routineExercises,
            (tbl) =>
                (tbl.id.isIn(remainingExerciseIds) &
                _ownedBy(tbl.userId, userId)),
          );
        }

        batch.insertAll(
          routineExercises,
          routine.flattenedExercises.toSortedRoutineExerciseInsertables(
            userId: userId,
          ),
        );
      });
    });
  }

  @override
  Future<void> updateRoutineSortOrders(
    List<String> ids, {
    required String? owner,
  }) {
    final now = DateTime.now().toUtc();
    return batch((batch) {
      for (final entry in ids.asMap().entries) {
        batch.update(
          routines,
          RoutinesCompanion(sortOrder: Value(entry.key), updatedAt: Value(now)),
          where: (row) =>
              row.id.equals(entry.value) &
              _ownedBy(row.userId, owner) &
              row.deleted.equals(false),
        );
      }
    });
  }

  @override
  Future writeAllRoutines(List<model.Workout> routines) async {
    final userId = currentUserId;
    final controls = (await trainerState()).controls;
    final existing = controls.isEmpty
        ? <model.Workout>[]
        : await getAllRoutinesFuture();
    for (final r in existing.where((r) => controls.contains(r.id))) {
      final replacement = routines.where((n) => n.id == r.id).firstOrNull;
      if (replacement == null ||
          jsonEncode(replacement.toJson()) != jsonEncode(r.toJson()))
        throw const TrainerControlledException();
    }
    final now = DateTime.now().toUtc();
    return transaction(() async {
      final oldRoutines =
          await (select(this.routines)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
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
          where: (tbl) =>
              (tbl.id.isIn(toDeleteIds) & _ownedBy(tbl.userId, userId)) &
              tbl.deleted.equals(false),
        );
        batch.insertAll(
          this.routines,
          routines.toSortedRoutineInsertables(userId: userId),
          mode: .insertOrReplace,
        );
      });
      await _overwriteAllRoutineExercises(routines.flattenedExercises, userId);
    });
  }

  @override
  Future<void> overwriteAllRoutineExercises(
    List<model.WorkoutExercisable> routineExercises,
  ) async {
    final controls = (await trainerState()).controls;
    if (controls.isNotEmpty) {
      final incoming = {for (final e in routineExercises) e.id: e};
      for (final r in await getAllRoutinesFuture()) {
        if (!controls.contains(r.id)) continue;
        for (final e in r.exercises) {
          if (!incoming.containsKey(e.id) ||
              jsonEncode(incoming[e.id]!.toJson()) != jsonEncode(e.toJson()))
            throw const TrainerControlledException();
        }
      }
    }
    await _overwriteAllRoutineExercises(routineExercises, currentUserId);
  }

  Future<void> _overwriteAllRoutineExercises(
    List<model.WorkoutExercisable> routineExercises,
    String? userId,
  ) async {
    final now = DateTime.now().toUtc();
    final routineExerciseInsertables = routineExercises
        .fold(<String, List<model.WorkoutExercisable>>{}, (m, r) {
          return m..putIfAbsent(r.workoutID!, () => []).add(r);
        })
        .values
        .expand(
          (list) => list.toSortedRoutineExerciseInsertables(userId: userId),
        );
    await transaction(() async {
      final oldExs =
          await (select(this.routineExercises)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
              ))
              .get();
      final toDeleteIds = oldExs
          .where((r) => !routineExercises.any((newR) => newR.id == r.id))
          .map((r) => r.id)
          .toList();
      await (update(this.routineExercises)..where(
            (tbl) => (tbl.id.isIn(toDeleteIds) & _ownedBy(tbl.userId, userId)),
          ))
          .write(
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
    return _watchForCurrentUser(() {
      return (select(routineFolders)..where(
            (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
          ))
          .watch()
          .map((l) => [for (final row in l) folderFromDatabase(row)]);
    });
  }

  @override
  Future<void> insertRoutineFolder(model.GTRoutineFolder folder) async {
    final userId = currentUserId;
    await into(routineFolders).insert(folder.toInsertable(userId: userId));
    await _recomputeFolderSortOrders(userId);
  }

  @override
  Future<void> deleteRoutineFolder(String id) async {
    final controlled = (await trainerState()).controls;
    if ((await getAllRoutinesFuture()).any(
      (r) => r.folder?.id == id && controlled.contains(r.id),
    ))
      throw const TrainerControlledException();
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    final allRoutines =
        await (select(routines)
              ..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
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
        where: (tbl) => tbl.id.equals(id) & _ownedBy(tbl.userId, userId),
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
              tbl.id.equals(routine.id) & _ownedBy(tbl.userId, userId),
        );
      }
    });

    await _recomputeFolderSortOrders(userId);
  }

  @override
  Future<void> updateRoutineFolder(model.GTRoutineFolder folder) async {
    final userId = currentUserId;
    await transaction(() async {
      await (delete(routineFolders)..where(
            (tbl) => tbl.id.equals(folder.id) & _ownedBy(tbl.userId, userId),
          ))
          .go();
      await into(routineFolders).insert(
        folder
            .toInsertable(userId: userId)
            .copyWith(
              updatedAt: Value(DateTime.now().toUtc()),
              deleted: const Value(false),
            ),
      );
    });
  }

  @override
  Future writeAllRoutineFolders(List<model.GTRoutineFolder> folders) {
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    return batch((batch) {
      batch.update(
        routineFolders,
        RoutineFoldersCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (tbl) => _ownedBy(tbl.userId, userId),
      );
      batch.insertAll(
        routineFolders,
        folders.map((f) => f.toInsertable(userId: userId)),
      );
    });
  }

  Future<void> _recomputeFolderSortOrders(String? userId) async {
    // Recompute sort orders
    final query = select(routineFolders)
      ..where((tbl) => tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId))
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
          where: (tbl) =>
              tbl.id.equals(entry.key) & _ownedBy(tbl.userId, userId),
        );
      }
    });
  }

  @override
  Stream<List<model.Workout>> getAllHistoryWorkouts() {
    return _watchForCurrentUser(() {
      logger.i("Getting all history workouts");

      final query = select(historyWorkouts)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
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
    final userId = currentUserId;
    final version = _uuid.v4();
    return batch((batch) {
      batch.insert(
        historyWorkouts,
        workout.toHistoryWorkoutInsertable(
          userId: userId,
          publicationVersion: version,
        ),
      );
      batch.insertAll(
        historyWorkoutExercises,
        workout.flattenedExercises.toSortedInsertables(
          userId: userId,
          publicationVersion: version,
        ),
      );
    });
  }

  @override
  Future<void> deleteHistoryWorkout(String id) async {
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    await (update(historyWorkouts)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          HistoryWorkoutsCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
    await (update(historyWorkoutExercises)..where(
          (tbl) => (tbl.routineId.equals(id) & _ownedBy(tbl.userId, userId)),
        ))
        .write(
          HistoryWorkoutExercisesCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> updateHistoryWorkout(model.Workout workout) async {
    if ((await trainerState()).controls.isNotEmpty) {
      final existing = await getHistoryWorkout(workout.id);
      if (await isTrainerRoutine(existing.parentID)) {
        if (existing.parentID != workout.parentID ||
            (existing.startingDate == null ||
                workout.startingDate == null ||
                !existing.startingDate!.isAtSameMomentAs(
                  workout.startingDate!,
                )))
          throw const TrainerControlledException();
      }
    }
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    final version = _uuid.v4();
    if (workout.id.isEmpty) {
      throw ArgumentError("Routine ID cannot be empty");
    }
    if (workout.duration == null) {
      throw ArgumentError("Workout duration cannot be null");
    }
    if (workout.startingDate == null) {
      throw ArgumentError("Workout starting date cannot be null");
    }
    return transaction(() async {
      final oldExercises =
          (await (select(historyWorkoutExercises)..where(
                    (tbl) =>
                        (tbl.routineId.equals(workout.id) &
                        _ownedBy(tbl.userId, userId)),
                  ))
                  .get())
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
        batch.deleteWhere(
          historyWorkouts,
          (tbl) => (tbl.id.equals(workout.id) & _ownedBy(tbl.userId, userId)),
        );
        batch.insert(
          historyWorkouts,
          workout
              .toHistoryWorkoutInsertable(
                userId: userId,
                publicationVersion: version,
              )
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
                (tbl.id.isIn(removedExerciseIds) &
                    _ownedBy(tbl.userId, userId)) &
                tbl.deleted.equals(false),
          );
        }

        if (remainingExerciseIds.isNotEmpty) {
          batch.deleteWhere(
            historyWorkoutExercises,
            (tbl) =>
                (tbl.id.isIn(remainingExerciseIds) &
                _ownedBy(tbl.userId, userId)),
          );
        }

        batch.insertAll(
          historyWorkoutExercises,
          workout.flattenedExercises.toSortedInsertables(
            userId: userId,
            publicationVersion: version,
          ),
        );
      });
    });
  }

  @override
  Future writeAllHistoryWorkouts(List<model.Workout> historyWorkouts) async {
    final userId = currentUserId;
    final controls = (await trainerState()).controls;
    if (controls.isNotEmpty) {
      final previous = await getAllHistoryWorkoutsFuture();
      for (final old in previous.where((w) => controls.contains(w.parentID))) {
        final next = historyWorkouts.where((w) => w.id == old.id).firstOrNull;
        if (next != null &&
            (old.parentID != next.parentID ||
                old.startingDate == null ||
                next.startingDate == null ||
                !old.startingDate!.isAtSameMomentAs(next.startingDate!)))
          throw const TrainerControlledException();
      }
    }
    final publicationVersions = {
      for (final workout in historyWorkouts) workout.id: _uuid.v4(),
    };
    final now = DateTime.now().toUtc();
    return transaction(() async {
      if (userId == null) {
        await (delete(
          this.historyWorkouts,
        )..where((tbl) => tbl.userId.isNull())).go();
      }
      final oldWorkouts =
          await (select(this.historyWorkouts)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
              ))
              .get();
      final toDeleteIds = oldWorkouts
          .where((r) => !historyWorkouts.any((newW) => newW.id == r.id))
          .map((r) => r.id)
          .toList();
      await batch((batch) {
        if (toDeleteIds.isNotEmpty) {
          batch.update(
            this.historyWorkouts,
            HistoryWorkoutsCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
            ),
            where: (tbl) =>
                (tbl.id.isIn(toDeleteIds) & _ownedBy(tbl.userId, userId)) &
                tbl.deleted.equals(false),
          );
        }
        batch.insertAll(
          this.historyWorkouts,
          historyWorkouts.toSortedHistoryWorkoutInsertables(
            userId: userId,
            publicationVersions: publicationVersions,
          ),
          mode: .insertOrReplace,
        );
      });
      await overwriteAllHistoryWorkoutExercises(
        historyWorkouts.flattenedExercises,
        publicationVersions: publicationVersions,
      );
    });
  }

  @override
  Future<void> overwriteAllHistoryWorkoutExercises(
    List<model.WorkoutExercisable> historyWorkoutExercises, {
    Map<String, String>? publicationVersions,
  }) async {
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    publicationVersions ??= {
      for (final w in await (select(
        historyWorkouts,
      )..where((t) => _ownedBy(t.userId, userId))).get())
        if (w.publicationManifest != null)
          w.id:
              (jsonDecode(w.publicationManifest!) as Map)['version'] as String,
    };
    final historyExerciseInsertables = historyWorkoutExercises
        .fold(<String, List<model.WorkoutExercisable>>{}, (m, r) {
          return m..putIfAbsent(r.workoutID!, () => []).add(r);
        })
        .values
        .expand(
          (list) => list.toSortedInsertables(
            userId: userId,
            publicationVersion: publicationVersions?[list.first.workoutID],
          ),
        );
    await transaction(() async {
      final oldExs =
          await (select(this.historyWorkoutExercises)..where(
                (tbl) =>
                    tbl.deleted.equals(false) & _ownedBy(tbl.userId, userId),
              ))
              .get();
      final toDeleteIds = oldExs
          .where((r) => !historyWorkoutExercises.any((newR) => newR.id == r.id))
          .map((r) => r.id)
          .toList();
      await (update(this.historyWorkoutExercises)..where(
            (tbl) => (tbl.id.isIn(toDeleteIds) & _ownedBy(tbl.userId, userId)),
          ))
          .write(
            HistoryWorkoutExercisesCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
            ),
          );
      await batch(
        (b) => b.insertAll(
          this.historyWorkoutExercises,
          historyExerciseInsertables,
          mode: .insertOrReplace,
        ),
      );
    });
  }

  @override
  Stream<List<model.Exercise>> getAllCustomExercises() {
    return _watchForCurrentUser(() {
      logger.i("Getting all custom exercises");
      return (select(customExercises)..where(
            (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
          ))
          .watch()
          .map((rows) {
            return [for (final row in rows) exerciseFromData(row)];
          });
    });
  }

  @override
  Future<void> insertCustomExercise(model.Exercise exercise) async {
    final userId = currentUserId;
    await into(customExercises).insert(exercise.toInsertable(userId: userId));
  }

  @override
  Future<void> deleteCustomExercise(String id) async {
    if ((await trainerState()).protectedExercises.contains(id))
      throw const TrainerControlledException();
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    await (update(customExercises)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          CustomExercisesCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<void> updateCustomExercise(model.Exercise exercise) async {
    if ((await trainerState()).protectedExercises.contains(exercise.id))
      throw const TrainerControlledException();
    final userId = currentUserId;
    await (update(customExercises)..where(
          (tbl) => tbl.id.equals(exercise.id) & _ownedBy(tbl.userId, userId),
        ))
        .write(
          exercise
              .toInsertable(userId: userId)
              .copyWith(
                updatedAt: Value(DateTime.now().toUtc()),
                deleted: const Value(false),
              ),
        );
  }

  @override
  Future<void> writeAllCustomExercises(exercises) async {
    final protected = (await trainerState()).protectedExercises;
    for (final e in await getAllCustomExercises().first) {
      if (!protected.contains(e.id)) continue;
      final replacement = exercises.where((n) => n.id == e.id).firstOrNull;
      if (replacement == null ||
          jsonEncode(replacement.toJson()) != jsonEncode(e.toJson()))
        throw const TrainerControlledException();
    }
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    return batch((batch) {
      batch.update(
        customExercises,
        CustomExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
        where: (tbl) => _ownedBy(tbl.userId, userId),
      );
      if (userId == null) {
        batch.deleteWhere(customExercises, (tbl) => tbl.userId.isNull());
      }
      batch.insertAll(customExercises, [
        for (final ex in exercises) ex.toInsertable(userId: userId),
      ], mode: InsertMode.insertOrReplace);
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

  String _ongoingOwner(String? userId) =>
      userId == null ? 'guest' : 'user:$userId';

  @override
  Stream<Map<String, dynamic>?> watchOngoing() {
    return _watchForCurrentUser(() {
      final owner = _ongoingOwner(currentUserId);
      return (select(
        ongoingData,
      )..where((row) => row.owner.equals(owner))).watchSingleOrNull().map(
        (row) =>
            row == null ? null : jsonDecode(row.data) as Map<String, dynamic>,
      );
    });
  }

  @override
  Future<void> setOngoing(Map<String, dynamic> ongoing) {
    final owner = _ongoingOwner(currentUserId);
    return into(ongoingData).insert(
      OngoingDataCompanion(
        data: Value(jsonEncode(ongoing)),
        owner: Value(owner),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> deleteOngoing() => deleteOngoingForUser(currentUserId);

  @override
  Future<void> deleteOngoingForUser(String? userId) {
    return (delete(
      ongoingData,
    )..where((row) => row.owner.equals(_ongoingOwner(userId)))).go();
  }

  @override
  Stream<Map<String, dynamic>?> watchLegacyOngoing() {
    return (select(
      ongoingData,
    )..where((row) => row.owner.equals('legacy'))).watchSingleOrNull().map(
      (row) =>
          row == null ? null : jsonDecode(row.data) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> recoverLegacyOngoing() {
    final owner = _ongoingOwner(currentUserId);
    return transaction(() async {
      final legacy = await (select(
        ongoingData,
      )..where((row) => row.owner.equals('legacy'))).getSingle();
      final active = await (select(
        ongoingData,
      )..where((row) => row.owner.equals(owner))).getSingleOrNull();
      if (active != null) throw StateError('An ongoing workout already exists');
      final data = jsonDecode(legacy.data) as Map<String, dynamic>;
      if (data['name'] is! String ||
          data['exercises'] is! List ||
          data['time'] is! int) {
        throw const FormatException('Invalid saved workout');
      }
      for (final exercise in data['exercises'] as List) {
        model.WorkoutExercisable.fromJson(exercise);
      }
      if (owner != _ongoingOwner(currentUserId))
        throw StateError('The account changed');
      await (update(ongoingData)..where((row) => row.owner.equals('legacy')))
          .write(OngoingDataCompanion(owner: Value(owner)));
    });
  }

  @override
  Stream<List<WeightMeasurement>> watchWeightMeasurements() {
    return _watchForCurrentUser(() {
      final query = select(weightMeasurements)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
      return query.watch();
    });
  }

  @override
  Future<void> insertWeightMeasurement(WeightMeasurement measurement) {
    final userId = currentUserId;
    return into(weightMeasurements).insert(
      measurement.toCompanion().copyWith(
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteWeightMeasurement(String id) {
    final userId = currentUserId;
    return (update(weightMeasurements)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          WeightMeasurementsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> updateWeightMeasurement(WeightMeasurement measurement) {
    final userId = currentUserId;
    return (update(weightMeasurements)..where(
          (tbl) =>
              (tbl.id.equals(measurement.id) & _ownedBy(tbl.userId, userId)),
        ))
        .write(
          measurement.toCompanion().copyWith(
            userId: Value(userId),
            updatedAt: Value(DateTime.now().toUtc()),
            deleted: const Value(false),
          ),
        );
  }

  @override
  Future<void> setWeightMeasurements(List<WeightMeasurement> measurements) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        weightMeasurements,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).write(
        WeightMeasurementsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        if (userId == null) {
          batch.deleteWhere(weightMeasurements, (tbl) => tbl.userId.isNull());
        }
        for (final measurement in measurements) {
          batch.insert(
            weightMeasurements,
            measurement.toCompanion().copyWith(
              userId: Value(userId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  @override
  Stream<List<model.TaggedFood>> watchFoods() {
    return _watchForCurrentUser(() {
      final query = select(foods)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.dateAdded)]);
      return query.watch().map((foods) {
        return foods.map((food) => foodFromDatabase(food)).toList();
      });
    });
  }

  @override
  Future<void> insertFoods(model.TaggedFood food) {
    final userId = currentUserId;
    return into(
      foods,
    ).insert(food.toInsertable(generateInsertionDate: true, userId: userId));
  }

  @override
  Future<void> deleteFoods(String id) {
    final userId = currentUserId;
    return (update(foods)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          FoodsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> updateFoods(model.TaggedFood food) async {
    final userId = currentUserId;
    final oldFood =
        await (select(foods)..where(
              (tbl) =>
                  (tbl.id.equals(food.value.id!) &
                  _ownedBy(tbl.userId, userId)),
            ))
            .getSingle();
    if (currentUserId != userId) throw StateError("Account changed");
    await (update(foods)..where(
          (tbl) => tbl.id.equals(food.value.id!) & _ownedBy(tbl.userId, userId),
        ))
        .write(
          food
              .toInsertable(generateInsertionDate: false, userId: userId)
              .copyWith(
                dateAdded: Value(oldFood.dateAdded),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
        );
  }

  @override
  Future<void> setFoods(List<model.TaggedFood> foods) {
    final userId = currentUserId;
    return transaction(() async {
      final existing = await (select(
        this.foods,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).get();
      final existingById = {for (final row in existing) row.id: row};
      final now = DateTime.now().toUtc();
      final retained = foods
          .map((f) => f.value.id)
          .whereType<String>()
          .toList();
      await (update(this.foods)..where(
            (tbl) =>
                _ownedBy(tbl.userId, userId) &
                tbl.id.isNotIn(retained) &
                tbl.deleted.equals(false),
          ))
          .write(
            FoodsCompanion(deleted: const Value(true), updatedAt: Value(now)),
          );
      for (final food in foods) {
        final insertable = food.toInsertable(
          generateInsertionDate: false,
          userId: userId,
          updatedAt: now,
        );
        final old = existingById[insertable.id.value];
        if (old == null) {
          await into(
            this.foods,
          ).insert(insertable.copyWith(dateAdded: insertable.referenceDate));
        } else {
          await (update(this.foods)..where(
                (tbl) => tbl.id.equals(old.id) & _ownedBy(tbl.userId, userId),
              ))
              .write(insertable.copyWith(dateAdded: Value(old.dateAdded)));
        }
      }
    });
  }

  @override
  Stream<List<model.TaggedNutritionGoal>> watchNutritionGoals() {
    return _watchForCurrentUser(() {
      final query = select(nutritionGoals)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.referenceDate)]);
      return query.watch().map((goals) {
        return goals.map((goal) => goalFromDatabase(goal)).toList();
      });
    });
  }

  @override
  Future<void> deleteNutritionGoal(DateTime date) {
    final userId = currentUserId;
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return (update(nutritionGoals)..where(
          (tbl) =>
              (tbl.id.equals(utcDate.toIso8601String()) &
              _ownedBy(tbl.userId, userId)),
        ))
        .write(
          NutritionGoalsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> updateNutritionGoal(model.TaggedNutritionGoal goal) =>
      transaction(() async {
        final user = currentUserId;
        final value = goal.toInsertable(userId: user);
        final existing =
            await (select(nutritionGoals)..where(
                  (t) => _ownedBy(t.userId, user) & t.id.equals(value.id.value),
                ))
                .get();
        if (existing.isEmpty) {
          await into(nutritionGoals).insert(value);
        } else {
          await (update(nutritionGoals)..where(
                (t) => _ownedBy(t.userId, user) & t.id.equals(value.id.value),
              ))
              .write(value);
        }
      });

  @override
  Future<void> setNutritionGoals(List<model.TaggedNutritionGoal> goals) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final retained = goals
          .map(
            (g) => DateTime.utc(
              g.date.year,
              g.date.month,
              g.date.day,
            ).toIso8601String(),
          )
          .toList();
      await (update(nutritionGoals)..where(
            (tbl) =>
                _ownedBy(tbl.userId, userId) &
                tbl.id.isNotIn(retained) &
                tbl.deleted.equals(false),
          ))
          .write(
            NutritionGoalsCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
            ),
          );
      await batch((batch) {
        for (final goal in goals) {
          batch.insert(
            nutritionGoals,
            goal.toInsertable(userId: userId, updatedAt: now),
            mode: .insertOrReplace,
          );
        }
      });
    });
  }

  @override
  Stream<List<Recipe>> watchRecipes() => _watchForCurrentUser(
    () =>
        (select(recipes)..where(
              (t) => t.deleted.equals(false) & _userIdPredicate(t.userId),
            ))
            .watch()
            .map(
              (rows) => rows.map((r) {
                final value = Recipe.fromJson(jsonDecode(r.jsonData));
                value.validate();
                return value;
              }).toList(),
            ),
  );

  @override
  Future<void> saveRecipe(Recipe recipe) {
    recipe.validate();
    final owner = currentUserId;
    return transaction(() async {
      final values = RecipesCompanion(
        id: Value(recipe.id),
        jsonData: Value(jsonEncode(recipe.toJson())),
        userId: Value(owner),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      );
      final count =
          await (update(recipes)..where(
                (t) => t.id.equals(recipe.id) & _ownedBy(t.userId, owner),
              ))
              .write(values);
      if (count == 0) await into(recipes).insert(values);
    });
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final owner = currentUserId;
    await (update(
      recipes,
    )..where((t) => t.id.equals(id) & _ownedBy(t.userId, owner))).write(
      RecipesCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> setRecipes(List<Recipe> values) => transaction(() async {
    for (final value in values) {
      value.validate();
    }
    await (update(recipes)..where((t) => _userIdPredicate(t.userId))).write(
      RecipesCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    for (final value in values) {
      await saveRecipe(value);
    }
  });

  @override
  Stream<Map<String, model.Food>> watchCustomBarcodeFoods() {
    return _watchForCurrentUser(() {
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
    });
  }

  @override
  Future<void> insertCustomBarcodeFood(String barcode, model.Food food) {
    final userId = currentUserId;
    return transaction(() async {
      final values = CustomBarcodeFoodsCompanion(
        id: Value(barcode),
        jsonData: Value(jsonEncode(food.toJson())),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      );
      // Match the owner explicitly: SQLite allows duplicate composite keys
      // when userId is null, so an upsert alone cannot handle guest foods.
      final updated =
          await (update(customBarcodeFoods)..where(
                (tbl) => tbl.id.equals(barcode) & _ownedBy(tbl.userId, userId),
              ))
              .write(values);
      if (updated == 0) {
        await into(customBarcodeFoods).insert(values);
      }
    });
  }

  @override
  Future<void> deleteCustomBarcodeFood(String barcode) {
    final userId = currentUserId;
    return (update(customBarcodeFoods)..where(
          (tbl) => (tbl.id.equals(barcode) & _ownedBy(tbl.userId, userId)),
        ))
        .write(
          CustomBarcodeFoodsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> setCustomBarcodeFoods(Map<String, model.Food> foods) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        customBarcodeFoods,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).write(
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
              userId: Value(userId),
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
    return _watchForCurrentUser(() {
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
    });
  }

  @override
  Future<void> insertFavoriteFood(String id) {
    final userId = currentUserId;
    return into(favoriteFoods).insert(
      FavoriteFoodsCompanion(
        id: Value(id),
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteFavoriteFood(String id) {
    final userId = currentUserId;
    return (update(favoriteFoods)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          FavoriteFoodsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> setFavoriteFoods(List<String> ids) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        favoriteFoods,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).write(
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
              userId: Value(userId),
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
    return _watchForCurrentUser(() {
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
    });
  }

  @override
  Future<void> deleteNutritionCategories(DateTime date) {
    final userId = currentUserId;
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return (update(nutritionCategories)..where(
          (tbl) =>
              tbl.referenceDate.equals(utcDate) & _ownedBy(tbl.userId, userId),
        ))
        .write(
          NutritionCategoriesCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> setNutritionCategoriesForDay(
    DateTime date,
    Map<String, model.NutritionCategory> categories,
  ) => transaction(() async {
    final day = DateTime.utc(date.year, date.month, date.day);
    final owner = currentUserId;
    final value = NutritionCategoriesCompanion(
      id: Value(day.toIso8601String()),
      referenceDate: Value(day),
      jsonData: Value(
        jsonEncode(categories.values.map((c) => c.toJson()).toList()),
      ),
      userId: Value(owner),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
    );
    final existing =
        await (select(nutritionCategories)..where(
              (t) =>
                  _ownedBy(t.userId, owner) &
                  t.id.equals(day.toIso8601String()),
            ))
            .get();
    if (existing.isEmpty) {
      await into(nutritionCategories).insert(value);
    } else {
      await (update(nutritionCategories)..where(
            (t) =>
                _ownedBy(t.userId, owner) & t.id.equals(day.toIso8601String()),
          ))
          .write(value);
    }
  });

  @override
  Future<void> mutateNutritionCategory(
    DateTime date, {
    model.NutritionCategory? category,
    String? oldName,
  }) => transaction(() async {
    final day = DateTime.utc(date.year, date.month, date.day);
    final previous =
        await (select(nutritionCategories)
              ..where(
                (t) =>
                    _ownedBy(t.userId, currentUserId) &
                    t.deleted.equals(false) &
                    t.referenceDate.isSmallerOrEqualValue(day),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.referenceDate)])
              ..limit(1))
            .getSingleOrNull();
    final map = <String, model.NutritionCategory>{};
    if (previous != null) {
      for (final raw in jsonDecode(previous.jsonData) as List) {
        final c = model.NutritionCategory.fromJson(raw);
        map[c.name] = c;
      }
    }
    if (oldName != null) {
      if (!map.containsKey(oldName))
        throw StateError('Category no longer exists');
      if (category != null) {
        if (category.name != oldName && map.containsKey(category.name)) {
          throw StateError('Category already exists');
        }
        final updated = <String, model.NutritionCategory>{
          for (final entry in map.entries)
            if (entry.key == oldName)
              category.name: category
            else
              entry.key: entry.value,
        };
        await setNutritionCategoriesForDay(day, updated);
        return;
      }
      map.remove(oldName);
    }
    if (category != null) {
      if (map.containsKey(category.name))
        throw StateError('Category already exists');
      map[category.name] = category;
    }
    await setNutritionCategoriesForDay(day, map);
  });

  @override
  Future<void> setNutritionCategories(
    Map<DateTime, Map<String, model.NutritionCategory>> categories,
  ) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      final retained = categories.keys
          .map((d) => DateTime.utc(d.year, d.month, d.day).toIso8601String())
          .toList();
      await (update(nutritionCategories)..where(
            (tbl) =>
                _ownedBy(tbl.userId, userId) &
                tbl.id.isNotIn(retained) &
                tbl.deleted.equals(false),
          ))
          .write(
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
              userId: Value(userId),
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
    return _watchForCurrentUser(() {
      return (select(achievements)..where(
            (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
          ))
          .watch();
    });
  }

  @override
  Future<void> insertAchievementCompletion(AchievementCompletion completion) {
    final userId = currentUserId;
    return into(achievements).insert(
      AchievementsCompanion(
        achievementID: Value(completion.achievementID),
        level: Value(completion.level),
        completedAt: Value(completion.completedAt),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
        userId: Value(userId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  @override
  Future<void> insertAchievementCompletions(
    List<AchievementCompletion> completions,
  ) {
    final userId = currentUserId;
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
                userId: Value(userId),
              ),
            )
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  @override
  Future<void> deleteAchievementCompletion(String achievementID, int level) {
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    return (update(achievements)..where((tbl) {
          return tbl.achievementID.equals(achievementID) &
              (tbl.level.equals(level) & _ownedBy(tbl.userId, userId));
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
    final userId = currentUserId;
    final now = DateTime.now().toUtc();
    return transaction(() async {
      await (update(
        achievements,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).write(
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
                  userId: Value(userId),
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
    return _watchForCurrentUser(() {
      final query = select(bodyMeasurements)
        ..where(
          (tbl) => tbl.deleted.equals(false) & _userIdPredicate(tbl.userId),
        )
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.time)]);
      return query.watch();
    });
  }

  @override
  Future<void> insertBodyMeasurement(BodyMeasurement measurement) {
    final userId = currentUserId;
    return into(bodyMeasurements).insert(
      measurement.toCompanion().copyWith(
        userId: Value(userId),
        updatedAt: Value(DateTime.now().toUtc()),
        deleted: const Value(false),
      ),
    );
  }

  @override
  Future<void> deleteBodyMeasurement(String id) {
    final userId = currentUserId;
    return (update(bodyMeasurements)
          ..where((tbl) => (tbl.id.equals(id) & _ownedBy(tbl.userId, userId))))
        .write(
          BodyMeasurementsCompanion(
            deleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  @override
  Future<void> updateBodyMeasurement(BodyMeasurement measurement) {
    final userId = currentUserId;
    return (update(bodyMeasurements)..where(
          (table) =>
              table.id.equals(measurement.id) & _ownedBy(table.userId, userId),
        ))
        .write(
          measurement.toCompanion().copyWith(
            userId: Value(userId),
            updatedAt: Value(DateTime.now().toUtc()),
            deleted: const Value(false),
          ),
        );
  }

  @override
  Future<void> setBodyMeasurements(List<BodyMeasurement> measurements) {
    final userId = currentUserId;
    return transaction(() async {
      final now = DateTime.now().toUtc();
      await (update(
        bodyMeasurements,
      )..where((tbl) => _ownedBy(tbl.userId, userId))).write(
        BodyMeasurementsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await batch((batch) {
        if (userId == null) {
          batch.deleteWhere(bodyMeasurements, (tbl) => tbl.userId.isNull());
        }
        for (final measurement in measurements) {
          batch.insert(
            bodyMeasurements,
            measurement.toCompanion().copyWith(
              userId: Value(userId),
              updatedAt: Value(now),
              deleted: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  @override
  Future<void> clearUserData(String? userId) {
    return transaction(() async {
      await deleteOngoingForUser(userId);
      if (_trainerSnapshots[this]?.owner == userId)
        _trainerSnapshots[this] = null;
      for (final name in [
        'trainer_caches',
        'catalog_submissions',
        'sync_outbox',
        'sync_metadata',
        'sync_cursors',
        'sync_conflicts',
        'sync_quarantine',
      ]) {
        await customStatement('DELETE FROM "$name" WHERE owner IS ?', [userId]);
      }
      for (final table in allTables) {
        final dsl = table.asDslTable;
        if (dsl is SyncableTable) {
          await (delete(table)..where(
                (_) => _ownedBy(dsl.userId as GeneratedColumn<String>, userId),
              ))
              .go();
        }
      }
    });
  }

  @override
  Future clearTheWholeThingIAmAbsolutelySureISwear() async {
    await SyncV2Store.receiving(this, () async {
      for (var table in allTables) {
        if (table.actualTableName != 'sync_context') await table.deleteAll();
      }
    });
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
    final epochs = [
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      DateTime.utc(0),
    ];
    await transaction(() async {
      await (update(routineFolders)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
          ))
          .write(
            RoutinesCompanion(userId: Value(userId), updatedAt: Value(now)),
          );

      await (update(historyWorkouts)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
          ))
          .write(
            AchievementsCompanion(userId: Value(userId), updatedAt: Value(now)),
          );

      await (update(foods)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
          ))
          .write(FoodsCompanion(userId: Value(userId), updatedAt: Value(now)));

      await (update(customBarcodeFoods)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
          ))
          .write(
            NutritionCategoriesCompanion(
              userId: Value(userId),
              updatedAt: Value(now),
            ),
          );

      await (update(waterLogs)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                r.updatedAt.isIn(epochs),
          ))
          .write(
            WaterLogsCompanion(userId: Value(userId), updatedAt: Value(now)),
          );

      await (update(nutritionGoals)..where(
            (r) =>
                (r.userId.isNull() | r.userId.equals(userId)) &
                (r.updatedAt.isNull() | r.updatedAt.isIn(epochs)),
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
    Map<String, String>? publicationVersions,
  }) {
    return [
      for (int i = 0; i < length; i++)
        this[i].toHistoryWorkoutInsertable(
          userId: userId,
          publicationVersion: publicationVersions?[this[i].id],
        ),
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

  HistoryWorkoutsCompanion toHistoryWorkoutInsertable({
    String? userId,
    String? publicationVersion,
  }) {
    return HistoryWorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(infobox ?? ""),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      visibility: Value(visibility),
      publicationManifest: Value(
        publicationVersion == null
            ? null
            : jsonEncode({
                'version': publicationVersion,
                'ids': flattenedExercises.map((e) => e.id).toList(),
              }),
      ),
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
  List<HistoryWorkoutExercisesCompanion> toSortedInsertables({
    String? userId,
    String? publicationVersion,
  }) {
    return [
      for (int i = 0; i < length; i++)
        this[i]
            .toInsertable(userId: userId)
            .copyWith(
              sortOrder: Value(i),
              publicationVersion: Value(publicationVersion),
            ),
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
      progression: this is model.Exercise
          ? Value(asExercise.progression)
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
      progression: this is model.Exercise
          ? Value(asExercise.progression)
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
      notes: Value(notes),
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
      water: Value(value.dailyWater),
      userId: Value(userId),
      updatedAt: Value(updatedAt ?? DateTime.now().toUtc()),
      deleted: const Value(false),
    );
  }
}

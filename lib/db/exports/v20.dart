import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/db/imports/v12.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/utils/extensions.dart';

/// Application-data export only. This format deliberately has no importer.
/// Like v12, exports active records belonging to the current user (or guest).
/// Ongoing workouts and the technical sync tables are excluded.
class VersionedJsonExportV20 {
  const VersionedJsonExportV20();

  int get version => 20;

  Future<Map<String, dynamic>> export(GTDatabase db) {
    final owner = db.currentUserId;
    return db.transaction(() async {
      void checkOwner() {
        if (db.currentUserId != owner) {
          throw StateError('Account changed during export');
        }
      }

      Future<T> read<T>(Stream<T> stream) async {
        checkOwner();
        final value = await stream.first;
        checkOwner();
        return value;
      }

      checkOwner();
      final routines = await read(db.getAllRoutines());
      final history = await read(db.getAllHistoryWorkouts());
      final categories = await read(db.watchNutritionCategories());
      final data = DatabaseSnapshot(
        customExercises: await read(db.getAllCustomExercises()),
        routines: routines,
        routineExercises: routines.flattenedExercises,
        historyWorkouts: history,
        historyWorkoutExercises: history.flattenedExercises,
        preferences: await read(db.watchPreferences()),
        weightMeasurements: await read(db.watchWeightMeasurements()),
        folders: await read(db.watchRoutineFolders()),
        foods: await read(db.watchFoods()),
        nutritionGoals: await read(db.watchNutritionGoals()),
        customBarcodeFoods: await read(db.watchCustomBarcodeFoods()),
        favoriteFoods: const [],
        foodCategories: {
          for (final entry in categories.entries)
            entry.key: entry.value.values.toList(),
        },
        achievements: await read(db.watchAchievementCompletions()),
        bodyMeasurements: await read(db.watchBodyMeasurements()),
      );
      final json = const VersionedJsonImportV12().export(data);
      json['version'] = version;
      (json['preferences'] as Map<String, dynamic>).addAll({
        'onboardingComplete': data.preferences.onboardingComplete,
        'anonymizedLogging': data.preferences.anonymizedLogging,
      });

      Future<List<QueryRow>> rows(String table) => db
          .customSelect(
            'SELECT * FROM "$table" WHERE deleted = 0 AND user_id IS ? ORDER BY rowid',
            variables: [Variable<String>(owner)],
          )
          .get();
      Map<String, dynamic> metadata(QueryRow row) => {
        'updated_at': row
            .readNullableWithType<DateTime>(DriftSqlType.dateTime, 'updated_at')
            ?.toUtc()
            .toIso8601String(),
        'deleted': row.readWithType<bool>(DriftSqlType.bool, 'deleted'),
        'user_id': row.readNullable<String>('user_id'),
      };

      // v13-v16: record ownership, modification/deletion metadata, composite IDs.
      for (final entry in const {
        'customExercises': 'custom_exercises',
        'routines': 'routines',
        'routineExercises': 'routine_exercises',
        'workouts': 'history_workouts',
        'workoutExercises': 'history_workout_exercises',
        'folders': 'routine_folders',
        'weightMeasurements': 'weight_measurements',
        'bodyMeasurements': 'body_measurements',
        'achievementCompletions': 'achievements_v2',
      }.entries) {
        final records = {
          for (final row in await rows(entry.value))
            row.read<String>('id'): row,
        };
        for (final item
            in (json[entry.key] as List).cast<Map<String, dynamic>>()) {
          final row = records[item['id']];
          if (row == null) {
            throw StateError(
              'Missing export record: ${entry.key}/${item['id']}',
            );
          }
          item.addAll(metadata(row));
          if (row.data.containsKey('sort_order')) {
            item['sortOrder'] = row.read<int>('sort_order');
          }
          if (entry.key == 'folders') {
            item['notes'] = row.readNullable<String>('notes');
          }
        }
      }
      // v17 folder notes and v19 exercise progressions are serialized by the
      // current model serializers used by the v12 application-data layout.
      final foods = {
        for (final row in await rows('foods')) row.read<String>('id'): row,
      };
      final foodItems = [
        for (final item in json['foods'] as List)
          Map<String, dynamic>.from(item as Map),
      ];
      json['foods'] = foodItems;
      for (final item in foodItems) {
        final row = foods[(item['food'] as Map)['id']]!;
        item.addAll({
          'id': row.read<String>('id'),
          ...metadata(row),
          'dateAdded': row
              .readWithType<DateTime>(DriftSqlType.dateTime, 'date_added')
              .toIso8601String(),
        });
      }
      json['nutritionGoals'] = [
        for (final row in await rows('nutrition_goals'))
          {
            'id': row.read<String>('id'),
            ...metadata(row),
            'date': databaseDateToLocalDay(
              row.readWithType<DateTime>(
                DriftSqlType.dateTime,
                'reference_date',
              ),
            ).toIso8601String(),
            'goal': {
              'dailyCalories': row.read<double>('calories'),
              'dailyFat': row.read<double>('fat'),
              'dailyCarbs': row.read<double>('carbs'),
              'dailyProtein': row.read<double>('protein'),
            },
          },
      ];
      final barcodeItems = (json['customBarcodeFoods'] as Map)
          .cast<String, dynamic>();
      for (final row in await rows('custom_barcode_foods')) {
        final id = row.read<String>('barcode');
        (barcodeItems[id] as Map<String, dynamic>).addAll({
          'id': id,
          ...metadata(row),
        });
      }
      // These v12 collections had no record objects to carry v14 metadata.
      json['favoriteFoods'] = [
        for (final row in await rows('favorite_foods'))
          {'id': row.read<String>('food_id'), ...metadata(row)},
      ];
      json['foodCategories'] = {
        for (final row in await rows('nutrition_categories'))
          databaseDateToLocalDay(
            row.readWithType<DateTime>(DriftSqlType.dateTime, 'reference_date'),
          ).toIso8601String(): {
            'id': row.readNullable<String>('id'),
            ...metadata(row),
            'categories':
                (json['foodCategories'] as Map)[databaseDateToLocalDay(
                  row.readWithType<DateTime>(
                    DriftSqlType.dateTime,
                    'reference_date',
                  ),
                ).toIso8601String()],
          },
      };
      checkOwner();
      return json;
    });
  }
}

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v20.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';

import '../helpers.dart';
import 'progression_persistence_test.dart' as progression;

void main() {
  late GTDatabaseImpl db;
  setUp(() => db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'exports every application area and post-v12 fields as encodable JSON',
    () async {
      db.setCurrentUserId('A');
      final day = DateTime(2026, 10, 22);
      final folder = GTRoutineFolder(
        id: 'folder',
        name: 'Folder',
        sortOrder: 0,
        notes: 'Folder notes',
      );
      await db.insertRoutineFolder(folder);
      await db.insertCustomExercise(exerciseHelper('custom', 'Custom'));
      await db.insertRoutine(
        Workout(
          id: 'routine',
          name: 'Routine',
          folder: folder,
          exercises: [
            progression.exercise('routine', progression: progression.goal),
          ],
        ),
      );
      await db.insertHistoryWorkout(
        Workout(
          id: 'workout',
          name: 'Workout',
          startingDate: day,
          duration: const Duration(minutes: 20),
          exercises: [
            progression.exercise('workout', progression: progression.goal),
          ],
        ),
      );
      await db.setPreferences(
        Prefs.defaultValue.copyWith(onboardingComplete: true),
      );
      await db.insertWeightMeasurement(
        WeightMeasurement(
          id: 'weight',
          weight: 80,
          time: day,
          weightUnit: Weights.kg,
        ),
      );
      await db.insertBodyMeasurement(
        BodyMeasurement(
          id: 'body',
          value: 90,
          time: day,
          type: BodyMeasurementPart.waist,
        ),
      );
      await db.insertAchievementCompletion(
        AchievementCompletion(
          achievementID: 'firstSteps',
          level: 1,
          completedAt: day,
        ),
      );
      final food = Food(
        id: 'food',
        name: 'Meal',
        amount: 100,
        nutritionalValuesPer100g: const NutritionValues(
          calories: 100,
          fat: 2,
          saturatedFat: 0,
          carbs: 10,
          sugar: 0,
          protein: 5,
        ),
      );
      await db.insertFoods(DateTagged(date: day, value: food));
      await db.insertCustomBarcodeFood('barcode', food);
      await db.insertFavoriteFood('food');
      await db.updateNutritionGoal(
        DateTagged(date: day, value: NutritionGoal.defaultGoal),
      );
      await db.setNutritionCategoriesForDay(day, {});
      await db.setOngoing({'name': 'Not exported'});

      final json = await const VersionedJsonExportV20()
          .export(db)
          .timeout(const Duration(seconds: 10));
      expect(jsonDecode(jsonEncode(json))['version'], 20);
      expect((json['folders'] as List).single['notes'], 'Folder notes');
      expect(
        (json['routineExercises'] as List).single['progression'],
        progression.goal.toJson(),
      );
      expect(
        (json['workoutExercises'] as List).single['progression'],
        progression.goal.toJson(),
      );
      expect(json['preferences']['onboardingComplete'], isTrue);
      for (final key in [
        'customExercises',
        'routines',
        'routineExercises',
        'workouts',
        'workoutExercises',
        'folders',
        'weightMeasurements',
        'bodyMeasurements',
        'achievementCompletions',
        'foods',
        'nutritionGoals',
        'favoriteFoods',
      ]) {
        final records = json[key] as List;
        expect(records, isNotEmpty, reason: key);
        for (final record in records) {
          expect(record['user_id'], 'A', reason: key);
          expect(record['deleted'], isFalse, reason: key);
          expect(record['updated_at'], isNotNull, reason: key);
          expect(record['id'], isNotNull, reason: key);
        }
      }
      expect(json['customBarcodeFoods']['barcode']['user_id'], 'A');
      expect(
        (json['foodCategories'] as Map).values.single['categories'],
        isEmpty,
      );
      expect(
        json.keys,
        unorderedEquals([
          'version',
          'customExercises',
          'routines',
          'routineExercises',
          'workouts',
          'workoutExercises',
          'preferences',
          'weightMeasurements',
          'folders',
          'foods',
          'nutritionGoals',
          'customBarcodeFoods',
          'favoriteFoods',
          'foodCategories',
          'achievementCompletions',
          'bodyMeasurements',
        ]),
      );
      expect(() => getConverter(20), throwsException);
    },
  );

  test(
    'reads persisted data without service caches and isolates active owner and guest',
    () async {
      for (final owner in [null, 'A', 'B']) {
        db.setCurrentUserId(owner);
        await db.insertCustomExercise(
          exerciseHelper('same-id', owner ?? 'Guest'),
        );
      }
      db.setCurrentUserId('A');
      await db.insertCustomExercise(exerciseHelper('deleted', 'Deleted'));
      await db.deleteCustomExercise('deleted');
      final service = DatabaseService.withDatabase(db);
      for (final owner in ['A', 'B', null]) {
        db.setCurrentUserId(owner);
        final json = await service.exportJson();
        expect(
          (json['customExercises'] as List).single['name'],
          owner ?? 'Guest',
        );
        expect((json['customExercises'] as List).single['user_id'], owner);
      }
    },
  );
}

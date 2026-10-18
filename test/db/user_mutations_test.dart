import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';

import '../helpers.dart';

void main() {
  late GTDatabaseImpl db;
  final day = DateTime(2026, 10, 18);
  final exercise = exerciseHelper('custom', 'Custom');
  final weight = WeightMeasurement(
    id: 'weight',
    weight: 70,
    time: day,
    weightUnit: .kg,
  );
  final body = BodyMeasurement(
    id: 'body',
    value: 30,
    time: day,
    type: .leftBicep,
  );
  final food = Food(
    id: 'food',
    name: 'Food',
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
  final folder = GTRoutineFolder(
    id: 'folder',
    name: 'Folder',
    sortOrder: 0,
    notes: '',
  );
  final routine = Workout(id: 'routine', name: 'Routine', exercises: []);
  final history = Workout(
    id: 'history',
    name: 'History',
    exercises: [],
    duration: const Duration(minutes: 30),
    startingDate: day,
  );
  final achievement = AchievementCompletion(
    achievementID: 'achievement',
    level: 1,
    completedAt: day,
  );

  Future<Map<String, dynamic>> otherUsers() async {
    final result = <String, dynamic>{};
    for (final table in db.allTables) {
      if (table.columnsByName.containsKey('user_id')) {
        result[table.actualTableName] =
            (await db
                    .customSelect(
                      'SELECT * FROM "${table.actualTableName}" WHERE user_id IS NOT ?',
                      variables: [Variable(db.currentUserId)],
                    )
                    .get())
                .map((r) => r.data)
                .toList();
      }
    }
    return result;
  }

  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    for (final user in [null, 'A', 'B']) {
      db.setCurrentUserId(user);
      await db.insertCustomExercise(exercise);
      await db.insertRoutineFolder(folder);
      await db.insertRoutine(routine);
      await db.insertHistoryWorkout(history);
      await db.insertWeightMeasurement(weight);
      await db.insertBodyMeasurement(body);
      await db.insertFoods(DateTagged(date: day, value: food));
      await db.insertCustomBarcodeFood('barcode', food);
      await db.insertFavoriteFood('food');
      await db
          .into(db.nutritionGoals)
          .insert(
            NutritionGoalsCompanion(
              id: Value(DateTime.utc(2026, 10, 18).toIso8601String()),
              userId: Value(user),
              referenceDate: Value(day),
              calories: const Value(2000),
              fat: const Value(50),
              carbs: const Value(250),
              protein: const Value(100),
            ),
          );
      await db.setNutritionCategories({day: {}});
      await db.insertAchievementCompletion(achievement);
    }
    db.setCurrentUserId('A');
  });
  tearDown(() => db.close());

  test('bulk mutations preserve all other users and guest rows', () async {
    final before = await otherUsers();
    for (final operation in <Future<void> Function()>[
      () => db.writeAllCustomExercises([]),
      () => db.writeAllRoutineFolders([]),
      () => db.writeAllRoutines([]),
      () => db.writeAllHistoryWorkouts([]),
      () => db.setWeightMeasurements([]),
      () => db.setBodyMeasurements([]),
      () => db.setFoods([]),
      () => db.setNutritionGoals([]),
      () => db.setCustomBarcodeFoods({}),
      () => db.setFavoriteFoods([]),
      () => db.setNutritionCategories({}),
      () => db.setAchievementCompletions([]),
    ]) {
      await operation();
      expect(await otherUsers(), before);
    }
  });

  test('point mutations use both identity and shared identifiers', () async {
    final before = await otherUsers();
    await db.updateRoutine(routine.copyWith(name: 'Changed'));
    await db.updateHistoryWorkout(history.copyWith(name: 'Changed'));
    await db.updateCustomExercise(exercise.copyWith(name: 'Changed'));
    await db.updateWeightMeasurement(weight);
    await db.updateBodyMeasurement(body);
    await db.updateFoods(DateTagged(date: day, value: food));
    await db.updateNutritionGoal(
      DateTagged(date: day, value: NutritionGoal.defaultGoal),
    );
    await db.deleteRoutine('routine');
    await db.deleteRoutineFolder('folder');
    await db.deleteHistoryWorkout('history');
    await db.deleteCustomExercise('custom');
    await db.deleteWeightMeasurement('weight');
    await db.deleteBodyMeasurement('body');
    await db.deleteFoods('food');
    await db.deleteCustomBarcodeFood('barcode');
    await db.deleteFavoriteFood('food');
    await db.deleteNutritionGoal(day);
    await db.deleteNutritionCategories(day);
    await db.deleteAchievementCompletion('achievement', 1);
    expect(await otherUsers(), before);
  });

  test(
    'scoped cleanup preserves all other accounts and device preferences',
    () async {
      final before = await otherUsers();
      final prefs = await db.watchPreferences().first;
      await db.clearUserData('A');
      expect(await otherUsers(), before);
      expect((await db.watchPreferences().first).toJson(), prefs.toJson());
      for (final table in db.allTables) {
        if (table.columnsByName.containsKey('user_id')) {
          expect(
            await db
                .customSelect(
                  'SELECT * FROM "${table.actualTableName}" WHERE user_id = ?',
                  variables: [Variable('A')],
                )
                .get(),
            isEmpty,
          );
        }
      }
    },
  );
}

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class _Database extends Mock implements DatabaseService {}

class _Online extends Mock implements OnlineService {}

void main() {
  setUpAll(() => registerFallbackValue(<AchievementCompletion>[]));

  group('food watcher calendar streaks', () {
    final now = DateTime.now();
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
    TaggedFood food(DateTime date) => DateTagged(
      date: date,
      value: const Food(
        name: 'Meal',
        amount: 100,
        nutritionalValuesPer100g: NutritionValues(
          calories: 100,
          fat: 0,
          saturatedFat: 0,
          carbs: 0,
          sugar: 0,
          protein: 0,
        ),
      ),
    );

    for (final days in [2, 7, 30]) {
      test('unlocks at exactly $days consecutive days including the first', () {
        final rules = AchievementRules(
          foods: () => [for (var i = 0; i < days; i++) food(day(-i))],
        );
        final level = rules.catalog['foodWatcher']!.levels.firstWhere(
          (level) => level.progressMax!() == days,
        );
        expect(level.progress!(), days.toDouble());
        expect(level.checkCompletion(level.progress!()), isTrue);
      });
    }

    test('counts today once and excludes future meals', () {
      final rules = AchievementRules(
        foods: () => [food(day(1)), food(day(0)), food(day(0))],
      );
      expect(rules.catalog['foodWatcher']!.levels.first.progress!(), 1);
    });

    test('keeps the longest historical streak across gaps and DST changes', () {
      final rules = AchievementRules(
        foods: () => [
          food(DateTime(2024, 3, 30)),
          food(DateTime(2024, 3, 31)),
          food(DateTime(2024, 4, 1)),
          food(DateTime(2024, 4, 1)),
          food(day(0)),
        ],
      );
      expect(rules.catalog['foodWatcher']!.levels.first.progress!(), 3);
    });
  });

  test(
    'catalog rules can evaluate empty data without an application scope',
    () {
      final catalog = AchievementRules().catalog;
      expect(
        catalog.keys,
        containsAll(['firstSteps', 'programPlanner', 'sparta']),
      );
      for (final achievement in catalog.values) {
        for (final level in achievement.levels) {
          final progress = level.progress?.call();
          expect(
            () => level.checkCompletion(progress),
            returnsNormally,
            reason: '${achievement.id}/${level.level}',
          );
        }
      }
    },
  );

  test(
    'real first steps rules persist and deduplicate unlocks for each owner',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      final service = _Database();
      final online = _Online();
      final events = EventBus();
      final completions = BehaviorSubject<List<AchievementCompletion>>.seeded(
        [],
      );
      final subscription = db.watchAchievementCompletions().listen(
        completions.add,
      );
      final weights = <WeightMeasurement>[];
      final rules = AchievementRules(
        history: () => [Workout(name: 'Completed', exercises: [])],
        weights: () => weights,
      );
      when(() => online.account).thenReturn(null);
      when(() => service.completions$).thenAnswer((_) => completions);
      when(() => service.insertAchievementCompletions(any())).thenAnswer(
        (inv) => db.insertAchievementCompletions(
          inv.positionalArguments.single as List<AchievementCompletion>,
        ),
      );
      final controller = AchievementsController(
        online,
        service: service,
        events: events,
        isSyncing: () => false,
        catalog: {'firstSteps': rules.catalog['firstSteps']!},
        unlocksEnabled: () => true,
      );
      addTearDown(() async {
        controller.dispose();
        events.dispose();
        await subscription.cancel();
        await completions.close();
        await db.close();
      });
      expect(
        controller
            .maybeUnlockAchievements(AchievementTrigger.workout)
            .values
            .single
            .single
            .level,
        1,
      );
      expect(
        controller.maybeUnlockAchievements(AchievementTrigger.workout),
        isEmpty,
      );
      final first = await db.watchAchievementCompletions().firstWhere(
        (rows) => rows.length == 1,
      );
      expect(first.single.userId, isNull);

      weights.add(
        WeightMeasurement(
          id: 'w',
          weight: 80,
          time: DateTime(2026),
          weightUnit: Weights.kg,
        ),
      );
      expect(
        controller
            .maybeUnlockAchievements(AchievementTrigger.weight)
            .values
            .single
            .single
            .level,
        2,
      );
      await db.watchAchievementCompletions().firstWhere(
        (rows) => rows.length == 2,
      );

      db.setCurrentUserId('A');
      when(() => online.account).thenReturn(OnlineAccount(id: 'A', name: 'A'));
      await completions.firstWhere((rows) => rows.isEmpty);
      final accountUnlocks = controller.maybeUnlockAchievements(
        AchievementTrigger.workout,
      );
      expect(
        accountUnlocks.values.single.map((completion) => completion.level),
        [1, 2],
      );
      final accountRows = await db.watchAchievementCompletions().firstWhere(
        (rows) => rows.length == 2,
      );
      expect(
        accountRows.every((completion) => completion.userId == 'A'),
        isTrue,
      );
      db.setCurrentUserId(null);
      expect((await db.watchAchievementCompletions().first).length, 2);
    },
  );
}

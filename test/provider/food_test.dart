import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class MockFoodsRepository extends Mock implements FoodsRepository {
  final foods$ = BehaviorSubject<List<DateTagged<Food>>>.seeded([]);
  final favoriteFoods$ = BehaviorSubject<List<Food>>.seeded([]);
  final customBarcodeFoods$ = BehaviorSubject<Map<String, Food>>.seeded({});
  final nutritionGoals$ = BehaviorSubject<List<TaggedNutritionGoal>>.seeded([]);
  final nutritionCategories$ =
      BehaviorSubject<DateSequence<Map<String, NutritionCategory>>>.seeded(
        DateSequence.empty(),
      );

  MockFoodsRepository() {
    when(() => watchFoods()).thenAnswer((_) => foods$.stream);
    when(() => watchFavoriteFoods()).thenAnswer((_) => favoriteFoods$.stream);
    when(
      () => watchCustomBarcodeFoods(),
    ).thenAnswer((_) => customBarcodeFoods$.stream);
    when(() => watchNutritionGoals()).thenAnswer((_) => nutritionGoals$.stream);
    when(
      () => watchNutritionCategories(),
    ).thenAnswer((_) => nutritionCategories$.stream);
  }
}

class MockAchievementsController extends Mock
    implements AchievementsController {}

class MockBackupScheduler extends Mock implements BackupScheduler {}

void main() {
  late MockFoodsRepository mockFoodsRepo;
  late MockAchievementsController mockAchievements;
  late MockBackupScheduler mockBackup;
  late ProviderContainer container;

  const sampleNutritionValues = NutritionValues(
    calories: 100,
    fat: 2,
    saturatedFat: 0.5,
    carbs: 15,
    sugar: 10,
    protein: 5,
  );

  Food createSampleFood({
    String? id = "food_1",
    String name = "Banana",
    String? brand,
    double amount = 100,
    String? category,
  }) {
    return Food(
      id: id,
      name: name,
      brand: brand,
      nutritionalValuesPer100g: sampleNutritionValues,
      amount: amount,
      category: category,
    );
  }

  setUpAll(() {
    registerFallbackValue(
      DateTagged<Food>(
        date: DateTime.now().startOfDay,
        value: createSampleFood(),
      ),
    );
    registerFallbackValue(
      TaggedNutritionGoal(
        date: DateTime.now().startOfDay,
        value: NutritionGoal.defaultGoal,
      ),
    );
    registerFallbackValue(createSampleFood());
    registerFallbackValue(
      const NutritionCategory(
        name: 'Test',
        dailyPercentage: 100,
        icon: NutritionCategoryIcon.coffee,
      ),
    );
    registerFallbackValue(AchievementTrigger.food);
  });

  setUp(() {
    mockFoodsRepo = MockFoodsRepository();
    mockAchievements = MockAchievementsController();
    mockBackup = MockBackupScheduler();

    when(
      () => mockFoodsRepo.addNutritionCategory(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFoodsRepo.removeNutritionCategory(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFoodsRepo.updateNutritionCategory(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockFoodsRepo.addFood(any())).thenAnswer((_) async {});
    when(() => mockFoodsRepo.removeFood(any())).thenAnswer((_) async {});
    when(() => mockFoodsRepo.updateFood(any())).thenAnswer((_) async {});
    when(() => mockFoodsRepo.addFavoriteFood(any())).thenAnswer((_) async {});
    when(
      () => mockFoodsRepo.removeFavoriteFood(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFoodsRepo.addCustomBarcodeFood(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockFoodsRepo.addNutritionGoal(any())).thenAnswer((_) async {});
    when(
      () => mockFoodsRepo.setNutritionCategoriesForDay(any(), any()),
    ).thenAnswer((_) async {});

    when(
      () => mockAchievements.maybeUnlockAchievements(any()),
    ).thenReturn(<Achievement, List<AchievementCompletion>>{});
    when(() => mockBackup.schedule()).thenAnswer((_) {});

    container = ProviderContainer(
      overrides: [
        foodsRepositoryProvider.overrideWithValue(mockFoodsRepo),
        backupSchedulerProvider.overrideWithValue(mockBackup),
        achievementTriggerProvider.overrideWithValue((trigger) {
          mockAchievements.maybeUnlockAchievements(trigger);
        }),
      ],
    );
    container.listen(foodLogsStreamProvider, (prev, next) {});
    container.listen(nutritionGoalsStreamProvider, (prev, next) {});
    container.listen(nutritionCategoriesStreamProvider, (prev, next) {});
    container.listen(favoriteFoodsStreamProvider, (prev, next) {});
    container.listen(customBarcodeFoodsStreamProvider, (prev, next) {});
  });

  tearDown(() {
    container.dispose();
  });

  group("FoodSelectedDateNotifier", () {
    test("initial state is today at start of day", () async {
      final selectedDate = container.read(foodSelectedDateProvider);
      expect(selectedDate, DateTime.now().startOfDay);
    });

    test("setDate updates state to start of given day", () async {
      final target = DateTime(2026, 5, 15, 14, 30);
      container.read(foodSelectedDateProvider.notifier).setDate(target);
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 15));
    });

    test("previousDay and nextDay shift by 1 day", () async {
      final target = DateTime(2026, 5, 15);
      container.read(foodSelectedDateProvider.notifier).setDate(target);

      container.read(foodSelectedDateProvider.notifier).previousDay();
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 14));

      container.read(foodSelectedDateProvider.notifier).nextDay();
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 15));
    });

    test("canGoToPreviousDay and canGoToNextDay boundary checks", () async {
      final notifier = container.read(foodSelectedDateProvider.notifier);

      notifier.setDate(DateTime(2026, 1, 1));
      expect(notifier.canGoToPreviousDay(), isTrue);
      expect(notifier.canGoToNextDay(), isTrue);

      notifier.setDate(DateTime(1999, 12, 31));
      expect(notifier.canGoToPreviousDay(), isFalse);

      notifier.setDate(DateTime(2100, 1, 1));
      expect(notifier.canGoToNextDay(), isFalse);
    });
  });

  group("foodCanUpdateCategoriesProvider", () {
    test("returns true for today and future dates, false for past", () async {
      final today = DateTime.now().startOfDay;
      container.read(foodSelectedDateProvider.notifier).setDate(today);
      expect(container.read(foodCanUpdateCategoriesProvider), isTrue);

      final tomorrow = today.add(const Duration(days: 1));
      container.read(foodSelectedDateProvider.notifier).setDate(tomorrow);
      expect(container.read(foodCanUpdateCategoriesProvider), isTrue);

      final yesterday = today.subtract(const Duration(days: 1));
      container.read(foodSelectedDateProvider.notifier).setDate(yesterday);
      expect(container.read(foodCanUpdateCategoriesProvider), isFalse);
    });
  });

  group("Food Logs & Queries", () {
    final d1 = DateTime(2026, 6, 1).startOfDay;
    final d2 = DateTime(2026, 6, 2).startOfDay;
    final foodA = createSampleFood(id: "f1", name: "Apple");
    final foodB = createSampleFood(id: "f2", name: "Banana");

    test("foodsForDate and taggedFoodsForDate filter by date", () async {
      mockFoodsRepo.foods$.add([
        DateTagged(date: d1, value: foodA),
        DateTagged(date: d2, value: foodB),
      ]);
      await pumpEventQueue();

      final foodsOnD1 = container.read(foodsForDateProvider(d1));
      expect(foodsOnD1, [foodA]);

      final taggedOnD1 = container.read(taggedFoodsForDateProvider(d1));
      expect(taggedOnD1.length, 1);
      expect(taggedOnD1.first.value, foodA);
      expect(taggedOnD1.first.date, d1);

      final foodsOnD2 = container.read(foodsForDateProvider(d2));
      expect(foodsOnD2, [foodB]);
    });

    test(
      "foodsForSelectedDate and taggedFoodsForSelectedDate follow foodSelectedDateProvider",
      () async {
        mockFoodsRepo.foods$.add([
          DateTagged(date: d1, value: foodA),
          DateTagged(date: d2, value: foodB),
        ]);
        await pumpEventQueue();

        container.read(foodSelectedDateProvider.notifier).setDate(d1);
        expect(container.read(foodsForSelectedDateProvider), [foodA]);
        expect(
          container.read(taggedFoodsForSelectedDateProvider).first.value,
          foodA,
        );

        container.read(foodSelectedDateProvider.notifier).setDate(d2);
        expect(container.read(foodsForSelectedDateProvider), [foodB]);
        expect(
          container.read(taggedFoodsForSelectedDateProvider).first.value,
          foodB,
        );
      },
    );

    test(
      "favoriteFoodsStream and customBarcodeFoodsStream pipe from database",
      () async {
        mockFoodsRepo.favoriteFoods$.add([foodA]);
        mockFoodsRepo.customBarcodeFoods$.add({"123456": foodB});
        await pumpEventQueue();

        final favs = container.read(favoriteFoodsStreamProvider).asData?.value;
        expect(favs, [foodA]);

        final barcodes = container
            .read(customBarcodeFoodsStreamProvider)
            .asData
            ?.value;
        expect(barcodes?["123456"], foodB);
      },
    );

    test(
      "foodSuggestions fuzzy matches and deduplicates by equality",
      () async {
        final f1 = createSampleFood(id: "1", name: "Oatmeal", brand: "Quaker");
        final f2 = createSampleFood(id: "2", name: "Oatmeal", brand: "Quaker");
        final f3 = createSampleFood(id: "3", name: "Banana");

        mockFoodsRepo.foods$.add([
          DateTagged(date: d1, value: f1),
          DateTagged(date: d2, value: f2),
          DateTagged(date: d2, value: f3),
        ]);
        await pumpEventQueue();

        final suggestions = container.read(foodSuggestionsProvider("Oat"));
        expect(suggestions.first.value.name, "Oatmeal");
        final oatmealCount = suggestions
            .where((s) => s.value.name == "Oatmeal")
            .length;
        expect(oatmealCount, 1);
      },
    );
  });

  group("FoodNotifier", () {
    final today = DateTime.now().startOfDay;
    final food = createSampleFood(id: "food_test", name: "Chicken Breast");

    test(
      "addFood calls dbService.addFood, maybeUnlockAchievements and scheduleBackup",
      () async {
        final cat = const NutritionCategory(
          name: "Lunch",
          dailyPercentage: 40,
          icon: NutritionCategoryIcon.fork_and_spoon,
        );

        final saved = await container
            .read(foodProvider.notifier)
            .addFood(today, food, category: cat);

        final captured =
            verify(() => mockFoodsRepo.addFood(captureAny())).captured.single
                as DateTagged<Food>;
        expect(captured.date, today);
        expect(saved, captured.value);
        expect(captured.value.name, "Chicken Breast");
        expect(captured.value.category, "Lunch");
        expect(captured.value.id, isNotNull);

        verify(
          () =>
              mockAchievements.maybeUnlockAchievements(AchievementTrigger.food),
        ).called(1);
        verify(() => mockBackup.schedule()).called(1);
      },
    );

    for (final operation in [
      'add',
      'remove',
      'update',
      'favorite',
      'unfavorite',
    ]) {
      test(
        '$operation completes achievements and backup after auto-disposal',
        () async {
          final pending = Completer<void>();
          mockFoodsRepo.foods$.add([DateTagged(date: today, value: food)]);
          await pumpEventQueue();
          switch (operation) {
            case 'add':
              when(
                () => mockFoodsRepo.addFood(any()),
              ).thenAnswer((_) => pending.future);
            case 'remove':
              when(
                () => mockFoodsRepo.removeFood(any()),
              ).thenAnswer((_) => pending.future);
            case 'update':
              when(
                () => mockFoodsRepo.updateFood(any()),
              ).thenAnswer((_) => pending.future);
            case 'favorite':
              when(
                () => mockFoodsRepo.addFavoriteFood(any()),
              ).thenAnswer((_) => pending.future);
            case 'unfavorite':
              when(
                () => mockFoodsRepo.removeFavoriteFood(any()),
              ).thenAnswer((_) => pending.future);
          }
          final notifier = container.read(foodProvider.notifier);
          final command = switch (operation) {
            'add' => notifier.addFood(today, food),
            'remove' => notifier.removeFood(today, food),
            'update' => notifier.updateFood(today, food.copyWith(amount: 250)),
            'favorite' => notifier.addFavorite(food),
            _ => notifier.removeFavorite(food),
          };
          await container.pump();
          expect(container.exists(foodProvider), isFalse);
          pending.complete();
          await command;
          verify(() => mockBackup.schedule()).called(1);
          if (operation == 'add' || operation == 'remove') {
            verify(
              () => mockAchievements.maybeUnlockAchievements(
                AchievementTrigger.food,
              ),
            ).called(1);
          }
        },
      );
    }

    test(
      'copy retains its command provider until the date is updated, then releases it',
      () async {
        final pending = Completer<void>();
        when(
          () => mockFoodsRepo.addFood(any()),
        ).thenAnswer((_) => pending.future);
        final dateSubscription = container.listen(
          foodSelectedDateProvider,
          (_, _) {},
        );
        container
            .read(foodSelectedDateProvider.notifier)
            .setDate(today.subtract(const Duration(days: 1)));
        final command = container.read(foodProvider.notifier).copyToToday(food);
        await container.pump();
        expect(container.exists(foodProvider), isTrue);
        pending.complete();
        await command;
        expect(container.read(foodSelectedDateProvider), today);
        await container.pump();
        expect(container.exists(foodProvider), isFalse);
        verify(() => mockBackup.schedule()).called(1);
        dateSubscription.close();
      },
    );

    test(
      'failed save after disposal does not trigger achievements or backup',
      () async {
        final pending = Completer<void>();
        when(
          () => mockFoodsRepo.addFood(any()),
        ).thenAnswer((_) => pending.future);
        final command = container
            .read(foodProvider.notifier)
            .addFood(today, food);
        final failure = expectLater(command, throwsStateError);
        await container.pump();
        expect(container.exists(foodProvider), isFalse);
        pending.completeError(StateError('Save failed'));
        await failure;
        verifyNever(() => mockBackup.schedule());
        verifyNever(() => mockAchievements.maybeUnlockAchievements(any()));
      },
    );

    test(
      "rapid additions and copies use independent food identities",
      () async {
        final notifier = container.read(foodProvider.notifier);
        for (var i = 0; i < 100; i++) {
          notifier.addFood(today, food);
          notifier.copyToToday(food);
        }
        final saved = verify(
          () => mockFoodsRepo.addFood(captureAny()),
        ).captured.cast<DateTagged<Food>>();
        expect(saved, hasLength(200));
        expect(saved.map((row) => row.value.id).toSet(), hasLength(200));
        expect(saved.every((row) => row.value.id != food.id), isTrue);
        expect(food.id, 'food_test');
      },
    );

    test(
      "removeFood calls dbService.removeFood, achievements and backup",
      () async {
        await container.read(foodProvider.notifier).removeFood(today, food);

        final captured =
            verify(() => mockFoodsRepo.removeFood(captureAny())).captured.single
                as DateTagged<Food>;
        expect(captured.date, today);
        expect(captured.value, food);

        verify(
          () =>
              mockAchievements.maybeUnlockAchievements(AchievementTrigger.food),
        ).called(1);
        verify(() => mockBackup.schedule()).called(1);
      },
    );

    test("updateFood updates food when it exists on the date", () async {
      mockFoodsRepo.foods$.add([DateTagged(date: today, value: food)]);
      await pumpEventQueue();

      final updated = food.copyWith(amount: 250);
      await container.read(foodProvider.notifier).updateFood(today, updated);

      final captured =
          verify(() => mockFoodsRepo.updateFood(captureAny())).captured.single
              as DateTagged<Food>;
      expect(captured.date, today);
      expect(captured.value.amount, 250);
      verify(() => mockBackup.schedule()).called(1);
    });

    test(
      "updateFood does nothing if food does not exist on the date",
      () async {
        mockFoodsRepo.foods$.add([]);
        await pumpEventQueue();

        final updated = food.copyWith(amount: 250);
        await container.read(foodProvider.notifier).updateFood(today, updated);

        verifyNever(() => mockFoodsRepo.updateFood(any()));
      },
    );

    test(
      "copyToToday adds food to today and sets selected date to today",
      () async {
        final pastDate = DateTime(2026, 1, 1).startOfDay;
        container.read(foodSelectedDateProvider.notifier).setDate(pastDate);

        await container.read(foodProvider.notifier).copyToToday(food);

        expect(container.read(foodSelectedDateProvider), today);
        verify(() => mockFoodsRepo.addFood(any())).called(1);
      },
    );

    test("addFavorite and removeFavorite delegate to dbService", () async {
      await container.read(foodProvider.notifier).addFavorite(food);
      verify(() => mockFoodsRepo.addFavoriteFood(food)).called(1);
      verify(() => mockBackup.schedule()).called(1);

      await container.read(foodProvider.notifier).removeFavorite(food);
      verify(() => mockFoodsRepo.removeFavoriteFood(food)).called(1);
    });

    test("addCustomBarcodeFood delegates to dbService with category", () async {
      final cat = const NutritionCategory(
        name: "Snack",
        dailyPercentage: 10,
        icon: NutritionCategoryIcon.cake,
      );

      await container
          .read(foodProvider.notifier)
          .addCustomBarcodeFood("11223344", food, cat);

      verify(
        () => mockFoodsRepo.addCustomBarcodeFood(
          "11223344",
          any(that: predicate<Food>((f) => f.category == "Snack")),
        ),
      ).called(1);
    });
  });

  group("Nutrition Goals Providers", () {
    final d1 = DateTime(2026, 3, 1).startOfDay;
    final d2 = DateTime(2026, 3, 15).startOfDay;
    const goal1 = NutritionGoal(
      dailyCalories: 2200,
      dailyFat: 70,
      dailyCarbs: 250,
      dailyProtein: 150,
    );
    const goal2 = NutritionGoal(
      dailyCalories: 2500,
      dailyFat: 80,
      dailyCarbs: 300,
      dailyProtein: 160,
    );

    test(
      "nutritionGoalsStream returns default goal if stream is empty",
      () async {
        mockFoodsRepo.nutritionGoals$.add([]);
        await pumpEventQueue();

        final seq = container.read(nutritionGoalsStreamProvider).asData?.value;
        expect(seq?.isNotEmpty, isTrue);
        expect(seq?[DateTime.now()], NutritionGoal.defaultGoal);
      },
    );

    test(
      "nutritionGoalForDate and nutritionGoalForSelectedDate fetch correct goals",
      () async {
        mockFoodsRepo.nutritionGoals$.add([
          TaggedNutritionGoal(date: d1, value: goal1),
          TaggedNutritionGoal(date: d2, value: goal2),
        ]);
        await pumpEventQueue();

        expect(container.read(nutritionGoalForDateProvider(d1)), goal1);
        expect(container.read(nutritionGoalForDateProvider(d2)), goal2);

        container.read(foodSelectedDateProvider.notifier).setDate(d1);
        expect(container.read(nutritionGoalForSelectedDateProvider), goal1);

        container.read(foodSelectedDateProvider.notifier).setDate(d2);
        expect(container.read(nutritionGoalForSelectedDateProvider), goal2);
      },
    );

    test("nutritionGoalDateRange calculates range for selected date", () async {
      mockFoodsRepo.nutritionGoals$.add([
        TaggedNutritionGoal(date: d1, value: goal1),
        TaggedNutritionGoal(date: d2, value: goal2),
      ]);
      await pumpEventQueue();

      container
          .read(foodSelectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 5));
      final range = container.read(nutritionGoalDateRangeProvider);
      expect(range, isNotNull);
      expect(range!.from, DateTime(2026, 3, 5));
      expect(range.to, d2);
    });

    test(
      "saveNewGoal adds goal to db for selected date and schedules backup",
      () async {
        container.read(foodSelectedDateProvider.notifier).setDate(d1);
        await container.read(nutritionGoalProvider.notifier).saveNewGoal(goal1);

        final captured =
            verify(
                  () => mockFoodsRepo.addNutritionGoal(captureAny()),
                ).captured.single
                as TaggedNutritionGoal;
        expect(captured.date, d1);
        expect(captured.value, goal1);
        verify(() => mockBackup.schedule()).called(1);
      },
    );
  });

  group('Category reordering', () {
    const a = NutritionCategory(
      name: 'A',
      dailyPercentage: 50,
      icon: NutritionCategoryIcon.coffee,
    );
    const b = NutritionCategory(
      name: 'B',
      dailyPercentage: 50,
      icon: NutritionCategoryIcon.cake,
    );
    setUp(() {
      mockFoodsRepo.nutritionCategories$.add(
        DateSequence.fromDatesAndValues({
          DateTime.now().startOfDay: {'A': a, 'B': b},
        }),
      );
      when(
        () => mockFoodsRepo.setNutritionCategoriesForDay(any(), any()),
      ).thenAnswer((_) async {});
    });
    test('saves order for today and future with backup', () async {
      for (final offset in [0, 1]) {
        final day = DateTime.now().startOfDay.add(Duration(days: offset));
        await container
            .read(nutritionCategoryProvider.notifier)
            .reorderCategories(day, ['B', 'A']);
        final saved =
            verify(
                  () => mockFoodsRepo.setNutritionCategoriesForDay(
                    day,
                    captureAny(),
                  ),
                ).captured.single
                as Map<String, NutritionCategory>;
        expect(saved.keys, ['B', 'A']);
        expect(saved['A'], a);
      }
      verify(() => mockBackup.schedule()).called(2);
    });
    test('rejects past, missing, duplicate and unknown names', () async {
      final today = DateTime.now().startOfDay;
      for (final names in [
        ['A'],
        ['A', 'A'],
        ['A', 'C'],
      ]) {
        await expectLater(
          container
              .read(nutritionCategoryProvider.notifier)
              .reorderCategories(today, names),
          throwsStateError,
        );
      }
      await expectLater(
        container.read(nutritionCategoryProvider.notifier).reorderCategories(
          today.subtract(const Duration(days: 1)),
          ['B', 'A'],
        ),
        throwsStateError,
      );
      verifyNever(
        () => mockFoodsRepo.setNutritionCategoriesForDay(any(), any()),
      );
      verifyNever(() => mockBackup.schedule());
    });
    test('unchanged order performs no write or backup', () async {
      await container
          .read(nutritionCategoryProvider.notifier)
          .reorderCategories(DateTime.now(), ['A', 'B']);
      verifyNever(
        () => mockFoodsRepo.setNutritionCategoriesForDay(any(), any()),
      );
      verifyNever(() => mockBackup.schedule());
    });
    test('failed save does not schedule backup', () async {
      when(
        () => mockFoodsRepo.setNutritionCategoriesForDay(any(), any()),
      ).thenThrow(StateError('failed'));
      await expectLater(
        container.read(nutritionCategoryProvider.notifier).reorderCategories(
          DateTime.now(),
          ['B', 'A'],
        ),
        throwsStateError,
      );
      verifyNever(() => mockBackup.schedule());
    });
  });

  group("Nutrition Categories Providers", () {
    final date = DateTime(2026, 4, 1).startOfDay;
    const catBreakfast = NutritionCategory(
      name: "Breakfast",
      dailyPercentage: 25,
      icon: NutritionCategoryIcon.coffee,
    );
    const catLunch = NutritionCategory(
      name: "Lunch",
      dailyPercentage: 40,
      icon: NutritionCategoryIcon.fork_and_spoon,
    );

    test("categoriesForDate and categoriesForSelectedDate fetch map", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast, "Lunch": catLunch},
      });
      mockFoodsRepo.nutritionCategories$.add(seq);
      await pumpEventQueue();

      final cats = container.read(categoriesForDateProvider(date));
      expect(cats.length, 2);
      expect(cats["Breakfast"], catBreakfast);

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      expect(container.read(categoriesForSelectedDateProvider), cats);
    });

    test(
      "unassignedFoodsForSelectedDate and foodsForCategory filter correctly",
      () async {
        final seq = DateSequence.fromDatesAndValues({
          date: {"Breakfast": catBreakfast},
        });
        mockFoodsRepo.nutritionCategories$.add(seq);

        final food1 = createSampleFood(
          id: "1",
          name: "Egg",
          category: "Breakfast",
        );
        final food2 = createSampleFood(id: "2", name: "Candy", category: null);
        final food3 = createSampleFood(
          id: "3",
          name: "Dinner Item",
          category: "Dinner",
        );

        mockFoodsRepo.foods$.add([
          DateTagged(date: date, value: food1),
          DateTagged(date: date, value: food2),
          DateTagged(date: date, value: food3),
        ]);
        await pumpEventQueue();

        container.read(foodSelectedDateProvider.notifier).setDate(date);

        final unassigned = container.read(
          unassignedFoodsForSelectedDateProvider,
        );
        expect(unassigned, [food2, food3]);

        final breakfastFoods = container.read(
          foodsForCategoryProvider(catBreakfast),
        );
        expect(breakfastFoods, [food1]);
      },
    );

    test("isUniqueCategoryName checks existence on selected date", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockFoodsRepo.nutritionCategories$.add(seq);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(date);

      expect(
        container.read(isUniqueCategoryNameProvider("Breakfast")),
        isFalse,
      );
      expect(container.read(isUniqueCategoryNameProvider("Dinner")), isTrue);
    });

    test(
      "addCategory adds new category to db and throws StateError if duplicate",
      () async {
        final seq = DateSequence.fromDatesAndValues({
          date: {"Breakfast": catBreakfast},
        });
        mockFoodsRepo.nutritionCategories$.add(seq);
        await pumpEventQueue();

        container.read(foodSelectedDateProvider.notifier).setDate(date);

        // Throws on duplicate
        expect(
          () => container
              .read(nutritionCategoryProvider.notifier)
              .addCategory(catBreakfast),
          throwsA(isA<StateError>()),
        );

        // Successfully adds unique category
        await container
            .read(nutritionCategoryProvider.notifier)
            .addCategory(catLunch);

        verify(
          () => mockFoodsRepo.addNutritionCategory(date, catLunch),
        ).called(1);
        verify(() => mockBackup.schedule()).called(1);
      },
    );

    test("removeCategory removes category and updates db", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast, "Lunch": catLunch},
      });
      mockFoodsRepo.nutritionCategories$.add(seq);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      await container
          .read(nutritionCategoryProvider.notifier)
          .removeCategory(catBreakfast);

      verify(
        () => mockFoodsRepo.removeNutritionCategory(date, "Breakfast"),
      ).called(1);
      verify(() => mockBackup.schedule()).called(1);
    });

    test("updateCategory replaces old category with new values", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockFoodsRepo.nutritionCategories$.add(seq);
      await pumpEventQueue();

      final updatedBreakfast = const NutritionCategory(
        name: "Morning Meal",
        dailyPercentage: 30,
        icon: NutritionCategoryIcon.coffee,
      );

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      await container
          .read(nutritionCategoryProvider.notifier)
          .updateCategory("Breakfast", updatedBreakfast);

      verify(
        () => mockFoodsRepo.updateNutritionCategory(
          date,
          "Breakfast",
          updatedBreakfast,
        ),
      ).called(1);
      verify(() => mockBackup.schedule()).called(1);
    });
  });

  group("showFoodPermissionsSettingsTileProvider", () {
    test(
      "returns true if permissions are incomplete, false if both granted",
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final containerWithIncomplete = ProviderContainer(
          overrides: [
            foodPermissionsProvider.overrideWith(
              () => _FakeFoodPermissionsNotifier(camera: true, gallery: false),
            ),
          ],
        );
        containerWithIncomplete.listen(
          foodPermissionsProvider,
          (prev, next) {},
        );
        await pumpEventQueue();

        expect(
          containerWithIncomplete.read(showFoodPermissionsSettingsTileProvider),
          isTrue,
        );
        containerWithIncomplete.dispose();

        final containerWithComplete = ProviderContainer(
          overrides: [
            foodPermissionsProvider.overrideWith(
              () => _FakeFoodPermissionsNotifier(camera: true, gallery: true),
            ),
          ],
        );
        containerWithComplete.listen(foodPermissionsProvider, (prev, next) {});
        await pumpEventQueue();

        expect(
          containerWithComplete.read(showFoodPermissionsSettingsTileProvider),
          isFalse,
        );
        containerWithComplete.dispose();
      },
    );
  });
}

class _FakeFoodPermissionsNotifier extends FoodPermissionsNotifier {
  final bool camera;
  final bool gallery;

  _FakeFoodPermissionsNotifier({required this.camera, required this.gallery});

  @override
  Future<FoodPermissions> build() async {
    return (camera: camera, gallery: gallery);
  }
}

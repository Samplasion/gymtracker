import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class MockInternalFinalCallback<T> extends Mock
    implements InternalFinalCallback<T> {
  @override
  T call() => null as dynamic;
}

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  final foods$ = BehaviorSubject<List<DateTagged<Food>>>.seeded([]);
  @override
  final favoriteFoods$ = BehaviorSubject<List<Food>>.seeded([]);
  @override
  final customBarcodeFoods$ = BehaviorSubject<Map<String, Food>>.seeded({});
  @override
  final nutritionGoals$ = BehaviorSubject<List<TaggedNutritionGoal>>.seeded([]);
  @override
  final nutritionCategories$ =
      BehaviorSubject<DateSequence<Map<String, NutritionCategory>>>.seeded(
    DateSequence.empty(),
  );

  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();

  @override
  void addListener(void Function() listener) {}
  @override
  void removeListener(void Function() listener) {}
}

class MockCoordinator extends Mock implements Coordinator {
  @override
  final onStart = MockInternalFinalCallback<void>();
  @override
  final onDelete = MockInternalFinalCallback<void>();
}

void main() {
  late MockDatabaseService mockDb;
  late MockCoordinator mockCoordinator;
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
    registerFallbackValue(AchievementTrigger.food);
  });

  setUp(() {
    Get.reset();
    Get.testMode = true;

    mockDb = MockDatabaseService();
    mockCoordinator = MockCoordinator();

    Get.put<DatabaseService>(mockDb);
    Get.put<Coordinator>(mockCoordinator);

    when(() => mockDb.addFood(any())).thenAnswer((_) {});
    when(() => mockDb.removeFood(any())).thenAnswer((_) {});
    when(() => mockDb.updateFood(any())).thenAnswer((_) {});
    when(() => mockDb.addFavoriteFood(any())).thenAnswer((_) {});
    when(() => mockDb.removeFavoriteFood(any())).thenAnswer((_) {});
    when(() => mockDb.addCustomBarcodeFood(any(), any())).thenAnswer((_) {});
    when(() => mockDb.addNutritionGoal(any())).thenAnswer((_) {});
    when(() => mockDb.setNutritionCategoriesForDay(any(), any()))
        .thenAnswer((_) {});

    when(() => mockCoordinator.maybeUnlockAchievements(any()))
        .thenReturn(<Achievement, List<AchievementCompletion>>{});
    when(() => mockCoordinator.scheduleBackup()).thenAnswer((_) {});

    container = ProviderContainer();
    container.listen(foodLogsStreamProvider, (prev, next) {});
    container.listen(nutritionGoalsStreamProvider, (prev, next) {});
    container.listen(nutritionCategoriesStreamProvider, (prev, next) {});
    container.listen(favoriteFoodsStreamProvider, (prev, next) {});
    container.listen(customBarcodeFoodsStreamProvider, (prev, next) {});
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group("FoodSelectedDateNotifier", () {
    test("initial state is today at start of day", () {
      final selectedDate = container.read(foodSelectedDateProvider);
      expect(selectedDate, DateTime.now().startOfDay);
    });

    test("setDate updates state to start of given day", () {
      final target = DateTime(2026, 5, 15, 14, 30);
      container.read(foodSelectedDateProvider.notifier).setDate(target);
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 15));
    });

    test("previousDay and nextDay shift by 1 day", () {
      final target = DateTime(2026, 5, 15);
      container.read(foodSelectedDateProvider.notifier).setDate(target);

      container.read(foodSelectedDateProvider.notifier).previousDay();
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 14));

      container.read(foodSelectedDateProvider.notifier).nextDay();
      expect(container.read(foodSelectedDateProvider), DateTime(2026, 5, 15));
    });

    test("canGoToPreviousDay and canGoToNextDay boundary checks", () {
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
    test("returns true for today and future dates, false for past", () {
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
      mockDb.foods$.add([
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

    test("foodsForSelectedDate and taggedFoodsForSelectedDate follow foodSelectedDateProvider", () async {
      mockDb.foods$.add([
        DateTagged(date: d1, value: foodA),
        DateTagged(date: d2, value: foodB),
      ]);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(d1);
      expect(container.read(foodsForSelectedDateProvider), [foodA]);
      expect(container.read(taggedFoodsForSelectedDateProvider).first.value, foodA);

      container.read(foodSelectedDateProvider.notifier).setDate(d2);
      expect(container.read(foodsForSelectedDateProvider), [foodB]);
      expect(container.read(taggedFoodsForSelectedDateProvider).first.value, foodB);
    });

    test("favoriteFoodsStream and customBarcodeFoodsStream pipe from database", () async {
      mockDb.favoriteFoods$.add([foodA]);
      mockDb.customBarcodeFoods$.add({"123456": foodB});
      await pumpEventQueue();

      final favs = container.read(favoriteFoodsStreamProvider).asData?.value;
      expect(favs, [foodA]);

      final barcodes = container.read(customBarcodeFoodsStreamProvider).asData?.value;
      expect(barcodes?["123456"], foodB);
    });

    test("foodSuggestions fuzzy matches and deduplicates by equality", () async {
      final f1 = createSampleFood(id: "1", name: "Oatmeal", brand: "Quaker");
      final f2 = createSampleFood(id: "2", name: "Oatmeal", brand: "Quaker");
      final f3 = createSampleFood(id: "3", name: "Banana");

      mockDb.foods$.add([
        DateTagged(date: d1, value: f1),
        DateTagged(date: d2, value: f2),
        DateTagged(date: d2, value: f3),
      ]);
      await pumpEventQueue();

      final suggestions = container.read(foodSuggestionsProvider("Oat"));
      expect(suggestions.first.value.name, "Oatmeal");
      final oatmealCount =
          suggestions.where((s) => s.value.name == "Oatmeal").length;
      expect(oatmealCount, 1);
    });
  });

  group("FoodNotifier", () {
    final today = DateTime.now().startOfDay;
    final food = createSampleFood(id: "food_test", name: "Chicken Breast");

    test("addFood calls dbService.addFood, maybeUnlockAchievements and scheduleBackup", () {
      final cat = const NutritionCategory(
        name: "Lunch",
        dailyPercentage: 40,
        icon: NutritionCategoryIcon.fork_and_spoon,
      );

      container.read(foodProvider.notifier).addFood(today, food, category: cat);

      final captured = verify(() => mockDb.addFood(captureAny())).captured.single
          as DateTagged<Food>;
      expect(captured.date, today);
      expect(captured.value.name, "Chicken Breast");
      expect(captured.value.category, "Lunch");
      expect(captured.value.id, isNotNull);

      verify(() => mockCoordinator.maybeUnlockAchievements(AchievementTrigger.food))
          .called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });

    test("removeFood calls dbService.removeFood, achievements and backup", () {
      container.read(foodProvider.notifier).removeFood(today, food);

      final captured = verify(() => mockDb.removeFood(captureAny())).captured.single
          as DateTagged<Food>;
      expect(captured.date, today);
      expect(captured.value, food);

      verify(() => mockCoordinator.maybeUnlockAchievements(AchievementTrigger.food))
          .called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });

    test("updateFood updates food when it exists on the date", () {
      mockDb.foods$.add([DateTagged(date: today, value: food)]);

      final updated = food.copyWith(amount: 250);
      container.read(foodProvider.notifier).updateFood(today, updated);

      final captured = verify(() => mockDb.updateFood(captureAny())).captured.single
          as DateTagged<Food>;
      expect(captured.date, today);
      expect(captured.value.amount, 250);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });

    test("updateFood does nothing if food does not exist on the date", () {
      mockDb.foods$.add([]);

      final updated = food.copyWith(amount: 250);
      container.read(foodProvider.notifier).updateFood(today, updated);

      verifyNever(() => mockDb.updateFood(any()));
    });

    test("copyToToday adds food to today and sets selected date to today", () {
      final pastDate = DateTime(2026, 1, 1).startOfDay;
      container.read(foodSelectedDateProvider.notifier).setDate(pastDate);

      container.read(foodProvider.notifier).copyToToday(food);

      expect(container.read(foodSelectedDateProvider), today);
      verify(() => mockDb.addFood(any())).called(1);
    });

    test("addFavorite and removeFavorite delegate to dbService", () {
      container.read(foodProvider.notifier).addFavorite(food);
      verify(() => mockDb.addFavoriteFood(food)).called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);

      container.read(foodProvider.notifier).removeFavorite(food);
      verify(() => mockDb.removeFavoriteFood(food)).called(1);
    });

    test("addCustomBarcodeFood delegates to dbService with category", () {
      final cat = const NutritionCategory(
        name: "Snack",
        dailyPercentage: 10,
        icon: NutritionCategoryIcon.cake,
      );

      container
          .read(foodProvider.notifier)
          .addCustomBarcodeFood("11223344", food, cat);

      verify(() => mockDb.addCustomBarcodeFood(
            "11223344",
            any(that: predicate<Food>((f) => f.category == "Snack")),
          )).called(1);
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

    test("nutritionGoalsStream returns default goal if stream is empty", () async {
      mockDb.nutritionGoals$.add([]);
      await pumpEventQueue();

      final seq = container.read(nutritionGoalsStreamProvider).asData?.value;
      expect(seq?.isNotEmpty, isTrue);
      expect(seq?[DateTime.now()], NutritionGoal.defaultGoal);
    });

    test("nutritionGoalForDate and nutritionGoalForSelectedDate fetch correct goals", () async {
      mockDb.nutritionGoals$.add([
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
    });

    test("nutritionGoalDateRange calculates range for selected date", () async {
      mockDb.nutritionGoals$.add([
        TaggedNutritionGoal(date: d1, value: goal1),
        TaggedNutritionGoal(date: d2, value: goal2),
      ]);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(DateTime(2026, 3, 5));
      final range = container.read(nutritionGoalDateRangeProvider);
      expect(range, isNotNull);
      expect(range!.from, DateTime(2026, 3, 5));
      expect(range.to, d2);
    });

    test("saveNewGoal adds goal to db for selected date and schedules backup", () {
      container.read(foodSelectedDateProvider.notifier).setDate(d1);
      container.read(nutritionGoalProvider.notifier).saveNewGoal(goal1);

      final captured =
          verify(() => mockDb.addNutritionGoal(captureAny())).captured.single
              as TaggedNutritionGoal;
      expect(captured.date, d1);
      expect(captured.value, goal1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
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
      mockDb.nutritionCategories$.add(seq);
      await pumpEventQueue();

      final cats = container.read(categoriesForDateProvider(date));
      expect(cats.length, 2);
      expect(cats["Breakfast"], catBreakfast);

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      expect(container.read(categoriesForSelectedDateProvider), cats);
    });

    test("unassignedFoodsForSelectedDate and foodsForCategory filter correctly", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockDb.nutritionCategories$.add(seq);

      final food1 = createSampleFood(id: "1", name: "Egg", category: "Breakfast");
      final food2 = createSampleFood(id: "2", name: "Candy", category: null);
      final food3 = createSampleFood(id: "3", name: "Dinner Item", category: "Dinner");

      mockDb.foods$.add([
        DateTagged(date: date, value: food1),
        DateTagged(date: date, value: food2),
        DateTagged(date: date, value: food3),
      ]);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(date);

      final unassigned = container.read(unassignedFoodsForSelectedDateProvider);
      expect(unassigned, [food2, food3]);

      final breakfastFoods =
          container.read(foodsForCategoryProvider(catBreakfast));
      expect(breakfastFoods, [food1]);
    });

    test("isUniqueCategoryName checks existence on selected date", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockDb.nutritionCategories$.add(seq);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(date);

      expect(container.read(isUniqueCategoryNameProvider("Breakfast")), isFalse);
      expect(container.read(isUniqueCategoryNameProvider("Dinner")), isTrue);
    });

    test("addCategory adds new category to db and throws StateError if duplicate", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockDb.nutritionCategories$.add(seq);
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
      container
          .read(nutritionCategoryProvider.notifier)
          .addCategory(catLunch);

      verify(() => mockDb.setNutritionCategoriesForDay(
            date,
            any(that: predicate<Map<String, NutritionCategory>>(
              (m) => m.containsKey("Breakfast") && m.containsKey("Lunch"),
            )),
          )).called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });

    test("removeCategory removes category and updates db", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast, "Lunch": catLunch},
      });
      mockDb.nutritionCategories$.add(seq);
      await pumpEventQueue();

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      container
          .read(nutritionCategoryProvider.notifier)
          .removeCategory(catBreakfast);

      verify(() => mockDb.setNutritionCategoriesForDay(
            date,
            any(that: predicate<Map<String, NutritionCategory>>(
              (m) => !m.containsKey("Breakfast") && m.containsKey("Lunch"),
            )),
          )).called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });

    test("updateCategory replaces old category with new values", () async {
      final seq = DateSequence.fromDatesAndValues({
        date: {"Breakfast": catBreakfast},
      });
      mockDb.nutritionCategories$.add(seq);
      await pumpEventQueue();

      final updatedBreakfast = const NutritionCategory(
        name: "Morning Meal",
        dailyPercentage: 30,
        icon: NutritionCategoryIcon.coffee,
      );

      container.read(foodSelectedDateProvider.notifier).setDate(date);
      container
          .read(nutritionCategoryProvider.notifier)
          .updateCategory("Breakfast", updatedBreakfast);

      verify(() => mockDb.setNutritionCategoriesForDay(
            date,
            any(that: predicate<Map<String, NutritionCategory>>(
              (m) =>
                  !m.containsKey("Breakfast") &&
                  m["Morning Meal"] == updatedBreakfast,
            )),
          )).called(1);
      verify(() => mockCoordinator.scheduleBackup()).called(1);
    });
  });

  group("showFoodPermissionsSettingsTileProvider", () {
    test("returns true if permissions are incomplete, false if both granted", () async {
      final containerWithIncomplete = ProviderContainer(
        overrides: [
          foodPermissionsProvider.overrideWith(
            () => _FakeFoodPermissionsNotifier(camera: true, gallery: false),
          ),
        ],
      );
      containerWithIncomplete.listen(foodPermissionsProvider, (prev, next) {});
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
    });
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

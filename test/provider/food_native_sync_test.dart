import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

class _Repository extends Mock implements FoodsRepository {}

class _Native extends Mock implements NativeService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BehaviorSubject<List<DateTagged<Food>>> foods;
  late BehaviorSubject<List<TaggedNutritionGoal>> goals;
  late BehaviorSubject<DateSequence<Map<String, NutritionCategory>>> categories;
  late ProviderContainer container;
  late List<NativeFoodStateMessage> messages;
  late StreamController<NativeFoodStateMessage> sent;

  Future<void> waitForMessage(
    bool Function(NativeFoodStateMessage) matches,
  ) async {
    if (messages.isNotEmpty && matches(messages.last)) return;
    await sent.stream.firstWhere(matches).timeout(const Duration(seconds: 2));
  }

  setUp(() {
    final repository = _Repository();
    final native = _Native();
    foods = BehaviorSubject.seeded([]);
    goals = BehaviorSubject.seeded([]);
    categories = BehaviorSubject.seeded(DateSequence.empty());
    messages = [];
    sent = StreamController.broadcast(sync: true);
    when(repository.watchFoods).thenAnswer((_) => foods.stream);
    when(repository.watchNutritionGoals).thenAnswer((_) => goals.stream);
    when(
      repository.watchNutritionCategories,
    ).thenAnswer((_) => categories.stream);
    registerFallbackValue(
      NativeFoodStateMessage(
        calorieGoal: 2000,
        calorieIntake: 0,
        categories: [],
        totalNutritionSplit: NativeFoodNutritionSplit(
          protein: 0,
          proteinGoal: 100,
          carbs: 0,
          carbsGoal: 250,
          fats: 0,
          fatsGoal: 60,
        ),
      ),
    );
    when(() => native.setFoodParameters(any())).thenAnswer((call) {
      final message = call.positionalArguments.single as NativeFoodStateMessage;
      messages.add(message);
      sent.add(message);
    });
    final version = VersionService()
      ..packageInfo = PackageInfo(
        appName: 'test',
        packageName: 'test',
        version: '1',
        buildNumber: '1',
      );
    container = ProviderContainer(
      overrides: [
        foodsRepositoryProvider.overrideWithValue(repository),
        nativeServiceProvider.overrideWithValue(native),
        versionServiceProvider.overrideWithValue(version),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Future.wait([
      foods.close(),
      goals.close(),
      categories.close(),
      sent.close(),
    ]);
  });

  test(
    'sync stays active without food screens and sends current daily totals',
    () async {
      container.listen(foodNativeSyncProvider, (_, _) {});

      await container.pump();
      final today = DateTime.now().startOfDay;
      goals.add([
        DateTagged(
          date: today,
          value: const NutritionGoal(
            dailyCalories: 2400,
            dailyProtein: 120,
            dailyCarbs: 300,
            dailyFat: 80,
          ),
        ),
      ]);
      categories.add(
        DateSequence.fromList([
          DateTagged(
            date: today,
            value: {
              'Lunch': const NutritionCategory(
                name: 'Lunch',
                dailyPercentage: 25,
                icon: NutritionCategoryIcon.fork_and_spoon,
              ),
              'Zero': const NutritionCategory(
                name: 'Zero',
                dailyPercentage: 0,
                icon: NutritionCategoryIcon.water,
              ),
            },
          ),
        ]),
      );
      Food meal(String id) => Food(
        id: id,
        name: 'Meal',
        amount: 200,
        category: 'Lunch',
        nutritionalValuesPer100g: const NutritionValues(
          saturatedFat: 0,
          sugar: 0,
          calories: 100,
          protein: 5,
          carbs: 15,
          fat: 2,
        ),
      );
      foods.add([
        DateTagged(date: today, value: meal('today')),
        DateTagged(
          date: today.subtract(const Duration(days: 1)),
          value: meal('yesterday'),
        ),
      ]);

      await container.pump();
      // Navigating the diary must not change the Watch's current-day snapshot.
      container.read(foodSelectedDateProvider.notifier).previousDay();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await container.pump();
      await waitForMessage(
        (m) =>
            m.calorieIntake == 200 &&
            m.calorieGoal == 2400 &&
            m.categories.length == 2,
      );
      final snapshot = messages.last;
      expect(snapshot.calorieGoal, 2400);
      expect(snapshot.calorieIntake, 200);
      expect(snapshot.totalNutritionSplit.protein, 10);
      expect(snapshot.totalNutritionSplit.carbs, 30);
      expect(snapshot.totalNutritionSplit.fats, 4);
      expect(snapshot.categories.first.nutritionSplit.proteinGoal, 30);
      expect(snapshot.categories.first.nutritionSplit.carbsGoal, 75);
      expect(snapshot.categories.first.nutritionSplit.fatsGoal, 20);
      expect(snapshot.categories.last.nutritionSplit.proteinGoal, 0);

      foods.add([]);

      await container.pump();
      await waitForMessage((m) => m.calorieIntake == 0);
      expect(messages.last.calorieIntake, 0);
      expect(messages.last.categories.first.nutritionSplit.protein, 0);
      // No food view is mounted while repository updates continue to arrive.
      goals.add([DateTagged(date: today, value: NutritionGoal.defaultGoal)]);

      await container.pump();
      await waitForMessage((m) => m.calorieGoal == 2000);
      expect(messages.last.calorieGoal, 2000);
      categories.add(DateSequence.empty());

      await container.pump();
      await waitForMessage((m) => m.categories.isEmpty);
      expect(messages.last.categories, isEmpty);
    },
  );

  test(
    'resume refreshes once; disposal cancels callbacks and stream listeners',
    () async {
      container.listen(foodNativeSyncProvider, (_, _) {});

      await container.pump();
      final before = messages.length;
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );

      await container.pump();
      expect(messages.length, before + 1);
      container.invalidate(foodNativeSyncProvider);

      await container.pump();
      final rebuilt = messages.length;
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );

      await container.pump();
      expect(messages.length, rebuilt + 1);
      container.dispose();
      final disposed = messages.length;
      foods.add([]);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );

      await container.pump();
      expect(messages.length, disposed);
      // Avoid disposing the same container twice in tearDown.
      container = ProviderContainer();
    },
  );
}

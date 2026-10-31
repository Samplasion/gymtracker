import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';
import 'package:rxdart/rxdart.dart';

import '../test_helpers/widget_test_app.dart';

void main() {
  const base = NutritionValues(
    calories: 100,
    fat: 4,
    saturatedFat: 1,
    carbs: 12,
    sugar: 2,
    protein: 8,
    fiber: 3,
  );
  const order = [
    'calories',
    'fat',
    'saturatedFat',
    'carbs',
    'sugar',
    'protein',
  ];

  testWidgets(
    'daily totals include categories, unassigned foods, quantities and pieces and follow date and log changes',
    (tester) async {
      await initTestLocalizations();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      Food food(
        String name,
        double amount, {
        int pieces = 1,
        String? category,
        NutritionValues values = base,
      }) => Food(
        name: name,
        amount: amount,
        pieces: pieces,
        category: category,
        nutritionalValuesPer100g: values,
      );
      final rows = [
        DateTagged(
          date: today,
          value: food('A', 50, pieces: 2, category: 'Breakfast'),
        ),
        DateTagged(
          date: today,
          value: food('B', 150, category: 'Lunch'),
        ),
        DateTagged(
          date: today,
          value: food(
            'C',
            50,
            values: const NutritionValues(
              calories: 100,
              fat: 4,
              saturatedFat: 1,
              carbs: 12,
              sugar: 2,
              protein: 8,
            ),
          ),
        ),
        DateTagged(date: tomorrow, value: food('Tomorrow', 200)),
      ];
      final source = BehaviorSubject<List<DateTagged<Food>>>.seeded(rows);
      final container = ProviderContainer(
        overrides: [
          foodLogsStreamProvider.overrideWith((ref) => source.stream),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await source.close();
      });
      container.read(foodSelectedDateProvider.notifier).setDate(today);
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WidgetTestApp(
            child: SingleChildScrollView(child: FoodDayNutritionTable()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      NutritionTable table() =>
          tester.widget<NutritionTable>(find.byType(NutritionTable));
      expect(find.text('Daily nutritional values'), findsOneWidget);
      expect(table().per100g.calories, 300);
      expect(table().per100g.fiber, 7.5);
      expect(table().per100g.sodium, isNull);
      expect(
        tester
            .widgetList<NutritionRow>(find.byType(NutritionRow))
            .take(6)
            .map((row) => row.id),
        order,
      );
      expect(tester.takeException(), isNull);

      // An addition, edit and removal all flow through the same reactive totals.
      source.add([...rows, DateTagged(date: today, value: food('Added', 100))]);
      await tester.pumpAndSettle();
      expect(table().per100g.calories, 400);
      source.add([
        DateTagged(date: today, value: food('Edited', 250)),
        rows.last,
      ]);
      await tester.pumpAndSettle();
      expect(table().per100g.calories, 250);
      source.add([rows.last]);
      await tester.pumpAndSettle();
      expect(table().per100g.calories, 0);
      expect(table().per100g.fiber, isNull);
      expect(
        tester
            .widgetList<NutritionRow>(find.byType(NutritionRow))
            .map((row) => row.value),
        everyElement(0),
      );
      container.read(foodSelectedDateProvider.notifier).setDate(tomorrow);
      await tester.pumpAndSettle();
      expect(table().per100g.calories, 200);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'food form fields follow table order and retain their nutrient bindings',
    (tester) async {
      await initTestLocalizations();
      await tester.pumpWidget(
        const WidgetTestApp(child: CustomAddFoodView(category: null)),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(CustomAddFoodView));
      final controllers =
          state.controllers as Map<String, TextEditingController>;
      expect(controllers.keys.take(6), order);
      for (var i = 0; i < order.length; i++) {
        controllers[order[i]]!.text = '${i + 1}';
      }
      await tester.pump();
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .where((field) => controllers.values.contains(field.controller))
          .toList();
      expect(fields.take(6).map((field) => field.controller!.text), [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
      ]);
      for (final field in fields.take(6)) {
        expect(field.validator!(field.controller!.text), isNull);
      }
      expect(tester.takeException(), isNull);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';

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

  for (final scenario in [
    (
      name: 'multiple pieces preserve nutrition per 100g',
      foods: [
        Food(
          name: 'Ingredient',
          amount: 100,
          pieces: 2,
          nutritionalValuesPer100g: base,
        ),
      ],
      factor: 1.0,
    ),
    (
      name: 'mixed ingredients use total mass including all pieces',
      foods: [
        Food(
          name: 'Ingredient A',
          amount: 50,
          pieces: 3,
          nutritionalValuesPer100g: base,
        ),
        Food(
          name: 'Ingredient B',
          amount: 100,
          pieces: 1,
          nutritionalValuesPer100g: base * 2,
        ),
      ],
      // 150g at 100kcal/100g plus 100g at 200kcal/100g:
      // 350kcal in 250g, hence 140kcal per 100g.
      factor: 1.4,
    ),
    (
      name: 'single pieces retain weighted nutrition',
      foods: [
        Food(
          name: 'Ingredient A',
          amount: 50,
          pieces: 1,
          nutritionalValuesPer100g: base,
        ),
        Food(
          name: 'Ingredient B',
          amount: 150,
          pieces: 1,
          nutritionalValuesPer100g: base * 2,
        ),
      ],
      factor: 1.75,
    ),
  ]) {
    testWidgets(scenario.name, (tester) async {
      await initTestLocalizations();
      await tester.pumpWidget(
        const WidgetTestApp(child: AddCombinedFoodView(category: null)),
      );
      final dynamic state = tester.state(find.byType(AddCombinedFoodView));
      state.constituents = scenario.foods;

      final NutritionValues result = state.nutritionalValues;
      final expected = base * scenario.factor;
      for (final nutrient in [
        'calories',
        'fat',
        'saturatedFat',
        'carbs',
        'sugar',
        'protein',
        'fiber',
      ]) {
        expect(
          result.toJson()[nutrient],
          closeTo(expected.toJson()[nutrient] as double, 0.00001),
          reason: nutrient,
        );
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }
}

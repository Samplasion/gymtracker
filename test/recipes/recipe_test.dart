import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/recipe.dart';

const values = NutritionValues(
  calories: 100,
  fat: 2,
  saturatedFat: 1,
  carbs: 10,
  sugar: 3,
  protein: 5,
  water: 80,
  fiber: 2,
);
const solid = Food(
  name: 'Solid',
  amount: 50,
  pieces: 2,
  nutritionalValuesPer100g: values,
);
const liquid = Food(
  name: 'Liquid',
  amount: 50,
  pieces: 2,
  unit: NutritionUnit.MILLI_L,
  nutritionalValuesPer100g: values,
);
Recipe recipe({int servings = 2, double? mass}) => Recipe(
  id: 'recipe',
  name: 'Meal',
  servings: servings,
  finalMass: mass,
  ingredients: const [
    RecipeIngredient(food: solid),
    RecipeIngredient(food: liquid, gramsPerMl: 0.8),
  ],
);

void main() {
  test(
    'mixed units and pieces conserve all nutrients, using explicit density',
    () {
      final r = recipe();
      expect(r.ingredientMass, 180);
      expect(r.servingMass, 90);
      for (final key in values.toJson().keys) {
        final original = values.toJson()[key];
        if (original == null) continue;
        expect(
          r.nutrients.toJson()[key],
          closeTo((original as num) * 2, 1e-9),
          reason: key,
        );
        expect(
          r.perServing.toJson()[key],
          closeTo(original.toDouble(), 1e-9),
          reason: key,
        );
        expect(
          r.toFood().nutritionalValues.toJson()[key],
          closeTo(original.toDouble(), 1e-9),
          reason: key,
        );
      }
    },
  );
  test(
    'cooked weight changes concentration without changing total nutrients',
    () {
      final r = recipe(mass: 120);
      expect(r.mass, 120);
      expect(r.servingMass, 60);
      expect(r.per100g.calories, closeTo(200 / 120 * 100, 1e-9));
      expect(r.nutrients.calories, 200);
      expect(r.perServing.calories, 100);
      expect(r.toFood(grams: 30).nutritionalValues.calories, closeTo(50, 1e-9));
      expect(r.toFood(portions: 0.5).amount, 30);
    },
  );
  test(
    'scaling a liquid preserves density and its original ml nutrient basis',
    () {
      const ingredient = RecipeIngredient(food: liquid, gramsPerMl: 0.8);
      final changed = ingredient.withFood(liquid.copyWith(amount: 100));
      expect(changed.mass, 160);
      expect(changed.food.nutritionalValues.calories, 200);
    },
  );
  test('JSON preserves original ingredients, density and Quill deltas', () {
    final r = Recipe(
      id: 'recipe',
      name: 'Meal',
      description:
          '[{"insert":"Bold","attributes":{"bold":true}},{"insert":"\\n"}]',
      instructions: '[{"insert":"Cook\\n"}]',
      ingredients: recipe().ingredients,
      servings: 3,
      finalMass: 150,
    );
    final copy = Recipe.fromJson(jsonDecode(jsonEncode(r.toJson())));
    expect(copy.toJson(), r.toJson());
    expect(copy.ingredients.last.food.unit, NutritionUnit.MILLI_L);
  });
  test(
    'serving bounds, quantities, masses and missing liquid conversions are validated',
    () {
      recipe(servings: 1).validate();
      recipe(servings: 32).validate();
      expect(() => recipe(servings: 0).validate(), throwsArgumentError);
      expect(() => recipe(servings: 33).validate(), throwsArgumentError);
      for (final mass in [0.0, -1.0, double.infinity, double.nan]) {
        expect(() => recipe(mass: mass).validate(), throwsArgumentError);
        expect(() => recipe().toFood(grams: mass), throwsArgumentError);
      }
      expect(
        () => const RecipeIngredient(food: liquid).validate(),
        throwsStateError,
      );
      expect(
        () => RecipeIngredient(food: solid.copyWith(amount: -1)).validate(),
        throwsArgumentError,
      );
      expect(
        () => RecipeIngredient(
          food: solid.copyWith(amount: double.nan),
        ).validate(),
        throwsArgumentError,
      );
      expect(
        () => Recipe(
          id: 'x',
          name: '',
          ingredients: recipe().ingredients,
        ).validate(),
        throwsArgumentError,
      );
      expect(
        () => Recipe(id: 'x', name: 'Empty', ingredients: []).validate(),
        throwsArgumentError,
      );
    },
  );
}

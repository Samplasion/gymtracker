import 'package:gymtracker/struct/nutrition.dart';

/// An ingredient keeps its original nutrition basis (g or ml).
class RecipeIngredient {
  final Food food;
  final double? gramsPerMl;

  const RecipeIngredient({required this.food, this.gramsPerMl});

  double get quantity => food.amount * food.pieces;
  double get mass => food.unit == NutritionUnit.MILLI_L
      ? quantity * (gramsPerMl ?? (throw StateError('Missing liquid mass')))
      : quantity;

  void validate() {
    if (!quantity.isFinite ||
        quantity <= 0 ||
        food.pieces < 1 ||
        !mass.isFinite ||
        mass <= 0 ||
        (food.unit != NutritionUnit.G && food.unit != NutritionUnit.MILLI_L)) {
      throw ArgumentError('Invalid ingredient quantity or mass');
    }
  }

  RecipeIngredient withFood(Food value) =>
      RecipeIngredient(food: value, gramsPerMl: gramsPerMl);

  Map<String, dynamic> toJson() => {
    'food': food.toJson(),
    if (gramsPerMl != null) 'gramsPerMl': gramsPerMl,
  };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        food: Food.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
        gramsPerMl: (json['gramsPerMl'] as num?)?.toDouble(),
      );
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final double? finalMass;

  Recipe({
    required this.id,
    required this.name,
    this.description = '',
    this.instructions = '',
    this.servings = 1,
    required List<RecipeIngredient> ingredients,
    this.finalMass,
  }) : ingredients = List.unmodifiable(ingredients);

  double get ingredientMass =>
      ingredients.fold(0, (sum, item) => sum + item.mass);
  double get mass => finalMass ?? ingredientMass;
  double get servingMass => mass / servings;
  NutritionValues get nutrients => ingredients.fold(
    NutritionValues.zero,
    (sum, item) => sum + item.food.nutritionalValues,
  );
  NutritionValues get per100g => nutrients / mass * 100;
  NutritionValues get perServing => nutrients / servings.toDouble();

  void validate() {
    if (name.trim().isEmpty ||
        servings < 1 ||
        servings > 32 ||
        ingredients.isEmpty) {
      throw ArgumentError('Invalid recipe');
    }
    for (final ingredient in ingredients) {
      ingredient.validate();
    }
    if (!mass.isFinite || mass <= 0) throw ArgumentError('Invalid recipe mass');
  }

  /// Independent diary snapshot: later recipe changes never alter this food.
  Food toFood({double? grams, double portions = 1}) {
    validate();
    final amount = grams ?? servingMass * portions;
    if (!amount.isFinite || amount <= 0) throw ArgumentError('Invalid amount');
    return Food(
      name: name,
      amount: amount,
      unit: NutritionUnit.G,
      origin: 'recipe',
      nutritionalValuesPer100g: per100g,
      servingSizes: [ServingSize(amount: servingMass)],
      downloadedFromOFF: ingredients.any((i) => i.food.downloadedFromOFF),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'instructions': instructions,
    'servings': servings,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    if (finalMass != null) 'finalMass': finalMass,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    instructions: json['instructions'] as String? ?? '',
    servings: json['servings'] as int? ?? 1,
    finalMass: (json['finalMass'] as num?)?.toDouble(),
    ingredients: (json['ingredients'] as List)
        .map(
          (i) => RecipeIngredient.fromJson(Map<String, dynamic>.from(i as Map)),
        )
        .toList(),
  );
}

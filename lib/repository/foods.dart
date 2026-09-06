import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foods.g.dart';

class FoodsRepository {
  final GTDatabase _db;
  FoodsRepository(this._db);

  // Food logs
  Stream<List<DateTagged<Food>>> watchFoods() {
    return _db.watchFoods();
  }

  Future<void> addFood(DateTagged<Food> food) {
    return _db.insertFoods(food);
  }

  Future<void> removeFood(DateTagged<Food> food) {
    return _db.deleteFoods(food.value.id!);
  }

  Future<void> updateFood(DateTagged<Food> food) {
    return _db.updateFoods(food);
  }

  Future<void> setFoods(List<DateTagged<Food>> foods) {
    return _db.setFoods(foods);
  }

  // Favorite foods
  Stream<List<Food>> watchFavoriteFoods() {
    return _db.watchFavoriteFoods();
  }

  Future<void> addFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be favorited");
    }
    return _db.insertFavoriteFood(food.id!);
  }

  Future<void> removeFavoriteFood(Food food) {
    if (food.id == null) {
      throw Exception("Food must have an ID to be unfavorited");
    }
    return _db.deleteFavoriteFood(food.id!);
  }

  Future<void> setFavoriteFoods(List<Food> foods) {
    return _db.setFavoriteFoods(foods.map((f) => f.id!).toList());
  }

  // Custom barcode foods
  Stream<Map<String, Food>> watchCustomBarcodeFoods() {
    return _db.watchCustomBarcodeFoods();
  }

  Future<void> addCustomBarcodeFood(String barcode, Food food) {
    return _db.insertCustomBarcodeFood(barcode, food);
  }

  Future<void> removeCustomBarcodeFood(String barcode) {
    return _db.deleteCustomBarcodeFood(barcode);
  }

  Future<void> setCustomBarcodeFoods(Map<String, Food> foods) {
    return _db.setCustomBarcodeFoods(foods);
  }

  // Nutrition goals
  Stream<List<TaggedNutritionGoal>> watchNutritionGoals() {
    return _db.watchNutritionGoals();
  }

  Future<void> addNutritionGoal(TaggedNutritionGoal goal) async {
    final currentGoals = await _db.watchNutritionGoals().first;
    final newGoals = [...currentGoals, goal];
    return _db.setNutritionGoals(
      DateSequence.normalized(newGoals).values.toList(),
    );
  }

  Future<void> removeNutritionGoal(TaggedNutritionGoal goal) {
    return _db.deleteNutritionGoal(goal.date.startOfDay);
  }

  Future<void> updateNutritionGoal(TaggedNutritionGoal goal) {
    return _db.updateNutritionGoal(goal);
  }

  Future<void> setNutritionGoals(List<TaggedNutritionGoal> goals) {
    return _db.setNutritionGoals(goals);
  }

  // Nutrition categories
  Stream<DateSequence<Map<String, NutritionCategory>>>
  watchNutritionCategories() {
    return _db
        .watchNutritionCategories()
        .map((event) => DateSequence.fromDatesAndValues(event).normalize());
  }

  Future<void> setNutritionCategoriesForDay(
    DateTime date,
    Map<String, NutritionCategory> map,
  ) async {
    final current = await watchNutritionCategories().first;
    final values = current.toMap();
    return _db.setNutritionCategories(
      DateSequence.fromDatesAndValues({
        ...values,
        date.startOfDay: map,
      }).normalize().toMap(),
    );
  }

  Future<void> setNutritionCategories(
    Map<DateTime, Map<String, NutritionCategory>> categories,
  ) {
    return _db.setNutritionCategories(categories);
  }
}

// Expose the repository
@Riverpod(keepAlive: true)
FoodsRepository foodsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return FoodsRepository(db);
}

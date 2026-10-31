import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/struct/recipe.dart';

class RecipesRepository {
  final GTDatabase db;
  RecipesRepository(this.db, {this.onChange});
  final void Function()? onChange;
  Stream<List<Recipe>> watch() => db.watchRecipes();
  Future<void> save(Recipe value) async {
    await db.saveRecipe(value);
    onChange?.call();
  }

  Future<void> remove(String id) async {
    await db.deleteRecipe(id);
    onChange?.call();
  }
}

final recipesRepositoryProvider = Provider(
  (ref) => RecipesRepository(
    ref.watch(appDatabaseProvider),
    onChange: () => ref.read(backupSchedulerProvider).schedule(),
  ),
);
final recipesProvider = StreamProvider(
  (ref) => ref.watch(recipesRepositoryProvider).watch(),
);

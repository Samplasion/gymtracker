import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/recipe.dart';
import 'package:syncable/syncable.dart';
import '../sync/durable_protocol_test.dart' show ProtocolBackend;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'recipe definitions, edits and tombstones synchronize between two devices',
    () async {
      final backend = ProtocolBackend()..entity = 'recipes';
      final devices = List.generate(
        2,
        (_) => GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()),
      );
      final managers = <SyncManager<GTDatabase>>[];
      addTearDown(() async {
        for (final manager in managers) {
          await manager.close();
        }
        for (final device in devices) {
          await device.close();
        }
        await backend.client.dispose();
      });
      for (final device in devices) {
        await device.customSelect('SELECT 1').get();
        device.setCurrentUserId('owner');
        final manager = SyncManager<GTDatabase>(
          localDatabase: device,
          supabaseClient: backend.client,
          useProtocolV2: true,
          syncInterval: const Duration(hours: 1),
        );
        manager.registerSyncable<DBRecipe>(
          backendTable: 'recipes',
          fromJson: DBRecipe.fromJson,
          companionConstructor: RecipesCompanion.new,
        );
        manager.setUserId('owner');
        manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
        managers.add(manager);
      }
      final recipe = Recipe(
        id: 'meal',
        name: 'Milk pudding',
        servings: 4,
        description: '[{"insert":"Description\\n","attributes":{"bold":true}}]',
        instructions: '[{"insert":"Cook\\n"}]',
        finalMass: 350,
        ingredients: const [
          RecipeIngredient(
            gramsPerMl: 1.03,
            food: Food(
              name: 'Milk',
              amount: 400,
              unit: NutritionUnit.MILLI_L,
              nutritionalValuesPer100g: NutritionValues.zero,
            ),
          ),
        ],
      );
      await devices.first.saveRecipe(recipe);
      managers.first.enableSync();
      await managers.first.syncTables();
      expect(
        jsonDecode(backend.rows['meal']!['json_data'] as String),
        recipe.toJson(),
      );
      managers.last.enableSync();
      await managers.last.syncTables();
      expect(
        (await devices.last.watchRecipes().first).single.toJson(),
        recipe.toJson(),
      );
      final changed = Recipe.fromJson({
        ...recipe.toJson(),
        'servings': 2,
        'instructions': '[{"insert":"Bake\\n"}]',
      });
      await devices.last.saveRecipe(changed);
      await managers.last.syncTables();
      await managers.first.syncTables();
      expect(
        (await devices.first.watchRecipes().first).single.toJson(),
        changed.toJson(),
      );
      await devices.first.deleteRecipe('meal');
      await managers.first.syncTables();
      await managers.last.syncTables();
      expect(await devices.last.watchRecipes().first, isEmpty);
      expect(backend.rows['meal']!['deleted'], true);
    },
  );
}

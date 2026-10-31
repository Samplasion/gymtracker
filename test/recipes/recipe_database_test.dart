import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v24.dart';
import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/db/sync_diagnostics.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/recipe.dart';

Recipe recipe(String name) => Recipe(
  id: 'shared-id',
  name: name,
  description: '[{"insert":"Description\\n","attributes":{"bold":true}}]',
  instructions: '[{"insert":"Cook\\n"}]',
  servings: 2,
  ingredients: const [
    RecipeIngredient(
      food: Food(
        name: 'Milk',
        amount: 200,
        unit: NutritionUnit.MILLI_L,
        nutritionalValuesPer100g: NutritionValues.zero,
      ),
      gramsPerMl: 1.03,
    ),
  ],
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  setUp(() => db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());
  test(
    'guest upserts, owner isolation, Quill persistence and tombstones',
    () async {
      await db.saveRecipe(recipe('Guest'));
      await db.saveRecipe(recipe('Guest edited'));
      expect(await db.watchRecipes().first, hasLength(1));
      for (final owner in ['A', 'B']) {
        db.setCurrentUserId(owner);
        await db.saveRecipe(recipe(owner));
      }
      db.setCurrentUserId('A');
      final r = (await db.watchRecipes().first).single;
      expect(r.name, 'A');
      expect(r.toJson(), recipe('A').toJson());
      await db.deleteRecipe(r.id);
      expect(await db.watchRecipes().first, isEmpty);
      expect(
        (await db
                .customSelect("SELECT deleted FROM recipes WHERE user_id='A'")
                .getSingle())
            .read<int>('deleted'),
        1,
      );
      db.setCurrentUserId('B');
      expect((await db.watchRecipes().first).single.name, 'B');
      db.setCurrentUserId(null);
      expect((await db.watchRecipes().first).single.name, 'Guest edited');
    },
  );
  test('recipe mutations are captured by the durable sync outbox', () async {
    db.setCurrentUserId('A');
    await db.saveRecipe(recipe('Meal'));
    final rows = await db
        .customSelect("SELECT * FROM sync_outbox WHERE entity='recipes'")
        .get();
    expect(rows, hasLength(1));
    final payload = jsonDecode(rows.single.read<String>('payload'));
    expect(payload['user_id'], 'A');
    expect(payload['id'], 'shared-id');
    await db.deleteRecipe('shared-id');
    final outbox = await db
        .customSelect(
          "SELECT payload FROM sync_outbox WHERE entity='recipes' ORDER BY rowid DESC LIMIT 1",
        )
        .getSingle();
    expect(jsonDecode(outbox.read<String>('payload'))['deleted'], 1);
  });
  test(
    'a diary snapshot survives recipe edits and deletion as a single food',
    () async {
      final r = recipe('Meal');
      await db.saveRecipe(r);
      final day = DateTime(2026, 10, 28);
      await db.insertFoods(
        DateTagged(
          date: day,
          value: r.toFood().copyWith(id: 'entry'),
        ),
      );
      await db.saveRecipe(recipe('Changed'));
      await db.deleteRecipe(r.id);
      final logs = await db.watchFoods().first;
      expect(logs, hasLength(1));
      expect(logs.single.value.name, 'Meal');
      expect(logs.single.value.amount, 103);
      expect(logs.single.value.origin, 'recipe');
    },
  );
  test(
    'v23 migration preserves foods and creates an empty recipe register',
    () async {
      final schema = jsonDecode(
        File('drift_schemas/drift_schema_v23.json').readAsStringSync(),
      );
      final upgraded = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            for (final entry in schema['fixed_sql'] as List) {
              for (final sql in entry['sql'] as List) {
                if (sql['dialect'] == 'sqlite') {
                  raw.execute(sql['sql'] as String);
                }
              }
            }
            raw.execute(
              "INSERT INTO foods(id,date_added,reference_date,json_data,updated_at,deleted) VALUES('old',0,0,'{}',0,0)",
            );
            raw.execute('PRAGMA user_version=23');
          },
        ),
      );
      addTearDown(upgraded.close);
      expect(await upgraded.watchRecipes().first, isEmpty);
      expect(
        (await upgraded.customSelect('SELECT id FROM foods').getSingle())
            .read<String>('id'),
        'old',
      );
      await upgraded.saveRecipe(recipe('After upgrade'));
      expect(await upgraded.watchRecipes().first, hasLength(1));
    },
  );
  test(
    'exports include only active recipes for the selected account',
    () async {
      await db.saveRecipe(recipe('Guest'));
      db.setCurrentUserId('A');
      await db.saveRecipe(recipe('A'));
      final json = await const VersionedJsonExportV24().export(db);
      expect(json['version'], 24);
      expect((json['recipes'] as List).single, recipe('A').toJson());
      await db.deleteRecipe('shared-id');
      expect(
        (await const VersionedJsonExportV24().export(db))['recipes'],
        isEmpty,
      );
    },
  );
  test(
    'legacy snapshot JSON carries recipes and old JSON defaults to none',
    () async {
      final service = DatabaseService.withDatabase(db);
      service.recipes$.add([recipe('Saved')]);
      final json = service.toJson();
      expect(
        getConverter(12).process(json).recipes.single.toJson(),
        recipe('Saved').toJson(),
      );
      json.remove('recipes');
      expect(getConverter(12).process(json).recipes, isEmpty);
      // The test owns the database, so do not dispose the service here.
    },
  );
  test(
    'the standard guest import includes recipes and keeps owner collisions separate',
    () async {
      await db.saveRecipe(recipe('Guest'));
      db.setCurrentUserId('A');
      final preview = await GuestImportPreview.load(db, 'A');
      expect(preview.rows['recipes'], hasLength(1));
      await preview.apply(db, 'A');
      expect((await db.watchRecipes().first).single.name, 'Guest');
      db.setCurrentUserId(null);
      expect(await db.watchRecipes().first, isEmpty);
      await db.saveRecipe(recipe('Another guest'));
      db.setCurrentUserId('A');
      final collision = await GuestImportPreview.load(db, 'A');
      expect(collision.collisions, 1);
      await collision.apply(db, 'A');
      expect((await db.watchRecipes().first).single.name, 'Guest');
      db.setCurrentUserId(null);
      expect((await db.watchRecipes().first).single.name, 'Another guest');
    },
  );

  test('native backups restore recipes and density', () async {
    final temp = await Directory.systemTemp.createTemp('recipes-test');
    addTearDown(() => temp.delete(recursive: true));
    await db.saveRecipe(recipe('Backup'));
    final path = '${temp.path}/backup.db';
    await db.customStatement('VACUUM INTO ?', [path]);
    await db.deleteRecipe('shared-id');
    final prepared = await PreparedDatabaseRestore.load(File(path), null);
    await prepared.apply(db, mode: RestoreMode.replace);
    expect(
      (await db.watchRecipes().first).single.toJson(),
      recipe('Backup').toJson(),
    );
  });
}

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/sync_diagnostics.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:syncable/syncable.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
  });
  tearDown(() => db.close());
  Future<void> goal(String? owner, double calories) => db
      .into(db.nutritionGoals)
      .insertOnConflictUpdate(
        NutritionGoalsCompanion.insert(
          id: const Value('day'),
          userId: Value(owner),
          referenceDate: DateTime.utc(2026, 10, 20),
          calories: calories,
          fat: 50,
          carbs: 200,
          protein: 100,
        ),
      );
  test(
    'category edits read the latest day atomically and preserve other days',
    () async {
      db.setCurrentUserId('A');
      final repo = FoodsRepository(db);
      final day = DateTime(2026, 10, 20);
      const breakfast = NutritionCategory(
        name: 'Breakfast',
        dailyPercentage: 50,
        icon: NutritionCategoryIcon.coffee,
      );
      const lunch = NutritionCategory(
        name: 'Lunch',
        dailyPercentage: 50,
        icon: NutritionCategoryIcon.coffee,
      );
      await Future.wait([
        repo.addNutritionCategory(day, breakfast),
        repo.addNutritionCategory(day, lunch),
      ]);
      await repo.addNutritionCategory(
        DateTime(2026, 10, 21),
        const NutritionCategory(
          name: 'Dinner',
          dailyPercentage: 10,
          icon: NutritionCategoryIcon.coffee,
        ),
      );
      final days = await db.watchNutritionCategories().first;
      expect(days[day]!.keys.toSet(), {'Breakfast', 'Lunch'});
      expect(days[DateTime(2026, 10, 21)]!.keys.toSet(), {
        'Breakfast',
        'Lunch',
        'Dinner',
      });
    },
  );
  test(
    'guest goals and categories can be edited repeatedly without duplicate identities',
    () async {
      final day = DateTime(2026, 10, 20);
      await db.updateNutritionGoal(
        TaggedNutritionGoal(date: day, value: NutritionGoal.defaultGoal),
      );
      await db.updateNutritionGoal(
        TaggedNutritionGoal(date: day, value: NutritionGoal.defaultGoal),
      );
      await db.setNutritionCategoriesForDay(day, {});
      await db.setNutritionCategoriesForDay(day, {});
      final id = DateTime.utc(2026, 10, 20).toIso8601String();
      expect(
        await (db.select(
          db.nutritionGoals,
        )..where((t) => t.userId.isNull() & t.id.equals(id))).get(),
        hasLength(1),
      );
      expect(
        await (db.select(
          db.nutritionCategories,
        )..where((t) => t.userId.isNull() & t.id.equals(id))).get(),
        hasLength(1),
      );
    },
  );

  test(
    'a missing category identity is archived and repaired without changing its day',
    () async {
      db.setCurrentUserId('A');
      await db
          .into(db.nutritionCategories)
          .insert(
            NutritionCategoriesCompanion(
              userId: const Value('A'),
              id: const Value(null),
              referenceDate: Value(DateTime.utc(2020, 3, 29)),
              jsonData: const Value('[]'),
            ),
          );
      await SyncV2Store.install(db);
      final repaired = await (db.select(
        db.nutritionCategories,
      )..where((t) => t.userId.equals('A'))).getSingle();
      expect(repaired.id, DateTime.utc(2020, 3, 29).toIso8601String());
      expect(
        await db
            .customSelect(
              "SELECT * FROM sync_quarantine WHERE reason='Missing category identity before repair'",
            )
            .get(),
        hasLength(1),
      );
    },
  );

  test(
    'guest data stays separate until explicit import; collisions preserve both',
    () async {
      await goal(null, 1800);
      await goal('A', 2200);
      db.setCurrentUserId('A');
      expect(
        (await db.watchNutritionGoals().first).map(
          (g) => g.value.dailyCalories,
        ),
        isNot(contains(1800)),
      );
      final preview = await GuestImportPreview.load(db, 'A');
      expect(preview.collisions, 1);
      await preview.apply(db, 'A');
      final rows = await (db.select(
        db.nutritionGoals,
      )..where((t) => t.id.equals('day'))).get();
      expect(rows.map((r) => r.calories).toSet(), {1800, 2200});
      expect(
        await db.customSelect('SELECT * FROM sync_quarantine').get(),
        isNotEmpty,
      );
    },
  );
  test(
    'a merge preserves current values and archives differing backup data',
    () async {
      db.setCurrentUserId('A');
      await goal('A', 2200);
      final source = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(source.close);
      await source.customSelect('SELECT 1').get();
      source.setCurrentUserId('A');
      await source
          .into(source.nutritionGoals)
          .insert(
            NutritionGoalsCompanion.insert(
              id: const Value('day'),
              userId: const Value('A'),
              referenceDate: DateTime.utc(2026, 10, 20),
              calories: 1800,
              fat: 50,
              carbs: 200,
              protein: 100,
            ),
          );
      final temp = await Directory.systemTemp.createTemp('merge-test-');
      addTearDown(() => temp.delete(recursive: true));
      final file = File('${temp.path}/backup.db');
      await source.customStatement('VACUUM INTO ?', [file.path]);
      final prepared = await PreparedDatabaseRestore.load(file, 'A');
      await prepared.apply(db, mode: RestoreMode.merge);
      expect(
        (await (db.select(db.nutritionGoals)
                  ..where((t) => t.userId.equals('A') & t.id.equals('day')))
                .getSingle())
            .calories,
        2200,
      );
      final saved = await db
          .customSelect(
            "SELECT * FROM sync_quarantine WHERE entity='nutrition_goals'",
          )
          .getSingle();
      await SyncDiagnostics.recover(db, saved.read<int>('id'));
      expect(
        (await (db.select(db.nutritionGoals)
                  ..where((t) => t.userId.equals('A') & t.id.equals('day')))
                .getSingle())
            .calories,
        1800,
      );
      expect(await SyncV2Store.pending(db, 'A'), greaterThan(0));
    },
  );
}

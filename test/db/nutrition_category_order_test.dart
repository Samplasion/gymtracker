import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const a = NutritionCategory(
    name: 'A',
    dailyPercentage: 50,
    icon: NutritionCategoryIcon.coffee,
  );
  const b = NutritionCategory(
    name: 'B',
    dailyPercentage: 50,
    icon: NutritionCategoryIcon.cake,
  );
  late GTDatabaseImpl db;
  late FoodsRepository repository;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    repository = FoodsRepository(db);
  });
  tearDown(() => db.close());

  test(
    'order-only configurations survive normalization and preserve date boundaries',
    () async {
      final past = DateTime(2026, 1, 1);
      final today = DateTime(2026, 1, 2);
      final future = DateTime(2026, 1, 4);
      await repository.setNutritionCategoriesForDay(past, {'A': a, 'B': b});
      await repository.setNutritionCategoriesForDay(future, {'A': a, 'B': b});
      await repository.setNutritionCategoriesForDay(today, {'B': b, 'A': a});
      final sequence = await repository.watchNutritionCategories().first;
      expect(sequence.length, 3);
      expect(sequence[past].keys, ['A', 'B']);
      expect(sequence[today].keys, ['B', 'A']);
      expect(sequence[DateTime(2026, 1, 3)].keys, ['B', 'A']);
      expect(sequence[future].keys, ['A', 'B']);
      expect(sequence[today]['A'], a);
    },
  );

  test('editing preserves position and adding appends', () async {
    final day = DateTime(2026, 1, 1);
    const renamed = NutritionCategory(
      name: 'Renamed',
      dailyPercentage: 50,
      icon: NutritionCategoryIcon.water,
    );
    await repository.setNutritionCategoriesForDay(day, {'A': a, 'B': b});
    await repository.updateNutritionCategory(day, 'A', renamed);
    var sequence = await repository.watchNutritionCategories().first;
    expect(sequence[day].keys, ['Renamed', 'B']);
    expect(sequence[day]['Renamed'], renamed);
    await repository.addNutritionCategory(day, a);
    sequence = await repository.watchNutritionCategories().first;
    expect(sequence[day].keys, ['Renamed', 'B', 'A']);
  });
}

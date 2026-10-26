import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/utils/search_anchor_plus.dart';

import '../test_helpers/widget_test_app.dart';

class _RecordingFoodNotifier extends FoodNotifier {
  _RecordingFoodNotifier(this.onAdd);
  final void Function(Food, NutritionCategory?) onAdd;

  @override
  Future<void> addFood(
    DateTime dateTime,
    Food food, {
    NutritionCategory? category,
  }) async {
    onAdd(food, category);
  }
}

void main() {
  setUpAll(initTestLocalizations);
  const category = NutritionCategory(
    name: 'Lunch',
    dailyPercentage: 40,
    icon: NutritionCategoryIcon.fork_and_spoon,
  );
  final product = CatalogFood.fromRow({
    'id': 'catalog-milk',
    'version': 1,
    'food': {
      'name': 'Catalog milk',
      'brand': 'Brand',
      'barcode': '00123456',
      'unit': 'ml',
      'isDownloaded': false,
      'servingSizes': [],
      'nutritionalValuesPer100g': const NutritionValues(
        calories: 45,
        fat: 1,
        saturatedFat: 0,
        carbs: 5,
        sugar: 5,
        protein: 3,
      ).toJson(),
    },
  });

  for (final outcome in ['confirm', 'cancel quantity', 'cancel results']) {
    testWidgets('catalog selection in category: $outcome', (tester) async {
      final added = <Food>[];
      final categories = <NutritionCategory?>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foodLogsStreamProvider.overrideWith((ref) => Stream.value([])),
            favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
            searchFoodCatalogProvider(
              'milk',
            ).overrideWith((ref) async => [product]),
            foodProvider.overrideWith(
              () => _RecordingFoodNotifier((food, selectedCategory) {
                added.add(food);
                categories.add(selectedCategory);
              }),
            ),
          ],
          child: const WidgetTestApp(
            child: FoodCategoryFoodsView(category: category),
          ),
        ),
      );
      await tester.pumpAndSettle();
      tester
          .widget<SearchAnchorPlus>(find.byType(SearchAnchorPlus))
          .onSubmitted!('milk');
      await tester.pumpAndSettle();
      expect(find.byType(SearchResultsView), findsOneWidget);
      if (outcome == 'cancel results') {
        Go.back();
      } else {
        await tester.tap(find.text('Catalog milk'));
        await tester.pumpAndSettle();
        expect(find.byType(AddFoodView), findsOneWidget);
        expect(added, isEmpty);
        if (outcome == 'confirm') {
          await tester.enterText(
            find.byWidgetPredicate(
              (widget) =>
                  widget is TextField &&
                  widget.decoration?.labelText == t.food.add.amount,
            ),
            '250',
          );
          await tester.pump();
          await tester.tap(find.widgetWithText(FilledButton, t.food.add.add));
        } else {
          Go.back();
        }
      }
      await tester.pumpAndSettle();
      expect(find.byType(FoodCategoryFoodsView), findsOneWidget);
      if (outcome == 'confirm') {
        expect(added, hasLength(1));
        expect(categories.single, same(category));
        expect(added.single.amount, 250);
        expect(added.single.barcode, '00123456');
        expect(added.single.nutritionalValuesPer100g.calories, 45);
        expect(added.single.nutritionalValues.calories, 112.5);
      } else {
        expect(added, isEmpty);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

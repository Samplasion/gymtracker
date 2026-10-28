import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';

import '../test_helpers/widget_test_app.dart';

const category = NutritionCategory(
  name: 'Lunch',
  dailyPercentage: 40,
  icon: NutritionCategoryIcon.fork_and_spoon,
);
const barcode = '00123456';
const localFood = Food(
  name: 'Personal barcode food',
  barcode: barcode,
  amount: 175,
  nutritionalValuesPer100g: NutritionValues.zero,
);

class RecordingFoods extends FoodNotifier {
  final added = <(Food, NutritionCategory?)>[];
  @override
  Future<Food> addFood(
    DateTime date,
    Food food, {
    NutritionCategory? category,
  }) async {
    added.add((food, category));
    return food.copyWith(id: 'diary-entry');
  }
}

Widget lookupApp({
  required Stream<Map<String, Food>> Function(Ref) local,
  required Future<VagueFood?> Function(Ref) catalog,
  required RecordingFoods foods,
  required void Function(Food?) onComplete,
}) => ProviderScope(
  overrides: [
    currentUserIdProvider.overrideWithValue(null),
    foodLogsStreamProvider.overrideWith((ref) => Stream.value([])),
    favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
    customBarcodeFoodsStreamProvider.overrideWith(local),
    searchFoodCatalogByBarcodeProvider(barcode).overrideWith(catalog),
    foodProvider.overrideWith(() => foods),
  ],
  child: WidgetTestApp(
    child: Consumer(
      builder: (context, ref, _) => TextButton(
        onPressed: () async {
          final food = await searchFoodByBarcode(
            context,
            ref,
            barcode,
            category: category,
          );
          if (!context.mounted) return;
          if (food != null) {
            await ref
                .read(foodProvider.notifier)
                .addFood(DateTime(2026, 10, 27), food, category: category);
          }
          onComplete(food);
        },
        child: const Text('Look up scanned barcode'),
      ),
    ),
  ),
);

void main() {
  setUpAll(initTestLocalizations);

  for (final localMatch in [true, false]) {
    testWidgets(
      'cold barcode lookup survives delayed data, local match=$localMatch',
      (tester) async {
        final local = StreamController<Map<String, Food>>.broadcast();
        final catalog = Completer<VagueFood?>();
        final foods = RecordingFoods();
        var localDisposed = false;
        var catalogDisposed = false;
        var catalogCalls = 0;
        Food? completed;
        addTearDown(local.close);
        await tester.pumpWidget(
          lookupApp(
            local: (ref) {
              ref.onDispose(() => localDisposed = true);
              return local.stream;
            },
            catalog: (ref) {
              catalogCalls++;
              ref.onDispose(() => catalogDisposed = true);
              return catalog.future;
            },
            foods: foods,
            onComplete: (food) => completed = food,
          ),
        );
        await tester.tap(find.text('Look up scanned barcode'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(localDisposed, isFalse);
        expect(catalogCalls, 0);
        expect(tester.takeException(), isNull);

        local.add(localMatch ? {barcode: localFood} : {});
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        if (!localMatch) {
          expect(catalogCalls, 1);
          expect(catalogDisposed, isFalse);
          expect(tester.takeException(), isNull);
          catalog.complete(
            const VagueFood(
              name: 'Catalog barcode food',
              barcode: barcode,
              nutritionalValuesPer100g: NutritionValues.zero,
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(find.byType(AddFoodView), findsOneWidget);
        expect(localDisposed, isTrue);
        if (!localMatch) expect(catalogDisposed, isTrue);
        expect(foods.added, isEmpty);
        await tester.tap(find.widgetWithText(FilledButton, t.food.add.add));
        await tester.pumpAndSettle();
        expect(completed?.barcode, barcode);
        expect(foods.added.single.$2, same(category));
        expect(foods.added.single.$1.amount, localMatch ? 175 : 100);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'unknown scanned code preserves category in custom form; cancel writes nothing',
    (tester) async {
      final local = StreamController<Map<String, Food>>.broadcast();
      addTearDown(local.close);
      final foods = RecordingFoods();
      var completed = false;
      await tester.pumpWidget(
        lookupApp(
          local: (_) => local.stream,
          catalog: (_) async => null,
          foods: foods,
          onComplete: (_) => completed = true,
        ),
      );
      await tester.tap(find.text('Look up scanned barcode'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      local.add({});
      await tester.pumpAndSettle();
      final form = tester.widget<CustomAddFoodView>(
        find.byType(CustomAddFoodView),
      );
      expect(form.category, same(category));
      expect(form.barcode, barcode);
      Go.back();
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(foods.added, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'local stream failure offers recovery instead of an uncaught error',
    (tester) async {
      final local = StreamController<Map<String, Food>>.broadcast();
      addTearDown(local.close);
      final foods = RecordingFoods();
      var catalogCalled = false;
      await tester.pumpWidget(
        lookupApp(
          local: (_) => local.stream,
          catalog: (_) async {
            catalogCalled = true;
            return null;
          },
          foods: foods,
          onComplete: (_) {},
        ),
      );
      await tester.tap(find.text('Look up scanned barcode'));
      await tester.pump();
      local.addError(StateError('Database unavailable'));
      await tester.pumpAndSettle();
      expect(find.text(t.food.picker.lookupFailed), findsOneWidget);
      expect(catalogCalled, isFalse);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(t.food.picker.custom));
      await tester.pumpAndSettle();
      expect(find.byType(CustomAddFoodView), findsOneWidget);
      expect(foods.added, isEmpty);
    },
  );
}

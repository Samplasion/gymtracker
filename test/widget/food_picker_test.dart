import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';

import '../test_helpers/widget_test_app.dart';

const recent = Food(
  name: 'Recent milk',
  amount: 175,
  pieces: 2,
  origin: 'personal',
  nutritionalValuesPer100g: NutritionValues.zero,
);

Widget pickerApp({
  required Future<Food> Function(Food) add,
  Future<void> Function(Food)? remove,
  bool failSearch = false,
  Future<List<VagueFood>> Function()? search,
}) => ProviderScope(
  overrides: [
    foodLogsStreamProvider.overrideWith(
      (ref) => Stream.value([
        DateTagged(
          date: DateTime(2026, 10, 20),
          value: recent.copyWith(amount: 50),
        ),
        DateTagged(date: DateTime(2026, 10, 21), value: recent),
      ]),
    ),
    searchFoodCatalogProvider('milk').overrideWith((ref) async {
      if (failSearch) throw StateError('offline');
      if (search != null) return search();
      return [
        CatalogFood.fromRow({
          'id': 'milk-id',
          'version': 1,
          'food': VagueFood(
            name: 'Catalog milk',
            unit: NutritionUnit.MILLI_L,
            servingSizes: const [ServingSize(name: 'Glass', amount: 250)],
            nutritionalValuesPer100g: NutritionValues.zero,
          ).toJson(),
        }),
      ];
    }),
  ],
  child: WidgetTestApp(
    child: FoodPickerView(onAdd: add, onRemove: remove ?? (_) async {}),
  ),
);

void main() {
  setUpAll(initTestLocalizations);

  testWidgets(
    'added button remains aligned left with a centered app bar theme',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foodLogsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: WidgetTestApp(
            child: Theme(
              data: ThemeData(
                appBarTheme: const AppBarTheme(centerTitle: true),
              ),
              child: FoodPickerView(
                onAdd: (food) async => food,
                onRemove: (_) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<AppBar>(find.byType(AppBar)).centerTitle, isFalse);
      expect(
        tester
            .getTopLeft(find.widgetWithText(TextButton, t.food.picker.added))
            .dx,
        lessThan(24),
      );
    },
  );

  testWidgets('diary updates cannot reorder or change the session history', (
    tester,
  ) async {
    final stream = StreamController<List<DateTagged<Food>>>();
    addTearDown(stream.close);
    const bread = Food(
      name: 'Bread',
      amount: 100,
      nutritionalValuesPer100g: NutritionValues.zero,
    );
    final logs = [
      DateTagged(date: DateTime(2026, 10, 20), value: recent),
      DateTagged(date: DateTime(2026, 10, 21), value: bread),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodLogsStreamProvider.overrideWith((ref) => stream.stream),
        ],
        child: WidgetTestApp(
          child: FoodPickerView(
            onAdd: (food) async {
              final saved = food.copyWith(id: 'new-entry', amount: 250);
              stream.add([
                ...logs,
                DateTagged(date: DateTime(2026, 10, 26), value: saved),
              ]);
              return saved;
            },
            onRemove: (_) async {},
          ),
        ),
      ),
    );
    stream.add(logs);
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.text('Recent milk'));
    final row = find.ancestor(
      of: find.text('Recent milk'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: row, matching: find.byIcon(Icons.add)),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Recent milk')), before);
    expect(tester.getTopLeft(find.text('Bread')).dy, lessThan(before.dy));
    expect(find.textContaining('2 × 175'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog precedes recents and expands all matches inline', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerApp(
        add: (food) async => food,
        search: () async => [
          for (var i = 0; i < 12; i++)
            VagueFood(
              name: 'Result $i',
              nutritionalValuesPer100g: NutritionValues.zero,
            ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'milk');
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text('Result 9'), findsOneWidget);
    expect(find.text('Result 10'), findsNothing);
    expect(find.text(t.food.picker.results), findsOneWidget);
    expect(find.text(t.food.picker.recent), findsNothing);
    final listScroll = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text(t.food.picker.showMore).hitTestable(),
      250,
      scrollable: listScroll,
    );
    await tester.tap(find.text(t.food.picker.showMore));
    await tester.pumpAndSettle();
    expect(find.text('Result 11'), findsOneWidget);
    expect(find.text(t.food.picker.showMore), findsNothing);
    expect(find.byType(FoodPickerView), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent milk').hitTestable(),
      200,
      scrollable: listScroll,
    );
    expect(find.text('Recent milk'), findsOneWidget);
    await tester.enterText(find.byType(SearchBar), '');
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    await tester.enterText(find.byType(SearchBar), 'milk');
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text('Result 10'), findsNothing);
    expect(find.text(t.food.picker.showMore), findsOneWidget);
  });

  testWidgets(
    'quick additions use latest portion and remove only one saved ID',
    (tester) async {
      final added = <Food>[];
      final removed = <Food>[];
      await tester.pumpWidget(
        pickerApp(
          add: (food) async {
            final saved = food.copyWith(id: 'entry-${added.length}');
            added.add(saved);
            return saved;
          },
          remove: (food) async => removed.add(food),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recent milk'), findsOneWidget);
      final plus = find.byIcon(Icons.add);
      await tester.tap(plus);
      await tester.pumpAndSettle();
      await tester.tap(plus);
      await tester.pumpAndSettle();
      expect(added.map((f) => f.id), ['entry-0', 'entry-1']);
      expect(added.every((f) => f.amount == 175 && f.pieces == 2), isTrue);
      expect(find.byType(FoodPickerView), findsOneWidget);
      await tester.tap(find.text(t.food.picker.added));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();
      expect(removed.single.id, 'entry-0');
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pending history add keeps the list mounted and stationary', (
    tester,
  ) async {
    final saved = Completer<Food>();
    var calls = 0;
    await tester.pumpWidget(
      pickerApp(
        add: (food) {
          calls++;
          return saved.future;
        },
      ),
    );
    await tester.pumpAndSettle();
    final listElement = tester.element(find.byType(ListView));
    final rowElement = tester.element(find.text('Recent milk'));
    final originalPosition = tester.getTopLeft(find.text('Recent milk'));
    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    final originalOffset = scroll.offset;

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.element(find.byType(ListView)), same(listElement));
    expect(tester.element(find.text('Recent milk')), same(rowElement));
    expect(tester.getTopLeft(find.text('Recent milk')), originalPosition);
    expect(scroll.offset, originalOffset);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(calls, 1);

    saved.complete(recent.copyWith(id: 'saved'));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.element(find.byType(ListView)), same(listElement));
    expect(tester.element(find.text('Recent milk')), same(rowElement));
    expect(tester.getTopLeft(find.text('Recent milk')), originalPosition);
    expect(scroll.offset, originalOffset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog quick add uses serving and preserves the search', (
    tester,
  ) async {
    Food? added;
    await tester.pumpWidget(
      pickerApp(
        add: (food) async {
          added = food;
          return food.copyWith(id: '1');
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'milk');
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.text('Catalog milk'), findsNothing);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Catalog milk'), findsOneWidget);
    final row = find.ancestor(
      of: find.text('Catalog milk'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(of: row, matching: find.byIcon(Icons.add)),
    );
    await tester.pumpAndSettle();
    expect(added?.amount, 250);
    expect(added?.unit, NutritionUnit.MILLI_L);
    expect(added?.catalogId, 'milk-id');
    expect(added?.origin, 'catalog');
    expect(
      tester.widget<SearchBar>(find.byType(SearchBar)).controller!.text,
      'milk',
    );
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
  });

  testWidgets('failed save leaves session count unchanged and allows retry', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      pickerApp(
        add: (food) async {
          if (calls++ == 0) throw StateError('disk full');
          return food.copyWith(id: 'saved');
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text(t.food.picker.failed), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.food.picker.added));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets(
    'a result from an obsolete query cannot overwrite current search',
    (tester) async {
      final pending = Completer<List<VagueFood>>();
      await tester.pumpWidget(
        pickerApp(add: (food) async => food, search: () => pending.future),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'milk');
      await tester.pump(const Duration(milliseconds: 301));
      await tester.enterText(find.byType(SearchBar), '');
      await tester.pump(const Duration(milliseconds: 301));
      pending.complete([
        const VagueFood(
          name: 'Obsolete result',
          nutritionalValuesPer100g: NutritionValues.zero,
        ),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Obsolete result'), findsNothing);
      expect(find.text('Recent milk'), findsOneWidget);
    },
  );

  testWidgets('small dark screen supports enlarged text and open keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          foodLogsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: WidgetTestApp(
          child: Theme(
            data: ThemeData.dark(),
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(2),
                viewInsets: EdgeInsets.only(bottom: 220),
              ),
              child: FoodPickerView(
                onAdd: (food) async => food,
                onRemove: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(t.food.picker.search), findsOneWidget);
    expect(find.text(t.food.picker.barcode), findsOneWidget);
    expect(find.text(t.food.picker.more), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search error offers retry without hiding recent selections', (
    tester,
  ) async {
    await tester.pumpWidget(
      pickerApp(add: (food) async => food, failSearch: true),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'milk');
    await tester.pumpAndSettle(const Duration(milliseconds: 350));
    expect(find.text(t.food.picker.retry), findsOneWidget);
    expect(find.text('Recent milk'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

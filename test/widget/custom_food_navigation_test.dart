import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';

import '../test_helpers/widget_test_app.dart';

Widget testApp(Widget child) => ProviderScope(
  overrides: [
    currentUserIdProvider.overrideWith((ref) => null),
    foodLogsStreamProvider.overrideWith((ref) => Stream.value([])),
  ],
  child: WidgetTestApp(child: child),
);

void main() {
  testWidgets('custom food closes search inside the nested navigator', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => const AddCombinedFoodView(category: null),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SearchBar));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(CustomAddFoodView), findsOneWidget);
    expect(tester.takeException(), isNull);
    Go.back();
    await tester.pumpAndSettle();
    expect(find.byType(AddCombinedFoodView), findsOneWidget);
    expect(find.byType(SearchBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final save in [false, true]) {
    testWidgets('custom food from results: ${save ? 'save' : 'cancel'}', (
      tester,
    ) async {
      Food? result;
      await tester.pumpWidget(
        testApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Go.to<Food>(
                  () => SearchResultsView(
                    foods: Future.value([]),
                    category: null,
                  ),
                );
              },
              child: const Text('Open results'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open results'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(CustomAddFoodView), findsOneWidget);
      expect(tester.takeException(), isNull);

      if (save) {
        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'My custom food');
        for (var i = 3; i <= 9; i++) {
          await tester.enterText(fields.at(i), '0');
        }
        await tester.tap(find.widgetWithText(FilledButton, t.food.add.add));
      } else {
        Go.back();
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (save) {
        expect(result?.name, 'My custom food');
        expect(find.text('Open results'), findsOneWidget);
        expect(find.byType(SearchResultsView), findsNothing);
      } else {
        expect(result, isNull);
        expect(find.byType(SearchResultsView), findsOneWidget);
      }
    });
  }
}

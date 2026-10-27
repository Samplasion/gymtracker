import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';

import '../test_helpers/widget_test_app.dart';

class _RecordingCategoryNotifier extends NutritionCategoryNotifier {
  final updates = <(String, NutritionCategory)>[];

  @override
  Future<void> updateCategory(
    String oldName,
    NutritionCategory category,
  ) async {
    updates.add((oldName, category));
  }
}

void main() {
  setUpAll(initTestLocalizations);
  const category = NutritionCategory(
    name: 'Lunch',
    dailyPercentage: 40,
    icon: NutritionCategoryIcon.fork_and_spoon,
  );

  for (final save in [true, false]) {
    testWidgets('category edit ${save ? 'saves' : 'cancels'} changes', (
      tester,
    ) async {
      final notifier = _RecordingCategoryNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foodCanUpdateCategoriesProvider.overrideWith((ref) => true),
            nutritionGoalForSelectedDateProvider.overrideWith(
              (ref) => NutritionGoal.defaultGoal,
            ),
            nutritionCategoryProvider.overrideWith(() => notifier),
          ],
          child: const WidgetTestApp(
            child: FoodCategoryListTile(category: category),
          ),
        ),
      );
      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(find.byType(FoodCategoryEditorView), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'Dinner');
      if (save) {
        await tester.tap(find.byType(FilledButton));
      } else {
        Go.back();
      }
      await tester.pumpAndSettle();
      expect(find.byType(FoodCategoryEditorView), findsNothing);
      if (save) {
        expect(notifier.updates, [
          (
            'Lunch',
            const NutritionCategory(
              name: 'Dinner',
              dailyPercentage: 40,
              icon: NutritionCategoryIcon.fork_and_spoon,
            ),
          ),
        ]);
      } else {
        expect(notifier.updates, isEmpty);
      }
    });
  }
}

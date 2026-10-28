import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';

import '../test_helpers/widget_test_app.dart';

class _Categories extends NutritionCategoryNotifier {
  int removes = 0;
  @override
  Future<void> removeCategory(NutritionCategory category) async {
    removes++;
  }
}

void main() {
  const category = NutritionCategory(
    name: 'Lunch',
    dailyPercentage: 100,
    icon: NutritionCategoryIcon.fork_and_spoon,
  );

  for (final dayOffset in [-1, 0, 1]) {
    testWidgets('category deletion respects selected day offset $dayOffset', (
      tester,
    ) async {
      await initTestLocalizations();
      final commands = _Categories();
      final container = ProviderContainer(
        overrides: [
          categoriesForSelectedDateProvider.overrideWith(
            (ref) => {'Lunch': category},
          ),
          categoriesDateRangeProvider.overrideWith((ref) => null),
          nutritionGoalForSelectedDateProvider.overrideWith(
            (ref) => NutritionGoal.defaultGoal,
          ),
          nutritionCategoryProvider.overrideWith(() => commands),
        ],
      );
      addTearDown(container.dispose);
      final now = DateTime.now();
      container
          .read(foodSelectedDateProvider.notifier)
          .setDate(DateTime(now.year, now.month, now.day + dayOffset));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WidgetTestApp(child: FoodCategoryList()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('Lunch'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      final deleteButton = find.byIcon(GTIcons.delete_forever).hitTestable();
      if (dayOffset < 0) {
        expect(deleteButton, findsNothing);
        expect(commands.removes, 0);
      } else {
        expect(deleteButton, findsOneWidget);
        final action = tester.widget<SlidableAction>(
          find.byType(SlidableAction),
        );
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        expect(commands.removes, 1);
        if (dayOffset == 0) {
          final context = tester.element(find.byType(FoodCategoryList));
          container
              .read(foodSelectedDateProvider.notifier)
              .setDate(DateTime(now.year, now.month, now.day - 1));
          await tester.pumpAndSettle();
          action.onPressed!(context);
          await tester.pump();
          expect(commands.removes, 1);
        }
      }
    });
  }
}

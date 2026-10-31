import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';

import '../test_helpers/widget_test_app.dart';

class _Categories extends NutritionCategoryNotifier {
  final pending = Completer<void>();
  List<String>? names;
  DateTime? date;

  @override
  Future<void> reorderCategories(DateTime date, List<String> names) {
    this.date = date;
    this.names = names;
    return pending.future;
  }
}

void main() {
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

  for (final offset in [-1, 0, 1]) {
    testWidgets(
      'reorder handles respect date offset $offset and failed saves restore order',
      (tester) async {
        await initTestLocalizations();
        final commands = _Categories();
        final container = ProviderContainer(
          overrides: [
            categoriesForSelectedDateProvider.overrideWith(
              (ref) => {'A': a, 'B': b},
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
        final date = DateTime(now.year, now.month, now.day + offset);
        container.read(foodSelectedDateProvider.notifier).setDate(date);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const WidgetTestApp(child: FoodCategoryList()),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(DragHandle),
          offset < 0 ? findsNothing : findsNWidgets(2),
        );
        if (offset < 0) return;

        final list = tester.widget<SliverReorderableList>(
          find.byType(SliverReorderableList),
        );
        final handle = offset == 1
            ? find.byType(DragHandle).first
            : find.byType(DragHandle).last;
        final gesture = await tester.startGesture(tester.getCenter(handle));
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.moveBy(Offset(0, offset == 1 ? 5 : -5));
        await tester.pump();
        await gesture.moveBy(Offset(0, offset == 1 ? 160 : -160));
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(commands.names, ['B', 'A']);
        expect(commands.date, date);
        expect(find.byType(DragHandle), findsNothing);
        list.onReorderItem!(1, 0);
        expect(commands.names, ['B', 'A']);
        commands.pending.completeError(StateError('Save failed'));
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.byType(DragHandle), findsNWidgets(2));
        expect(
          tester.getTopLeft(find.text('A')).dy,
          lessThan(tester.getTopLeft(find.text('B')).dy),
        );
      },
    );
  }
  for (final count in [0, 1]) {
    testWidgets('$count categories have no drag handles', (tester) async {
      await initTestLocalizations();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesForSelectedDateProvider.overrideWith(
              (ref) => count == 0 ? {} : {'A': a},
            ),
            categoriesDateRangeProvider.overrideWith((ref) => null),
            nutritionGoalForSelectedDateProvider.overrideWith(
              (ref) => NutritionGoal.defaultGoal,
            ),
          ],
          child: const WidgetTestApp(child: FoodCategoryList()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DragHandle), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

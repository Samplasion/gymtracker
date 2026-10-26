import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';
import 'package:relative_time/relative_time.dart';
import 'package:rxdart/rxdart.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

DateSequence<NutritionGoal> goals(double calories) => DateSequence.fromList([
  TaggedNutritionGoal(
    date: DateTime(2020),
    value: NutritionGoal(
      dailyCalories: calories,
      dailyProtein: 100,
      dailyCarbs: 200,
      dailyFat: 60,
    ),
  ),
]);

void main() {
  testWidgets('diary reads a dirty paused nutrition provider during build', (
    tester,
  ) async {
    final source = BehaviorSubject<DateSequence<NutritionGoal>>.seeded(
      goals(2000),
      sync: true,
    );
    final container = ProviderContainer(
      overrides: [
        nutritionGoalsStreamProvider.overrideWith((ref) => source.stream),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await source.close();
    });
    final upstream = container.listen(nutritionGoalsStreamProvider, (_, _) {});
    final diary = container.listen(
      nutritionGoalForSelectedDateProvider,
      (_, _) {},
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(
      container.read(nutritionGoalForSelectedDateProvider).dailyCalories,
      2000,
    );
    final visible = ValueNotifier(false);
    addTearDown(visible.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ValueListenableBuilder(
            valueListenable: visible,
            builder: (_, show, _) => show
                ? Consumer(
                    builder: (context, ref, _) {
                      final selected = ref.watch(
                        nutritionGoalForSelectedDateProvider,
                      );
                      return Text('${selected.dailyCalories}');
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    diary.pause();
    source.add(goals(1800));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    visible.value = true;
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('1800.0'), findsOneWidget);
    diary.close();
    upstream.close();
    await tester.pump(const Duration(milliseconds: 1));
  });
  testWidgets('full diary can reopen after goals change off screen', (
    tester,
  ) async {
    MockServices.setup();
    await initTestLocalizations();
    addTearDown(MockServices.tearDown);
    final source = BehaviorSubject<DateSequence<NutritionGoal>>.seeded(
      goals(2000),
      sync: true,
    );
    final container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        currentUserIdProvider.overrideWith((ref) => null),
        nutritionGoalsStreamProvider.overrideWith((ref) => source.stream),
        waterEntriesProvider.overrideWith((ref) => Stream.value([])),
        hydrationPageVisitProvider.overrideWith((ref) async => false),
        hydrationPermissionProvider.overrideWith(
          (ref) => Stream.value(HydrationPermission.unavailable),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await source.close();
    });
    final upstream = container.listen(nutritionGoalsStreamProvider, (_, _) {});
    final shown = ValueNotifier(true);
    addTearDown(shown.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: WidgetTestApp(
          child: Builder(
            builder: (context) => Localizations.override(
              context: context,
              delegates: const [RelativeTimeLocalizations.delegate],
              child: ValueListenableBuilder(
                valueListenable: shown,
                builder: (_, visible, _) =>
                    visible ? const FoodView() : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    shown.value = false;
    await tester.pumpAndSettle();
    source.add(goals(1800));
    await tester.pumpAndSettle();
    shown.value = true;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      container.read(nutritionGoalForSelectedDateProvider).dailyCalories,
      1800,
    );
    container.read(foodSelectedDateProvider.notifier).previousDay();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      container.read(nutritionGoalForSelectedDateProvider).dailyCalories,
      1800,
    );
    upstream.close();
  });
}

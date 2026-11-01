import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    // Stub routinesController methods and getters
    when(
      () => MockServices.routinesController.suggestions,
    ).thenReturn(<RoutineSuggestion>[]);
    when(
      () => MockServices.routinesController.folders,
    ).thenReturn(<GTRoutineFolder, List<Workout>>{});
    when(
      () => MockServices.routinesController.rootRoutines,
    ).thenReturn(<Workout>[]);
    when(() => MockServices.routinesController.workouts).thenReturn(<Workout>[
      Workout(
        id: 'workout_1',
        name: 'Test Routine',
        exercises: [],
        duration: const Duration(hours: 1),
        startingDate: DateTime.now(),
      ),
    ]);
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('RoutinesView renders successfully with create options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: RoutinesView()),
    );
    await tester.pump();

    // Verify view has "New routine" and "New folder" options
    expect(find.textContaining('New routine'), findsOneWidget);
    expect(find.textContaining('New folder'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets(
    'folders follow alphabetical order instead of stored sort order',
    (tester) async {
      const first = GTRoutineFolder(
        id: 'first',
        name: 'Z first',
        sortOrder: 0,
        notes: '',
      );
      const second = GTRoutineFolder(
        id: 'second',
        name: 'A second',
        sortOrder: 1,
        notes: '',
      );
      await tester.pumpWidget(
        WidgetTestApp(
          wrapWithProviderScope: true,
          child: ProviderScope(
            overrides: [
              routinesStreamProvider.overrideWith(
                (ref) => Stream.value(<Workout>[]),
              ),
              foldersStreamProvider.overrideWith(
                (ref) => Stream.value([second, first]),
              ),
            ],
            child: const RoutinesView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Z first'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.getTopLeft(find.text('A second')).dy,
        lessThan(tester.getTopLeft(find.text('Z first')).dy),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  for (final failFolders in [false, true]) {
    testWidgets(
      'routine loading failure offers retry (folders: $failFolders)',
      (tester) async {
        var routineLoads = 0;
        var folderLoads = 0;
        await tester.pumpWidget(
          WidgetTestApp(
            wrapWithProviderScope: true,
            child: ProviderScope(
              overrides: [
                routinesStreamProvider.overrideWith((ref) {
                  routineLoads++;
                  return !failFolders && routineLoads == 1
                      ? Stream.error(StateError('technical routine failure'))
                      : Stream.value(<Workout>[]);
                }),
                foldersStreamProvider.overrideWith((ref) {
                  folderLoads++;
                  return failFolders && folderLoads == 1
                      ? Stream.error(StateError('technical folder failure'))
                      : Stream.value(<GTRoutineFolder>[]);
                }),
              ],
              child: const RoutinesView(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Unable to load routines'), findsOneWidget);
        expect(find.textContaining('technical'), findsNothing);
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.text('Unable to load routines'), findsNothing);
        expect(routineLoads, 2);
        expect(folderLoads, 2);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('free workout explains the PRO limit before tapping', (
    tester,
  ) async {
    when(() => MockServices.historyController.history).thenReturn(
      List.generate(
        Configuration.trialWorkoutLimit,
        (i) => Workout(
          id: 'history-$i',
          name: 'Workout',
          exercises: [],
          duration: Duration.zero,
        ),
      ),
    );
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: RoutinesView()),
    );
    await tester.pumpAndSettle();
    final freeWorkout = find.ancestor(
      of: find.textContaining('Free workout'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: freeWorkout, matching: find.byType(ProBadge)),
      findsOneWidget,
    );
    expect(
      find.textContaining('You have reached the free workout limit'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

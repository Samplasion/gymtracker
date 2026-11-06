import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('RoutineCreator renders successfully in create mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: RoutineCreator()),
    );
    await tester.pump();

    // Verify title "Create new routine" is rendered
    expect(find.text("Create new routine"), findsOneWidget);

    // Verify name field is rendered
    expect(find.widgetWithText(TextFormField, "Routine name"), findsOneWidget);
  });

  testWidgets('existing exercises appear without an unrelated rebuild', (
    WidgetTester tester,
  ) async {
    final exercise = exerciseHelper('bench', 'Bench Press');
    final routine = Workout(name: 'MCP routine', exercises: [exercise]);
    registerFallbackValue(exercise);
    when(() => MockServices.exercisesController.exercises).thenReturn([]);
    when(
      () => MockServices.historyController.getHistoryOf(any()),
    ).thenReturn([]);

    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: RoutineCreator(base: routine),
      ),
    );
    expect(find.widgetWithText(TextFormField, 'MCP routine'), findsOneWidget);
    expect(find.byType(WorkoutExerciseEditor), findsOneWidget);
    final editor = tester.widget<WorkoutExerciseEditor>(
      find.byType(WorkoutExerciseEditor),
    );
    expect(editor.exercise.name, exercise.name);
    expect(editor.exercise.sets, exercise.sets);
    expect(identical(editor.exercise, exercise), isFalse);
  });
}

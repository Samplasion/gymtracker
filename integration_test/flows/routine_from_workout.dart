import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/workout.dart';

import '../utils.dart';

const workoutName = "Workout";

Future<void> testRoutineFromWorkout(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  await createWorkout(tester, databaseService);
  await createRoutineFromWorkout(tester, databaseService);
  await checkRoutine(tester, databaseService);
}

Future<void> createWorkout(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Verify that the app has started.
  expect(find.text(t.routines.quickWorkout.title), findsOneWidget);

  await tester.tap(
    find.widgetWithText(ListTile, t.routines.quickWorkout.title),
  );
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutView), findsOneWidget);

  await tester.tap(
    find.widgetWithText(FilledButton, t.ongoingWorkout.exercises.add),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, t.library.abs.name));
  await tester.pumpAndSettle();
  final crunches = find.widgetWithText(ListTile, t.library.abs.exercises.crunches);
  await scrollToIfNeeded(tester, crunches);
  await tester.tap(crunches);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('pick')));
  await tester.pumpAndSettle();

  // Add two sets
  // Add two more sets
  final addSetButton = find.widgetWithText(
    FilledButton,
    t.exercise.actions.addSet,
  );

  await tester.tap(addSetButton);
  await tester.pumpAndSettle();
  await tester.tap(addSetButton);
  await tester.pumpAndSettle();

  final setFields = find.widgetWithText(TextField, "Reps");
  expect(setFields, findsNWidgets(3));
  final widgets = [...setFields.evaluate()];
  for (final field in widgets) {
    await enterTextAndDismissKeyboard(
      tester,
      find.byWidget(field.widget),
      "10",
    );
  }
  await tester.pumpAndSettle();

  await dismissKeyboard(tester);
  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await enterTextAndDismissKeyboard(
    tester,
    find.widgetWithText(TextField, t.ongoingWorkout.finish.fields.name.label),
    workoutName,
  );

  await dismissKeyboard(tester);
  await tester.tap(find.text(t.ongoingWorkout.finish.save));
  await waitForWidget(tester, find.byType(WorkoutFinishPage), present: false);

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);

  // No Workout done sheet because we haven't marked any of the sets as done
  // expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  // await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  // await tester.pumpAndSettle();
}

Future<void> createRoutineFromWorkout(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  await openHistory(tester);
  await tester.pumpAndSettle();
  expect(find.byType(HistoryWorkout), findsOneWidget);
  await tester.tap(find.widgetWithText(HistoryWorkout, workoutName));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("save-as-routine")));
  await tester.pumpAndSettle();

  expect(
    find.widgetWithText(SnackBar, t.workouts.actions.saveAsRoutine.done),
    findsOneWidget,
  );
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

  // History is a pushed page above the profile; return to the shell first.
  await tester.pageBack();
  await tester.pumpAndSettle();
  await openMainSection(tester, GTIcons.muscle);
  await tester.pumpAndSettle();
  expect(find.byType(HistoryWorkout), findsNothing);
  expect(find.widgetWithText(ListTile, workoutName), findsOneWidget);
}

Future<void> checkRoutine(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  final routine = integrationContainer
      .read(routinesControllerProvider)
      .workouts
      .single;
  expect(routine.name, workoutName);
  expect(routine.exercises.length, 1);
  expect(
    routine.exercises.first.asExercise.parentID,
    "library.abs.exercises.crunches",
  );
}

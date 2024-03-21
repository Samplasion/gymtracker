import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';

const workoutName = "Workout";

Future<void> testRoutineFromWorkout(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await tester.pumpWidget(
    MainApp(localizations: l, databaseService: databaseService),
    const Duration(seconds: 5),
  );
  // Wait for the app to finish loading
  await tester.pumpAndSettle(const Duration(seconds: 5));

  await createWorkout(tester, l, databaseService);
  await createRoutineFromWorkout(tester, l, databaseService);
  await checkRoutine(tester, l, databaseService);
}

Future<void> createWorkout(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Verify that the app has started.
  expect(find.text('routines.quickWorkout.title'.t), findsOneWidget);

  await tester
      .tap(find.widgetWithText(ListTile, 'routines.quickWorkout.title'.t));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutView), findsOneWidget);

  await tester
      .tap(find.widgetWithText(FilledButton, 'ongoingWorkout.exercises.add'.t));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'library.abs.name'.t));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(ListTile, 'library.abs.exercises.crunches'.t));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('pick')));
  await tester.pumpAndSettle();

  // Add two sets
  // Add two more sets
  final addSetButton = find.widgetWithText(
    FilledButton,
    "exercise.actions.addSet".t,
  );

  await tester.tap(addSetButton);
  await tester.pumpAndSettle();
  await tester.tap(addSetButton);
  await tester.pumpAndSettle();

  final setFields = find.widgetWithText(TextField, "Reps");
  expect(setFields, findsNWidgets(3));
  final widgets = [...setFields.evaluate()];
  for (final field in widgets) {
    await tester.enterText(find.byWidget(field.widget), "10");
  }
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.enterText(
    find.widgetWithText(
      TextField,
      "ongoingWorkout.finish.fields.name.label".t,
    ),
    workoutName,
  );

  await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);

  // No Workout done sheet because we haven't marked any of the sets as done
  // expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  // await tester.tap(find.widgetWithIcon(IconButton, Icons.done_rounded));
  // await tester.pumpAndSettle();
}

Future<void> createRoutineFromWorkout(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  await tester
      .tap(find.widgetWithText(NavigationDestination, 'history.title'.t));
  await tester.pumpAndSettle();
  expect(find.byType(HistoryWorkout), findsOneWidget);
  await tester.tap(find.widgetWithText(HistoryWorkout, workoutName));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("save-as-routine")));
  await tester.pumpAndSettle();

  expect(find.widgetWithText(SnackBar, "workouts.actions.saveAsRoutine.done".t),
      findsOneWidget);
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

  await tester
      .tap(find.widgetWithText(NavigationDestination, 'routines.title'.t));
  await tester.pumpAndSettle();
  expect(find.byType(HistoryWorkout), findsNothing);
  expect(find.widgetWithText(ListTile, workoutName), findsOneWidget);
}

Future<void> checkRoutine(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  final routine = Get.find<RoutinesController>().workouts.single;
  expect(routine.name, workoutName);
  expect(routine.exercises.length, 1);
  expect(routine.exercises.first.asExercise.parentID,
      "library.abs.exercises.crunches");
}

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:gymtracker/view/workout_editor.dart';

Workout get baseRoutine {
  final libEx =
      exerciseStandardLibrary[GTExerciseMuscleCategory.abs]!.exercises.first;
  final baseRoutine = Workout(
    name: "Test Routine",
    id: "test-routine",
    exercises: [
      libEx.copyWith(
        parentID: libEx.id,
        workoutID: "test-routine",
        restTime: const Duration(minutes: 1),
        sets: [
          GTSet(
            reps: 10,
            kind: GTSetKind.normal,
            parameters: GTSetParameters.freeBodyReps,
          ),
          GTSet(
            reps: 10,
            kind: GTSetKind.normal,
            parameters: GTSetParameters.freeBodyReps,
          ),
          GTSet(
            reps: 10,
            kind: GTSetKind.normal,
            parameters: GTSetParameters.freeBodyReps,
          ),
        ],
      ),
    ],
    infobox: "Inject",
  );
  baseRoutine.exercises.first = (baseRoutine.exercises.first as Exercise)
      .instantiate(workout: baseRoutine, rpe: const None());
  return baseRoutine;
}

Future<void> testEditWorkoutFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await tester.pumpWidget(
    MainApp(localizations: l, databaseService: databaseService),
    duration: const Duration(seconds: 5),
  );

  // Manually add the routine
  // We can do it this way since we verified the "Create routine" flow
  // is working in another test
  databaseService.setRoutine(baseRoutine);

  // Wait for the app to finish loading
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify that the app has started.
  expect(find.text('New routine'), findsOneWidget);
  expect(find.text('Test Routine'), findsOneWidget);

  await tester.tap(find.widgetWithText(ListTile, "Test Routine"));
  await tester.pumpAndSettle();

  expect(find.widgetWithText(FilledButton, 'Start routine'), findsOneWidget);
  expect(find.byType(ExerciseDataView, skipOffstage: false), findsOneWidget);
  expect(find.text("Rest time: 01:00"), findsOneWidget);
  expect(find.text("10 reps"), findsNWidgets(3));

  await tester.tap(find.widgetWithText(FilledButton, 'Start routine'));
  await tester.pumpAndSettle(const Duration(seconds: 5));

  expect(find.byType(WorkoutView), findsOneWidget);

  final setFields = find.widgetWithText(TextField, "Reps");
  expect(setFields, findsNWidgets(3));

  for (final field in setFields.evaluate()) {
    await tester.enterText(find.byWidget(field.widget), "10");
  }

  final checkboxes = find.byType(Checkbox);
  expect(checkboxes, findsNWidgets(3));

  for (final checkbox in checkboxes.evaluate()) {
    await tester.tap(find.byWidget(checkbox.widget));
  }

  // Avoiding pumpAndSettle here because the animation in WorkoutTimerView
  // causes the tester to wait for the entire duration of the timer
  await tester.pump(const Duration(seconds: 2));

  expect(find.byType(WorkoutTimerView), findsOneWidget);

  // Avoid the above issue for the next pumpAndSettle calls
  await tester.tap(find.widgetWithIcon(IconButton, GTIcons.skip));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsOneWidget);

  await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishPage), findsNothing);
  expect(find.byType(WorkoutView), findsNothing);
  expect(find.byType(AlertDialog), findsNothing);

  final originalWorkout = databaseService.workoutHistory.single.clone();

  // Close the Good Job sheet
  expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  await tester.tap(find.byIcon(GTIcons.done));
  await tester.pumpAndSettle();

  await tester.tap(
    find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.byIcon(GTIcons.history)),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byType(HistoryWorkout));
  await tester.pumpAndSettle();

  expect(find.byType(ExercisesView), findsOneWidget);

  await tester.tap(find.widgetWithIcon(PopupMenuButton, Icons.adaptive.more));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("edit-workout")));
  await tester.pumpAndSettle();

  final addSetButton = find.widgetWithText(FilledButton, "+ Add Set");
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));
  await tester.pumpAndSettle();
  await tester.tap(addSetButton);
  await tester.pumpAndSettle();
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));
  await tester.pumpAndSettle();
  await tester.tap(addSetButton);
  await tester.pumpAndSettle();

  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));
  final fourthSetTypeButton = find.descendant(
    of: find.byType(IconButton),
    matching: find.text('4'),
  );
  await tester.pumpAndSettle();
  await tester.tap(fourthSetTypeButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text("To failure, with stripping"));
  await tester.pumpAndSettle();

  // Now it finds the fifth set
  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));
  await tester.pumpAndSettle();
  await tester.tap(fourthSetTypeButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text("Drop set"));
  await tester.pumpAndSettle();

  await tester.dragUntilVisible(
    find.widgetWithText(FilledButton, "+ Add exercise"),
    find.byType(ListView),
    const Offset(0, -100),
  );

  final addExerciseButton = find.widgetWithText(FilledButton, "+ Add exercise");
  await tester.tap(addExerciseButton);
  await tester.pumpAndSettle();
  await tester.tap(find.text("Cardio"));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Zumba"));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key("pick")));
  await tester.pumpAndSettle();

  await tester.drag(find.byType(ListView), const Offset(0.0, -600.0));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextField, "Time"), "100");
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish editing"));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutFinishEditingPage), findsOneWidget);

  await tester.quillEnterText(
    find.byType(QuillEditor),
    "Edited notes\n",
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("submit")));
  await tester.pumpAndSettle(const Duration(seconds: 1));

  expect(find.byType(WorkoutFinishEditingPage), findsNothing);
  expect(find.byType(WorkoutEditor), findsNothing);

  // Check the edited workout
  final editedWorkout = databaseService.workoutHistory.single;
  expect(editedWorkout.id, originalWorkout.id);
  expect(editedWorkout.exercises.length, 2);
  expect(editedWorkout.exercises[0].id, originalWorkout.exercises[0].id);
  expect(editedWorkout.exercises[0].sets.length, 5);
  expect(editedWorkout.exercises[0].sets[0].id,
      originalWorkout.exercises[0].sets[0].id);
  expect(editedWorkout.exercises[0].sets[1].id,
      originalWorkout.exercises[0].sets[1].id);
  expect(editedWorkout.exercises[0].sets[2].id,
      originalWorkout.exercises[0].sets[2].id);
  expect(editedWorkout.exercises[0].sets[3].kind, GTSetKind.failureStripping);
  expect(editedWorkout.exercises[0].sets[4].kind, GTSetKind.drop);
  expect((editedWorkout.exercises[1] as Exercise).name, "Zumba");
  expect((editedWorkout.exercises[1] as Exercise).standard, true);
  expect(editedWorkout.exercises[1].sets.length, 1);
  expect(
      editedWorkout.exercises[1].sets.single.parameters, GTSetParameters.time);
  expect(
      editedWorkout.exercises[1].sets.single.time, const Duration(minutes: 1));
  expect(editedWorkout.infobox, "Edited notes\n".asQuillDocument().toEncoded());
}

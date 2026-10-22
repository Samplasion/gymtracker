import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/optional.dart';

import '../../test/expectations.dart';
import '../utils.dart';

final Exercise baseExercise = Exercise.custom(
  id: "ourNewID",
  name: "CustomExercise",
  parameters: GTSetParameters.freeBodyReps,
  sets: [],
  primaryMuscleGroup: GTMuscleGroup.abductors,
  secondaryMuscleGroups: {GTMuscleGroup.glutes},
  restTime: Duration.zero,
  notes: "Base Notes",
  workoutID: null,
  supersetID: null,
  equipment: GTGymEquipment.none,
);

Future<void> testEditExerciseInRoutineAndHistoryFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  print(
    "Starting database state: ${databaseService.currentSnapshot.customExercises.map((e) => e.id).toList()}",
  );

  // Manually add the exercise
  // We can do it this way since we verified the "Create exercise" flow
  // is working in another test
  await databaseService.writeExercises([]);
  integrationContainer
      .read(exercisesControllerProvider)
      .addExercise(baseExercise);
  await awaitCustomExercise(tester, baseExercise.id);

  await tester.pumpAndSettle();

  print(
    "Edited database state: ${databaseService.currentSnapshot.customExercises.map((e) => e.id).toList()}",
  );
  expect(
    integrationContainer.read(exercisesControllerProvider).exercises.isNotEmpty,
    true,
  );
  expectAbstractExercise(
    integrationContainer.read(exercisesControllerProvider).exercises.single,
    baseExercise,
  );

  // Add a fake workout
  // We can do it this way since we verified the "Create workout" flow
  // is working in another test
  final workout = Workout(
    id: "ourFakeWorkout",
    name: "Test workout",
    exercises: [],
    duration: Duration.zero,
    startingDate: DateTime.now(),
  );
  expect(workout.isConcrete, true);
  // Simulate picking the exercise
  workout.exercises.add(
    baseExercise.makeChild().instantiate(
      workout: workout.toRoutine(),
      rpe: const None(),
    ),
  );
  globalLogger.d(workout.exercises.single);
  expect(baseExercise.isAbstract, true);
  expect(workout.exercises.single.asExercise.isAbstract, false);
  expect(workout.exercises.single.id != baseExercise.id, true);
  expect((workout.exercises.single as Exercise).parentID, baseExercise.id);
  databaseService.setHistoryWorkout(workout);

  // Verify that the app has started.
  expect(find.text('New routine'), findsOneWidget);

  final button = find.widgetWithText(ListTile, "New routine");
  await tester.tap(button);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Create the routine
  // Verify that we're at a new page
  expect(find.text('New routine'), findsNothing);
  expect(find.text('Create new routine'), findsOneWidget);

  final nameField = find.widgetWithText(TextFormField, "Routine name");
  await enterTextAndDismissKeyboard(tester, nameField, "Test Routine");
  await dismissKeyboard(tester);

  // Scroll down
  await tester.drag(findMainListView(tester), const Offset(0.0, -600.0));

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Add an exercise
  final addExerciseButton = find.widgetWithText(ListTile, "Add exercises");
  await tester.scrollUntilVisible(
    addExerciseButton.hitTestable(),
    200,
    scrollable: find
        .descendant(
          of: findMainListView(tester),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(addExerciseButton);

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Verify that we're at a new page
  expect(find.text('Select exercises'), findsOneWidget);

  // Add an exercise
  await tester.tap(find.widgetWithIcon(ListTile, GTIcons.custom_exercises));
  await tester.pumpAndSettle();

  final exercise = find.byType(ListTile);
  expect(exercise, findsOneWidget);

  await tester.tap(exercise);

  // Trigger a frame.
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('pick')));

  // Trigger a frame.
  await tester.pumpAndSettle();

  // Save the routine
  final saveButton = find.widgetWithIcon(IconButton, GTIcons.done);
  await tester.tap(saveButton);

  // Trigger a frame.
  await tester.pumpAndSettle();

  expect(find.text(t.routines.title), findsAny);

  await openMainSection(tester, GTIcons.library);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithIcon(ListTile, GTIcons.custom_exercises));
  await tester.pumpAndSettle();
  // TODO: Pick more precisely
  expect(databaseService.exercises.length, 1);
  expect(databaseService.exercises.single.name, baseExercise.name);
  await tester.tap(find.byType(ListTile).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(PopupMenuItem, t.actions.edit));
  await tester.pumpAndSettle();

  final titleBtn = find.widgetWithText(
    TextField,
    t.exercise.editor.fields.title.label,
  );
  final primaryMuscleGroupBtn = find.widgetWithText(
    DropdownButtonFormField<GTMuscleGroup>,
    t.exercise.editor.fields.primaryMuscleGroup.label,
  );
  final setFields = [titleBtn, primaryMuscleGroupBtn];

  for (final finder in setFields) {
    expect(finder, findsOneWidget);
  }
  await enterTextAndDismissKeyboard(tester, setFields[0], "EditedExercise");
  await tester.pumpAndSettle();
  await tester.tap(setFields[1]);
  await tester.pumpAndSettle();
  await tester.tap(
    find.widgetWithText(
      DropdownMenuItem<GTMuscleGroup>,
      t.muscleGroups['chest']!,
    ),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, t.muscleGroups['glutes']!));
  await tester.tap(find.widgetWithText(ChoiceChip, t.muscleGroups['triceps']!));
  await tester.pumpAndSettle();

  // Save changes (pushes to DB)
  await tester.tap(find.byKey(const Key('done')));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  var ex = databaseService.exercises.first;
  expectAbstractExercise(
    ex,
    Exercise.custom(
      id: baseExercise.id,
      name: "EditedExercise",
      parameters: GTSetParameters.freeBodyReps,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "Base Notes",
      workoutID: null,
      supersetID: null,
      equipment: GTGymEquipment.none,
    ),
  );

  print(
    databaseService.currentSnapshot.customExercises.map((e) => e.id).toList(),
  );

  // Check the history data as well
  final historyWorkout = databaseService.workoutHistory.firstWhere(
    (workout) => workout.id == "ourFakeWorkout",
  );
  ex = historyWorkout.exercises.single as Exercise;
  expectExercise(
    ex,
    Exercise.custom(
      // We don't care about the ID, we want to check the rest of the data
      id: ex.id,
      parentID: baseExercise.id,
      name: "EditedExercise",
      parameters: GTSetParameters.freeBodyReps,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "Base Notes",
      workoutID: historyWorkout.id,
      supersetID: null,
      equipment: GTGymEquipment.none,
    ),
  );

  // And the routine data
  ex = databaseService.routines.single.exercises.single as Exercise;
  expectExercise(
    // We don't care about the sets in this test.
    ex.copyWith.sets([]),
    Exercise.custom(
      // We don't care about the ID, we want to check the rest of the data
      id: ex.id,
      parentID: baseExercise.id,
      name: "EditedExercise",
      parameters: GTSetParameters.freeBodyReps,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      // Note to self: We don't set the notes in the test. So we don't have
      // notes to expect here in the routine. The previous behavior in which
      // we had notes in the exercise was wrong.
      notes: "",
      workoutID: databaseService.routines.single.id,
      supersetID: null,
      equipment: GTGymEquipment.none,
    ),
  );
}

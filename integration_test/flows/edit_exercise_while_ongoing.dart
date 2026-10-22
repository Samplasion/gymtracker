import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/workout.dart';

import '../../test/expectations.dart';
import '../utils.dart';

const wait = Duration(milliseconds: 500);

final Exercise baseExercise = Exercise.custom(
  id: "ourID",
  name: "CustomExercise",
  parameters: GTSetParameters.distance,
  sets: [],
  primaryMuscleGroup: GTMuscleGroup.abductors,
  secondaryMuscleGroups: {GTMuscleGroup.glutes},
  restTime: Duration.zero,
  notes: "Base Notes",
  workoutID: "routineID",
  supersetID: "supersetID",
  equipment: GTGymEquipment.none,
);

Future<void> testEditExerciseWhileWorkoutIsOngoingFlow(
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

  await tester.tap(
    find.widgetWithText(ListTile, t.routines.quickWorkout.title),
  );
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutView), findsOneWidget);

  await tester.tap(
    find.widgetWithText(FilledButton, t.ongoingWorkout.exercises.add),
  );
  await tester.pumpAndSettle(wait);
  await tester.tap(find.byIcon(GTIcons.custom_exercises));
  await tester.pumpAndSettle(wait);
  // TODO: Pick more precisely
  await tester.tap(find.byType(ExerciseListTile));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.byKey(const Key('pick')));
  await tester.pumpAndSettle(wait);

  final ongoingWorkout = integrationContainer.read(
    workoutControllerProvider.notifier,
  );
  print(ongoingWorkout.exercises.single.toJson());
  expect(
    (ongoingWorkout.exercises.single as Exercise).parentID,
    baseExercise.id,
  );

  await tester.tap(
    find.byType(CircleAvatar),
  ); // faccio parte del codice di questo progetto adesso, voglio i nomi nei titoli finali
  await tester.pumpAndSettle(wait);
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.widgetWithText(PopupMenuItem, t.actions.edit));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.widgetWithText(TextButton, "OK"));
  await tester.pumpAndSettle(wait);

  final titleBtn = find.widgetWithText(
    TextField,
    t.exercise.editor.fields.title.label,
  );
  final parametersBtn = find.widgetWithText(
    DropdownButtonFormField<GTSetParameters>,
    t.exercise.editor.fields.parameters.label,
  );
  final primaryMuscleGroupBtn = find.widgetWithText(
    DropdownButtonFormField<GTMuscleGroup>,
    t.exercise.editor.fields.primaryMuscleGroup.label,
  );
  final setFields = [titleBtn, parametersBtn, primaryMuscleGroupBtn];

  for (final finder in setFields) {
    expect(finder, findsOneWidget);
  }
  await enterTextAndDismissKeyboard(
    tester,
    setFields[0],
    "SecondEditedExercise",
  );
  await tester.tap(setFields[1]);
  await tester.pumpAndSettle(wait);
  await tester.tap(
    find.widgetWithText(
      DropdownMenuItem<GTSetParameters>,
      t.exercise.editor.fields.parameters.values['time']!,
    ),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle(wait);
  await tester.tap(setFields[2]);
  await tester.pumpAndSettle(wait);
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

  await tester.tap(find.byKey(const Key('main-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Finish workout"));
  await tester.pumpAndSettle();

  await enterTextAndDismissKeyboard(
    tester,
    find.widgetWithText(TextField, t.ongoingWorkout.finish.fields.name.label),
    "Workout",
  );

  await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  await tester.pumpAndSettle();

  // expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  // await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  // await tester.pumpAndSettle();

  // Wait for the database changes to flush
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check that our changes have been saved
  var ex = databaseService.exercises.first;
  expectAbstractExercise(
    ex,
    Exercise.custom(
      id: baseExercise.id,
      name: "SecondEditedExercise",
      parameters: GTSetParameters.time,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "",
      workoutID: null,
      supersetID: null,
      equipment: GTGymEquipment.none,
    ),
  );
}

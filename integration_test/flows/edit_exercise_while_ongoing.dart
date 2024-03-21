import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/workout.dart';

void expectExercise(Exercise result, Exercise expected) {
  expect(result.name, expected.name);
  expect(result.parameters, expected.parameters);
  expect(result.primaryMuscleGroup, expected.primaryMuscleGroup);
  expect(result.secondaryMuscleGroups, expected.secondaryMuscleGroups);
  expect(result.restTime, expected.restTime);
  expect(result.notes, expected.notes);
  expect(result.sets.length, expected.sets.length);
  for (int i = 0; i < result.sets.length; i++) {
    expect(result.sets[i].kind, expected.sets[i].kind);
    expect(result.sets[i].parameters, expected.sets[i].parameters);
    expect(result.sets[i].reps, expected.sets[i].reps);
    expect(result.sets[i].weight, expected.sets[i].weight);
  }
}

const wait = Duration(milliseconds: 500);

final Exercise baseExercise = Exercise.custom(
  id: "ourID",
  name: "CustomExercise",
  parameters: SetParameters.distance,
  sets: [],
  primaryMuscleGroup: MuscleGroup.abductors,
  secondaryMuscleGroups: {MuscleGroup.glutes},
  restTime: Duration.zero,
  notes: "Base Notes",
);

Future<void> testEditExerciseWhileWorkoutIsOngoingFlow(
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

  print("Starting database state: ${databaseService.toJson()}");

  // Manually add the exercise
  // We can do it this way since we verified the "Create exercise" flow
  // is working in another test
  await databaseService.exerciseBox.clear();
  Get.find<ExercisesController>().addExercise(baseExercise);

  await tester.pumpAndSettle();

  print("Edited database state: ${databaseService.toJson()}");
  expect(Get.find<ExercisesController>().exercises.isNotEmpty, true);
  expectExercise(
      Get.find<ExercisesController>().exercises.single, baseExercise);

  await tester
      .tap(find.widgetWithText(ListTile, 'routines.quickWorkout.title'.t));
  await tester.pumpAndSettle();

  expect(find.byType(WorkoutView), findsOneWidget);

  await tester
      .tap(find.widgetWithText(FilledButton, 'ongoingWorkout.exercises.add'.t));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.widgetWithText(ListTile, 'library.custom'.t));
  await tester.pumpAndSettle(wait);
  // TODO: Pick more precisely
  await tester.tap(find.byType(ExerciseListTile));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.byKey(const Key('pick')));
  await tester.pumpAndSettle(wait);

  final ongoingWorkout = Get.find<WorkoutController>();
  print(ongoingWorkout.exercises.single.toJson());
  expect(
      (ongoingWorkout.exercises.single as Exercise).parentID, baseExercise.id);

  await tester.tap(find.widgetWithText(
      CircleAvatar, baseExercise.displayName.characters.first));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.widgetWithText(PopupMenuItem, "actions.edit".t));
  await tester.pumpAndSettle(wait);
  await tester.tap(find.widgetWithText(TextButton, "OK"));
  await tester.pumpAndSettle(wait);

  final titleBtn =
      find.widgetWithText(TextField, "exercise.editor.fields.title.label".t);
  final parametersBtn = find.widgetWithText(
      DropdownButtonFormField<SetParameters>,
      "exercise.editor.fields.parameters.label".t);
  final primaryMuscleGroupBtn = find.widgetWithText(
      DropdownButtonFormField<MuscleGroup>,
      "exercise.editor.fields.primaryMuscleGroup.label".t);
  final setFields = [
    titleBtn,
    parametersBtn,
    primaryMuscleGroupBtn,
  ];

  for (final finder in setFields) {
    expect(finder, findsOneWidget);
  }
  await tester.enterText(setFields[0], "SecondEditedExercise");
  await tester.tap(setFields[1]);
  await tester.pumpAndSettle(wait);
  await tester.tap(
    find.widgetWithText(DropdownMenuItem<SetParameters>,
        "exercise.editor.fields.parameters.values.time".t),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle(wait);
  await tester.tap(setFields[2]);
  await tester.pumpAndSettle(wait);
  await tester.tap(
    find.widgetWithText(DropdownMenuItem<MuscleGroup>, "muscleGroups.chest".t),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, "muscleGroups.glutes".t));
  await tester.tap(find.widgetWithText(ChoiceChip, "muscleGroups.triceps".t));
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

  await tester.enterText(
    find.widgetWithText(
      TextField,
      "ongoingWorkout.finish.fields.name.label".t,
    ),
    "Workout",
  );

  await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
  await tester.pumpAndSettle();

  // expect(find.byType(WorkoutDoneSheet), findsOneWidget);
  // await tester.tap(find.widgetWithIcon(IconButton, Icons.done_rounded));
  // await tester.pumpAndSettle();

  // Wait for the database changes to flush
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check that our changes have been saved
  var ex = databaseService.exerciseBox.values.first;
  expectExercise(
    ex,
    Exercise.custom(
      id: baseExercise.id,
      name: "SecondEditedExercise",
      parameters: SetParameters.time,
      sets: [],
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: {MuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "Base Notes",
    ),
  );
}

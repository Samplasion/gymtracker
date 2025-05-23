import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/badges.dart';

import '../../test/expectations.dart';

Future<void> testCreateExerciseFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await tester.pumpWidget(
    MainApp(localizations: l, databaseService: databaseService),
    duration: const Duration(seconds: 5),
  );

  // Wait for the app to finish loading
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Verify that the app has started.
  expect(find.text('library.title'.t), findsAny);

  await tester.tap(
    find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.byIcon(GTIcons.library)),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithIcon(ListTile, GTIcons.custom_exercises));
  await tester.pumpAndSettle();
  await tester
      .tap(find.widgetWithText(ListTile, 'library.newCustomExercise'.t));
  await tester.pumpAndSettle();

  final titleBtn =
      find.widgetWithText(TextField, "exercise.editor.fields.title.label".t);
  final parametersBtn = find.widgetWithText(
      DropdownButtonFormField<GTSetParameters>,
      "exercise.editor.fields.parameters.label".t);
  final primaryMuscleGroupBtn = find.widgetWithText(
      DropdownButtonFormField<GTMuscleGroup>,
      "exercise.editor.fields.primaryMuscleGroup.label".t);
  final setFields = [
    titleBtn,
    parametersBtn,
    primaryMuscleGroupBtn,
  ];

  for (final finder in setFields) {
    expect(finder, findsOneWidget);
  }
  await tester.enterText(setFields[0], "EditedExercise");
  await tester.tap(setFields[1]);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(DropdownMenuItem<GTSetParameters>,
      "exercise.editor.fields.parameters.values.time".t));
  await tester.pumpAndSettle();
  await tester.tap(setFields[2]);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(
      DropdownMenuItem<GTMuscleGroup>, "muscleGroups.chest".t));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, "muscleGroups.triceps".t));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('done')));
  await tester.pumpAndSettle();

  await tester.tap(find.ancestor(
    of: find.byType(CustomExerciseBadge),
    matching: find.byType(ListTile),
  ));
  await tester.pumpAndSettle();

  // Check that our changes have been saved
  final ex = databaseService.exercises.first;
  expectExercise(
    ex,
    Exercise.custom(
      // We don't care about the ID, just that the data is correct
      id: ex.id,
      name: "EditedExercise",
      parameters: GTSetParameters.time,
      sets: [],
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {GTMuscleGroup.triceps},
      restTime: Duration.zero,
      notes: "",
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.none,
    ),
  );
}

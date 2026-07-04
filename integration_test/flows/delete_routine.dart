import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/exercises.dart';

import '../utils.dart';

Future<void> testDeleteRoutineFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, l, databaseService);

  // 1. Create a routine to delete
  expect(find.text('New routine'), findsOneWidget);
  await tester.tap(find.widgetWithText(ListTile, "New routine"));
  await tester.pumpAndSettle();

  // Enter name
  await tester.enterText(
    find.widgetWithText(TextFormField, "Routine name"),
    "Routine to Delete",
  );

  // Add exercise
  await tester.tap(find.widgetWithText(ListTile, "Add exercises"));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, "Abs"));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Crunches'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("pick")));
  await tester.pumpAndSettle();

  // Save the routine
  await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  await tester.pumpAndSettle();

  // Verify created
  expect(find.text('Routine to Delete'), findsOneWidget);
  expect(databaseService.routines.length, 1);

  // 2. Open the routine detail page
  await tester.tap(find.widgetWithText(ListTile, 'Routine to Delete'));
  await tester.pumpAndSettle();

  // Verify we are on details page (ExercisesView)
  expect(find.byType(ExercisesView), findsOneWidget);

  // 3. Delete the routine
  await tester.tap(find.byKey(const Key('menu')));
  await tester.pumpAndSettle();

  await tester.tap(find.text('routines.actions.delete.title'.t));
  await tester.pumpAndSettle();

  // Verify confirmation dialog
  expect(find.byType(AlertDialog), findsOneWidget);
  await tester.tap(find.text('routines.actions.delete.actions.yes'.t));
  await tester.pumpAndSettle();

  // 4. Verify routine is deleted and we are back to main routines screen
  expect(find.text('Routine to Delete'), findsNothing);
  expect(databaseService.routines.length, 0);
  expect(Get.find<RoutinesController>().workouts.length, 0);
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/database.dart';

import '../utils.dart';

Future<void> testLogWeightFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  // 1. Navigate to the Me tab
  await openMainSection(tester, GTIcons.profile);
  await tester.pumpAndSettle();

  // 2. Verify we are on the Me page
  expect(find.text(t.me.title), findsAtLeast(1));

  // 3. Tap the "Add measurement" button
  await tester.tap(find.widgetWithText(TextButton, t.me.weight.addMeasurement));
  await tester.pumpAndSettle();

  await dismissKeyboard(tester);

  // 4. Fill in the weight field (e.g. 75.5 kg)
  final weightField = find.widgetWithText(
    TextField,
    t.me.addWeight.weight.label,
  );
  await waitForWidget(tester, weightField);
  expect(weightField, findsOneWidget);
  await enterTextAndDismissKeyboard(tester, weightField, "75.5");
  await tester.pumpAndSettle();

  await dismissKeyboard(tester);

  // 5. Submit the form by tapping the done icon
  await tester.tap(find.widgetWithIcon(IconButton, GTIcons.done));
  await tester.pumpAndSettle();

  // 6. Verify that the weight is updated in database and controller
  final meController = integrationContainer.read(meControllerProvider);
  expect(meController.weightMeasurements.length, 1);
  expect(meController.weightMeasurements.first.weight, 75.5);

  // Also check that it displays on the screen
  expect(find.textContaining("75.5"), findsAtLeast(1));
}

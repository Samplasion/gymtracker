import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/view/routine_creator.dart';

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

  testWidgets('RoutineCreator renders successfully in create mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WidgetTestApp(child: RoutineCreator()));
    await tester.pump();

    // Verify title "Create new routine" is rendered
    expect(find.text("Create new routine"), findsOneWidget);

    // Verify name field is rendered
    expect(find.widgetWithText(TextFormField, "Routine name"), findsOneWidget);
  });
}

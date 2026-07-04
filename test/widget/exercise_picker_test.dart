import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    // Stub exercisesController
    when(() => MockServices.exercisesController.exercises)
        .thenReturn(<Exercise>[].obs);
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('ExercisePicker renders successfully with search bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WidgetTestApp(
      child: ExercisePicker(singlePick: true),
    ));
    await tester.pump();

    // Should render the title "Select exercises"
    expect(find.text("Select exercises"), findsOneWidget);

    // Should render search anchor
    expect(find.byType(SearchAnchor), findsOneWidget);
  });
}

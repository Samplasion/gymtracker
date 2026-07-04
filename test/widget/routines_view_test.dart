import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    // Stub routinesController methods and getters
    when(() => MockServices.routinesController.suggestions)
        .thenReturn(<RoutineSuggestion>[].obs);
    when(() => MockServices.routinesController.folders)
        .thenReturn(<GTRoutineFolder, List<Workout>>{}.obs);
    when(() => MockServices.routinesController.rootRoutines)
        .thenReturn(<Workout>[].obs);
    when(() => MockServices.routinesController.onServiceChange())
        .thenAnswer((_) {});
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('RoutinesView renders successfully with create options',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WidgetTestApp(child: RoutinesView()));
    await tester.pump();

    // Verify view has "New routine" and "New folder" options
    expect(find.text('New routine'), findsOneWidget);
    expect(find.text('New folder'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/history.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    // Stub historyController methods and getters
    when(() => MockServices.historyController.history)
        .thenReturn(<Workout>[].obs);
    when(() => MockServices.historyController.userVisibleWorkouts)
        .thenReturn(<Workout>[]);
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('HistoryView renders successfully when history is empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WidgetTestApp(child: HistoryView()));
    await tester.pump();

    // Should render empty history message
    expect(find.text("No history"), findsOneWidget);
  });
}

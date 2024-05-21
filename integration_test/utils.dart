import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';

Future<void> awaitApp(
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
  expect(find.text('library.title'.t), findsOneWidget);
}

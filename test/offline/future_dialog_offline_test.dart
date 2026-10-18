import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:http/http.dart';

import '../test_helpers/widget_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initTestLocalizations();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Go.futureDialog should complete or reject when the future fails offline instead of hanging permanently',
    (tester) async {
      await tester.pumpWidget(
        WidgetTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Go.futureDialog(
                    future: () async {
                      throw ClientException(
                        'Failed to connect to Supabase: No internet',
                      );
                    },
                    title: 'Syncing',
                  ).catchError((error, stackTrace) {
                    // Bubbling the error to the test fails it, but we can log it to verify that the futureDialog rejected the future instead of hanging.
                    print("FutureDialog failed with error: $error");
                  });
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open futureDialog with a failing offline future
      await tester.tap(find.text('Open Dialog'));
      await tester.pump();

      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));

      // The dialog should be dismissible or should have completed/closed when the future failed
      // In current implementation, the dialog is permanently stuck because canPop is false and Navigator.pop was never called.
      expect(
        find.byType(AlertDialog),
        findsNothing,
        reason:
            'Go.futureDialog remains stuck on screen with canPop=false when the future fails offline',
      );
    },
  );
}

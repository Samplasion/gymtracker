import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/login.dart';
import 'package:http/http.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _FailingOnlineNotifier extends Online {
  @override
  FutureOr<OnlineAccount?> build() async => null;

  @override
  CredentialsState checkCredentials({
    required String email,
    required String password,
    String? username,
  }) {
    return CredentialsState.empty();
  }

  @override
  Future<void> login({required String email, required String password}) async {
    throw ClientException('Failed host lookup: api.supabase.co');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();

    globalContainer = ProviderContainer(
      overrides: [onlineProvider.overrideWith(() => _FailingOnlineNotifier())],
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'AuthScreen submit sign in catches ClientException when offline instead of throwing uncaught exception',
    (tester) async {
      await tester.pumpWidget(
        const WidgetTestApp(wrapWithProviderScope: true, child: AuthScreen()),
      );
      await tester.pumpAndSettle();

      // Enter valid email and password
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'Password123!');
      await tester.pump();

      // Tap Sign In button
      final signInButton = find.widgetWithText(
        ElevatedButton,
        t.login.buttons.signIn,
      );
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pump();

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason:
            'ClientException was thrown uncaught during offline login instead of being handled as no internet',
      );
    },
  );
}

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/email_confirmation.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/view/login.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/widget_test_app.dart';

class _Links extends Mock implements AppLinks {}

class _Online extends Online {
  _Online() : super(service: TestOnlineServiceImpl());
  final requests = <(String, String)>[];
  Completer<bool> response = Completer<bool>();

  @override
  FutureOr<OnlineAccount?> build() => null;

  @override
  Future<bool> checkEmailVerificationAndLogIn({
    required String email,
    required String password,
  }) {
    requests.add((email, password));
    return response.future;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    fail('Verification already logs in: do not authenticate twice');
  }
}

void main() {
  test('only the exact native return link requests a server check', () {
    expect(
      isEmailConfirmationLink('gymtracker://auth/email-confirmed'),
      isTrue,
    );
    for (final url in [
      'https://auth/email-confirmed',
      'gymbro://auth/email-confirmed',
      'gymtracker://routine/email-confirmed',
      'gymtracker://auth/other',
      'gymtracker://auth/email-confirmed?verified=true',
      'gymtracker://user@auth/email-confirmed',
      'gymtracker://auth:42/email-confirmed',
      'gymtracker://auth/email-confirmed#token',
      'invalid',
    ]) {
      expect(isEmailConfirmationLink(url), isFalse, reason: url);
    }
  });

  for (final outcome in ['confirmed', 'unconfirmed', 'offline']) {
    testWidgets(
      'return to app checks server: $outcome, deduplicates and cleans up',
      (tester) async {
        final appLinks = _Links();
        final events = StreamController<Uri>.broadcast(sync: true);
        when(() => appLinks.uriLinkStream).thenAnswer((_) => events.stream);
        when(
          () => appLinks.getInitialLinkString(),
        ).thenAnswer((_) async => null);
        final links = ProtocolService(appLinks: appLinks);
        await links.initialize();
        links.markReady();
        final online = _Online();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              onlineProvider.overrideWith(() => online),
              protocolServiceProvider.overrideWithValue(links),
            ],
            child: WidgetTestApp(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AuthVerifyEmailScreen(
                        email: 'me@example.com',
                        password: 'secret',
                      ),
                    ),
                  ),
                  child: const Text('Verify'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();
        events.add(Uri.parse('gymtracker://routine/ignored'));
        expect(online.requests, isEmpty);
        events.add(Uri.parse('gymtracker://auth/email-confirmed'));
        events.add(Uri.parse('gymtracker://auth/email-confirmed'));
        await tester.pump();
        expect(online.requests, [('me@example.com', 'secret')]);
        expect(find.byType(AuthVerifyEmailScreen), findsOneWidget);
        if (outcome == 'offline') {
          online.response.completeError(StateError('offline'));
        } else {
          online.response.complete(outcome == 'confirmed');
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.byType(AuthVerifyEmailScreen),
          outcome == 'confirmed' ? findsNothing : findsOneWidget,
        );
        if (outcome != 'confirmed') {
          online.response = Completer<bool>();
          events.add(Uri.parse('gymtracker://auth/email-confirmed'));
          await tester.pump();
          expect(
            online.requests.length,
            2,
            reason: 'A failed check must be retryable',
          );
          online.response.complete(true);
          await tester.pumpAndSettle();
        }
        expect(links.listeners, isEmpty);
        events.add(Uri.parse('gymtracker://auth/email-confirmed'));
        await tester.pump();
        expect(online.requests.length, outcome == 'confirmed' ? 1 : 2);
        await tester.pumpWidget(const SizedBox.shrink());
        links.dispose();
        await events.close();
      },
    );
  }
}

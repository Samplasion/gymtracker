import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/trainer.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _NoOnlineAccount extends Online {
  @override
  FutureOr<OnlineAccount?> build() => null;
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);
  testWidgets(
    'a guest opening an invitation link sees sign-in, never acceptance controls',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...MockServices.defaultOverrides,
            onlineProvider.overrideWith(_NoOnlineAccount.new),
            currentUserIdProvider.overrideWithValue(null),
          ],
          child: const WidgetTestApp(
            child: TrainerView(token: 'test-invitation'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Accept connection'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
  for (final signedIn in [false, true]) {
    testWidgets(
      'trainer requests entry is ${signedIn ? 'visible to registered users' : 'hidden from guests'}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...MockServices.defaultOverrides,
              onlineProvider.overrideWith(_NoOnlineAccount.new),
              currentUserIdProvider.overrideWithValue(
                signedIn ? 'registered-user' : null,
              ),
            ],
            child: const WidgetTestApp(child: MeView()),
          ),
        );
        await tester.pumpAndSettle();
        if (signedIn) {
          await tester.scrollUntilVisible(
            find.text('My trainer'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          expect(find.text('Personal trainer'), findsOneWidget);
          expect(
            tester.getTopLeft(find.text('My trainer')).dy,
            greaterThan(tester.getTopLeft(find.text('Personal trainer')).dy),
          );
        } else {
          expect(find.text('Personal trainer'), findsNothing);
        }
        expect(
          find.text('My trainer'),
          signedIn ? findsOneWidget : findsNothing,
        );
        expect(
          find.byIcon(Icons.sports_rounded),
          signedIn ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

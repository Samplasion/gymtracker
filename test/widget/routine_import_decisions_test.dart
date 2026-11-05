import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/view/paywall.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  final routine = Workout(name: 'Received routine', exercises: []);
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.en);
  });
  tearDown(MockServices.tearDown);
  for (final pro in [false, true]) {
    testWidgets(
      'import ${pro ? 'saves once for Pro' : 'opens paywall without saving for free account'}',
      (tester) async {
        final info = SubscriptionInfo(
          isPro: pro,
          isTrial: false,
          isForcedPro: false,
          isAboutToExpire: false,
        );
        when(
          () => MockServices.purchasesController.subscriptionInfoStream,
        ).thenAnswer((_) => Stream.value(info));
        when(
          () => MockServices.purchasesController.subscriptionInfo,
        ).thenReturn(info);
        when(
          () => MockServices.routinesController.importWorkout(routine),
        ).thenReturn('imported');
        await tester.pumpWidget(
          WidgetTestApp(
            wrapWithProviderScope: true,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ImportRoutineModal(workout: routine),
                  ),
                ),
                child: const Text('Open import'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open import'));
        await tester.pumpAndSettle();
        final importButton = find.byType(FilledButton).last;
        // Pro access is checked by the actual import button, before any writes.
        if (!pro) {
          when(
            () => MockServices.purchasesController.canPresentNativePaywall(),
          ).thenReturn(false);
          when(
            () => MockServices.purchasesController.getPaywallData(),
          ).thenAnswer((_) async => const Offering(subscriptions: []));
          await tester.tap(importButton);
          await tester.pumpAndSettle();
          expect(find.byType(PaywallScreen), findsOneWidget);
          verifyNever(
            () => MockServices.routinesController.importWorkout(routine),
          );
          tester.state<NavigatorState>(find.byType(Navigator).first).pop();
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Close'));
          await tester.pumpAndSettle();
          verifyNever(
            () => MockServices.routinesController.importWorkout(routine),
          );
        } else {
          await tester.tap(importButton);
          await tester.pumpAndSettle();
          verify(
            () => MockServices.routinesController.importWorkout(routine),
          ).called(1);
          expect(find.byType(ImportRoutineModal), findsNothing);
        }
      },
    );
  }
}

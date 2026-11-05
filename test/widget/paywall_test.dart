import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/legal.dart';
import 'package:gymtracker/view/paywall.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

const _subscription = Subscription(
  productId: 'monthly',
  price: '€4.99',
  displayName: 'Pro monthly',
  duration: SubscriptionPeriod.month,
  trial: SubscriptionTrial(duration: 1, periodType: SubscriptionPeriod.week),
);
const _offering = Offering(subscriptions: [_subscription]);

void testPaywall(String description, WidgetTesterCallback callback) {
  testWidgets(
    description,
    callback,
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    LocaleSettings.setLocale(AppLocale.en);
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => _offering);
  });

  tearDown(() {
    LocaleSettings.setLocale(AppLocale.en);
    MockServices.tearDown();
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: PaywallScreen()),
    );
    await tester.pumpAndSettle();
  }

  testPaywall('loading disables subscription until offerings arrive', (
    tester,
  ) async {
    final pending = Completer<Offering?>();
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) => pending.future);
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: PaywallScreen()),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete(_offering);
    await tester.pumpAndSettle();
    expect(find.text('Pro monthly'), findsOneWidget);
    expect(find.text('Free trial: 1 week'), findsOneWidget);
    expect(find.textContaining('€4.99 per month'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testPaywall('daily trials are displayed in days', (tester) async {
    when(() => MockServices.purchasesController.getPaywallData()).thenAnswer(
      (_) async => const Offering(
        subscriptions: [
          Subscription(
            productId: 'monthly',
            price: '€4.99',
            displayName: 'Monthly',
            duration: SubscriptionPeriod.month,
            trial: SubscriptionTrial(
              duration: 7,
              periodType: SubscriptionPeriod.day,
            ),
          ),
        ],
      ),
    );
    await open(tester);
    expect(find.text('Free trial: 7 days'), findsOneWidget);
  });

  testPaywall('failed load hides technical error and retry recovers', (
    tester,
  ) async {
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => throw StateError('secret SDK configuration'));
    await open(tester);
    expect(find.text(t.paywall.loadError), findsOneWidget);
    expect(find.textContaining('secret SDK'), findsNothing);
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => _offering);
    await tester.tap(find.text(t.error.retry));
    await tester.pumpAndSettle();
    expect(find.text('Pro monthly'), findsOneWidget);
    expect(find.text(t.paywall.loadError), findsNothing);
  });

  testPaywall('empty and null offerings have a retryable empty state', (
    tester,
  ) async {
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => Offering.empty);
    await open(tester);
    expect(find.text(t.paywall.empty), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => null);
    await tester.tap(find.text(t.error.retry));
    await tester.pumpAndSettle();
    expect(find.text(t.paywall.empty), findsOneWidget);
  });

  testPaywall('cancellation stays on the paywall without an error', (
    tester,
  ) async {
    when(
      () =>
          MockServices.purchasesController.purchaseSubscription(_subscription),
    ).thenAnswer((_) async => SubscriptionPurchaseStatus.cancelled);
    await open(tester);
    await tester.tap(find.text(t.paywall.actions.subscribe));
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testPaywall('purchase failure resets busy state and shows localized error', (
    tester,
  ) async {
    final pending = Completer<SubscriptionPurchaseStatus>();
    when(
      () =>
          MockServices.purchasesController.purchaseSubscription(_subscription),
    ).thenAnswer((_) => pending.future);
    await open(tester);
    await tester.tap(find.text(t.paywall.actions.subscribe));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.completeError(StateError('secret purchase failure'));
    await tester.pumpAndSettle();
    expect(find.text(t.paywall.purchaseError.subtitle), findsOneWidget);
    expect(find.textContaining('secret purchase'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testPaywall('restore failure shows a translated message and allows retry', (
    tester,
  ) async {
    when(
      () => MockServices.purchasesController.restorePurchases(),
    ).thenAnswer((_) async => throw StateError('secret restore failure'));
    await open(tester);
    await tester.tap(find.text(t.paywall.actions.restorePurchase));
    await tester.pumpAndSettle();
    expect(find.text(t.paywall.restoreError.subtitle), findsOneWidget);
    expect(find.textContaining('secret restore'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  for (final restoring in [false, true]) {
    testPaywall(
      '${restoring ? 'restore' : 'purchase'} success closes after a busy frame',
      (tester) async {
        final purchase = Completer<SubscriptionPurchaseStatus>();
        final restore = Completer<void>();
        when(
          () => MockServices.purchasesController.purchaseSubscription(
            _subscription,
          ),
        ).thenAnswer((_) => purchase.future);
        when(
          () => MockServices.purchasesController.restorePurchases(),
        ).thenAnswer((_) => restore.future);
        await tester.pumpWidget(
          WidgetTestApp(
            wrapWithProviderScope: true,
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PaywallScreen(),
                  ),
                ),
                child: const Text('Open paywall'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open paywall'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(
            restoring
                ? t.paywall.actions.restorePurchase
                : t.paywall.actions.subscribe,
          ),
        );
        await tester.pump();
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        if (restoring) {
          restore.complete();
        } else {
          purchase.complete(SubscriptionPurchaseStatus.success);
        }
        await tester.pumpAndSettle();
        expect(find.byType(PaywallScreen), findsNothing);
        expect(find.text('Open paywall'), findsOneWidget);
      },
    );
  }

  testPaywall('legal actions open their documents', (tester) async {
    await open(tester);
    await tester.tap(find.text(t.paywall.actions.termsOfService));
    await tester.pumpAndSettle();
    expect(find.byType(TosViewerPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.paywall.actions.privacyPolicy));
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyViewerPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testPaywall('Italian paywall uses translated empty and action labels', (
    tester,
  ) async {
    LocaleSettings.setLocale(AppLocale.it);
    when(
      () => MockServices.purchasesController.getPaywallData(),
    ).thenAnswer((_) async => null);
    await open(tester);
    expect(find.text('Abbonati'), findsOneWidget);
    expect(
      find.text(
        'Nessun abbonamento disponibile al momento. Riprova più tardi.',
      ),
      findsOneWidget,
    );
    expect(t.paywall.trialPeriod.week(n: 1), 'Prova gratuita: 1 settimana');
    expect(t.paywall.trialPeriod.week(n: 2), 'Prova gratuita: 2 settimane');
  });

  testPaywall('shared error view keeps technical details in logs', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      WidgetTestApp(
        child: ErrorViewComponent(
          error: StateError('secret server details'),
          retryCallback: () => retried = true,
        ),
      ),
    );
    expect(find.textContaining('secret server'), findsNothing);
    expect(find.text(t.errorView.subtitle), findsOneWidget);
    await tester.tap(find.text(t.error.retry));
    expect(retried, isTrue);
  });
}

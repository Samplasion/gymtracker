import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/shared_program.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/shared_program.dart';
import 'package:gymtracker/view/components/routine_import_content.dart';
import 'package:gymtracker/view/paywall.dart';
import 'package:gymtracker/view/utils/shared_program.dart';
import 'package:mocktail/mocktail.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _SharedService extends Mock implements SharedProgramService {}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.en);
  });
  tearDown(MockServices.tearDown);
  testWidgets('multi-day import keeps one app bar when switching days', (
    tester,
  ) async {
    final service = _SharedService();
    final program = SharedProgramV1.fromWorkouts('Shared plan', [
      Workout(name: 'Day 1', exercises: []),
      Workout(name: 'Day 2', exercises: []),
    ], folder: GTRoutineFolder.generate(name: 'Shared plan'));
    when(() => service.read('token')).thenAnswer((_) async => program);
    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: ProviderScope(
          overrides: [sharedProgramServiceProvider.overrideWithValue(service)],
          child: const SharedProgramImportView(token: 'token'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SliverAppBar), findsNothing);
    expect(find.text('Shared plan'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day 2').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RoutineImportContent>(find.byType(RoutineImportContent))
          .routines[tester
              .widget<RoutineImportContent>(find.byType(RoutineImportContent))
              .selectedDay]
          .name,
      'Day 2',
    );
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(SliverAppBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('loading and recoverable errors keep one app bar and retry', (
    tester,
  ) async {
    final service = _SharedService();
    final pending = Completer<SharedProgramV1>();
    when(() => service.read('token')).thenAnswer((_) => pending.future);
    await tester.pumpWidget(
      WidgetTestApp(
        wrapWithProviderScope: true,
        child: ProviderScope(
          overrides: [sharedProgramServiceProvider.overrideWithValue(service)],
          child: const SharedProgramImportView(token: 'token'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    pending.completeError(const FormatException('not_found'));
    await tester.pumpAndSettle();
    expect(find.text('Program unavailable'), findsOneWidget);
    final program = SharedProgramV1.fromWorkouts('Recovered', [
      Workout(name: 'Day', exercises: []),
    ]);
    when(() => service.read('token')).thenAnswer((_) async => program);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final pro in [false, true]) {
    testWidgets(
      'shared token import ${pro ? 'rechecks token and shows revocation' : 'opens paywall without writing'}',
      (tester) async {
        final service = _SharedService();
        final program = SharedProgramV1.fromWorkouts('Shared plan', [
          Workout(name: 'Day', exercises: []),
        ]);
        when(() => service.read('token')).thenAnswer((_) async => program);
        when(
          () => service.import('token', MockServices.databaseService),
        ).thenThrow(const FormatException('not_found'));
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
          () => MockServices.purchasesController.canPresentNativePaywall(),
        ).thenReturn(false);
        when(
          () => MockServices.purchasesController.getPaywallData(),
        ).thenAnswer((_) async => const Offering(subscriptions: []));
        await tester.pumpWidget(
          WidgetTestApp(
            wrapWithProviderScope: true,
            child: ProviderScope(
              overrides: [
                sharedProgramServiceProvider.overrideWithValue(service),
              ],
              child: const SharedProgramImportView(token: 'token'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Shared plan'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(SliverAppBar), findsNothing);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Shared plan'),
          ),
          findsOneWidget,
        );
        await tester.tap(find.byType(FilledButton).last);
        await tester.pumpAndSettle();
        if (pro) {
          verify(
            () => service.import('token', MockServices.databaseService),
          ).called(1);
          expect(
            find.text('This link does not exist or has been revoked.'),
            findsOneWidget,
          );
        } else {
          expect(find.byType(PaywallScreen), findsOneWidget);
          verifyNever(
            () => service.import('token', MockServices.databaseService),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}

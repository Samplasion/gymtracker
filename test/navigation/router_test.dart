import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/router.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/error.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/loading.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Offline extends Online {
  _Offline() : super(service: TestOnlineServiceImpl());

  @override
  FutureOr<OnlineAccount?> build() => null;
}

class _Connected extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

class _LogoutOnline extends Online {
  _LogoutOnline() : super(service: TestOnlineServiceImpl());

  final pending = Completer<void>();
  int logoutCalls = 0;

  @override
  FutureOr<OnlineAccount?> build() =>
      OnlineAccount(id: 'test-user', name: 'tester');

  @override
  Future<void> logout() async {
    logoutCalls++;
    await pending.future;
    state = const AsyncData(null);
  }
}

class _FoodPermissions extends FoodPermissionsNotifier {
  @override
  FutureOr<FoodPermissions> build() => (camera: true, gallery: true);
}

class _EmptyFeed extends Feed {
  @override
  Future<List<FeedItem>> build() async => [];
  @override
  void setVisible(bool visible) {}
  @override
  Future<void> refreshIfStale() async {}
  @override
  bool get hasMore => false;
}

class _Protocol extends Mock implements ProtocolService {}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  Future<GoRouter> mount(
    WidgetTester tester,
    String location, {
    ThemeData? theme,
  }) async {
    final router = MockServices.container.read(appRouterProvider);
    router.go(location);
    theme ??= ThemeData(useMaterial3: true);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: MockServices.container,
        child: TranslationProvider(
          child: MaterialApp.router(
            routerConfig: router,
            theme: theme.copyWith(
              extensions: [MoreColors.fromColorScheme(theme.colorScheme)],
            ),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
          ),
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  test(
    'root, onboarding and section routes resolve through one shared shell',
    () {
      final router = MockServices.container.read(appRouterProvider);
      expect(
        identical(router, MockServices.container.read(appRouterProvider)),
        isTrue,
      );
      for (final path in [
        '/',
        '/onboarding',
        '/feed',
        '/profile',
        '/routines',
        '/workout',
        '/workout/simple',
        '/error',
        '/paywall',
      ]) {
        final match = router.configuration.findMatch(Uri.parse(path));
        expect(match.isError, isFalse, reason: path);
        expect(match.uri.path, path);
      }
      final sections = [
        '/feed',
        '/profile',
        '/routines',
      ].map((path) => router.configuration.findMatch(Uri.parse(path)));
      final shells = sections
          .map((match) => match.matches.first.route)
          .toList();
      expect(shells.every((route) => route is ShellRoute), isTrue);
      expect(identical(shells[0], shells[1]), isTrue);
      expect(identical(shells[1], shells[2]), isTrue);
      expect(
        router.configuration
            .findMatch(Uri.parse('/onboarding'))
            .matches
            .first
            .route,
        isA<GoRoute>(),
      );
    },
  );

  for (final frameworkError in [false, true]) {
    testWidgets(
      'error route preserves ${frameworkError ? 'Flutter' : 'async'} error and stack',
      (tester) async {
        await mount(tester, '/workout');
        final error = StateError('Original error for navigation test');
        final stack = StackTrace.fromString('original_error_stack');
        final args = frameworkError
            ? ErrorViewArguments(
                details: FlutterErrorDetails(exception: error, stack: stack),
              )
            : ErrorViewArguments(error: error, stack: stack);

        unawaited(Go.toNamed<void>(ErrorView.routeName, arguments: args));
        await tester.pumpAndSettle();

        expect(find.byType(ErrorView), findsOneWidget);
        expect(
          find.textContaining('Original error for navigation test'),
          findsOneWidget,
        );
        expect(find.textContaining('original_error_stack'), findsOneWidget);
        final context = tester.element(find.byType(ErrorView));
        expect(find.text(context.t.errorView.noStack), findsNothing);
        expect(find.text('{}'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('error route without details shows an explicit fallback', (
    tester,
  ) async {
    await mount(tester, '/error');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No error details were provided.'),
      findsOneWidget,
    );
    final context = tester.element(find.byType(ErrorView));
    expect(find.text(context.t.errorView.noStack), findsOneWidget);
    expect(find.text('{}'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  Future<Completer<void>> configureBoot({
    required bool completedOnboarding,
    Online? online,
  }) async {
    final ready = Completer<void>();
    final prefs = BehaviorSubject<Prefs>.seeded(
      Prefs.defaultValue.copyWith(onboardingComplete: completedOnboarding),
    );
    addTearDown(prefs.close);
    when(() => MockServices.databaseService.prefs$).thenAnswer((_) => prefs);
    when(
      () => MockServices.settingsController.service,
    ).thenReturn(MockServices.databaseService);
    when(
      () => MockServices.routinesController.suggestions,
    ).thenReturn(<RoutineSuggestion>[]);
    when(() => MockServices.routinesController.folders).thenReturn({});
    when(() => MockServices.routinesController.rootRoutines).thenReturn([]);
    when(() => MockServices.notifications.hasPermission).thenReturn(false);
    when(
      () => MockServices.notifications.usesAndroidExactAlarmPermission,
    ).thenReturn(false);
    when(
      () => MockServices.notifications.hasAndroidScheduleExactAlarmPermission,
    ).thenReturn(false);
    VersionService().packageInfo = PackageInfo(
      appName: 'Gym Bro',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
    );
    MockServices.container.dispose();
    MockServices.container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        appStartupProvider.overrideWith((ref) => ready.future),
        onlineProvider.overrideWith(() => online ?? _Offline()),
        foodPermissionsProvider.overrideWith(_FoodPermissions.new),
        userAvatarProvider.overrideWith((ref, id) async => null),
        feedProvider.overrideWith(_EmptyFeed.new),
        networkConnectivityProvider.overrideWith(_Connected.new),
        protocolServiceProvider.overrideWithValue(_Protocol()),
        notificationPermissionsProvider.overrideWith(
          (ref) => Stream.value((
            hasPermission: false,
            usesExactAlarm: false,
            hasExactAlarmPermission: false,
            showSettingsTile: true,
          )),
        ),
      ],
    );
    TestService().isTest = false;
    return ready;
  }

  for (final outcome in [
    'success',
    'success-after-back',
    'failure',
    'cancel',
  ]) {
    testWidgets('settings logout handles $outcome without losing the router', (
      tester,
    ) async {
      final online = _LogoutOnline();
      await configureBoot(completedOnboarding: true, online: online);
      final permissionsTile = BehaviorSubject<bool>.seeded(true);
      addTearDown(permissionsTile.close);
      when(
        () => MockServices.notifications.showSettingsTileStream,
      ).thenAnswer((_) => permissionsTile);
      final router = await mount(tester, '/feed');
      unawaited(Go.to<void>(() => const SettingsView()));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(SettingsView));
      final labels = context.t;
      await tester.ensureVisible(find.text(labels.settings.logout));
      await tester.tap(find.text(labels.settings.logout));
      await tester.pumpAndSettle();
      final material = MaterialLocalizations.of(context);
      await tester.tap(
        find.widgetWithText(
          TextButton,
          outcome == 'cancel'
              ? material.cancelButtonLabel
              : material.okButtonLabel,
        ),
      );
      await tester.pumpAndSettle();
      expect(online.logoutCalls, outcome == 'cancel' ? 0 : 1);
      expect(find.byType(SettingsView), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/feed');

      if (outcome.startsWith('success')) {
        if (outcome == 'success-after-back') {
          Go.back();
          await tester.pumpAndSettle();
          expect(find.byType(SettingsView), findsNothing);
        }
        online.pending.complete();
        await tester.pumpAndSettle();
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(SettingsView), findsNothing);
        expect(find.byType(SkeletonView), findsNothing);
        expect(router.routeInformationProvider.value.uri.path, '/onboarding');
        expect(router.canPop(), isFalse);
        expect(Go.navigator.canPop(), isFalse);
      } else if (outcome == 'failure') {
        online.pending.completeError(StateError('Logout failed'));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsView), findsOneWidget);
        expect(
          find.text(labels.me.profile.errors.logout.title),
          findsOneWidget,
        );
        expect(find.textContaining('Logout failed'), findsOneWidget);
        expect(router.routeInformationProvider.value.uri.path, '/feed');
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'startup waits for readiness then routes incomplete onboarding outside the shell',
    (tester) async {
      final ready = await configureBoot(completedOnboarding: false);
      final router = await mount(tester, '/');
      expect(find.byType(LoadingPage), findsOneWidget);
      ready.complete();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SkeletonView), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/onboarding');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'completed onboarding enters the shared shell and sections switch without independent stacks',
    (tester) async {
      final ready = await configureBoot(completedOnboarding: true);
      final router = await mount(tester, '/');
      ready.complete();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(FeedView), findsOneWidget);
      expect(find.byType(SkeletonView), findsOneWidget);
      router.go('/profile');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MeView), findsOneWidget);
      expect(router.canPop(), isFalse);
      router.go('/routines');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(RoutinesView), findsOneWidget);
      expect(find.byType(SkeletonView), findsOneWidget);
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  for (final collapsed in [false, true]) {
    testWidgets(
      'tablet sidebar updates selection on first tap (collapsed: $collapsed)',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const SizedBox());
        final ready = await configureBoot(completedOnboarding: true);
        final router = await mount(
          tester,
          '/',
          theme:
              getGymTrackerThemeFor(
                tester.element(find.byType(SizedBox).first),
                Colors.blue,
                Brightness.light,
              ).copyWith(
                platform: TargetPlatform.iOS,
                splashFactory: NoSplash.splashFactory,
              ),
        );
        ready.complete();
        await tester.pumpAndSettle();
        if (collapsed) {
          await tester.tap(
            find
                .descendant(
                  of: find.byType(SkeletonView),
                  matching: find.byIcon(Icons.menu),
                )
                .hitTestable()
                .first,
          );
          await tester.pumpAndSettle();
        }
        for (final (index, path) in [
          (1, '/profile'),
          (3, '/routines'),
          (0, '/feed'),
        ]) {
          final navigation = collapsed
              ? find.byType(NavigationRail).hitTestable()
              : find.byType(NavigationDrawer).hitTestable();
          final destination = find.descendant(
            of: navigation,
            matching: collapsed
                ? find.text(
                    (tester
                                .widget<NavigationRail>(navigation)
                                .destinations[index]
                                .label
                            as Text)
                        .data!,
                  )
                : find.byType(NavigationDrawerDestination),
          );
          await tester.tap(collapsed ? destination : destination.at(index));
          await tester.pumpAndSettle();
          expect(router.routeInformationProvider.value.uri.path, path);
          expect(
            collapsed
                ? tester.widget<NavigationRail>(navigation).selectedIndex
                : tester.widget<NavigationDrawer>(navigation).selectedIndex,
            index,
          );
          if (!collapsed) {
            for (
              var destinationIndex = 0;
              destinationIndex < 4;
              destinationIndex++
            ) {
              final indicator = tester.widget<NavigationIndicator>(
                find.descendant(
                  of: destination.at(destinationIndex),
                  matching: find.byType(NavigationIndicator),
                ),
              );
              expect(
                indicator.animation.value,
                destinationIndex == index ? 1 : 0,
              );
              final fade = tester.widget<FadeTransition>(
                find.descendant(
                  of: find.descendant(
                    of: destination.at(destinationIndex),
                    matching: find.byType(NavigationIndicator),
                  ),
                  matching: find.byType(FadeTransition),
                ),
              );
              expect(fade.opacity.value, destinationIndex == index ? 1 : 0);
            }
          }
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('full and simple workout routes preserve back navigation', (
    tester,
  ) async {
    final router = await mount(tester, '/workout');
    expect(find.byType(WorkoutView), findsOneWidget);
    unawaited(router.push<void>('/workout/simple'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WorkoutSimpleView), findsOneWidget);
    expect(Go.getTopmostRouteName(), '/workout/simple');
    Go.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(WorkoutView), findsOneWidget);
    expect(Go.getTopmostRouteName(), '/workout');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('simple workout survives preferences refresh and rest expiry', (
    tester,
  ) async {
    final preferences = BehaviorSubject<Prefs>.seeded(Prefs.defaultValue);
    addTearDown(preferences.close);
    MockServices.container.dispose();
    MockServices.container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides.where(
          (override) =>
              override.origin != settingsControllerProvider &&
              override.origin != appPreferencesProvider,
        ),
        settingsControllerProvider.overrideWith(settingsControllerInstance),
        appPreferencesProvider.overrideWith((ref) => preferences.stream),
      ],
    );
    final preferencesSubscription = MockServices.container.listen(
      appPreferencesProvider,
      (_, _) {},
    );
    addTearDown(preferencesSubscription.close);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      MockServices.container.read(appPreferencesProvider).hasValue,
      isTrue,
    );
    MockServices.createWorkout('Rest expiry', null, null);
    final initialSettings = MockServices.container.read(
      settingsControllerProvider,
    );
    await mount(tester, '/workout/simple');
    final countdown = MockServices.container.read(
      countdownControllerProvider.notifier,
    );
    countdown.setCountdown(const Duration(seconds: 2));
    await tester.pump();
    expect(countdown.isActive, isTrue);
    preferences.add(Prefs.defaultValue.copyWith(color: Colors.red));
    await tester.pump();
    expect(
      MockServices.container.read(settingsControllerProvider),
      isNot(same(initialSettings)),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(countdown.isActive, isFalse);
    expect(find.byType(WorkoutSimpleView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('simple workout menu replaces the route with full workout', (
    tester,
  ) async {
    MockServices.createWorkout('Switch view', null, null);
    final router = await mount(tester, '/workout');
    unawaited(router.push<void>('/workout/simple'));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(WorkoutSimpleView));
    final label = context.t.ongoingWorkout.simple.switchToFull;
    await tester.tap(find.byType(PopupMenuButton).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutView), findsOneWidget);
    expect(find.byType(WorkoutSimpleView), findsNothing);
    expect(Go.getTopmostRouteName(), '/workout');
    expect(router.canPop(), isTrue);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutView), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('picker pages and modal dialogs return typed results', (
    tester,
  ) async {
    await mount(tester, '/workout/simple');
    final picked = Go.to<String>(
      () => Scaffold(
        body: Center(
          child: FilledButton(
            key: const Key('pick-result'),
            onPressed: () => Go.back(result: 'selected'),
            child: const Text('Choose'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('pick-result')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(await picked, 'selected');
    final modal = Go.toDialog<int>(
      () => AlertDialog(
        actions: [
          FilledButton(
            key: const Key('dialog-result'),
            onPressed: () => Go.back(result: 7),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('dialog-result')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(await modal, 7);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

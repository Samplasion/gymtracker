import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../test_helpers/widget_test_app.dart';

class _Offline extends Online {
  _Offline() : super(service: TestOnlineServiceImpl());

  @override
  FutureOr<OnlineAccount?> build() => null;
}

class _Notifications extends NotificationController {
  _Notifications() : super(service: NotificationsService());

  late final response = Completer<bool>();
  int requests = 0;
  int alarmRequests = 0;

  @override
  Future<void> requestPermission() async {
    requests++;
    hasPermission = await response.future;
  }

  @override
  Future<void> requestExactAlarmsPermission() async {
    alarmRequests++;
    hasAndroidScheduleExactAlarmPermission = true;
  }
}

class _FoodPermissions extends FoodPermissionsNotifier {
  final requests = <Permission>[];
  late final cameraResponse = Completer<void>();

  @override
  FutureOr<FoodPermissions> build() => (camera: false, gallery: false);

  @override
  Future<void> requestPermission(Permission permission) async {
    requests.add(permission);
    if (permission == Permission.camera) await cameraResponse.future;
  }
}

void main() {
  late _Notifications notifications;
  late _FoodPermissions food;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    notifications = _Notifications()..usesAndroidExactAlarmPermission = true;
    food = _FoodPermissions();
  });

  tearDown(() {
    notifications.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> mount(WidgetTester tester, {int page = 1}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationControllerProvider.overrideWithValue(notifications),
          foodPermissionsProvider.overrideWith(() => food),
          onlineProvider.overrideWith(_Offline.new),
        ],
        child: const WidgetTestApp(child: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .state<IntroductionScreenState>(find.byType(IntroductionScreen))
        .controller
        .jumpToPage(page);
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    debugDefaultTargetPlatformOverride = null;
  }

  int currentPage(WidgetTester tester) => tester
      .state<IntroductionScreenState>(find.byType(IntroductionScreen))
      .getCurrentPage()
      .round();

  Future<void> next(WidgetTester tester) async {
    await tester.tap(
      find.widgetWithText(ElevatedButton, t.onboarding.buttons.next),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Next waits for notifications and immediately explains alarms', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(ElevatedButton), findsOneWidget);
    await next(tester);
    expect(notifications.requests, 1);
    expect(currentPage(tester), 1);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    notifications.response.complete(true);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(
      find.text(t.androidRequestExactAlarmsPermission.title),
      findsOneWidget,
    );
    expect(currentPage(tester), 1);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(notifications.alarmRequests, 1);
    expect(currentPage(tester), 2);
    await unmount(tester);
  });

  testWidgets('denying notifications continues without an alarm prompt', (
    tester,
  ) async {
    await mount(tester);
    await next(tester);
    notifications.response.complete(false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(notifications.alarmRequests, 0);
    expect(find.byType(AlertDialog), findsNothing);
    expect(currentPage(tester), 2);
    await unmount(tester);
  });

  testWidgets('declining the alarm explanation still continues', (
    tester,
  ) async {
    await mount(tester);
    await next(tester);
    notifications.response.complete(true);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(notifications.alarmRequests, 0);
    expect(currentPage(tester), 2);
    await unmount(tester);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'Next requests camera and platform photos sequentially: $platform',
      (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        await mount(tester, page: 2);
        await next(tester);
        expect(food.requests, [Permission.camera]);
        expect(currentPage(tester), 2);
        food.cameraResponse.complete();
        await tester.pump();
        await tester.pumpAndSettle();
        expect(food.requests, [
          Permission.camera,
          if (platform == TargetPlatform.iOS) Permission.photos,
        ]);
        expect(currentPage(tester), 3);
        expect(
          find.widgetWithText(FilledButton, t.login.title),
          findsOneWidget,
        );
        await tester.tap(
          find.widgetWithText(TextButton, t.onboarding.buttons.skip),
        );
        await tester.pumpAndSettle();
        expect(currentPage(tester), 4);
        await unmount(tester);
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';

class _Health extends Mock implements Health {}

class _Plugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(<HealthDataType>[]);
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue((NotificationResponse response) {});
  });

  testWidgets(
    'debug state is isolated and ignores deferred work after disposal',
    (tester) async {
      final first = ProviderContainer();
      final second = ProviderContainer();
      first.read(debugControllerProvider.notifier).toggleSimulator();
      expect(first.read(debugControllerProvider).showSimulator, isTrue);
      expect(second.read(debugControllerProvider).showSimulator, isFalse);
      await tester.pumpWidget(const SizedBox());
      first.read(debugControllerProvider.notifier).addMissingKey('late');
      first.dispose();
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(tester.takeException(), isNull);
      second.dispose();
    },
  );

  test('error handler disposal restores the previously installed handlers', () {
    final previousFlutter = FlutterError.onError;
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final previousPlatform = dispatcher.onError;
    final controller = ErrorController();
    addTearDown(controller.dispose);
    controller.initialize(enabled: true);
    expect(FlutterError.onError, isNot(same(previousFlutter)));
    expect(dispatcher.onError, isNot(same(previousPlatform)));
    controller.dispose();
    expect(FlutterError.onError, same(previousFlutter));
    expect(dispatcher.onError, same(previousPlatform));
  });

  test('health permission result arriving after disposal is ignored', () async {
    final plugin = _Health();
    final permission = Completer<bool?>();
    when(() => plugin.configure()).thenAnswer((_) async {});
    when(
      () => plugin.hasPermissions(any()),
    ).thenAnswer((_) => permission.future);
    final service = HealthController(health: plugin);
    final init = service.init();
    await Future<void>.delayed(Duration.zero);
    await service.dispose();
    permission.complete(false);
    await expectLater(init, completes);
    expect(service.hasPermissionStream.isClosed, isTrue);
  });

  test('native callbacks belong to one scope and are cleared on disposal', () {
    final first = ProviderContainer();
    final native = first.read(nativeServiceProvider);
    native.onMarkSetDone = () {};
    native.onCursorNext = () => true;
    first.dispose();
    expect(native.onMarkSetDone, isNull);
    expect(native.onCursorNext, isNull);
    final second = ProviderContainer();
    final recreated = second.read(nativeServiceProvider);
    expect(identical(native, recreated), isFalse);
    expect(recreated.onMarkSetDone, isNull);
    second.dispose();
  });

  test('unsupported health platforms do not invoke mobile plugins', () async {
    final plugin = _Health();
    final service = HealthController(health: plugin, supported: false);
    await service.init();
    await service.requestPermission();
    verifyNever(() => plugin.configure());
    verifyNever(() => plugin.hasPermissions(any()));
    await service.dispose();
  });

  test('notification provider detaches native callbacks on disposal', () async {
    final plugin = _Plugin();
    final callbacks = <void Function(NotificationResponse)>[];
    when(
      () => plugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((inv) async {
      callbacks.add(
        inv.namedArguments[#onDidReceiveNotificationResponse]
            as void Function(NotificationResponse),
      );
      return true;
    });
    var taps = 0;
    final container = ProviderContainer(
      overrides: [
        notificationsPluginProvider.overrideWithValue(plugin),
        notificationResponseProvider.overrideWithValue((_) {
          taps++;
        }),
      ],
    );
    container.read(notificationsServiceProvider);
    await Future<void>.delayed(Duration.zero);
    const response = NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
    );
    callbacks.single(response);
    expect(taps, 1);
    container.dispose();
    callbacks.single(response);
    expect(taps, 1);
  });

  test(
    'notification reinitialization maintains one internal status listener',
    () async {
      final c = NotificationController(
        service: NotificationsService(plugin: _Plugin()),
        queryPermission: () async => true,
        usesExactAlarms: () async => false,
      );
      final changes = <bool>[];
      final subscription = c.showSettingsTileStream.listen(changes.add);
      await c.initialize();
      await c.initialize();
      await Future<void>.delayed(Duration.zero);
      final before = changes.length;
      c.notifyListeners();
      await Future<void>.delayed(Duration.zero);
      expect(changes.length, before + 1);
      expect(changes.last, isFalse);
      await subscription.cancel();
      c.dispose();
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/intents_controller.dart';
import 'package:gymtracker/controller/migrations_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/view/actions/migrations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Plugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  test(
    'Siri dispatches matching routine arguments and maps failures',
    () async {
      final calls = <String>[];
      final result = await IntentsController.handleStartRoutine(
        {'routineId': 'r', 'routineDisplayName': 'Routine'},
        supported: true,
        start: (id, name) => calls.add('$id:$name'),
      );
      expect(result.success, isTrue);
      expect(calls, ['r:Routine']);
      final invalid = await IntentsController.handleStartRoutine(
        {'routineId': 42},
        supported: true,
        start: (_, _) => fail('Invalid input dispatched'),
      );
      expect(invalid.success, isFalse);
      final failed = await IntentsController.handleStartRoutine(
        {'routineId': 'r', 'routineDisplayName': 'R'},
        supported: true,
        start: (_, _) => throw StateError('unavailable'),
      );
      expect(failed.success, isFalse);
      final unsupported = await IntentsController.handleStartRoutine(
        {},
        supported: false,
        start: (_, _) => fail('Unsupported dispatch'),
      );
      expect(unsupported.success, isFalse);
    },
  );

  testWidgets(
    'migration catalog exposes each existing migration with localized labels',
    (tester) async {
      final c = MockServices.container.read(migrationsControllerProvider);
      await tester.pumpWidget(
        WidgetTestApp(
          child: Builder(
            builder: (context) {
              final migrations = c.getMigrations(context: context);
              expect(migrations, hasLength(5));
              expect(
                migrations.every(
                  (m) => m.title.isNotEmpty && m.description.isNotEmpty,
                ),
                isTrue,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

  testWidgets(
    'framework error from another package is reported without opening an error page',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Home'))),
      );
      ErrorController().sendDetails(
        FlutterErrorDetails(
          exception: StateError('framework'),
          stack: StackTrace.fromString('package:other/widget.dart:1'),
        ),
      );
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'notification initialization publishes denied and granted permission state',
    () async {
      for (final allowed in [false, true]) {
        final plugin = _Plugin();
        final c = NotificationController(
          service: NotificationsService(plugin: plugin),
          queryPermission: () async => allowed,
          usesExactAlarms: () async => false,
        );
        await c.initialize();
        await Future<void>.delayed(Duration.zero);
        expect(c.hasPermission, allowed);
        expect(c.showSettingsTileStream.value, !allowed);
      }
    },
  );

  test(
    'rest notification is scheduled with translated content and canceled by its ID',
    () async {
      final plugin = _Plugin();
      when(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
      when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
      final c = NotificationController(
        service: NotificationsService(plugin: plugin),
      )..hasPermission = true;
      final target = DateTime.now().add(const Duration(minutes: 1));
      c.scheduleRestOverNotification(t, target);
      final call = verify(
        () => plugin.zonedSchedule(
          id: NotificationIDs.restTimer,
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: t.appName,
          body: t.ongoingWorkout.restOver,
        ),
      );
      expect(
        (call.captured.single as tz.TZDateTime).millisecondsSinceEpoch,
        target.millisecondsSinceEpoch,
      );
      c.cancelRestOverNotification();
      verify(() => plugin.cancel(id: NotificationIDs.restTimer)).called(1);
    },
  );

  test(
    'rest notifications are suppressed without permission or for expired targets',
    () {
      final plugin = _Plugin();
      final c = NotificationController(
        service: NotificationsService(plugin: plugin),
      );
      c.scheduleRestOverNotification(
        t,
        DateTime.now().add(const Duration(minutes: 1)),
      );
      c.hasPermission = true;
      c.scheduleRestOverNotification(
        t,
        DateTime.now().subtract(const Duration(seconds: 1)),
      );
      c.usesAndroidExactAlarmPermission = true;
      c.scheduleRestOverNotification(
        t,
        DateTime.now().add(const Duration(minutes: 1)),
      );
      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    },
  );
}

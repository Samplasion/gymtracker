import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/version_resolver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart';

part 'notifications_controller.g.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({
    required this.service,
    Future<bool> Function()? queryPermission,
    Future<bool> Function()? usesExactAlarms,
  }) : _queryPermission = queryPermission,
       _usesExactAlarms = usesExactAlarms;
  final NotificationsService service;
  final Future<bool> Function()? _queryPermission;
  final Future<bool> Function()? _usesExactAlarms;

  Stream<void> get status => _statusSubject.stream;
  final _statusSubject = BehaviorSubject<void>();

  bool hasPermission = false;
  bool usesAndroidExactAlarmPermission = false;
  bool hasAndroidScheduleExactAlarmPermission = false;

  bool get shouldShowAndroidExactAlarmPermissionRequest =>
      hasPermission &&
      usesAndroidExactAlarmPermission &&
      !hasAndroidScheduleExactAlarmPermission;

  final showSettingsTileStream = BehaviorSubject<bool>.seeded(true);

  StreamSubscription<void>? _statusSubscription;
  bool _disposed = false;

  Future<void> initialize() async {
    if (_disposed) return;
    usesAndroidExactAlarmPermission =
        await (_usesExactAlarms?.call() ??
            versionMatches(
              // Android 14
              android: VersionRequirement(min: 34),
            ));
    bool result =
        await service.plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.canScheduleExactNotifications() ??
        true;
    hasAndroidScheduleExactAlarmPermission = result;

    _statusSubscription ??= status.listen((_) {
      logger.i("NotificationController status changed");
      showSettingsTileStream.add(
        !(hasPermission &&
            (!usesAndroidExactAlarmPermission ||
                hasAndroidScheduleExactAlarmPermission)),
      );
    });
    hasPermission = await _getHasPermission();

    logger.i(
      "Has permission: $hasPermission\n"
      "(Android) Uses \"Schedule exact alarms\" permission: $usesAndroidExactAlarmPermission\n"
      "(Android 14+) Has \"Schedule exact alarms\" permission: $hasAndroidScheduleExactAlarmPermission\n",
    );

    notifyListeners();
  }

  Future<bool> _getHasPermission() async {
    if (_queryPermission case final query?) return query();
    // The permission_handler plugin doesn't support macOS
    if (Platform.isMacOS) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()!
          .checkPermissions();
      return perms!.isEnabled;
    } else if (Platform.isIOS) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!
          .checkPermissions();
      return perms!.isEnabled;
    } else if (Platform.isAndroid) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!
          .areNotificationsEnabled();
      return perms ?? true;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  Future<void> requestPermission() async {
    if (hasPermission) return;

    try {
      await Permission.notification.request().then(
        (status) => status.isGranted,
      );
    } on PlatformException catch (e) {
      if (e.code == "ERROR_ALREADY_REQUESTING_PERMISSIONS") {
        logger.i("Permission already being requested.", error: e);
        return;
      }

      rethrow;
    }

    hasPermission = await _getHasPermission();

    notifyListeners();
  }

  Future<void> requestExactAlarmsPermission() async {
    final granted = await service.plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
    if (_disposed) return;
    hasAndroidScheduleExactAlarmPermission = granted ?? false;
    notifyListeners();
  }

  void scheduleRestOverNotification(Translations t, DateTime targetTime) {
    if (!hasPermission) return;
    if (shouldShowAndroidExactAlarmPermissionRequest) return;

    final targetTimeTZ = TZDateTime.from(targetTime, local);
    final now = TZDateTime.now(local);

    if (now.add(const Duration(milliseconds: 500)).isAfter(targetTimeTZ)) {
      logger.i("Rest time is in the past. Not scheduling notification.");
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'org.js.samplasion.gymtracker.RestTimeoutChannel',
      t.androidNotificationChannel.name,
      channelDescription: t.androidNotificationChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: t.ongoingWorkout.restOver,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      macOS: darwinDetails,
      iOS: darwinDetails,
    );
    service.plugin.zonedSchedule(
      id: NotificationIDs.restTimer,
      title: t.appName,
      body: t.ongoingWorkout.restOver,
      scheduledDate: targetTimeTZ,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void cancelRestOverNotification() {
    service.plugin.cancel(id: NotificationIDs.restTimer);
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    _statusSubject.add(null);
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_statusSubscription?.cancel());
    unawaited(_statusSubject.close());
    unawaited(showSettingsTileStream.close());
    super.dispose();
  }
}

typedef NotificationPermissions = ({
  bool hasPermission,
  bool usesExactAlarm,
  bool hasExactAlarmPermission,
  bool showSettingsTile,
});

@Riverpod(keepAlive: true)
NotificationController notificationController(Ref ref) {
  final controller = NotificationController(
    service: ref.watch(notificationsServiceProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
}

@riverpod
Stream<NotificationPermissions> notificationPermissions(Ref ref) {
  final controller = ref.watch(notificationControllerProvider);
  return controller.showSettingsTileStream.map(
    (show) => (
      hasPermission: controller.hasPermission,
      usesExactAlarm: controller.usesAndroidExactAlarmPermission,
      hasExactAlarmPermission:
          controller.hasAndroidScheduleExactAlarmPermission,
      showSettingsTile: show,
    ),
  );
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Translations;
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/version_resolver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart';

class NotificationController extends GetxController implements Listenable {
  final NotificationsService service = Get.find();

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
  Widget get settingsTile {
    return StreamBuilder(
      stream: status,
      builder: (context, __) {
        final hasPermission = !showSettingsTileStream.value;
        if (showSettingsTileStream.value == false) {
          return const SizedBox.shrink();
        }
        if (!hasPermission) {
          return ListTile(
            leading: const Icon(GTIcons.notification_dialog),
            title: Text(context.t.settings.options.notifications.label),
            subtitle: Text(context.t.settings.permissions.tapToRequest),
            onTap: () {
              requestPermission();
            },
          );
        }
        if (shouldShowAndroidExactAlarmPermissionRequest) {
          return ListTile(
            leading: const Icon(GTIcons.notification_dialog),
            title: Text(context.t.settings.options.notifications.label),
            subtitle: Text(
              context
                  .t
                  .settings
                  .options
                  .notifications
                  .subtitle
                  .noExactAlarmPermission,
            ),
            onTap: () {
              androidRequestExactAlarmsPermission();
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> initialize() async {
    usesAndroidExactAlarmPermission = await versionMatches(
      // Android 14
      android: VersionRequirement(min: 34),
    );
    bool result =
        await service.plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.canScheduleExactNotifications() ??
        true;
    hasAndroidScheduleExactAlarmPermission = result;

    status.listen((_) {
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

  Future<void> androidRequestExactAlarmsPermission() async {
    if (!usesAndroidExactAlarmPermission) return;
    if (!hasPermission) {
      logger.i(
        "We don't have notifications permission. "
        "Don't bother asking for exact alarms.",
      );
      return;
    }
    if (hasAndroidScheduleExactAlarmPermission) {
      logger.i("We already have the exact alarms permission.");
      return;
    }

    final shouldAsk = await Go.confirm(
      t.androidRequestExactAlarmsPermission.title,
      t.androidRequestExactAlarmsPermission.message,
      icon: const Icon(GTIcons.notification_dialog),
    );

    if (shouldAsk) {
      final hasPermissionNow = await service.plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();

      hasAndroidScheduleExactAlarmPermission = hasPermissionNow ?? false;
    }

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

  void notifyListeners() {
    _statusSubject.add(null);
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
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

  final showSettingsTileStream = BehaviorSubject<bool>.seeded(true);
  Widget get settingsTile {
    return StreamBuilder(
      stream: status,
      builder: (_, __) {
        final hasPermission = !showSettingsTileStream.value;
        if (showSettingsTileStream.value == false) {
          return const SizedBox.shrink();
        }
        if (!hasPermission) {
          return ListTile(
            leading: const Icon(GymTrackerIcons.notification_dialog),
            title: Text("settings.options.notifications.label".t),
            subtitle: Text("settings.permissions.tapToRequest".t),
            onTap: () {
              requestPermission();
            },
          );
        }
        if (hasPermission &&
            usesAndroidExactAlarmPermission &&
            !hasAndroidScheduleExactAlarmPermission) {
          return ListTile(
            leading: const Icon(GymTrackerIcons.notification_dialog),
            title: Text("settings.options.notifications.label".t),
            subtitle: Text(
                "settings.options.notifications.subtitle.noExactAlarmPermission"
                    .t),
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
    bool result = await service.plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ??
        true;
    hasAndroidScheduleExactAlarmPermission = result;

    status.listen((_) {
      logger.i("NotificationController status changed");
      showSettingsTileStream.add(!(hasPermission &&
          (!usesAndroidExactAlarmPermission ||
              hasAndroidScheduleExactAlarmPermission)));
    });
    hasPermission = await _getHasPermission();

    logger.i("Has permission: $hasPermission\n"
        "(Android) Uses \"Schedule exact alarms\" permission: $usesAndroidExactAlarmPermission\n"
        "(Android 14+) Has \"Schedule exact alarms\" permission: $hasAndroidScheduleExactAlarmPermission\n");

    notifyListeners();
  }

  Future<bool> _getHasPermission() async {
    // The permission_handler plugin doesn't support macOS
    if (Platform.isMacOS) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()!
          .checkPermissions();
      return perms!.isEnabled;
    } else if (Platform.isIOS) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .checkPermissions();
      return perms!.isEnabled;
    } else if (Platform.isAndroid) {
      final perms = await service.plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .areNotificationsEnabled();
      return perms ?? true;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  requestPermission() async {
    if (hasPermission) return;

    await Permission.notification.request().then((status) => status.isGranted);

    hasPermission = await _getHasPermission();

    notifyListeners();
  }

  androidRequestExactAlarmsPermission() async {
    if (!usesAndroidExactAlarmPermission) return;
    if (!hasPermission) {
      logger.i("We don't have notifications permission. "
          "Don't bother asking for exact alarms.");
      return;
    }
    if (hasAndroidScheduleExactAlarmPermission) {
      logger.i("We already have the exact alarms permission.");
      return;
    }

    final shouldAsk = await Go.confirm(
      "androidRequestExactAlarmsPermission.title",
      "androidRequestExactAlarmsPermission.message",
      icon: const Icon(GymTrackerIcons.notification_dialog),
    );

    if (shouldAsk) {
      final hasPermissionNow = await service.plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();

      hasAndroidScheduleExactAlarmPermission = hasPermissionNow ?? false;
    }

    notifyListeners();
  }

  void scheduleRestOverNotification(DateTime targetTime) {
    if (!hasPermission) return;
    if (usesAndroidExactAlarmPermission &&
        !hasAndroidScheduleExactAlarmPermission) return;

    final androidDetails = AndroidNotificationDetails(
      'org.js.samplasion.gymtracker.RestTimeoutChannel',
      'androidNotificationChannel.name'.t,
      channelDescription: 'androidNotificationChannel.description'.t,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ongoingWorkout.restOver'.t,
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
      NotificationIDs.restTimer,
      'appName'.t,
      'ongoingWorkout.restOver'.t,
      TZDateTime.from(targetTime, local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void cancelRestOverNotification() {
    service.plugin.cancel(NotificationIDs.restTimer);
  }

  void notifyListeners() {
    _statusSubject.add(null);
  }
}

import 'package:flutter/material.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';

extension NotificationPresentation on NotificationController {
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
      await requestExactAlarmsPermission();
    }
  }
}

import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/utils/constants.dart';

class CountdownController extends GetxController {
  Rx<DateTime?> targetTime = Rx(null);
  Rx<DateTime?> startingTime = Rx(null);
  Timer? timer;

  FlutterLocalNotificationsPlugin get notificationsPlugin =>
      Get.find<NotificationsService>().plugin;

  bool get isActive => targetTime.value != null && timer != null;
  Duration get remaining =>
      targetTime.value
          ?.add(const Duration(seconds: 1))
          .difference(DateTime.now()) ??
      Duration.zero;
  double get progress {
    try {
      final end = targetTime.value!.millisecondsSinceEpoch;
      final start = startingTime.value!.millisecondsSinceEpoch;
      final now = DateTime.now();

      final diff = end - start;
      return (end - now.millisecondsSinceEpoch) / diff;
    } catch (_) {
      return 0;
    }
  }

  _onUpdate() {
    timer?.cancel();
    if (targetTime.value != null) {
      timer = Timer(targetTime.value!.difference(DateTime.now()), _onRing);
    }
  }

  _onRing() async {
    // Clean up
    timer?.cancel();
    timer = null;
    targetTime.value = null;
    startingTime.value = null;

    // Show notification
    final androidDetails = AndroidNotificationDetails(
      'org.js.samplasion.gymtracker.RestTimeoutChannel',
      'androidNotificationChannel.name'.t,
      channelDescription: 'androidNotificationChannel.description'.t,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'workout.restOver'.t,
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
    notificationsPlugin.show(
      NotificationIDs.restTimer,
      'appName'.t,
      'ongoingWorkout.restOver'.t,
      notificationDetails,
    );
  }

  setCountdown(Duration delta) {
    notificationsPlugin.cancel(NotificationIDs.restTimer);
    final now = DateTime.now();
    startingTime(now);
    targetTime(now.add(delta));
    _onUpdate();
  }

  void removeCountdown() {
    targetTime.value = null;
    startingTime.value = null;
    _onUpdate();
  }

  void add15Seconds() {
    if (targetTime.value != null) {
      targetTime(targetTime()!.add(const Duration(seconds: 15)));
      _onUpdate();
    }
  }

  void subtract15Seconds() {
    if (targetTime.value != null) {
      targetTime(targetTime()!.subtract(const Duration(seconds: 15)));
      _onUpdate();
    }
  }
}

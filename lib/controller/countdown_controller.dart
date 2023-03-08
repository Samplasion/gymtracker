import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class CountdownController extends GetxController {
  Rx<DateTime?> targetTime = Rx(null);
  Rx<DateTime?> startingTime = Rx(null);
  Timer? timer;

  @override
  onInit() {
    super.onInit();

    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('ic_launcher_foreground');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    plugin.initialize(const InitializationSettings(
      android: androidInit,
      macOS: darwinInit,
      iOS: darwinInit,
    ));
  }

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

  _onRing() {
    // Clean up
    timer?.cancel();
    timer = null;
    targetTime.value = null;
    startingTime.value = null;

    // Show notification
    final plugin = FlutterLocalNotificationsPlugin();
    final androidDetails = AndroidNotificationDetails(
      'org.js.samplasion.gymtracker.RestTimeoutChannel',
      'androidNotificationChannel.name'.tr,
      channelDescription: 'androidNotificationChannel.description'.tr,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'workout.restOver'.tr,
    );
    const darwinDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      macOS: darwinDetails,
      iOS: darwinDetails,
    );
    plugin.cancel(0).then((_) {
      plugin.show(
        0,
        'appName'.tr,
        'ongoingWorkout.restOver'.tr,
        notificationDetails,
      );
    });
  }

  setCountdown(Duration delta) {
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

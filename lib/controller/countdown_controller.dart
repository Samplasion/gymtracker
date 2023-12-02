import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../service/notifications.dart';
import '../utils/constants.dart';

class CountdownController extends GetxController {
  ReceivePort receivePort = ReceivePort();
  late SendPort bgnSendPort;

  @override
  onInit() async {
    super.onInit();

    WidgetsFlutterBinding.ensureInitialized();

    await Isolate.spawn<_BGNIsolateConstructor>(
      _backgroundNotificationManager,
      _BGNIsolateConstructor(
        receivePort.sendPort,
        ServicesBinding.rootIsolateToken!,
      ),
    );

    printInfo(info: "Isolate spawned");

    receivePort.listen((message) {
      if (message is SendPort) {
        bgnSendPort = message;
      } else {
        _onBGNServiceRing(message);
      }
    });
  }

  Rx<DateTime?> targetTime = Rx(null);
  Rx<DateTime?> startingTime = Rx(null);
  Timer? timer;

  FlutterLocalNotificationsPlugin get notificationsPlugin =>
      Get.find<NotificationsService>().plugin;

  bool get isActive => targetTime.value != null;
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
    printInfo(
        info: "targetTime: ${targetTime.value}\n"
            "startingTime: ${startingTime.value}\n"
            "remaining: $remaining\n"
            "progress: $progress");
    timer?.cancel();
    if (targetTime.value != null) {
      // timer =
      //     Timer(targetTime.value!.difference(DateTime.now()).abs(), _onRing);

      bgnSendPort.send({
        "type": _BGNMessageType.set,
        "targetTime": targetTime.value,
      });
    }
  }

  _onBGNServiceRing(message) {
    printInfo(
        info: "[Main Isolate] Received message from BGN service: $message");

    _onRing();
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
      'androidNotificationChannel.name'.tr,
      channelDescription: 'androidNotificationChannel.description'.tr,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'workout.restOver'.tr,
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
      'appName'.tr,
      'ongoingWorkout.restOver'.tr,
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

enum _BGNMessageType { set, change, cancel }

class _BGNIsolateConstructor {
  SendPort sendPort;
  RootIsolateToken token;

  _BGNIsolateConstructor(this.sendPort, this.token);
}

void _backgroundNotificationManager(_BGNIsolateConstructor constructor) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(constructor.token);

  ReceivePort bgnReceivePort = ReceivePort();
  constructor.sendPort.send(bgnReceivePort.sendPort);

  DateTime? targetTime;
  Timer? timer;

  ring() {
    print("[BGN Service] Ringing main isolate");

    // Clean up
    timer?.cancel();
    timer = null;
    targetTime = null;

    // Tell main isolate to send notification
    constructor.sendPort.send({
      "type": "ring",
    });
  }

  await for (var message in bgnReceivePort) {
    assert(message is Map &&
        message.containsKey("type") &&
        message["type"] is _BGNMessageType);

    print("[BGN Service] Received message from main isolate: $message");

    final type = message["type"] as _BGNMessageType;
    switch (type) {
      case _BGNMessageType.set:
        assert(message.containsKey("targetTime") &&
            message["targetTime"] is DateTime);
        targetTime = message["targetTime"] as DateTime;
        timer?.cancel();
        timer = Timer(targetTime!.difference(DateTime.now()).abs(), ring);

        break;
      case _BGNMessageType.change:
        assert(message.containsKey("delta") && message["delta"] is Duration);
        assert(targetTime != null);
        targetTime = targetTime?.add(message["delta"] as Duration);
        timer?.cancel();
        timer = Timer(targetTime!.difference(DateTime.now()).abs(), ring);
        break;
      case _BGNMessageType.cancel:
        timer?.cancel();
        timer = null;
        targetTime = null;
        break;
    }
  }
}

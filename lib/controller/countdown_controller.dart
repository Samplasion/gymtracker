import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

class CountdownController extends GetxController {
  Rx<DateTime?> targetTime = Rx(null);
  Rx<DateTime?> startingTime = Rx(null);
  Timer? timer;

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

    // Play sound
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterRingtonePlayer.playNotification(
        asAlarm: true,
      );
    } else {
      SystemSound.play(SystemSoundType.alert);
    }
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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'countdown_controller.g.dart';

/// Injectable time source shared by workout timers and deterministic tests.
class WorkoutClock {
  const WorkoutClock();
  DateTime now() => DateTime.now();
  Timer once(Duration duration, void Function() callback) =>
      Timer(duration, callback);
  Timer periodic(Duration duration, void Function(Timer) callback) =>
      Timer.periodic(duration, callback);
}

final workoutClockProvider = Provider<WorkoutClock>(
  (ref) => const WorkoutClock(),
);

class CountdownState {
  const CountdownState({this.targetTime, this.startingTime});
  final DateTime? targetTime;
  final DateTime? startingTime;
}

@Riverpod(keepAlive: true)
class CountdownController extends _$CountdownController {
  Timer? timer;
  WorkoutClock get clock => ref.read(workoutClockProvider);
  DateTime? get targetTime => state.targetTime;
  DateTime? get startingTime => state.startingTime;
  bool get isActive => targetTime != null && timer != null;
  Duration get remaining =>
      targetTime?.add(const Duration(seconds: 1)).difference(clock.now()) ??
      Duration.zero;
  double get progress {
    if (targetTime == null || startingTime == null) return 0;
    return (targetTime!.millisecondsSinceEpoch -
            clock.now().millisecondsSinceEpoch) /
        (targetTime!.millisecondsSinceEpoch -
            startingTime!.millisecondsSinceEpoch);
  }

  @override
  CountdownState build() {
    ref.onDispose(() {
      timer?.cancel();
      timer = null;
    });
    return const CountdownState();
  }

  void _onUpdate() {
    timer?.cancel();
    timer = null;
    final notifications = ref.read(notificationControllerProvider);
    notifications.cancelRestOverNotification();
    final target = targetTime;
    if (target != null) {
      timer = clock.once(target.difference(clock.now()), _onRing);
      notifications.scheduleRestOverNotification(
        ref.read(translationsProvider),
        target,
      );
    }
  }

  void _onRing() {
    timer?.cancel();
    timer = null;
    state = const CountdownState();
    logger.i('Rest timer finished');
  }

  void restoreCountdown(DateTime start, DateTime end) {
    state = CountdownState(startingTime: start, targetTime: end);
    _onUpdate();
  }

  void setCountdown(Duration delta) {
    final now = clock.now();
    state = CountdownState(startingTime: now, targetTime: now.add(delta));
    _onUpdate();
  }

  void removeCountdown() {
    state = const CountdownState();
    _onUpdate();
  }

  void add15Seconds() => _adjust(const Duration(seconds: 15));
  void subtract15Seconds() => _adjust(const Duration(seconds: -15));
  void _adjust(Duration delta) {
    if (targetTime == null) return;
    state = CountdownState(
      startingTime: startingTime,
      targetTime: targetTime!.add(delta),
    );
    _onUpdate();
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/struct/stopwatch_extended.dart';
import 'package:gymtracker/utils/time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stopwatch_controller.g.dart';

const _globalStopwatchID = "global";

abstract class GTStopwatch {
  DateTime get startingTime;
  String get currentTime;
  Function get onTick;
  bool get isStopped;

  void dispose();
}

class GlobalStopwatch extends GTStopwatch {
  late StopwatchEx stopwatch;
  void Function()? onChanged;
  final DateTime Function() now;

  Duration get currentDuration => stopwatch.elapsed;
  @override
  String get currentTime => encodeTimerDuration(stopwatch.elapsed);
  @override
  DateTime get startingTime => now().subtract(currentDuration);
  @override
  final void Function(Duration duration) onTick;

  @override
  bool isStopped = true;

  GlobalStopwatch({
    required this.onTick,
    DateTime Function()? now,
    StopwatchEx Function(int elapsedMilliseconds)? createStopwatch,
  }) : now = now ?? DateTime.now {
    stopwatch = (createStopwatch ?? StopwatchEx.fromMilliseconds)(0);
    stopwatch.stop();
    stopwatch.reset();
  }

  @override
  void dispose() {
    onTick(now().difference(startingTime));
    stopwatch.stop();
    stopwatch.reset();
  }

  void pause() {
    isStopped = true;
    stopwatch.stop();
    onChanged?.call();
  }

  void start() {
    isStopped = false;
    stopwatch.start();
    onChanged?.call();
  }

  void reset() {
    isStopped = true;
    stopwatch.stop();
    stopwatch.reset();
    onTick(Duration.zero);
    onChanged?.call();
  }
}

typedef TickBinding =
    void Function(Timer timer, Duration duration, String encoded);

class TimeFieldStopwatch extends GTStopwatch {
  @override
  TickBinding onTick;
  void Function()? onChanged;
  final String Function() getCurrentTime;
  final String setID;
  final WorkoutClock clock;
  late final Duration _initialDuration;

  @override
  final DateTime startingTime;
  late Timer timer;
  @override
  late String currentTime;
  @override
  bool get isStopped => !timer.isActive;

  TimeFieldStopwatch({
    required this.onTick,
    required this.setID,
    required this.getCurrentTime,
    this.clock = const WorkoutClock(),
  }) : startingTime = clock.now() {
    currentTime = getCurrentTime();
    _initialDuration = parseTimerDuration(currentTime);
    timer = clock.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
      onChanged?.call();
    });
  }

  void _updateTime() {
    // Callbacks refresh the display; elapsed time also includes suspension.
    final elapsed = _initialDuration + clock.now().difference(startingTime);
    final duration = Duration(seconds: elapsed.inSeconds);
    currentTime = encodeTimerDuration(duration);
    onTick(timer, duration, currentTime);
  }

  @override
  void dispose() {
    _updateTime();
    timer.cancel();
  }
}

class StopwatchState {
  const StopwatchState(
    this.running,
    this.elapsed, {
    this.fieldTimes = const {},
  });
  final Map<String, bool> running;
  final Duration elapsed;
  final Map<String, String> fieldTimes;
}

final workoutStopwatchFactoryProvider =
    Provider<StopwatchEx Function(int elapsedMilliseconds)>(
      (ref) => StopwatchEx.fromMilliseconds,
    );

@Riverpod(keepAlive: true)
class StopwatchController extends _$StopwatchController {
  final Map<String, GTStopwatch> stopwatches = {};
  Timer? _globalTicker;

  @override
  StopwatchState build() {
    stopwatches[_globalStopwatchID] = GlobalStopwatch(
      onTick: (_) {},
      now: ref.read(workoutClockProvider).now,
      createStopwatch: ref.read(workoutStopwatchFactoryProvider),
    );
    globalStopwatch.onChanged = _publish;
    ref.onDispose(() {
      _globalTicker?.cancel();
      for (final stopwatch in stopwatches.values) {
        if (stopwatch is TimeFieldStopwatch) {
          stopwatch.timer.cancel();
        } else if (stopwatch is GlobalStopwatch) {
          stopwatch.stopwatch.stop();
        }
      }
      stopwatches.clear();
    });
    return const StopwatchState({_globalStopwatchID: false}, Duration.zero);
  }

  void _publish() {
    if (!ref.mounted) return;
    if (globalStopwatch.isStopped) {
      _globalTicker?.cancel();
      _globalTicker = null;
    } else {
      _globalTicker ??= ref
          .read(workoutClockProvider)
          .periodic(const Duration(milliseconds: 200), (_) => _publish());
    }
    state = StopwatchState(
      Map.unmodifiable({for (final id in stopwatches.keys) id: isRunning(id)}),
      globalStopwatch.currentDuration,
      fieldTimes: Map.unmodifiable({
        for (final entry in stopwatches.entries)
          if (entry.value is TimeFieldStopwatch)
            entry.key: entry.value.currentTime,
      }),
    );
  }

  void addStopwatch(TimeFieldStopwatch stopwatch) {
    stopwatches[stopwatch.setID]?.dispose();
    stopwatches[stopwatch.setID] = stopwatch;
    stopwatch.onChanged = _publish;
    _publish();
  }

  void removeStopwatch(String setID) {
    if (setID == _globalStopwatchID) {
      return;
    }
    stopwatches[setID]?.dispose();
    stopwatches.remove(setID);
    _publish();
  }

  void removeStopwatches(Iterable<String> setIDs) {
    for (final id in setIDs) {
      removeStopwatch(id);
    }
  }

  bool isRunning(String setID) {
    final stopwatch = stopwatches[setID];
    if (stopwatch == null) return false;
    if (stopwatch is GlobalStopwatch) {
      return !stopwatch.isStopped;
    } else if (stopwatch is TimeFieldStopwatch) {
      return stopwatch.timer.isActive;
    }
    return false;
  }

  void updateBinding(String setID, TickBinding binding) {
    final stopwatch = stopwatches[setID];
    if (stopwatch != null && stopwatch is TimeFieldStopwatch) {
      stopwatch.onTick = binding;
    }
  }

  GlobalStopwatch get globalStopwatch =>
      stopwatches[_globalStopwatchID] as GlobalStopwatch;
}

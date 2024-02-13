import 'dart:async';

import 'package:get/get.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'serviceable_controller.dart';

const _globalStopwatchID = "global";

abstract class GTStopwatch {
  DateTime get startingTime;
  String get currentTime;
  Function get onTick;
  RxBool get isStopped;

  dispose();
}

class GlobalStopwatch extends GTStopwatch {
  late Stopwatch stopwatch;

  Duration get currentDuration => stopwatch.elapsed;
  late Timer timer;
  @override
  String get currentTime => TimeInputField.encodeDuration(stopwatch.elapsed);
  @override
  DateTime get startingTime => DateTime.now().subtract(currentDuration);
  @override
  final void Function(Duration duration) onTick;

  @override
  RxBool isStopped = true.obs;

  GlobalStopwatch({
    required this.onTick,
  }) {
    stopwatch = Stopwatch();
    stopwatch.stop();
    stopwatch.reset();
  }

  @override
  void dispose() {
    onTick(DateTime.now().difference(startingTime));
    timer.cancel();
    stopwatch.stop();
    stopwatch.reset();
  }

  void pause() {
    isStopped.value = true;
    stopwatch.stop();
  }

  void start() {
    isStopped.value = false;
    stopwatch.start();
  }

  void reset() {
    // Intentionally trigger a rebuild by setting isStopped to false and then true
    isStopped.value = false;
    isStopped.value = true;
    stopwatch.stop();
    stopwatch.reset();
    onTick(Duration.zero);
  }
}

typedef TickBinding = void Function(
    Timer timer, Duration duration, String encoded);

class TimeFieldStopwatch extends GTStopwatch {
  @override
  TickBinding onTick;
  final String Function() getCurrentTime;
  final String setID;

  @override
  final DateTime startingTime = DateTime.now();
  late Timer timer;
  @override
  late String currentTime;
  @override
  RxBool get isStopped => RxBool(timer.isActive);

  TimeFieldStopwatch({
    required this.onTick,
    required this.setID,
    required this.getCurrentTime,
  }) {
    currentTime = getCurrentTime();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final parsed = TimeInputField.parseDuration(currentTime);
      final encoded = TimeInputField.encodeDuration(Duration(
        seconds: parsed.inSeconds + 1,
      ));
      currentTime = encoded;
      onTick(timer, parsed, encoded);
    });
  }

  @override
  void dispose() {
    onTick(timer, TimeInputField.parseDuration(currentTime), currentTime);
    timer.cancel();
  }
}

class StopwatchController extends GetxController with ServiceableController {
  final RxMap<String, GTStopwatch> stopwatches = <String, GTStopwatch>{
    _globalStopwatchID: GlobalStopwatch(onTick: (duration) {})..reset(),
  }.obs;

  @override
  void onServiceChange() {
    printInfo(info: "Service changed");
  }

  void addStopwatch(TimeFieldStopwatch stopwatch) {
    stopwatches[stopwatch.setID] = stopwatch;
  }

  void removeStopwatch(String setID) {
    if (setID == _globalStopwatchID) {
      return;
    }
    stopwatches[setID]?.dispose();
    stopwatches.remove(setID);
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
      return !stopwatch.isStopped.value;
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

import 'dart:async';

import 'package:get/get.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'serviceable_controller.dart';

const _globalStopwatchID = "global";

abstract class Stopwatch {
  DateTime get startingTime;
  Timer get timer;
  String get currentTime;
  Function get onTick;

  dispose();
}

class GlobalStopwatch extends Stopwatch {
  Duration currentDuration = Duration.zero;
  @override
  DateTime get startingTime => DateTime.now().subtract(currentDuration);
  @override
  late Timer timer;
  @override
  String get currentTime => TimeInputField.encodeDuration(currentDuration);

  @override
  final void Function(Duration duration) onTick;

  RxBool isStopped = false.obs;

  GlobalStopwatch({
    required this.onTick,
  }) {
    timer = Timer.periodic(const Duration(seconds: 1), _onTickInternal);
  }

  @override
  void dispose() {
    onTick(DateTime.now().difference(startingTime));
    timer.cancel();
  }

  void pause() {
    isStopped.value = true;
    timer.cancel();
  }

  void start() {
    isStopped.value = false;
    if (!timer.isActive) {
      timer = Timer.periodic(const Duration(seconds: 1), _onTickInternal);
    }
  }

  void _onTickInternal(_) {
    currentDuration = currentDuration + const Duration(seconds: 1);
    onTick(currentDuration);
  }

  void reset() {
    // Intentionally trigger a rebuild by setting isStopped to false and then true
    isStopped.value = false;
    isStopped.value = true;
    timer.cancel();
    currentDuration = Duration.zero;
    onTick(Duration.zero);
  }
}

typedef TickBinding = void Function(
    Timer timer, Duration duration, String encoded);

class TimeFieldStopwatch extends Stopwatch {
  @override
  TickBinding onTick;
  final String Function() getCurrentTime;
  final String setID;

  @override
  final DateTime startingTime = DateTime.now();
  @override
  late Timer timer;
  @override
  late String currentTime;

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
  final RxMap<String, Stopwatch> stopwatches = <String, Stopwatch>{
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

  bool isRunning(String setID) => stopwatches[setID]?.timer.isActive ?? false;

  void updateBinding(String setID, TickBinding binding) {
    final stopwatch = stopwatches[setID];
    if (stopwatch != null && stopwatch is TimeFieldStopwatch) {
      stopwatch.onTick = binding;
    }
  }

  GlobalStopwatch get globalStopwatch =>
      stopwatches[_globalStopwatchID] as GlobalStopwatch;
}

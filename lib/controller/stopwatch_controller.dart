import 'dart:async';

import 'package:get/get.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'serviceable_controller.dart';

typedef TickBinding = void Function(
    Timer timer, Duration duration, String encoded);

class TimeFieldStopwatch {
  TickBinding onTick;
  final String Function() getCurrentTime;
  final String setID;

  late Timer timer;
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

  void dispose() {
    onTick(timer, TimeInputField.parseDuration(currentTime), currentTime);
    timer.cancel();
  }
}

class StopwatchController extends GetxController with ServiceableController {
  final RxMap<String, TimeFieldStopwatch> stopwatches =
      <String, TimeFieldStopwatch>{}.obs;

  @override
  void onServiceChange() {
    printInfo(info: "Service changed");
  }

  void addStopwatch(TimeFieldStopwatch stopwatch) {
    stopwatches[stopwatch.setID] = stopwatch;
  }

  void removeStopwatch(String setID) {
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
    if (stopwatch != null) {
      stopwatch.onTick = binding;
    }
  }
}

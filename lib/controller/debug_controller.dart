import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class DebugController extends GetxController {
  RxSet<String> missingKeys = RxSet();
  RxBool showSimulator = false.obs;

  addMissingKey(String key) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      missingKeys.add(key);
    });
  }

  toggleSimulator() => showSimulator.toggle();
  setShowSimulator(bool v) => showSimulator(v);
}

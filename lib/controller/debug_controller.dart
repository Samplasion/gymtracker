import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class DebugController extends GetxController {
  RxSet<String> missingKeys = RxSet();

  addMissingKey(String key) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      missingKeys.add(key);
    });
  }
}

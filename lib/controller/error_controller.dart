import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';

class ErrorController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      sendDetails(details);
      // if (kReleaseMode) exit(1);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      sendError(error, stack);
      return true;
    };
  }

  void sendDetails(FlutterErrorDetails details) {
    Go.to(() => ErrorView(details: details));
  }

  void sendError(Object error, StackTrace stack) {
    Go.to(() => ErrorView(error: error, stack: stack));
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';

class ErrorController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    // FIXME: This is not working
    // FlutterError.onError = (details) {
    //   FlutterError.presentError(details);
    //   sendDetails(details);
    //   // if (kReleaseMode) exit(1);
    // };
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   sendError(error, stack);
    //   return true;
    // };
  }

  void sendDetails(FlutterErrorDetails details) {
    // Ignore errors that are not from the app
    if (details.stack != null &&
        !details.stack!.toString().contains('package:gymtracker')) {
      return;
    }

    Go.to(() => ErrorView(details: details));
  }

  void sendError(Object error, StackTrace stack) {
    Go.to(() => ErrorView(error: error, stack: stack));
  }
}

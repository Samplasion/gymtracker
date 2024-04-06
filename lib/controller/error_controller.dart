import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';

class ErrorController extends GetxController {
  int get loggerErrorMethodCount => 24;

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
    if (Go.getTopmostRouteName() == ErrorView.routeName) {
      logger.d("We are already in ErrorView. Here's the error:");
      logger.i("", error: details.exception, stackTrace: details.stack);
      return;
    }

    // Ignore errors that are not from the app
    if (details.stack != null &&
        !details.stack!.toString().contains('package:gymtracker')) {
      logger.w("We got a framework error:");
      logger.e("", error: details.exception, stackTrace: details.stack);
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.toNamed(
        ErrorView.routeName,
        arguments: _generateRouteArguments(details: details),
      );
    });
  }

  void sendError(Object error, StackTrace stack) {
    if (Go.getTopmostRouteName() == ErrorView.routeName) {
      logger.d("We are already in ErrorView. Here's the error:");
      logger.e("", error: error, stackTrace: stack);
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.toNamed(
        ErrorView.routeName,
        arguments: _generateRouteArguments(error: error, stack: stack),
      );
    });
  }

  ErrorViewArguments _generateRouteArguments({
    FlutterErrorDetails? details,
    Object? error,
    StackTrace? stack,
  }) {
    return ErrorViewArguments(
      details: details,
      error: error,
      stack: stack,
    );
  }

  void dumpError(ErrorViewArguments args) {
    if (args.details != null) {
      logger.e("",
          error: args.details!.exception, stackTrace: args.details!.stack);
    } else {
      logger.e("", error: args.error, stackTrace: args.stack);
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorController extends GetxController {
  int get loggerErrorMethodCount => 24;

  @override
  void onInit() {
    super.onInit();

    if (TestService().isTest) return;

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
    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
      withScope: (scope) {
        if (details.context != null) {
          scope.setExtra('context', details.context.toString());
        }
        if (details.library != null) {
          scope.setExtra('library', details.library!);
        }
      },
    );

    if (Go.getTopmostRouteName() == ErrorView.routeName) {
      logger.i("We are already in ErrorView. Here's the error:");
      logger.w("", error: details.exception, stackTrace: details.stack);
      return;
    }

    // Ignore errors that are not from the app
    if (details.stack != null &&
        !details.stack!.toString().contains('package:gymtracker')) {
      logger.w(
        "We got a framework error:",
        error: details.exception,
        stackTrace: details.stack,
      );
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
    Sentry.captureException(
      error,
      stackTrace: stack,
    );
    if (Go.getTopmostRouteName() == ErrorView.routeName) {
      logger.w(
        "We are already in ErrorView. Here's the error:",
        error: error,
        stackTrace: stack,
      );
      return;
    }

    if (ignoreError(error)) {
      logger.w("Ignoring error", error: error);
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
    return ErrorViewArguments(details: details, error: error, stack: stack);
  }

  void dumpError(ErrorViewArguments args) {
    if (args.details != null) {
      logger.e(
        "",
        error: args.details!.exception,
        stackTrace: args.details!.stack,
      );
      print(args.details!.stack);
    } else {
      logger.e("", error: args.error, stackTrace: args.stack);
      print(args.stack);
    }
  }

  bool ignoreError(Object error) {
    if (error is AuthRetryableFetchException) {
      // No Internet connection: ignore error
      return [
        "WebSocketChannelException",
        "ClientException with SocketException",
        "Connection closed before full header was received",
        "Connection terminated during handshake",
      ].any((string) => error.message.contains(string));
    }
    // Sometimes Flutter + riverpod is just quirky like that
    if (error.toString().contains(
      "setState() or markNeedsBuild() called during build",
    )) {
      return true;
    }
    return false;
  }
}

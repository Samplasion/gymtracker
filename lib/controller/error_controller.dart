import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/service/error_reporter.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'error_controller.g.dart';

class ErrorController {
  ErrorController({ErrorReporter? reporter})
    : _reporter = reporter ?? ErrorReporter();
  final ErrorReporter _reporter;
  FlutterExceptionHandler? _previousFlutter;
  bool Function(Object, StackTrace)? _previousPlatform;
  FlutterExceptionHandler? _flutterHandler;
  bool Function(Object, StackTrace)? _platformHandler;
  bool _disposed = false;
  bool _installed = false;
  int get loggerErrorMethodCount => 24;

  void initialize({bool? enabled}) {
    if (_installed || _disposed || !(enabled ?? !TestService().isTest)) return;
    _installed = true;
    _previousFlutter = FlutterError.onError;
    _previousPlatform = PlatformDispatcher.instance.onError;
    _flutterHandler = (details) {
      FlutterError.presentError(details);
      sendDetails(details);
      // if (kReleaseMode) exit(1);
    };
    _platformHandler = (error, stack) {
      sendError(error, stack);
      return true;
    };
    FlutterError.onError = _flutterHandler;
    PlatformDispatcher.instance.onError = _platformHandler;
  }

  void dispose() {
    _disposed = true;
    if (!_installed) return;
    if (identical(FlutterError.onError, _flutterHandler)) {
      FlutterError.onError = _previousFlutter;
    }
    if (identical(PlatformDispatcher.instance.onError, _platformHandler)) {
      PlatformDispatcher.instance.onError = _previousPlatform;
    }
    _installed = false;
  }

  void sendDetails(FlutterErrorDetails details) {
    if (_disposed) return;
    _reporter.report(
      details.exception,
      details.stack,
      context: details.context?.toString(),
      library: details.library,
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
      if (_disposed) return;
      Go.toNamed(
        ErrorView.routeName,
        arguments: _generateRouteArguments(details: details),
      );
    });
  }

  void sendError(Object error, StackTrace stack) {
    if (_disposed) return;
    _reporter.report(error, stack);
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
      if (_disposed) return;
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

@Riverpod(keepAlive: true)
ErrorController errorController(Ref ref) {
  final controller = ErrorController(
    reporter: ref.watch(errorReporterProvider),
  );
  controller.initialize();
  ref.onDispose(controller.dispose);
  return controller;
}

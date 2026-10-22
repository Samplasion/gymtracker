import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'error_reporter.g.dart';

class ErrorReporter {
  Future<void> report(
    Object error,
    StackTrace? stack, {
    String? context,
    String? library,
  }) async {
    await Sentry.captureException(
      error,
      stackTrace: stack,
      withScope: (scope) {
        // Preserve the existing telemetry fields during this migration.
        if (context != null) {
          // ignore: deprecated_member_use
          scope.setExtra('context', context);
        }
        if (library != null) {
          // ignore: deprecated_member_use
          scope.setExtra('library', library);
        }
      },
    );
  }
}

@Riverpod(keepAlive: true)
ErrorReporter errorReporter(Ref ref) => ErrorReporter();

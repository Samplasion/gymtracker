import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart';

LoggerController? get loggerController =>
    Get.isRegistered<LoggerController>() ? Get.find<LoggerController>() : null;

class AnsiColor {
  final String _code;
  const AnsiColor([this._code = '']);
  const AnsiColor.fg(int code) : _code = '\x1B[38;5;${code}m';
  const AnsiColor.none() : _code = '';

  String call(String text) {
    if (_code.isEmpty) return text;
    return '$_code$text\x1B[0m';
  }
}

final Map<Level, AnsiColor> levelColors = {
  Level.FINEST: const AnsiColor.fg(244),
  Level.FINER: const AnsiColor.fg(244),
  Level.FINE: const AnsiColor.fg(73),
  Level.CONFIG: const AnsiColor.fg(73),
  Level.INFO: const AnsiColor.fg(12),
  Level.WARNING: const AnsiColor.fg(208),
  Level.SEVERE: const AnsiColor.fg(196),
  Level.SHOUT: const AnsiColor.fg(199),
};

String _formatLevelPrefix(Level level) {
  if (level == Level.FINEST || level == Level.FINER) return '[TRACE]';
  if (level == Level.FINE || level == Level.CONFIG) return '[DEBUG]';
  if (level == Level.INFO) return '[INFO]';
  if (level == Level.WARNING) return '[WARN]';
  if (level == Level.SEVERE) return '[ERROR]';
  if (level == Level.SHOUT) return '[FATAL]';
  return '[${level.name}]';
}

void _logToConsole(LogRecord record) {
  final useColors = !Platform.isIOS;
  final color = useColors
      ? (levelColors[record.level] ?? const AnsiColor.none())
      : const AnsiColor.none();
  final prefix = _formatLevelPrefix(record.level).padLeft(7);
  final coloredPrefix = color(prefix);
  final timeStr = record.time.toIso8601String();
  final loggerName =
      record.loggerName.isNotEmpty ? ' [${record.loggerName}]' : '';

  final buffer =
      StringBuffer('$coloredPrefix [$timeStr]$loggerName ${record.message}');
  if (record.error != null) {
    buffer.write('\n$coloredPrefix Error: ${record.error}');
  }
  // Console output intentionally omits stack traces per configuration.
  print(buffer.toString());
}

StreamSubscription<LogRecord>? _logSubscription;

void initLogger() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;

  _logSubscription?.cancel();
  _logSubscription = Logger.root.onRecord.listen((record) {
    _logToConsole(record);
    loggerController?.addLogFromRecord(record);
  });
}

final globalLogger = Logger('Gym Bro');

extension LoggerShorthands on Logger {
  void t(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.FINEST, message, error, stackTrace);
  }

  void d(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.FINE, message, error, stackTrace);
  }

  void i(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.INFO, message, error, stackTrace);
  }

  void w(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.WARNING, message, error, stackTrace);
  }

  void e(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.SEVERE, message, error, stackTrace);
  }

  void f(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.SHOUT, message, error, stackTrace);
  }

  void trace(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) => t(message, time: time, error: error, stackTrace: stackTrace);

  void debug(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) => d(message, time: time, error: error, stackTrace: stackTrace);

  void error(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) => e(message, time: time, error: error, stackTrace: stackTrace);

  void fatal(
    Object? message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) => f(message, time: time, error: error, stackTrace: stackTrace);
}

mixin LoggerConfigurationMixin on Object {
  int get loggerErrorMethodCount => 8;
  int get loggerMethodCount => 4;
}

extension ObjectLoggerExt on Object {
  Logger get logger => Logger(runtimeType.toString());
}

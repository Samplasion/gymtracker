import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:logger/logger.dart';

void initLogger() {
  Logger.level = kDebugMode ? Level.debug : Level.warning;
}

LoggerController? get loggerController =>
    Get.isRegistered<LoggerController>() ? Get.find<LoggerController>() : null;

Map<Level, AnsiColor> get levelColors => {
      Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
      Level.debug: const AnsiColor.fg(73),
      Level.info: const AnsiColor.fg(12),
      Level.warning: const AnsiColor.fg(208),
      Level.error: const AnsiColor.fg(196),
      Level.fatal: const AnsiColor.fg(199),
    };

OneLinePrefixPrinter get _oneLinePrefixPrinter => OneLinePrefixPrinter(
      printer: PrettyPrinter(
        printEmojis: false,
        colors: !Platform.isIOS,
        lineLength: 80,
        noBoxingByDefault: true,
        methodCount: 0,
        levelColors: levelColors,
      ),
      levels: {
        Level.trace: '[TRACE]',
        Level.debug: '[DEBUG]',
        Level.info: '[INFO]',
        Level.warning: '[WARN]',
        Level.error: '[ERROR]',
        Level.fatal: '[FATAL]',
      },
      levelColors: levelColors,
    );

class GlobalControllerOutput extends LogOutput {
  final parent = ConsoleOutput();

  LoggerController? get loggerController => Get.isRegistered<LoggerController>()
      ? Get.find<LoggerController>()
      : null;

  @override
  void output(OutputEvent event) {
    loggerController?.addLog(Log(
      message: event.origin.message,
      timestamp: event.origin.time,
      level: event.origin.level,
      object: null,
      error: event.origin.error,
      stackTrace: event.origin.stackTrace,
    ));
    parent.output(event);
  }
}

final globalLogger =
    Logger(printer: _oneLinePrefixPrinter, output: GlobalControllerOutput());

class OneLinePrefixPrinter extends LogPrinter {
  final PrettyPrinter printer;
  final Map<Level, String> levels;
  final Map<Level, AnsiColor> levelColors;

  OneLinePrefixPrinter({
    required this.printer,
    required this.levels,
    required this.levelColors,
  });

  List<String> _prefix(List<String> lines, Level level) {
    var color = levelColors[level] ?? const AnsiColor.none();

    if (!printer.colors) {
      color = const AnsiColor.none();
    }

    final maxPrefixLength =
        levels.values.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    final prefix = (levels[level] ?? "[UNK]").padLeft(maxPrefixLength);
    lines[0] = "${color(prefix)} ${lines[0]}";
    for (int i = 1; i < lines.length; i++) {
      lines[i] = "${" " * (maxPrefixLength)} ${color(lines[i])}";
    }

    return lines;
  }

  List<String>? _formatStackTrace(List<String>? currentString) {
    if (currentString == null) return null;

    currentString = currentString
        .where((line) => !line.contains("/service/logger.dart"))
        .toList();

    final result = <String>[];

    final parseRegex = RegExp(r'^#\d+   (.+)$', multiLine: true);
    int count = 0;
    for (final match in parseRegex.allMatches(currentString.join("\n"))) {
      result.add("#${count++}   ${match[1]}");
    }

    return result;
  }

  @override
  List<String> log(LogEvent event) {
    final lines = printer.log(event);

    final stack = _formatStackTrace(printer
        .formatStackTrace(event.stackTrace ?? StackTrace.current, 4)
        ?.trim()
        .split("\n"));
    if (stack != null && stack.isNotEmpty) {
      lines.addAll([
        "",
        ...stack,
      ]);
    }

    return _prefix(lines, event.level);
  }

  copyWith({
    PrettyPrinter? printer,
    Map<Level, String>? levels,
    Map<Level, AnsiColor>? levelColors,
  }) {
    return OneLinePrefixPrinter(
      printer: printer ?? this.printer,
      levels: levels ?? this.levels,
      levelColors: levelColors ?? this.levelColors,
    );
  }
}

class ObjectLogger<T> extends Logger {
  final T _obj;

  ObjectLogger(
    this._obj, {
    super.filter,
    super.printer,
    super.output,
    super.level,
  });

  @override
  void log(Level level, message,
      {DateTime? time, Object? error, StackTrace? stackTrace}) {
    super.log(
      level,
      "[${_obj.runtimeType}] $_obj\n$message".trim(),
      time: time,
      error: error,
      stackTrace: stackTrace,
    );

    loggerController?.addLog(Log(
      message: message.toString(),
      timestamp: time ?? DateTime.now(),
      object: _obj,
      level: level,
      error: error,
      stackTrace: stackTrace,
    ));
  }
}

extension ObjectLoggerExt on Object {
  Logger get logger => ObjectLogger(
        this,
        printer: _oneLinePrefixPrinter.copyWith(
          printer: _oneLinePrefixPrinter.printer
              .copyWith(errorMethodCount: loggerErrorMethodCount),
        ),
      );

  int get loggerErrorMethodCount => 8;
}

extension on PrettyPrinter {
  PrettyPrinter copyWith({
    int? errorMethodCount,
  }) {
    return PrettyPrinter(
      errorMethodCount: errorMethodCount ?? this.errorMethodCount,
      printEmojis: printEmojis,
      colors: colors,
      lineLength: lineLength,
      noBoxingByDefault: noBoxingByDefault,
      methodCount: methodCount,
      levelColors: levelColors,
    );
  }
}

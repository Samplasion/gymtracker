import 'dart:io';

import 'package:get/get.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:logger/logger.dart';

LoggerController get loggerController => Get.find<LoggerController>();

Map<Level, AnsiColor> get levelColors => {
      Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
      Level.debug: const AnsiColor.fg(73),
      Level.info: const AnsiColor.fg(12),
      Level.warning: const AnsiColor.fg(208),
      Level.error: const AnsiColor.fg(196),
      Level.fatal: const AnsiColor.fg(199),
    };

final _oneLinePrefixPrinter = OneLinePrefixPrinter(
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

  @override
  List<String> log(LogEvent event) {
    final lines = printer.log(event);
    var color = levelColors[event.level] ?? const AnsiColor.none();

    if (!printer.colors) {
      color = const AnsiColor.none();
    }

    final maxPrefixLength =
        levels.values.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    final prefix = (levels[event.level] ?? "[UNK]").padLeft(maxPrefixLength);
    lines[0] = "${color(prefix)} ${lines[0]}";
    for (int i = 1; i < lines.length; i++) {
      lines[i] = "${" " * (maxPrefixLength)} ${lines[i]}";
    }
    return lines;
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

    loggerController.addLog(Log(
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

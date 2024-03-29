import 'package:logger/logger.dart';

Map<Level, AnsiColor> get _levelColors => {
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
    colors: true,
    lineLength: 80,
    noBoxingByDefault: true,
    methodCount: 0,
    levelColors: _levelColors,
  ),
  levels: {
    Level.trace: '[TRACE]',
    Level.debug: '[DEBUG]',
    Level.info: '[INFO]',
    Level.warning: '[WARN]',
    Level.error: '[ERROR]',
    Level.fatal: '[FATAL]',
  },
  levelColors: _levelColors,
);

final globalLogger = Logger(printer: _oneLinePrefixPrinter);

class OneLinePrefixPrinter extends LogPrinter {
  final LogPrinter printer;
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
    final color = levelColors[event.level] ?? const AnsiColor.none();

    final maxPrefixLength =
        levels.values.map((e) => e.length).reduce((a, b) => a > b ? a : b);
    final prefix = (levels[event.level] ?? "[UNK]").padLeft(maxPrefixLength);
    lines[0] = "${color(prefix)} ${lines[0]}";
    for (int i = 1; i < lines.length; i++) {
      lines[i] = "${" " * (maxPrefixLength)} ${lines[i]}";
    }
    return lines;
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
  }
}

extension ObjectLoggerExt on Object {
  Logger get logger => ObjectLogger(this, printer: _oneLinePrefixPrinter);
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class Log {
  final dynamic message;
  final DateTime timestamp;
  final Level level;
  final Object? object;
  final Object? error;
  final StackTrace? stackTrace;

  Color get color => level.color;

  Log({
    required this.message,
    required this.timestamp,
    required this.level,
    required this.object,
    this.error,
    this.stackTrace,
  });
}

extension LevelExt on Level {
  String get displayName {
    return switch (this) {
      Level.all => 'All',
      Level.trace => 'Trace',
      Level.debug => 'Debug',
      Level.info => 'Info',
      Level.warning => 'Warning',
      Level.error => 'Error',
      Level.fatal => 'Fatal',
      Level.off => 'Off',
      _ => "DON'T USE THIS LEVEL",
    };
  }

  String get shortName {
    return switch (this) {
      Level.trace => 'TRC',
      Level.debug => 'DBG',
      Level.info => 'NFO',
      Level.warning => 'WRN',
      Level.error => 'ERR',
      Level.fatal => 'FTL',
      _ => "XXX",
    };
  }

  Color get color {
    return switch (this) {
      Level.trace => Colors.grey,
      Level.debug => Colors.cyan,
      Level.info => Colors.blue,
      Level.warning => Colors.orange,
      Level.error => Colors.red,
      Level.fatal => Colors.redAccent,
      _ => Colors.black,
    };
  }
}

const availableLevels = [
  if (kDebugMode) ...[
    Level.trace,
    Level.debug,
    Level.info,
  ],
  Level.warning,
  Level.error,
  Level.fatal,
];

class LoggerController extends GetxController {
  // Whether to show the logger pane in the bottom nav bar
  static const shouldShowPane =
      kDebugMode || bool.hasEnvironment('SHOW_LOGGER_PANE');
  static const keptLogs = shouldShowPane ? 500 : 50;

  Stream get onLogsUpdated => _onLogsUpdatedSubject.stream;
  final _onLogsUpdatedSubject = BehaviorSubject();

  final List<Log> logs = [];

  Level level = kDebugMode ? Level.debug : Level.warning;

  List<Log> get filteredLogs {
    return logs.where((log) => log.level.value >= level.value).toList();
  }

  addLog(Log log) {
    logs.add(log);
    if (logs.length > keptLogs) {
      logs.removeRange(0, logs.length - keptLogs);
    }
    _onLogsUpdatedSubject.add(null);
    update();
  }

  showLevelRadioModal() {
    Go.showRadioModal(
      selectedValue: level,
      values: {
        for (final lvl in availableLevels)
          lvl: "settings.advanced.options.logs.levels.${lvl.name}".t,
      },
      title: Text("settings.advanced.options.logs.level".t),
      onChange: (newLevel) {
        if (newLevel == null) return;
        level = newLevel;
        _onLogsUpdatedSubject.add(null);
        update();
      },
    );
  }

  clearLogs() {
    logs.clear();
    _onLogsUpdatedSubject.add(null);
    update();
  }

  void shareLogs() {
    final logs = filteredLogs;
    final maxLevelLength = logs
        .map((log) => log.level.displayName.length)
        .reduce((value, element) => value > element ? value : element);
    final logsString = logs.map((log) {
      final timestamp = log.timestamp.toIso8601String();
      final level = log.level.displayName.toUpperCase();
      final message = log.message;
      final object = log.object;
      final error = log.error;
      final stackTrace = log.stackTrace;
      final errorString = "${error ?? ""}\n\n${stackTrace ?? ""}".trim();
      final firstLine = "${" " * (maxLevelLength - level.length)}[$level] ";
      return "$firstLine$timestamp $object\n${" " * firstLine.length}$message\n\n$errorString"
          .trimRight();
    }).join('\n\n${"=" * (maxLevelLength + 2)}\n\n');

    if (logsString.isEmpty) return;
    shareText(logsString);
  }

  void dumpAllLevels() {
    if (!kDebugMode) return;
    for (final lvl in availableLevels) {
      logger.log(
          lvl, "This is an example ${lvl.displayName.toLowerCase()} message");
    }
  }
}

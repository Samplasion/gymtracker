import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class Log {
  final dynamic message;
  final DateTime timestamp;
  final Level level;
  final String loggerName;
  final Object? error;
  final StackTrace? stackTrace;

  Color get color => level.color;

  Log({
    required this.message,
    required this.timestamp,
    required this.level,
    required this.loggerName,
    this.error,
    this.stackTrace,
  });

  Object? get object => loggerName;
}

extension LevelExt on Level {
  String get displayName {
    if (this == Level.ALL) return 'All';
    if (this == Level.FINEST || this == Level.FINER) return 'Trace';
    if (this == Level.FINE || this == Level.CONFIG) return 'Debug';
    if (this == Level.INFO) return 'Info';
    if (this == Level.WARNING) return 'Warning';
    if (this == Level.SEVERE) return 'Error';
    if (this == Level.SHOUT) return 'Fatal';
    if (this == Level.OFF) return 'Off';
    return name;
  }

  String get shortName {
    if (this == Level.FINEST || this == Level.FINER) return 'TRC';
    if (this == Level.FINE || this == Level.CONFIG) return 'DBG';
    if (this == Level.INFO) return 'NFO';
    if (this == Level.WARNING) return 'WRN';
    if (this == Level.SEVERE) return 'ERR';
    if (this == Level.SHOUT) return 'FTL';
    return 'XXX';
  }

  Color get color {
    if (this == Level.FINEST || this == Level.FINER) return Colors.grey;
    if (this == Level.FINE || this == Level.CONFIG) return Colors.cyan;
    if (this == Level.INFO) return Colors.blue;
    if (this == Level.WARNING) return Colors.orange;
    if (this == Level.SEVERE) return Colors.red;
    if (this == Level.SHOUT) return Colors.redAccent;
    return Colors.black;
  }

  String get translationKey {
    if (this == Level.FINEST || this == Level.FINER) return 'trace';
    if (this == Level.FINE || this == Level.CONFIG) return 'debug';
    if (this == Level.INFO) return 'info';
    if (this == Level.WARNING) return 'warning';
    if (this == Level.SEVERE) return 'error';
    if (this == Level.SHOUT) return 'fatal';
    return name.toLowerCase();
  }
}

const availableLevels = [
  if (kDebugMode) ...[Level.FINEST, Level.FINE],
  Level.INFO,
  Level.WARNING,
  Level.SEVERE,
  Level.SHOUT,
];

class LoggerController extends GetxController {
  // Whether to show the logger pane in the bottom nav bar
  static const shouldShowPane =
      kDebugMode || bool.hasEnvironment('SHOW_LOGGER_PANE');
  static const keptLogs = shouldShowPane ? 500 : 100;

  Stream get onLogsUpdated => _onLogsUpdatedSubject.stream;
  final _onLogsUpdatedSubject = BehaviorSubject();

  final List<Log> logs = [];

  Level level = kDebugMode ? Level.FINE : Level.INFO;

  List<Log> get filteredLogs {
    return logs.where((log) => log.level.value >= level.value).toList();
  }

  void addLogFromRecord(LogRecord record) {
    addLog(
      Log(
        message: record.message,
        timestamp: record.time,
        level: record.level,
        loggerName: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      ),
    );
  }

  void addLog(Log log) {
    logs.add(log);
    if (logs.length > keptLogs) {
      logs.removeRange(0, logs.length - keptLogs);
    }
    _onLogsUpdatedSubject.add(null);
    update();
  }

  void showLevelRadioModal() {
    Go.showRadioModal(
      selectedValue: level,
      values: {
        for (final lvl in availableLevels)
          lvl: "settings.advanced.options.logs.levels.${lvl.translationKey}".t,
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

  void clearLogs() {
    logs.clear();
    _onLogsUpdatedSubject.add(null);
    update();
  }

  void shareLogs() {
    final logs = filteredLogs;
    if (logs.isEmpty) return;

    final maxLevelLength = logs
        .map((log) => log.level.displayName.length)
        .reduce((value, element) => value > element ? value : element);
    final logsString = logs
        .map((log) {
          final timestamp = log.timestamp.toIso8601String();
          final level = log.level.displayName.toUpperCase();
          final message = log.message;
          final loggerName = log.loggerName;
          final error = log.error;
          final stackTrace = log.stackTrace;
          final errorString = "${error ?? ""}\n\n${stackTrace ?? ""}".trim();
          final firstLine =
              "${" " * (maxLevelLength - level.length)}[$level] ";
          return "$firstLine$timestamp $loggerName\n${" " * firstLine.length}$message\n\n$errorString"
              .trimRight();
        })
        .join('\n\n${"=" * (maxLevelLength + 2)}\n\n');

    if (logsString.isEmpty) return;
    shareText(logsString);
  }

  void dumpAllLevels() {
    if (!kDebugMode) return;
    for (final lvl in availableLevels) {
      logger.log(
        lvl,
        "This is an example ${lvl.displayName.toLowerCase()} message",
      );
    }
  }

  String _stringifyLog(Log log) {
    final timestamp = log.timestamp.toIso8601String();
    final level = log.level.displayName.toUpperCase();
    final message = log.message;
    final loggerName = log.loggerName;
    final error = log.error;
    final stackTrace = log.stackTrace;
    final errorString = "${error ?? ""}\n\n${stackTrace ?? ""}".trim();
    final firstLine = "[$level] ";
    return "$firstLine$timestamp $loggerName\n${" " * firstLine.length}$message\n\n$errorString"
        .trimRight();
  }
}

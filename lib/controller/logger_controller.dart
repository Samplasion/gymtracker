import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/go.dart';
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

class LoggerController extends GetxController {
  static const shouldShowPane =
      kDebugMode || bool.hasEnvironment('SHOW_LOGGER_PANE');

  Stream get onLogsUpdated => _onLogsUpdatedSubject.stream;
  final _onLogsUpdatedSubject = BehaviorSubject();

  final List<Log> logs = [];

  Level level = Level.debug;

  List<Log> get filteredLogs {
    return logs.where((log) => log.level.value >= level.value).toList();
  }

  addLog(Log log) {
    // This has the potential to be a huge memory burden
    // So don't keep logs around if we're not showing the pane
    if (!shouldShowPane) return;

    logs.add(log);
    _onLogsUpdatedSubject.add(log);
    update();
  }

  showLevelRadioModal() {
    Go.showRadioModal(
      selectedValue: level,
      values: {
        for (final lvl in Level.values)
          // ignore: deprecated_member_use
          if (lvl != Level.nothing && lvl != Level.verbose && lvl != Level.wtf)
            lvl: lvl.displayName,
      },
      title: const Text("Level"),
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
}

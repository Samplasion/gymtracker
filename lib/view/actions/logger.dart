import 'package:flutter/material.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';

extension LoggerPresentation on LoggerController {
  void showLevelRadioModal(Translations t) {
    Go.showRadioModal(
      selectedValue: level,
      values: {
        for (final lvl in availableLevels)
          lvl:
              t.settings.advanced.options.logs.levels[lvl.translationKey] ??
              "UNKNOWN",
      },
      title: Text(t.settings.advanced.options.logs.level),
      onChange: (newLevel) {
        if (newLevel == null) return;
        level = newLevel;
      },
    );
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
          final firstLine = "${" " * (maxLevelLength - level.length)}[$level] ";
          return "$firstLine$timestamp $loggerName\n${" " * firstLine.length}$message\n\n$errorString"
              .trimRight();
        })
        .join('\n\n${"=" * (maxLevelLength + 2)}\n\n');

    if (logsString.isEmpty) return;
    shareText(logsString);
  }
}

import 'dart:io';

import 'package:gymtracker/service/logger.dart';
import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.gymtrackerwidget';
const String iOSWidgetName = 'Widgets';
const String androidWidgetName = 'org.js.samplasion.gymtracker.StreakWidget';

final isSupported = Platform.isIOS || Platform.isAndroid;

abstract class WidgetsService {
  static WidgetsService instance() {
    if (isSupported) {
      return _WidgetsService();
    } else {
      return _WidgetsServiceUnsupported();
    }
  }

  updateWeeklyStreak(int streak);
}

class _WidgetsService extends WidgetsService {
  static final _WidgetsService _instance = _WidgetsService._internal();
  factory _WidgetsService() => _instance;
  _WidgetsService._internal() {
    HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  updateWeeklyStreak(int streak) {
    HomeWidget.saveWidgetData<int>("weekly_streak", streak);
    _update();
  }

  _update() {
    try {
      HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        qualifiedAndroidName: androidWidgetName,
      );
    } catch (e) {
      logger.e(e);
    }
  }
}

class _WidgetsServiceUnsupported extends WidgetsService {
  @override
  updateWeeklyStreak(int streak) {}
}

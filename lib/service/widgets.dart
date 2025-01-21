import 'dart:io';

import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.gymtrackerwidget';
const String iOSWidgetName = 'Widgets';
const String androidWidgetName = 'Widget';

final isSupported = Platform.isIOS || Platform.isAndroid;

class WidgetsService {
  static WidgetsService instance() {
    if (isSupported) {
      return _WidgetsService();
    } else {
      return _WidgetsServiceUnsupported();
    }
  }

  updateWeeklyStreak(int streak) {}
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
    HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
}

class _WidgetsServiceUnsupported extends WidgetsService {
  @override
  updateWeeklyStreak(int streak) {}
}

import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.gymtrackerwidget';
const String iOSWidgetName = 'Widgets';
const String androidWidgetName = 'Widget';

class WidgetsService {
  static final WidgetsService _instance = WidgetsService._internal();
  factory WidgetsService() => _instance;
  WidgetsService._internal() {
    HomeWidget.setAppGroupId(appGroupId);
  }

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

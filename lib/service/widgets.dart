import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.samplasion.gymtracker';
const iOSWidgetName = [
  'GymBroWidgets',
  'GymBroWidgetsRest',
  'GymBroWidgetsTotal'
];
const String androidWidgetName = 'org.js.samplasion.gymtracker.StreakWidget';

const streakKey = "weekly_streak";
const restKey = "daily_rest_streak_since";
const totalWorkoutsKey = "total_workouts";
const workoutDensityKey = "workout_density_chart_data";

final isSupported = Platform.isIOS || Platform.isAndroid;

abstract class WidgetsService {
  static WidgetsService instance() {
    if (isSupported) {
      return _WidgetsService();
    } else {
      return _WidgetsServiceUnsupported();
    }
  }

  Future<void> updateWeeklyStreak(int streak);
  Future<void> updateRestStreak(int streak);
  Future<void> updateWorkouts(int total);
}

class _WidgetsService extends WidgetsService {
  static final _WidgetsService _instance = _WidgetsService._internal();
  factory _WidgetsService() => _instance;
  _WidgetsService._internal() {
    HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  updateWeeklyStreak(int streak) async {
    await HomeWidget.saveWidgetData<int>("weekly_streak", streak);
    _update();
  }

  @override
  updateRestStreak(int streak) async {
    await HomeWidget.saveWidgetData<int>("daily_rest_streak", streak);
    _update();
  }

  @override
  updateWorkouts(int workouts) async {
    await HomeWidget.saveWidgetData<int>("total_workouts", workouts);
    _update();
  }

  _update() async {
    try {
      for (final name in iOSWidgetName) {
        await HomeWidget.updateWidget(
          iOSName: name,
          qualifiedAndroidName: androidWidgetName,
        );
      }
      logger.i("Updated widget.");
    } catch (e) {
      logger.e(e);
    }
  }
}

class _WidgetsServiceUnsupported extends WidgetsService {
  @override
  updateWeeklyStreak(int streak) async {}

  @override
  updateRestStreak(int streak) async {}

  @override
  updateWorkouts(int total) async {}
}

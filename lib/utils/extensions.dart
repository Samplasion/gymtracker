import 'dart:convert';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/utils.dart';

extension StringUtils on String {
  double parseDouble() {
    return double.parse(replaceAll(",", "."));
  }

  double? tryParseDouble() {
    return double.tryParse(replaceAll(",", "."));
  }
}

extension DateUtils on DateTime {
  DateTime get startOfDay {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }
}

extension ColorUtils on Color {
  Brightness estimateForegroundBrightness() {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Brightness.dark : Brightness.light;
  }
}

extension ListUtils<T> on List<T> {
  T? getAt(int index) {
    if (index < 0) index += length;
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

extension IterableUtils<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }
}

extension NumIterableUtils<T extends num> on Iterable<T> {
  T get min {
    T min = first;
    for (final element in this) {
      if (element < min) {
        min = element;
      }
    }
    return min;
  }

  T get max {
    T max = first;
    for (final element in this) {
      if (element > max) {
        max = element;
      }
    }
    return max;
  }

  T get sum {
    T sum = 0 as T;
    for (final element in this) {
      sum = (sum + element as T);
    }
    return sum;
  }
}

extension BuildContextUtils on BuildContext {
  Color harmonizeColor(Color color) {
    return color.harmonizeWith(Theme.of(this).colorScheme.primary);
  }
}

extension NumUtils on num {
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

final Compressor = utf8.fuse(gzip.fuse(base64));

extension StringCompression on String {
  String get compressed => Compressor.encode(this);
  String get uncompressed => Compressor.decode(this);
}

extension WorkoutIterableUtils on Iterable<Workout> {
  /// Returns all the workouts performed in the given time [period].
  ///
  /// Assumes [this] is sorted such that the most recent workout is last.
  List<Workout> inTimePeriod(Duration period) {
    List<Workout> result = [];
    List<Workout> self = toList();
    final today = DateTime.now().startOfDay;
    final timeStart = today.subtract(period);
    for (final workout in self.reversed) {
      if (workout.startingDate != null &&
          workout.startingDate!.isAfter(timeStart)) {
        result.add(workout);
      }
    }
    return result;
  }

  /// Returns all the workouts performed in the time [period] immediately
  /// preceding the current period.
  ///
  /// Assumes [this] is sorted such that the most recent workout is last.
  List<Workout> inPrecedingTimePeriod(Duration period) {
    List<Workout> result = [];
    List<Workout> self = toList();
    final today = DateTime.now().startOfDay.subtract(period);
    final timeStart = today;
    for (final workout in self.reversed) {
      if (workout.startingDate != null &&
          workout.startingDate!.isAfter(timeStart) &&
          workout.startingDate!.isBefore(today)) {
        result.add(workout);
      }
    }
    return result;
  }
}

extension WeightUtils on double {
  String get userFacingWeight {
    return "exerciseList.fields.weight".tParams({
      "weight": stringifyDouble(this),
      "unit": "units.${settingsController.weightUnit.value!.name}".t,
    });
  }
}

extension ContextThemingUtils on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;

  Color cardColor({double elevation = 1}) {
    return ElevationOverlay.applySurfaceTint(
      theme.cardTheme.color ?? colorScheme.background,
      theme.cardTheme.surfaceTintColor ?? colorScheme.surfaceTint,
      elevation,
    );
  }
}

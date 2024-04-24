import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';

bool doubleIsActuallyInt(double double, [double epsilon = 0.001]) {
  return doubleEquality(double, double.floorToDouble(), epsilon: epsilon);
}

bool doubleEquality(double a, double b, {required double epsilon}) {
  return (b - a).abs() < epsilon;
}

String stringifyDouble(double double, [double epsilon = 0.001]) {
  if (doubleIsActuallyInt(double, epsilon)) {
    return double.floor().toString();
  }
  return double.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), "");
}

void reorder<T>(List<T> list, int oldIndex, int newIndex) {
  if (newIndex > oldIndex) newIndex -= 1;
  list.insert(newIndex, list.removeAt(oldIndex));
}

Color getContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .primaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

Color getOnContainerColor(BuildContext context, Color color) {
  final theme = Theme.of(context);
  return ColorScheme.fromSeed(seedColor: color, brightness: theme.brightness)
      .onPrimaryContainer
      .harmonizeWith(theme.colorScheme.primary);
}

double oneRepMax({required double weight, required int reps}) {
  return weight / (1.0278 - (0.0278 * reps));
}

double mapRange(
  double value,
  double min,
  double max,
  double newMin,
  double newMax,
) {
  return (((value - min) * (newMax - newMin)) / (max - min)) + newMin;
}

QuillController quillControllerFromText(String? text) {
  return QuillController(
    document: (text ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );
}

// Returns a date such that, if today's day of week is [firstDayOfWeek], then
// the returned date is today. Otherwise, it is the most recent day of the week
// in the past that has [firstDayOfWeek] as its day of week.
DateTime getLastDayOfWeek(DateTime date, int firstDayOfWeek) {
  final today = date.startOfDay;
  var offset = today.weekday - firstDayOfWeek;
  if (offset <= 0) offset += 7;
  final lastMonday = today.weekday == firstDayOfWeek
      ? today
      : today.subtract(Duration(days: offset));
  return lastMonday;
}

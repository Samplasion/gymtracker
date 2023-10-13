import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

bool doubleIsActuallyInt(double double, [double epsilon = 0.001]) {
  return (double - double.floor()).abs() < epsilon;
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

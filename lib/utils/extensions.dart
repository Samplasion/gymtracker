import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

extension StringUtils on String {
  double parseDouble() {
    return double.parse(replaceAll(",", "."));
  }

  double? tryParseDouble() {
    return double.tryParse(replaceAll(",", "."));
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

extension ListDoubleUtils on List<double> {
  double get min {
    double min = first;
    for (final element in this) {
      if (element < min) {
        min = element;
      }
    }
    return min;
  }

  double get max {
    double max = first;
    for (final element in this) {
      if (element > max) {
        max = element;
      }
    }
    return max;
  }
}

extension BuildContextUtils on BuildContext {
  Color harmonizeColor(Color color) {
    return color.harmonizeWith(Theme.of(this).colorScheme.primary);
  }
}
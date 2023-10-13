import 'dart:ui';

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

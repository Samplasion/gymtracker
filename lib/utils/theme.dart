import 'package:flutter/material.dart';

const kDarkBackgroundBase = Color(0xFF000000);
const kDarkBackgroundLight1 = Color(0xFF111111);
const kDarkForeground = Color(0xFFE9E9E9);
const kLightBackgroundBase = Color(0xFFFFFFFF);
const kLightBackgroundLight1 = Color(0xFFF6F6F6);
const kLightForeground = Color(0xFF1D1B1B);

extension NeutralBackgroundColorScheme on ColorScheme {
  ColorScheme neutralBackground() {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? kDarkBackgroundBase : kLightBackgroundBase;
    final fg = isDark ? kDarkForeground : kLightForeground;
    final surface = isDark ? kDarkBackgroundLight1 : kLightBackgroundBase;
    final surfaceTint = isDark ? Colors.white : Colors.grey[800];
    return copyWith(
      background: bg,
      onBackground: fg,
      surface: surface,
      surfaceTint: surfaceTint,
    );
  }
}

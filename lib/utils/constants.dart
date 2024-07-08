import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Breakpoints {
  /// Class xx-small (width: 320)
  xxs._(320),

  /// Class extra-small (width: 480)
  xs._(480),

  /// Class small (width: 600)
  s._(600),

  /// Class medium (width: 720)
  m._(720),

  /// Class large (width: 024)
  l._(1024),

  /// Class extra-large (width: 999)
  xl._(999999);

  const Breakpoints._(this.screenWidth);

  final int screenWidth;

  static Breakpoints get currentBreakpoint =>
      computeBreakpoint(Get.context!.width);

  static Breakpoints computeBreakpoint(double width) {
    final w = width;
    if (w < xxs.screenWidth) return xxs;
    if (w < xs.screenWidth) return xs;
    if (w < s.screenWidth) return s;
    if (w < m.screenWidth) return m;
    if (w < l.screenWidth) return l;
    return xl;
  }

  Breakpoints next() => switch (this) {
        xxs => xs,
        xs => s,
        s => m,
        m => l,
        l => xl,
        xl => xl,
      };

  Breakpoints previous() => switch (this) {
        xxs => xxs,
        xs => xxs,
        s => xs,
        m => s,
        l => m,
        xl => l,
      };

  bool operator <(Breakpoints other) =>
      screenWidth <= other.previous().screenWidth;
  bool operator <=(Breakpoints other) => screenWidth <= other.screenWidth;
  bool operator >(Breakpoints other) => screenWidth >= other.next().screenWidth;
  bool operator >=(Breakpoints other) => screenWidth >= other.screenWidth;
}

class NotificationIDs {
  static const restTimer = 0;
}

const monospace = TextStyle(
  fontFamily: "monospace",
  fontFamilyFallback: <String>["Menlo", "Courier"],
);

InteractiveInkFeatureFactory get platformDependentSplashFactory =>
    switch (defaultTargetPlatform) {
      TargetPlatform.android => InkSparkle.splashFactory,
      TargetPlatform.iOS || TargetPlatform.macOS => NoSplash.splashFactory,
      _ => InkRipple.splashFactory,
    };

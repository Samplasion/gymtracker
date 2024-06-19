import 'package:animations/animations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';

const kDarkBackgroundBase = Color(0xFF000000);
const kDarkBackgroundLight1 = Color(0xFF111111);
const kDarkForeground = Color(0xFFE9E9E9);
const kLightBackgroundBase = Color(0xFFFFFFFF);
const kLightBackgroundLight1 = Color(0xFFF6F6F6);
const kLightForeground = Color(0xFF1D1B1B);

ThemeData getGymTrackerThemeFor(ColorScheme scheme) {
  final settings = Get.find<SettingsController>();
  if (settings.amoledMode.isTrue) {
    scheme = scheme.neutralBackground();
  }
  var pageTransitionsTheme = PageTransitionsTheme(builders: {
    TargetPlatform.android: _SharedAxisTransitionBuilder(),
    TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: _SharedAxisTransitionBuilder(),
  });

  final brightness = scheme.brightness;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    pageTransitionsTheme: pageTransitionsTheme,
    extensions: [
      MoreColors.fromColorScheme(scheme),
    ],
    splashFactory: platformDependentSplashFactory,
    dialogTheme: DialogTheme(
      backgroundColor: scheme.surfaceContainer,
    ),
  );
}

@immutable
class MoreColors extends ThemeExtension<MoreColors> {
  const MoreColors({
    required this.quaternary,
    required this.onQuaternary,
    required this.quaternaryContainer,
    required this.onQuaternaryContainer,
    required this.quinary,
    required this.onQuinary,
    required this.quinaryContainer,
    required this.onQuinaryContainer,
  });

  factory MoreColors.fromColorScheme(ColorScheme colorScheme) {
    final quaternary = colorScheme.primary.pentadicColors[4];
    final quatCS = ColorScheme.fromSeed(
      seedColor: quaternary,
      brightness: colorScheme.brightness,
    );

    final quinary = colorScheme.primary.pentadicColors[3];
    final quinCS = ColorScheme.fromSeed(
      seedColor: quinary,
      brightness: colorScheme.brightness,
    );

    return MoreColors(
      quaternary: quatCS.primary.harmonizeWith(colorScheme.primary),
      onQuaternary: quatCS.onPrimary.harmonizeWith(colorScheme.primary),
      quaternaryContainer:
          quatCS.primaryContainer.harmonizeWith(colorScheme.primary),
      onQuaternaryContainer:
          quatCS.onPrimaryContainer.harmonizeWith(colorScheme.primary),
      quinary: quinCS.primary.harmonizeWith(colorScheme.primary),
      onQuinary: quinCS.onPrimary.harmonizeWith(colorScheme.primary),
      quinaryContainer:
          quinCS.primaryContainer.harmonizeWith(colorScheme.primary),
      onQuinaryContainer:
          quinCS.onPrimaryContainer.harmonizeWith(colorScheme.primary),
    );
  }

  final Color quaternary;
  final Color onQuaternary;
  final Color quaternaryContainer;
  final Color onQuaternaryContainer;
  final Color quinary;
  final Color onQuinary;
  final Color quinaryContainer;
  final Color onQuinaryContainer;

  @override
  MoreColors copyWith({
    Color? quaternary,
    Color? onQuaternary,
    Color? quaternaryContainer,
    Color? onQuaternaryContainer,
    Color? quinary,
    Color? onQuinary,
    Color? quinaryContainer,
    Color? onQuinaryContainer,
  }) {
    return MoreColors(
      quaternary: quaternary ?? this.quaternary,
      onQuaternary: onQuaternary ?? this.onQuaternary,
      quaternaryContainer: quaternaryContainer ?? this.quaternaryContainer,
      onQuaternaryContainer:
          onQuaternaryContainer ?? this.onQuaternaryContainer,
      quinary: quinary ?? this.quinary,
      onQuinary: onQuinary ?? this.onQuinary,
      quinaryContainer: quinaryContainer ?? this.quinaryContainer,
      onQuinaryContainer: onQuinaryContainer ?? this.onQuinaryContainer,
    );
  }

  @override
  MoreColors lerp(MoreColors? other, double t) {
    if (other is! MoreColors) {
      return this;
    }
    return MoreColors(
      quaternary: Color.lerp(quaternary, other.quaternary, t) ?? quaternary,
      onQuaternary:
          Color.lerp(onQuaternary, other.onQuaternary, t) ?? onQuaternary,
      quaternaryContainer:
          Color.lerp(quaternaryContainer, other.quaternaryContainer, t) ??
              quaternaryContainer,
      onQuaternaryContainer:
          Color.lerp(onQuaternaryContainer, other.onQuaternaryContainer, t) ??
              onQuaternaryContainer,
      quinary: Color.lerp(quinary, other.quinary, t) ?? quinary,
      onQuinary: Color.lerp(onQuinary, other.onQuinary, t) ?? onQuinary,
      quinaryContainer:
          Color.lerp(quinaryContainer, other.quinaryContainer, t) ??
              quinaryContainer,
      onQuinaryContainer:
          Color.lerp(onQuinaryContainer, other.onQuinaryContainer, t) ??
              onQuinaryContainer,
    );
  }

  // Optional
  @override
  String toString() =>
      'MoreColors(quaternary: $quaternary, onQuaternary: $onQuaternary, quaternaryContainer: $quaternaryContainer, onQuaternaryContainer: $onQuaternaryContainer)';
}

extension NeutralBackgroundColorScheme on ColorScheme {
  ColorScheme neutralBackground() {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? kDarkBackgroundBase : kLightBackgroundBase;
    final fg = isDark ? kDarkForeground : kLightForeground;
    final surface = isDark ? kDarkBackgroundLight1 : kLightBackgroundBase;
    final surfaceTint = isDark ? Colors.white : Colors.grey[800];
    final surfaceContainerHighest = Colors.grey[isDark ? 800 : 200];
    return copyWith(
      background: bg,
      onBackground: fg,
      surface: bg,
      onSurface: fg,
      surfaceDim: surface,
      surfaceTint: surfaceTint,
      surfaceContainer: Colors.grey[isDark ? 900 : 100],
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceBright: surfaceContainerHighest,
    );
  }
}

extension MoreColorsOnColorScheme on ColorScheme {
  Color get quaternary =>
      Theme.of(Get.context!).extension<MoreColors>()!.quaternary;
  Color get onQuaternary =>
      Theme.of(Get.context!).extension<MoreColors>()!.onQuaternary;
  Color get quaternaryContainer =>
      Theme.of(Get.context!).extension<MoreColors>()!.quaternaryContainer;
  Color get onQuaternaryContainer =>
      Theme.of(Get.context!).extension<MoreColors>()!.onQuaternaryContainer;
  Color get quinary => Theme.of(Get.context!).extension<MoreColors>()!.quinary;
  Color get onQuinary =>
      Theme.of(Get.context!).extension<MoreColors>()!.onQuinary;
  Color get quinaryContainer =>
      Theme.of(Get.context!).extension<MoreColors>()!.quinaryContainer;
  Color get onQuinaryContainer =>
      Theme.of(Get.context!).extension<MoreColors>()!.onQuinaryContainer;
}

class _SharedAxisTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return SharedAxisTransition(
      transitionType: SharedAxisTransitionType.horizontal,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

import 'package:animations/animations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

const kDarkBackgroundBase = Color(0xFF000000);
const kDarkBackgroundLight1 = Color(0xFF111111);
const kDarkForeground = Color(0xFFE9E9E9);
const kLightBackgroundBase = Color(0xFFFFFFFF);
const kLightBackgroundLight1 = Color(0xFFF6F6F6);
const kLightForeground = Color(0xFF1D1B1B);
const kAppBarRadius = 16.0;

ThemeData getGymTrackerThemeFor(
    BuildContext context, Color seedColor, Brightness brightness) {
  late FlexColorScheme scheme = switch (brightness) {
    Brightness.light => FlexColorScheme.light(
        colors: FlexSchemeColor.from(
          primary: seedColor,
          secondary: seedColor,
          brightness: brightness,
        ),
      ),
    Brightness.dark => FlexColorScheme.dark(
        colors: FlexSchemeColor.from(
          primary: seedColor,
          secondary: seedColor,
          brightness: brightness,
        ),
      ),
  };
  var pageTransitionsTheme = PageTransitionsTheme(builders: {
    TargetPlatform.android: _SharedAxisTransitionBuilder(),
    TargetPlatform.iOS: _SharedAxisTransitionBuilder(),
    TargetPlatform.macOS: _SharedAxisTransitionBuilder(),
  });
  final equivalentScheme = scheme.toScheme;

  var subThemesData = FlexSubThemesData(
    interactionEffects: true,
    blendOnColors: true,
    scaffoldBackgroundBaseColor: FlexScaffoldBaseColor.lowestBase,
    defaultRadius: 8.0,
    cardRadius: 12,
    inputDecoratorIsFilled: true,
    inputDecoratorIsDense: true,
    inputDecoratorContentPadding:
        const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorBorderSchemeColor: SchemeColor.primary,
    inputDecoratorUnfocusedHasBorder: false,
    chipSelectedSchemeColor: SchemeColor.primaryContainer,
    chipSecondarySelectedSchemeColor: SchemeColor.primaryContainer,
    popupMenuSchemeColor: SchemeColor.surfaceContainerHigh,
    alignedDropdown: true,
    tooltipRadius: 4,
    tooltipSchemeColor: SchemeColor.inverseSurface,
    snackBarElevation: 6,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
    navigationRailUseIndicator: true,
    navigationRailLabelType: NavigationRailLabelType.all,
    drawerIndicatorSchemeColor: SchemeColor.primaryContainer,
    inputDecoratorFillColor: equivalentScheme.surfaceContainerHighest
        .withAlpha((0.45 * 255).round()),
    navigationRailMinWidth: 96,
    menuSchemeColor: SchemeColor.surfaceContainerHigh,
  );

  return switch (brightness) {
    Brightness.light => FlexThemeData.light(
        colors: FlexSchemeColor.from(
          primary: seedColor,
          secondary: seedColor,
          tertiary: seedColor,
          brightness: brightness,
        ),
        usedColors: 3,
        subThemesData: subThemesData,
        appBarStyle: FlexAppBarStyle.scaffoldBackground,
        keyColors: const FlexKeyColors(
          useSecondary: true,
          keepPrimary: true,
          keepSecondary: true,
          keepSecondaryContainer: true,
          useTertiary: true,
          keepTertiary: true,
        ),
        tones: FlexSchemeVariant.jolly
            .tones(Brightness.light)
            .surfacesUseBW()
            .monochromeSurfaces(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
        extensions: [
          MoreColors.fromColorScheme(equivalentScheme),
        ],
        pageTransitionsTheme: pageTransitionsTheme,
        splashFactory: platformDependentSplashFactory,
      ),
    Brightness.dark => FlexThemeData.dark(
        colors: FlexSchemeColor.from(
          primary: seedColor,
          secondary: seedColor,
          brightness: brightness,
        ),
        usedColors: 3,
        subThemesData: subThemesData,
        appBarStyle: FlexAppBarStyle.scaffoldBackground,
        keyColors: const FlexKeyColors(
          useSecondary: true,
          keepPrimary: true,
          keepSecondary: true,
          keepSecondaryContainer: true,
          useTertiary: true,
          keepTertiary: true,
        ),
        tones: FlexSchemeVariant.jolly
            .tones(Brightness.dark)
            .surfacesUseBW()
            .monochromeSurfaces(),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
        extensions: [
          MoreColors.fromColorScheme(equivalentScheme),
        ],
        pageTransitionsTheme: pageTransitionsTheme,
        splashFactory: platformDependentSplashFactory,
      ),
  };
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
    // Grayscale mode
    final primary = colorScheme.primary;
    if (primary.isGray) {
      return MoreColors(
        quaternary: colorScheme.primary,
        onQuaternary: colorScheme.onPrimary,
        quaternaryContainer: colorScheme.primaryContainer,
        onQuaternaryContainer: colorScheme.onPrimaryContainer,
        quinary: colorScheme.secondary,
        onQuinary: colorScheme.onSecondary,
        quinaryContainer: colorScheme.secondaryContainer,
        onQuinaryContainer: colorScheme.onSecondaryContainer,
      );
    }

    ColorScheme _buildScheme({
      required Color seedColor,
      required Brightness brightness,
    }) {
      return switch (brightness) {
        Brightness.light => FlexColorScheme.light(
            colors: FlexSchemeColor.from(
              primary: seedColor,
              brightness: brightness,
            ),
          ),
        Brightness.dark => FlexColorScheme.dark(
            colors: FlexSchemeColor.from(
              primary: seedColor,
              brightness: brightness,
            ),
          ),
      }
          .toScheme;
    }

    final quaternary = colorScheme.primary.pentadicColors[4];
    final quatCS = _buildScheme(
      seedColor: quaternary.harmonizeWith(colorScheme.primary),
      brightness: colorScheme.brightness,
    );

    final quinary = colorScheme.primary.pentadicColors[3];
    final quinCS = _buildScheme(
      seedColor: quinary.harmonizeWith(colorScheme.primary),
      brightness: colorScheme.brightness,
    );

    return MoreColors(
      quaternary: quatCS.primary,
      onQuaternary: quatCS.onPrimary,
      quaternaryContainer: quatCS.primaryContainer,
      onQuaternaryContainer: quatCS.onPrimaryContainer,
      quinary: quinCS.primary,
      onQuinary: quinCS.onPrimary,
      quinaryContainer: quinCS.primaryContainer,
      onQuinaryContainer: quinCS.onPrimaryContainer,
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

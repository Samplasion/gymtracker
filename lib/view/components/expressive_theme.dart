import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as expressive;

/// Keeps standalone Material widgets (m3e_core 1.x) in the app's existing theme.
/// The package's own compatibility bridge maps in the opposite direction.
class GTExpressiveTheme extends StatelessWidget {
  const GTExpressiveTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final source = Theme.of(context);
    final scheme = source.colorScheme;
    final textTheme = source.textTheme;
    final theme = expressive.ThemeData(
      useMaterial3: source.useMaterial3,
      platform: source.platform,
      visualDensity: expressive.VisualDensity(
        horizontal: source.visualDensity.horizontal,
        vertical: source.visualDensity.vertical,
      ),
      colorScheme: expressive.ColorScheme(
        brightness: scheme.brightness,
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        primaryContainer: scheme.primaryContainer,
        onPrimaryContainer: scheme.onPrimaryContainer,
        secondary: scheme.secondary,
        onSecondary: scheme.onSecondary,
        secondaryContainer: scheme.secondaryContainer,
        onSecondaryContainer: scheme.onSecondaryContainer,
        tertiary: scheme.tertiary,
        onTertiary: scheme.onTertiary,
        tertiaryContainer: scheme.tertiaryContainer,
        onTertiaryContainer: scheme.onTertiaryContainer,
        error: scheme.error,
        onError: scheme.onError,
        errorContainer: scheme.errorContainer,
        onErrorContainer: scheme.onErrorContainer,
        surface: scheme.surface,
        onSurface: scheme.onSurface,
        surfaceDim: scheme.surfaceDim,
        surfaceBright: scheme.surfaceBright,
        surfaceContainerLowest: scheme.surfaceContainerLowest,
        surfaceContainerLow: scheme.surfaceContainerLow,
        surfaceContainer: scheme.surfaceContainer,
        surfaceContainerHigh: scheme.surfaceContainerHigh,
        surfaceContainerHighest: scheme.surfaceContainerHighest,
        onSurfaceVariant: scheme.onSurfaceVariant,
        outline: scheme.outline,
        outlineVariant: scheme.outlineVariant,
        shadow: scheme.shadow,
        scrim: scheme.scrim,
        inverseSurface: scheme.inverseSurface,
        onInverseSurface: scheme.onInverseSurface,
        inversePrimary: scheme.inversePrimary,
        surfaceTint: scheme.surfaceTint,
        primaryFixed: scheme.primaryFixed,
        primaryFixedDim: scheme.primaryFixedDim,
        onPrimaryFixed: scheme.onPrimaryFixed,
        onPrimaryFixedVariant: scheme.onPrimaryFixedVariant,
        secondaryFixed: scheme.secondaryFixed,
        secondaryFixedDim: scheme.secondaryFixedDim,
        onSecondaryFixed: scheme.onSecondaryFixed,
        onSecondaryFixedVariant: scheme.onSecondaryFixedVariant,
        tertiaryFixed: scheme.tertiaryFixed,
        tertiaryFixedDim: scheme.tertiaryFixedDim,
        onTertiaryFixed: scheme.onTertiaryFixed,
        onTertiaryFixedVariant: scheme.onTertiaryFixedVariant,
      ),
      textTheme: expressive.TextTheme(
        displayLarge: textTheme.displayLarge,
        displayMedium: textTheme.displayMedium,
        displaySmall: textTheme.displaySmall,
        headlineLarge: textTheme.headlineLarge,
        headlineMedium: textTheme.headlineMedium,
        headlineSmall: textTheme.headlineSmall,
        titleLarge: textTheme.titleLarge,
        titleMedium: textTheme.titleMedium,
        titleSmall: textTheme.titleSmall,
        bodyLarge: textTheme.bodyLarge,
        bodyMedium: textTheme.bodyMedium,
        bodySmall: textTheme.bodySmall,
        labelLarge: textTheme.labelLarge,
        labelMedium: textTheme.labelMedium,
        labelSmall: textTheme.labelSmall,
      ),
    );
    return Localizations.override(
      context: context,
      delegates: const [expressive.GlobalMaterialLocalizations.delegate],
      child: expressive.Theme(data: theme, child: child),
    );
  }
}

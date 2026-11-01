import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart' as expressive;

void main() {
  testWidgets(
    'Expressive widgets inherit app colors, typography and Italian localizations',
    (tester) async {
      late expressive.ThemeData resolved;
      late expressive.MaterialLocalizations localizations;
      var presses = 0;
      for (final brightness in Brightness.values) {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: brightness,
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(
              fontFamily: 'AppFont',
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('it'),
            supportedLocales: const [Locale('it')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: theme,
            builder: (context, child) => GTExpressiveTheme(child: child!),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  resolved = expressive.Theme.of(context);
                  localizations = expressive.MaterialLocalizations.of(context);
                  return M3EButton(
                    onPressed: () => presses++,
                    child: const Text('Azione'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(resolved.brightness, brightness);
        expect(resolved.colorScheme.primary, theme.colorScheme.primary);
        expect(
          resolved.colorScheme.surfaceContainerLow,
          theme.colorScheme.surfaceContainerLow,
        );
        expect(
          resolved.colorScheme.onPrimaryFixedVariant,
          theme.colorScheme.onPrimaryFixedVariant,
        );
        expect(resolved.textTheme.titleMedium?.fontFamily, 'AppFont');
        expect(resolved.textTheme.titleMedium?.fontSize, 21);
        expect(resolved.textTheme.titleMedium?.fontWeight, FontWeight.w600);
        expect(
          resolved.visualDensity.horizontal,
          theme.visualDensity.horizontal,
        );
        expect(localizations.cancelButtonLabel, 'Annulla');
        await tester.tap(find.text('Azione'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(presses, 2);
    },
  );
}

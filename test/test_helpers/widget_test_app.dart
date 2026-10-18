import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initTestLocalizations() async {
  await initializeDateFormatting('en_US', null);
}

class WidgetTestApp extends StatelessWidget {
  final Widget child;
  final bool wrapWithProviderScope;

  const WidgetTestApp({
    super.key,
    required this.child,
    this.wrapWithProviderScope = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(useMaterial3: true);
    final app = TranslationProvider(
      child: GetMaterialApp(
        locale: const Locale('en'),
        theme: baseTheme.copyWith(
          extensions: [MoreColors.fromColorScheme(baseTheme.colorScheme)],
        ),
        home: Scaffold(body: child),
      ),
    );

    if (wrapWithProviderScope) {
      return UncontrolledProviderScope(
        container: globalContainer,
        child: app,
      );
    }
    return app;
  }
}

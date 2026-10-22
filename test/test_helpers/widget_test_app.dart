import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'mock_services.dart';

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
      child: MaterialApp(
        navigatorKey: Go.navigatorKey,
        locale: const Locale('en'),
        theme: baseTheme.copyWith(
          extensions: [MoreColors.fromColorScheme(baseTheme.colorScheme)],
        ),
        home: Scaffold(body: child),
      ),
    );

    var hasParentScope = false;
    try {
      ProviderScope.containerOf(context, listen: false);
      hasParentScope = true;
    } on StateError {
      // Legacy widget fixtures need a root scope as their widgets migrate.
    }
    if (wrapWithProviderScope) {
      return UncontrolledProviderScope(
        container: MockServices.container,
        child: app,
      );
    }
    if (!hasParentScope) return ProviderScope(child: app);
    return app;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/i18n/strings.g.dart';

import 'package:gymtracker/utils/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initTestLocalizations() async {
  await initializeDateFormatting('en_US', null);
}

class WidgetTestApp extends StatelessWidget {
  final Widget child;

  const WidgetTestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(useMaterial3: true);
    return TranslationProvider(
      child: GetMaterialApp(
        locale: const Locale('en'),
        theme: baseTheme.copyWith(
          extensions: [MoreColors.fromColorScheme(baseTheme.colorScheme)],
        ),
        home: Scaffold(body: child),
      ),
    );
  }
}

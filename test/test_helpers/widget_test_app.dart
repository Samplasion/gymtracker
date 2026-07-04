import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';

import 'package:gymtracker/utils/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initTestLocalizations() async {
  await initializeDateFormatting('en_US', null);
  if (Get.isRegistered<GTLocalizations>()) return;
  final l = GTLocalizations();
  final file = File('assets/i18n/en.json');
  final jsonStr = await file.readAsString();
  l.keys['en'] = l.flattenTranslations(jsonDecode(jsonStr));
  Get.translations.clear();
  Get.addTranslations(l.keys);
  Get.put(l);
  Get.locale = const Locale('en');
}

class WidgetTestApp extends StatelessWidget {
  final Widget child;

  const WidgetTestApp({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(useMaterial3: true);
    return GetMaterialApp(
      locale: const Locale('en'),
      translations: Get.find<GTLocalizations>(),
      theme: baseTheme.copyWith(
        extensions: [
          MoreColors.fromColorScheme(baseTheme.colorScheme),
        ],
      ),
      home: Scaffold(
        body: child,
      ),
    );
  }
}

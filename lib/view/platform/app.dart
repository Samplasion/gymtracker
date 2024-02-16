import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';
import 'package:gymtracker/service/localizations.dart';

class PlatformApp extends StatelessWidget {
  final String title;
  final GTLocalizations translations;
  final Locale? locale;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final List<LocalizationsDelegate<Object>> localizationsDelegates;
  final ThemeData theme;
  final ThemeData darkTheme;
  final Widget home;
  final bool debugShowCheckedModeBanner;
  final AnnotatedRegion<SystemUiOverlayStyle> Function(
      dynamic context, dynamic child) builder;

  const PlatformApp({
    super.key,
    required this.title,
    required this.translations,
    required this.supportedLocales,
    required this.fallbackLocale,
    required this.localizationsDelegates,
    required this.theme,
    required this.darkTheme,
    required this.home,
    required this.debugShowCheckedModeBanner,
    required this.builder,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlatformController>();
    return controller.platform.value == UIPlatform.material
        ? buildMaterial(context)
        : buildCupertino(context);
  }

  Widget buildMaterial(BuildContext context) {
    return GetMaterialApp(
      title: title,
      translations: translations,
      locale: locale,
      supportedLocales: supportedLocales,
      fallbackLocale: fallbackLocale,
      localizationsDelegates: localizationsDelegates,
      theme: theme,
      darkTheme: darkTheme,
      home: home,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      builder: builder,
    );
  }

  Widget buildCupertino(BuildContext context) {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;

    return Theme(
      data: brightness == Brightness.light ? theme : darkTheme,
      child: GetCupertinoApp(
        title: title,
        translations: translations,
        locale: locale,
        supportedLocales: supportedLocales,
        fallbackLocale: fallbackLocale,
        localizationsDelegates: localizationsDelegates,
        theme: _buildCupertinoTheme(context),
        home: home,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        builder: builder,
      ),
    );
  }

  CupertinoThemeData _buildCupertinoTheme(BuildContext context) {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;

    if (brightness == Brightness.light) {
      return CupertinoThemeData(
        primaryColor: theme.colorScheme.primary,
        brightness: Brightness.light,
      );
    } else {
      return CupertinoThemeData(
        primaryColor: darkTheme.colorScheme.primary,
        brightness: Brightness.dark,
      );
    }
  }
}

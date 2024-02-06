import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/skeleton.dart';

import 'controller/exercises_controller.dart';
import 'controller/settings_controller.dart';
import 'service/database.dart';
import 'service/localizations.dart';
import 'service/notifications.dart';
import 'utils/go.dart';

final _databaseService = DatabaseService();

void main() async {
  await GetStorage.init();

  final l = GTLocalizations();
  await l.init();

  await _databaseService.ensureInitialized();

  await ColorService().init();

  runApp(MainApp(localizations: l));
}

class MainApp extends StatelessWidget {
  final GTLocalizations localizations;

  const MainApp({required this.localizations, super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(_databaseService);
    Get.put(NotificationsService());
    Get.put(CountdownController());
    Get.put(ExercisesController());
    Get.put(DebugController());
    final settings = Get.put(SettingsController());
    final localizations = Get.put(this.localizations);

    return DynamicColorBuilder(builder: (light, dark) {
      return AnimatedBuilder(
          animation: settings.service,
          builder: (context, _) {
            return Container(
              child: () {
                final seedColor = settings.color();
                (seedColor, settings.usesDynamicColor()).printInfo();
                final lightScheme =
                    (light != null && settings.usesDynamicColor())
                        ? light.harmonized()
                        : ColorScheme.fromSeed(
                            seedColor: seedColor,
                            brightness: Brightness.light,
                          );
                final darkScheme = (dark != null && settings.usesDynamicColor())
                    ? dark.harmonized()
                    : ColorScheme.fromSeed(
                        seedColor: seedColor,
                        brightness: Brightness.dark,
                      ).harmonized();
                return AnimatedBuilder(
                  animation: localizations,
                  builder: (context, _) {
                    return GetMaterialApp(
                      translations: localizations,
                      locale: () {
                        printInfo(info: "${settings.locale.value}");
                        return settings.locale.value;
                      }(),
                      supportedLocales: GTLocalizations.supportedLocales,
                      fallbackLocale: const Locale('en'),
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      theme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.light,
                        colorScheme: lightScheme,
                      ),
                      darkTheme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.dark,
                        colorScheme: darkScheme,
                      ),
                      home: const _Loader(),
                      debugShowCheckedModeBanner: false,
                      builder: (context, child) =>
                          AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          systemNavigationBarColor:
                              Theme.of(context).colorScheme.background,
                          systemNavigationBarIconBrightness: Theme.of(context)
                              .colorScheme
                              .background
                              .estimateForegroundBrightness(),
                        ),
                        child: child ?? Container(),
                      ),
                    );
                  },
                );
              }(),
            );
          });
    });
  }
}

/// A widget that launches the actual root widget.
///
/// Used to force the root widget to be an
/// animated route, so that exit animations work.
class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => __LoaderState();
}

class __LoaderState extends State<_Loader> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Go.off(() => const SkeletonView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Loading...")),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

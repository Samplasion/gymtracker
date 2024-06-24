import 'package:device_sim/device_sim.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/error.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(LoggerController());

  final _databaseService = DatabaseService();

  final l = GTLocalizations();
  await l.init();

  await _databaseService.ensureInitialized();

  await ColorService().init();
  await VersionService().init();

  initLogger();

  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  await protocolHandler.register('gymtracker');

  runApp(MainApp(localizations: l, databaseService: _databaseService));
}

const applicationKey = Key("GymTracker");

class MainApp extends StatelessWidget {
  final GTLocalizations localizations;
  final DatabaseService databaseService;

  const MainApp({
    required this.localizations,
    required this.databaseService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(databaseService);
    Get.put(Coordinator()..init());
    final debugController = Get.find<DebugController>();
    final settings = Get.find<SettingsController>();
    final localizations = Get.put(this.localizations);

    final application = DynamicColorBuilder(
      key: applicationKey,
      builder: (light, dark) {
        return AnimatedBuilder(
          animation: settings.service,
          builder: (context, _) {
            return Container(
              child: () {
                final seedColor = settings.color();
                var lightScheme = (light != null && settings.usesDynamicColor())
                    ? light.harmonized()
                    : ColorScheme.fromSeed(
                        seedColor: seedColor,
                        brightness: Brightness.light,
                      ).harmonized();
                var darkScheme = (dark != null && settings.usesDynamicColor())
                    ? dark.harmonized()
                    : ColorScheme.fromSeed(
                        seedColor: seedColor,
                        brightness: Brightness.dark,
                      ).harmonized();
                return AnimatedBuilder(
                  animation: localizations,
                  builder: (context, _) {
                    return GetMaterialApp(
                      useInheritedMediaQuery: true,
                      title: () {
                        if (kDebugMode) {
                          return "${"appName".t} (Debug)";
                        } else {
                          return "appName".t;
                        }
                      }(),
                      translations: localizations,
                      locale:
                          settings.locale.value ?? Prefs.defaultValue.locale,
                      supportedLocales: GTLocalizations.supportedLocales,
                      fallbackLocale: const Locale('en'),
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      themeMode: settings.themeMode(),
                      theme: getGymTrackerThemeFor(lightScheme),
                      darkTheme: getGymTrackerThemeFor(darkScheme),
                      home: const GymTrackerAppLoader(),
                      onGenerateRoute: (settings) {
                        return switch (settings.name) {
                          WorkoutView.routeName => Go.materialRoute(
                              () => const WorkoutView(),
                              settings: settings,
                            ),
                          ErrorView.routeName => Go.materialRoute(
                              () => const ErrorView(),
                              settings: settings,
                            ),
                          null ||
                          String() =>
                            throw Exception("Invalid route: ${settings.name}"),
                        };
                      },
                      debugShowCheckedModeBanner: false,
                      builder: (context, child) =>
                          AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          systemNavigationBarColor:
                              Theme.of(context).colorScheme.surface,
                          systemNavigationBarIconBrightness: Theme.of(context)
                              .colorScheme
                              .surface
                              .estimateForegroundBrightness(),
                        ),
                        child: child ?? Container(),
                      ),
                      logWriterCallback: (text, {bool? isError}) {
                        if (isError == true) {
                          logger.e(text);
                        } else {
                          logger.d(text);
                        }
                      },
                    );
                  },
                );
              }(),
            );
          },
        );
      },
    );

    return Obx(() {
      if (debugController.showSimulator.isTrue) {
        return DeviceSim(builder: (context) => application);
      }

      return application;
    });
  }
}

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
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
import 'package:gymtracker/licenses.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/debug/iphone15.dart';
import 'package:gymtracker/view/error.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:relative_time/relative_time.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  initLicenses();

  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await Supabase.initialize(
    url: Env.supabaseInstance,
    anonKey: Env.supabaseAnonKey,
  );

  AudioCache.instance = AudioCache(prefix: '');
  AudioPlayer.global.setAudioContext(AudioContextConfig(
    // TODO: Prevent indefinite ducking
    // focus: AudioContextConfigFocus.duckOthers,
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build());

  Get.put(LoggerController());
  initLogger();

  final _databaseService = DatabaseService();

  final l = GTLocalizations();
  await l.init();

  final _compl = Completer();
  _databaseService.ensureInitialized(onDone: () => _compl.complete());
  await _compl.future;

  await ColorService().init();
  await VersionService().init();

  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  await protocolHandler.register('gymtracker');

  runApp(MainApp(localizations: l, databaseService: _databaseService));
}

const applicationKey = Key("GymTracker");

class MainApp extends StatefulWidget {
  final GTLocalizations localizations;
  final DatabaseService databaseService;

  const MainApp({
    required this.localizations,
    required this.databaseService,
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with LoggerConfigurationMixin {
  @override
  void initState() {
    super.initState();
    Get.put(widget.databaseService);
    Get.put(Coordinator()..init());
    Get.put(widget.localizations);
  }

  @override
  int loggerMethodCount = 0;

  @override
  Widget build(BuildContext context) {
    final debugController = Get.find<DebugController>();
    final settings = Get.find<SettingsController>();
    final localizations = widget.localizations;

    final application = DynamicColorBuilder(
      key: applicationKey,
      builder: (light, dark) {
        return AnimatedBuilder(
          animation: settings.service,
          builder: (context, _) {
            return Container(
              child: () {
                var platformSeedColor = ({
                  Brightness.light: light?.primary,
                  Brightness.dark: dark?.primary,
                }[switch (settings.themeMode()) {
                  ThemeMode.light => Brightness.light,
                  ThemeMode.dark => Brightness.dark,
                  ThemeMode.system => MediaQuery.of(context).platformBrightness,
                }]);
                final seedColor = settings.usesDynamicColor()
                    ? platformSeedColor ?? settings.color()
                    : settings.color();

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
                        RelativeTimeLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      themeMode: settings.themeMode(),
                      theme: getGymTrackerThemeFor(
                        context,
                        seedColor,
                        Brightness.light,
                      ),
                      darkTheme: getGymTrackerThemeFor(
                        context,
                        seedColor,
                        Brightness.dark,
                      ),
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
                          logger.t(text);
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

    return RootRestorationScope(
      restorationId: "org.js.samplasion.GymTracker-restoration-flt",
      child: Obx(() {
        if (debugController.showSimulator.isTrue) {
          return DeviceSim(
            builder: (context) => application,
            devices: const [iphone13Mini, iphone15, ipad129Gen5],
          );
        }

        return application;
      }),
    );
  }
}

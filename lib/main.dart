// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_sim/device_sim.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:gymtracker/struct/navigation_observer.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/charts/density_calendar_chart.dart'
    show DensityCalendarChart;
import 'package:gymtracker/view/charts/line_charts_time_series.dart';
import 'package:gymtracker/view/charts/weight_chart.dart';
import 'package:gymtracker/view/debug/iphone15.dart';
import 'package:gymtracker/view/error.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/paywall.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:relative_time/relative_time.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sentry_flutter/sentry_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// TODO: Move ProviderContainer back inside the widget tree once Getx is fully migrated.
late final ProviderContainer globalContainer;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  if (kDebugMode) {
    print(
      "Health check: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}",
    );
  }

  globalContainer = ProviderContainer();

  initLicenses();

  WidgetsFlutterBinding.ensureInitialized();
  SentryWidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await Supabase.initialize(
    url: Env.supabaseInstance,
    publishableKey: Env.supabaseAnonKey,
  );

  AudioCache.instance = AudioCache(prefix: '');
  AudioPlayer.global.setAudioContext(
    AudioContextConfig(
      // TODO: Prevent indefinite ducking
      // focus: AudioContextConfigFocus.duckOthers,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build(),
  );

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

  final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

  await SentryFlutter.init(
    _sentryInit,
    appRunner: () => runApp(
      SentryWidget(
        child: UncontrolledProviderScope(
          container: globalContainer,
          child: MainApp(localizations: l, databaseService: _databaseService),
        ),
      ),
    ),
  );
}

FutureOr<void> _sentryInit(SentryFlutterOptions options) {
  options.dsn =
      'https://7d93abf745f54d8f8edb3812690bbbac@o1165851.ingest.us.sentry.io/6256038';
  options.sendDefaultPii = false;
  options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
  options.profilesSampleRate = 1.0;

  options.replay.sessionSampleRate = 0.1;
  options.replay.onErrorSampleRate = 1.0;

  options.feedback.title = 'Report a Bug';
  options.feedback.isNameRequired = false;
  options.feedback.showName = true;
  options.feedback.isEmailRequired = false;
  options.feedback.showEmail = true;
  options.feedback.useSentryUser = true;
  options.feedback.showBranding = false;

  options.privacy.mask<DensityCalendarChart>();
  options.privacy.mask<WeightCard>();
  options.privacy.mask<WeightChartTimeSeries>();
  options.privacy.mask<LineChartTimeSeries>();

  options.privacy.maskCallback((el, widget) {
    SentryMaskingDecision shouldMask = .continueProcessing;

    // Hide sensitive data in certain widgets, such as charts that may contain personal information.
    // Since we disable our chart wrappers with the methods above, if this fails
    // in the release build, we still don't receive any sensitive data.
    if ([
      "AxisChartScaffoldWidget",
      "LineChartLeaf",
    ].contains(widget.runtimeType.toString())) {
      shouldMask = .mask;
    }

    return shouldMask;
  });

  options.enableLogs = true;
  options.beforeSendLog = (log) {
    if (log.level.toSeverityNumber() <=
        SentryLogLevel.warn.toSeverityNumber()) {
      return null;
    }
    return log;
  };

  options.navigatorKey = navigatorKey;
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
                var platformSeedColor =
                    ({
                      Brightness.light: light?.primary,
                      Brightness.dark: dark?.primary,
                    }[switch (settings.themeMode()) {
                      ThemeMode.light => Brightness.light,
                      ThemeMode.dark => Brightness.dark,
                      ThemeMode.system => MediaQuery.of(
                        context,
                      ).platformBrightness,
                    }]);
                final seedColor = settings.usesDynamicColor()
                    ? platformSeedColor ?? settings.color()
                    : settings.color();

                return AnimatedBuilder(
                  animation: localizations,
                  builder: (context, _) {
                    final systemLocale =
                        WidgetsBinding.instance.platformDispatcher.locale;
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
                          settings.locale.value ??
                          Prefs.defaultValue.locale ??
                          systemLocale,
                      supportedLocales: GTLocalizations.supportedLocales,
                      fallbackLocale: const Locale('en'),
                      localizationsDelegates: const [
                        RelativeTimeLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        FlutterQuillLocalizations.delegate,
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
                          WorkoutSimpleView.routeName => Go.materialRoute(
                            () => const WorkoutSimpleView(),
                            settings: settings,
                          ),
                          ErrorView.routeName => Go.materialRoute(
                            () => const ErrorView(),
                            settings: settings,
                          ),
                          PaywallScreen.routeName => Go.materialRoute(
                            () => const PaywallScreen(),
                            settings: settings,
                          ),
                          null || String() => throw Exception(
                            "Invalid route: ${settings.name}",
                          ),
                        };
                      },
                      debugShowCheckedModeBanner: false,
                      builder: (context, child) =>
                          AnnotatedRegion<SystemUiOverlayStyle>(
                            value: SystemUiOverlayStyle(
                              systemNavigationBarColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              systemNavigationBarIconBrightness:
                                  Theme.of(context).colorScheme.surface
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
                      navigatorObservers: [
                        LoggerNavigationObserver(),
                        SentryNavigatorObserver(),
                      ],
                      navigatorKey: navigatorKey,
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

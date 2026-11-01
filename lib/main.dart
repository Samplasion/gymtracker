// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_sim/device_sim.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/licenses.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/router.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/charts/density_calendar_chart.dart'
    show DensityCalendarChart;
import 'package:gymtracker/view/charts/line_charts_time_series.dart';
import 'package:gymtracker/view/charts/weight_chart.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:gymtracker/view/debug/iphone15.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:relative_time/relative_time.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = Go.navigatorKey;

void main() async {
  if (kDebugMode) {
    print(
      "Health check: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}",
    );
  }

  initLicenses();

  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  SentryWidgetsFlutterBinding.ensureInitialized();

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

  initLogger();

  await ColorService().init();
  await VersionService().init();

  final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

  await SentryFlutter.init(
    _sentryInit,
    appRunner: () => runApp(
      SentryWidget(
        child: ProviderScope(child: TranslationProvider(child: MainApp())),
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

  options.addIntegration(
    LoggingIntegration(
      minBreadcrumbLevel: Level.INFO,
      minEventLevel: Level.SEVERE,
    ),
  );

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

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp>
    with LoggerConfigurationMixin {
  StreamSubscription<Map<Achievement, List<AchievementCompletion>>>?
  _achievementSubscription;

  StreamSubscription<NotificationResponse>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = ref
        .read(notificationEventsProvider)
        .stream
        .listen((response) async {
          if (response.payload?.startsWith('social:') == true) return;
          await ref.read(appStartupProvider.future);
          if (!mounted || ref.read(workoutControllerProvider) == null) return;
          ref
              .read(workoutControllerProvider.notifier)
              .onNotificationTapped(
                response,
                simple: ref
                    .read(settingsControllerProvider)
                    .defaultToSimpleWorkoutView,
              );
        });
    ref.listenManual(appStartupProvider, (_, next) {
      if (!next.hasValue) return;
      _achievementSubscription?.cancel();
      _achievementSubscription = ref
          .read(achievementsControllerProvider)
          .unlocked
          .listen((unlocked) {
            if (!mounted) return;
            for (final entry in unlocked.entries) {
              for (final completion in entry.value) {
                Go.customSnack(
                  AchievementSnackBar(
                    achievement: entry.key,
                    completion: completion,
                  ),
                );
              }
            }
          });
    });
  }

  @override
  void dispose() {
    _achievementSubscription?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  int loggerMethodCount = 0;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    ref.watch(loggerControllerInstanceProvider);
    ref.watch(meControllerProvider);
    final showSimulator = ref.watch(
      debugControllerProvider.select((s) => s.showSimulator),
    );
    final settings = ref.watch(settingsControllerInstanceProvider);
    ref.watch(appPreferencesProvider);

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
                    }[switch (settings.themeMode) {
                      ThemeMode.light => Brightness.light,
                      ThemeMode.dark => Brightness.dark,
                      ThemeMode.system => MediaQuery.platformBrightnessOf(
                        context,
                      ),
                    }]);
                final seedColor = settings.usesDynamicColor
                    ? platformSeedColor ?? settings.color
                    : settings.color;

                return MaterialApp.router(
                  routerConfig: router,
                  title: () {
                    if (kDebugMode) {
                      return "${context.t.appName} (Debug)";
                    } else {
                      return context.t.appName;
                    }
                  }(),
                  locale: TranslationProvider.of(context).flutterLocale,
                  supportedLocales: AppLocaleUtils.supportedLocales,
                  localizationsDelegates: const [
                    RelativeTimeLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    FlutterQuillLocalizations.delegate,
                  ],
                  themeMode: settings.themeMode,
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
                  debugShowCheckedModeBanner: false,
                  builder: (context, child) =>
                      AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          systemNavigationBarColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          systemNavigationBarIconBrightness: Theme.of(
                            context,
                          ).colorScheme.surface.estimateForegroundBrightness(),
                        ),
                        child: GTExpressiveTheme(
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                );
              }(),
            );
          },
        );
      },
    );

    if (showSimulator) {
      return DeviceSim(
        builder: (context) => application,
        devices: const [iphone13Mini, iphone15, ipad129Gen5],
      );
    }

    return application;
  }
}

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/notifications.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final _databaseService = DatabaseService();

void main() async {
  await GetStorage.init();

  final l = GTLocalizations();
  await l.init();

  await _databaseService.ensureInitialized();

  await ColorService().init();
  await VersionService().init();

  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  await protocolHandler.register('gymtracker');

  runApp(MainApp(localizations: l, databaseService: _databaseService));
}

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
    Get.put(NotificationsService());
    Get.put(CountdownController());
    Get.put(ExercisesController());
    Get.put(DebugController());
    Get.put(StopwatchController());
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
                      title: () {
                        if (kDebugMode) {
                          return "${"appName".t} (Debug)";
                        } else {
                          return "appName".t;
                        }
                      }(),
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

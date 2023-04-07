import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/view/skeleton.dart';

import 'controller/exercises_controller.dart';
import 'controller/settings_controller.dart';
import 'service/database.dart';
import 'service/localizations.dart';
import 'service/notifications.dart';
import 'utils/go.dart';
import 'view/routines.dart';

final _databaseService = DatabaseService();

void main() async {
  await GetStorage.init();

  final l = GTLocalizations();
  await l.init();

  await _databaseService.ensureInitialized();

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
    final settings = Get.put(SettingsController());
    final localizations = Get.put(this.localizations);

    const seedColor = Colors.blue;
    return DynamicColorBuilder(builder: (light, dark) {
      return Obx(
        () {
          final lightScheme = (light != null && settings.usesDynamicColor())
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
                  print(settings.locale.value);
                  return settings.locale.value;
                }(),
                fallbackLocale: const Locale('en'),
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
                  ),
                  child: child ?? Container(),
                ),
              );
            },
          );
        },
      );
    });
  }
}

/// A widget that launches the actual root widget.
///
/// Used to force the root widget to be an
/// animated route, so that exit animations work.
class _Loader extends StatefulWidget {
  const _Loader({super.key});

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

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/converters.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/logs.dart';
import 'package:gymtracker/view/migrations.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:share_plus/share_plus.dart';

Color defaultColor = Color(Colors.blue.value);

SettingsController get settingsController => Get.find<SettingsController>();

class SettingsController extends GetxController with ServiceableController {
  RxBool hasInitialized = false.obs;
  RxBool usesDynamicColor = Prefs.defaultValue.usesDynamicColor.obs;
  Rx<Color> color = Prefs.defaultValue.color.obs;
  Rx<Locale?> locale = Prefs.defaultValue.locale.obs;
  Rx<Weights> weightUnit = Prefs.defaultValue.weightUnit.obs;
  Rx<Distance> distanceUnit = Prefs.defaultValue.distanceUnit.obs;
  RxBool showSuggestedRoutines = Prefs.defaultValue.showSuggestedRoutines.obs;
  Rx<ThemeMode> themeMode = Prefs.defaultValue.themeMode.obs;
  RxBool tintExercises = Prefs.defaultValue.tintExercises.obs;
  Rx<NutritionLanguage> nutritionLanguage =
      Prefs.defaultValue.nutritionLanguage.obs;
  Rx<NutritionCountry> nutritionCountry =
      Prefs.defaultValue.nutritionCountry.obs;

  void setUsesDynamicColor(bool usesDC) =>
      service.writeSettings(service.prefs$.value.copyWith(
        usesDynamicColor: usesDC,
      ));

  void setColor(Color color) =>
      service.writeSettings(service.prefs$.value.copyWith(color: color));

  void setLocale(Locale locale) {
    Get.updateLocale(locale);
    service.writeSettings(service.prefs$.value.copyWith(locale: locale));
  }

  void setWeightUnit(Weights weightUnit) =>
      service.writeSettings(service.prefs$.value.copyWith(
        weightUnit: weightUnit,
      ));

  void setDistanceUnit(Distance distanceUnit) =>
      service.writeSettings(service.prefs$.value.copyWith(
        distanceUnit: distanceUnit,
      ));

  void setShowSuggestedRoutines(bool show) =>
      service.writeSettings(service.prefs$.value.copyWith(
        showSuggestedRoutines: show,
      ));

  void setThemeMode(ThemeMode themeMode) =>
      service.writeSettings(service.prefs$.value.copyWith(
        themeMode: themeMode,
      ));

  void setTintExercises(bool tintExercises) =>
      service.writeSettings(service.prefs$.value.copyWith(
        tintExercises: tintExercises,
      ));

  void setNutritionLanguage(NutritionLanguage nutritionLanguage) =>
      service.writeSettings(service.prefs$.value.copyWith(
        nutritionLanguage: nutritionLanguage,
      ));

  void setNutritionCountry(NutritionCountry nutritionCountry) =>
      service.writeSettings(service.prefs$.value.copyWith(
        nutritionCountry: nutritionCountry,
      ));

  @override
  void onInit() {
    super.onInit();

    service.prefs$.listen((prefs) {
      hasInitialized(true);

      Get.updateLocale(prefs.locale);

      usesDynamicColor(prefs.usesDynamicColor);
      color(prefs.color);
      locale(prefs.locale);
      weightUnit(prefs.weightUnit);
      distanceUnit(prefs.distanceUnit);
      showSuggestedRoutines(prefs.showSuggestedRoutines);
      themeMode(prefs.themeMode);
      tintExercises(prefs.tintExercises);
      nutritionLanguage(prefs.nutritionLanguage);
      nutritionCountry(prefs.nutritionCountry);

      notifyChildrens();
    });
  }

  @override
  void onServiceChange() {
    final prefs = service.prefs$.value;

    usesDynamicColor(prefs.usesDynamicColor);
    color(prefs.color);
    locale(prefs.locale);
    weightUnit(prefs.weightUnit);
    distanceUnit(prefs.distanceUnit);
    showSuggestedRoutines(prefs.showSuggestedRoutines);
    themeMode(prefs.themeMode);
    tintExercises(prefs.tintExercises);
    nutritionLanguage(prefs.nutritionLanguage);
    nutritionCountry(prefs.nutritionCountry);

    notifyChildrens();
  }

  Future exportSettings(BuildContext context) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(json.encode(service.toJson()))),
            mimeType: "application/json",
            name:
                "${"settings.options.export.filename".t}_${DateTime.now().toIso8601String()}.json",
          )
        ],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e, s) {
      logger.e(null, error: e, stackTrace: s);

      Go.dialog(
        "settings.options.export.failed.title".t,
        "$e\n$s".trim(),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "$e\n$s".trim()));
              Go.snack("settings.options.export.failed.copy".t);
            },
            child: Text(
              // ignore: use_build_context_synchronously
              MaterialLocalizations.of(context).copyButtonLabel,
            ),
          )
        ],
        bodyStyle: monospace,
      );
    }
  }

  Future importSettings(BuildContext context) async {
    final choice = await Go.pick(
      title: "settings.options.import.label".t,
      values: {
        "gt": "settings.options.import.types.gt".t,
        "hevy": "settings.options.import.types.hevy".t,
      },
    );

    if (choice == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String content;

    if (kIsWeb && result?.files.single.bytes != null) {
      content = String.fromCharCodes(result!.files.single.bytes!.toList());
    } else if (!kIsWeb && result?.files.single.path != null) {
      File file = File(result!.files.single.path!);
      content = await file.readAsString();
    } else {
      // User canceled the picker
      logger.i("Picker canceled");
      return;
    }

    try {
      switch (choice) {
        case "gt":
          // ignore: use_build_context_synchronously
          await _importGTJson(context, content);
          break;
        case "hevy":
          // ignore: use_build_context_synchronously
          await _importHevy(context, content);
          break;
      }

      Go.snack("settings.options.import.success".t);
    } catch (e, s) {
      logger.e("", error: e, stackTrace: s);

      String errorString = e.toString();
      if (e is Error) {
        errorString = "$errorString\n${e.stackTrace}";
      }

      Go.dialog(
        "settings.options.import.failed.title".t,
        errorString,
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorString));
              Go.snack("settings.options.import.failed.copy".t);
            },
            child: Text(
                // ignore: use_build_context_synchronously
                MaterialLocalizations.of(context).copyButtonLabel),
          )
        ],
      );
    }
  }

  Future _importGTJson(BuildContext context, String content) async {
    Map<String, dynamic> map = json.decode(content);

    await service.fromJson(map);
  }

  Future _importHevy(BuildContext context, String content) async {
    List<List<dynamic>> data =
        const CsvToListConverter().convert(content, eol: "\n");
    final header = data.removeAt(0);

    if (header.contains("fat_percent")) {
      final measurementData = convertHevyMeasurementData(data);

      await service.addWeightMeasurements(measurementData.weightMeasurements);
    } else {
      final workoutData = convertHevyWorkoutData(data);

      await service.addExercises(workoutData.customExercises);
      await service.addHistoryWorkouts(workoutData.workouts);
    }
  }

  /// Waits for the database to fire the first "Preferences loaded" event.
  ///
  /// Guaranteed to always return if the first event has already been fired.
  /// Otherwise, it is guaranteed to return in 5 seconds if the database
  /// doesn't fire the event for some reason.
  Future<void> awaitInitialized() async {
    if (hasInitialized()) return;
    await Future.any([
      service.db.watchPreferences().first,
      Future.delayed(const Duration(seconds: 5)),
    ]);
  }

  showLogs() {
    Go.to(() => const LogView());
  }

  showMigrations() {
    Go.to(() => const AllMigrationsView());
  }

  bool get canExportRaw => service.canExportRaw;
  exportRawDatabase(BuildContext context) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [
          XFile(
            (await service.exportRaw()).path,
            mimeType: "application/octet-stream",
            name:
                "${"settings.options.export.filename".t}_${DateTime.now().toIso8601String()}.db",
          )
        ],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e, s) {
      logger.e(null, error: e, stackTrace: s);

      Go.dialog(
        "settings.options.export.failed.title".t,
        "$e\n$s".trim(),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "$e\n$s".trim()));
              Go.snack("settings.options.export.failed.copy".t);
            },
            child: Text(
              // ignore: use_build_context_synchronously
              MaterialLocalizations.of(context).copyButtonLabel,
            ),
          )
        ],
        bodyStyle: monospace,
      );
    }
  }

  showBackups() {
    Go.to(() => const BackupListView());
  }
}

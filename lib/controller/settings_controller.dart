import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/data/converters.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

Color defaultColor = Color(Colors.blue.hexValue);

class SettingsController {
  SettingsController({required Ref ref}) : _ref = ref;
  final Ref _ref;
  DatabaseService get service => _ref.read(databaseServiceProvider);
  Prefs get _preferences =>
      _ref.read(appPreferencesProvider).value ?? service.prefs$.value;
  bool get hasInitialized => _ref.read(appPreferencesProvider).hasValue;
  bool get usesDynamicColor => _preferences.usesDynamicColor;
  Color get color => _preferences.color;
  Locale get locale => _preferences.locale ?? kSystemLocaleSentinel;
  Weights get weightUnit => _preferences.weightUnit;
  Distance get distanceUnit => _preferences.distanceUnit;
  bool get showSuggestedRoutines => _preferences.showSuggestedRoutines;
  ThemeMode get themeMode => _preferences.themeMode;
  bool get tintExercises => _preferences.tintExercises;
  bool get defaultToSimpleWorkoutView =>
      _preferences.defaultToSimpleWorkoutView;
  NutritionLanguage get nutritionLanguage => _preferences.nutritionLanguage;
  NutritionCountry get nutritionCountry => _preferences.nutritionCountry;

  Future<void> setUsesDynamicColor(bool usesDC) =>
      service.writeSettings(_preferences.copyWith(usesDynamicColor: usesDC));

  Future<void> setColor(Color color) =>
      service.writeSettings(_preferences.copyWith(color: color));

  Future<void> setLocale(Locale? locale) {
    if (locale == kSystemLocaleSentinel) {
      locale = null;
    }
    if (locale == null) {
      LocaleSettings.useDeviceLocaleSync();
    } else {
      LocaleSettings.setLocaleRaw(locale.languageCode);
    }
    _ref
        .read(translationsProvider.notifier)
        .setLocale(locale ?? _ref.read(platformLocaleProvider));
    return service.writeSettings(_preferences.copyWith(locale: locale));
  }

  Future<void> setWeightUnit(Weights weightUnit) =>
      service.writeSettings(_preferences.copyWith(weightUnit: weightUnit));

  Future<void> setDistanceUnit(Distance distanceUnit) =>
      service.writeSettings(_preferences.copyWith(distanceUnit: distanceUnit));

  Future<void> setShowSuggestedRoutines(bool show) =>
      service.writeSettings(_preferences.copyWith(showSuggestedRoutines: show));

  Future<void> setThemeMode(ThemeMode themeMode) =>
      service.writeSettings(_preferences.copyWith(themeMode: themeMode));

  Future<void> setTintExercises(bool tintExercises) => service.writeSettings(
    _preferences.copyWith(tintExercises: tintExercises),
  );

  Future<void> setDefaultToSimpleWorkoutView(bool value) => service
      .writeSettings(_preferences.copyWith(defaultToSimpleWorkoutView: value));

  Future<void> setNutritionLanguage(NutritionLanguage nutritionLanguage) =>
      service.writeSettings(
        _preferences.copyWith(nutritionLanguage: nutritionLanguage),
      );

  Future<void> setNutritionCountry(NutritionCountry nutritionCountry) => service
      .writeSettings(_preferences.copyWith(nutritionCountry: nutritionCountry));

  Future<void> importHevy(String content) async {
    List<List<dynamic>> data = const CsvDecoder().convert(content);
    final header = data.removeAt(0);

    if (header.contains("fat_percent")) {
      final measurementData = convertHevyMeasurementData(data);

      await service.transaction(() async {
        await service.addWeightMeasurements(measurementData.weightMeasurements);
        await service.addBodyMeasurements(measurementData.bodyMeasurements);
      });
    } else {
      final workoutData = convertHevyWorkoutData(data);

      await service.transaction(() async {
        await service.addExercises(workoutData.customExercises);
        await service.addHistoryWorkouts(workoutData.workouts);
      });
    }
  }

  /// Waits for the database to fire the first "Preferences loaded" event.
  ///
  /// Guaranteed to always return if the first event has already been fired.
  /// Otherwise, it is guaranteed to return in 5 seconds if the database
  /// doesn't fire the event for some reason.
  Future<void> awaitInitialized() async {
    if (hasInitialized) return;
    await Future.any([
      service.db.watchPreferences().first,
      Future.delayed(const Duration(seconds: 5)),
    ]);
  }

  bool get canExportRaw => service.canExportRaw;
}

@Riverpod(keepAlive: true)
SettingsController settingsControllerInstance(Ref ref) {
  ref.watch(appPreferencesProvider);
  ref.listen(appPreferencesProvider, (_, next) {
    final prefs = next.value;
    if (prefs == null) return;
    final locale = prefs.locale == kSystemLocaleSentinel ? null : prefs.locale;
    ref
        .read(translationsProvider.notifier)
        .setLocale(locale ?? ref.read(platformLocaleProvider));
  });
  final controller = SettingsController(ref: ref);
  return controller;
}

final settingsControllerProvider = settingsControllerInstanceProvider;

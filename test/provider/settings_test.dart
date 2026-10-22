import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabase db;
  late DatabaseService service;
  late ProviderContainer container;
  late SettingsController commands;

  Future<Prefs> until(bool Function(Prefs) matches) {
    final done = Completer<Prefs>();
    final sub = container.listen(appPreferencesProvider, (_, next) {
      if (next.value case final prefs?) {
        if (matches(prefs) && !done.isCompleted) done.complete(prefs);
      }
    }, fireImmediately: true);
    return done.future.whenComplete(sub.close);
  }

  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    service = DatabaseService.withDatabase(db);
    container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(service),
        appDatabaseProvider.overrideWithValue(db),
        platformLocaleProvider.overrideWithValue(const Locale('en')),
      ],
    );
    container.listen(appPreferencesProvider, (_, _) {});
    commands = container.read(settingsControllerInstanceProvider);
    await container.read(appPreferencesProvider.future);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'commands persist each preference without resetting other values',
    () async {
      await commands.setWeightUnit(Weights.lb);
      await until((prefs) => prefs.weightUnit == Weights.lb);
      await commands.setDistanceUnit(Distance.mi);
      await until((prefs) => prefs.distanceUnit == Distance.mi);
      await commands.setColor(const Color(0xFFB01234));
      await until((prefs) => prefs.color == const Color(0xFFB01234));
      await commands.setThemeMode(ThemeMode.dark);
      final prefs = await until((prefs) => prefs.themeMode == ThemeMode.dark);
      expect(prefs.weightUnit, Weights.lb);
      expect(prefs.distanceUnit, Distance.mi);
      expect(prefs.color, const Color(0xFFB01234));
      expect(commands.hasInitialized, isTrue);
      expect(commands.weightUnit, Weights.lb);
      expect(commands.themeMode, ThemeMode.dark);
    },
  );

  test(
    'remaining preferences and system language use the same persisted source',
    () async {
      await commands.setUsesDynamicColor(false);
      await until((prefs) => !prefs.usesDynamicColor);
      await commands.setShowSuggestedRoutines(false);
      await until((prefs) => !prefs.showSuggestedRoutines);
      await commands.setTintExercises(false);
      await until((prefs) => !prefs.tintExercises);
      await commands.setDefaultToSimpleWorkoutView(true);
      await until((prefs) => prefs.defaultToSimpleWorkoutView);
      final language = NutritionLanguage.values.firstWhere(
        (value) => value != Prefs.defaultValue.nutritionLanguage,
      );
      final country = NutritionCountry.values.firstWhere(
        (value) => value != Prefs.defaultValue.nutritionCountry,
      );
      await commands.setNutritionLanguage(language);
      await until((prefs) => prefs.nutritionLanguage == language);
      await commands.setNutritionCountry(country);
      await until((prefs) => prefs.nutritionCountry == country);
      expect(commands.locale, kSystemLocaleSentinel);
      await commands.setLocale(const Locale('it'));
      await until((prefs) => prefs.locale?.languageCode == 'it');
      expect(commands.locale, const Locale('it'));
      expect(
        container.read(translationsProvider).$meta.locale.languageCode,
        'it',
      );
      await commands.setLocale(kSystemLocaleSentinel);
      final prefs = await until((prefs) => prefs.locale == null);
      expect(commands.locale, kSystemLocaleSentinel);
      expect(
        container.read(translationsProvider).$meta.locale.languageCode,
        'en',
      );
      expect(prefs.nutritionLanguage, language);
      expect(prefs.nutritionCountry, country);
      expect(prefs.defaultToSimpleWorkoutView, isTrue);
      expect(prefs.usesDynamicColor, isFalse);
      expect(prefs.showSuggestedRoutines, isFalse);
      expect(prefs.tintExercises, isFalse);
    },
  );

  test(
    'external preference writes update getters and locale from the same stream',
    () async {
      await db.setPreferences(
        Prefs.defaultValue.copyWith(
          weightUnit: Weights.lb,
          locale: const Locale('it'),
          tintExercises: true,
        ),
      );
      await until((prefs) => prefs.locale?.languageCode == 'it');
      expect(commands.weightUnit, Weights.lb);
      expect(commands.locale.languageCode, 'it');
      expect(commands.tintExercises, isTrue);
      expect(container.read(translationsProvider).appName, isNotEmpty);
    },
  );
}

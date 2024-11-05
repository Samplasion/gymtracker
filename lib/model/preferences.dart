import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';

class Prefs implements Insertable<Preference> {
  final bool usesDynamicColor;
  final Color color;
  final Locale locale;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool showSuggestedRoutines;
  final ThemeMode themeMode;
  final bool tintExercises;
  final NutritionLanguage nutritionLanguage;
  final NutritionCountry nutritionCountry;

  const Prefs({
    required this.usesDynamicColor,
    required this.color,
    required this.locale,
    required this.weightUnit,
    required this.distanceUnit,
    required this.showSuggestedRoutines,
    required this.themeMode,
    required this.tintExercises,
    required this.nutritionLanguage,
    required this.nutritionCountry,
  });

  factory Prefs.fromDatabase(Preference row) =>
      Prefs.fromJson(jsonDecode(row.data));

  static const defaultValue = Prefs(
    usesDynamicColor: true,
    color: Color(0xFF2196F3),
    locale: Locale("en"),
    weightUnit: Weights.kg,
    distanceUnit: Distance.km,
    showSuggestedRoutines: true,
    themeMode: ThemeMode.system,
    tintExercises: true,
    nutritionLanguage: NutritionLanguage.WORLD,
    nutritionCountry: NutritionCountry.WORLD,
  );

  Map<String, dynamic> toJson() => {
        "usesDynamicColor": usesDynamicColor,
        "color": color.value,
        "locale": [
          locale.languageCode,
          if (locale.scriptCode != null) locale.scriptCode!
        ],
        "weightUnit": weightUnit.name,
        "distanceUnit": distanceUnit.name,
        "showSuggestedRoutines": showSuggestedRoutines,
        "themeMode": themeMode.name,
        "tintExercises": tintExercises,
        "nutritionLanguage": nutritionLanguage.stringValue,
        "nutritionCountry": nutritionCountry.stringValue,
      };

  factory Prefs.fromJson(Map<String, dynamic> json) {
    const defaults = Prefs.defaultValue;
    final lang = (json['locale'] as List?)?.map((v) => "$v").toList();
    return Prefs(
      usesDynamicColor: json['usesDynamicColor'] ?? defaults.usesDynamicColor,
      color: json['color'] == null ? defaults.color : Color(json['color']),
      locale: lang == null || lang.isEmpty
          ? defaults.locale
          : Locale(lang[0], lang.getAt(1)),
      weightUnit: json['weightUnit'] == null
          ? defaults.weightUnit
          : Weights.values.firstWhere((w) => w.name == json['weightUnit']),
      distanceUnit: json['distanceUnit'] == null
          ? defaults.distanceUnit
          : Distance.values.firstWhere((d) => d.name == json['distanceUnit']),
      showSuggestedRoutines:
          json['showSuggestedRoutines'] ?? defaults.showSuggestedRoutines,
      themeMode: ThemeMode.values.firstWhere(
        (t) => t.name == json['themeMode'],
        orElse: () => defaults.themeMode,
      ),
      tintExercises: json['tintExercises'] ?? defaults.tintExercises,
      nutritionLanguage: NutritionLanguage.fromString(
        json['nutritionLanguage'] ?? defaults.nutritionLanguage.stringValue,
      )!,
      nutritionCountry: NutritionCountry.fromString(
        json['nutritionCountry'] ?? defaults.nutritionCountry.stringValue,
      )!,
    );
  }

  @override
  String toString() {
    return """Prefs(
  usesDynamicColor: $usesDynamicColor,
  color: $color,
  locale: $locale,
  weightUnit: $weightUnit,
  distanceUnit: $distanceUnit,
  showSuggestedRoutines: $showSuggestedRoutines,
  themeMode: $themeMode,
  tintExercises: $tintExercises,
  nutritionLanguage: $nutritionLanguage,
  nutritionCountry: $nutritionCountry,
)""";
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return PreferencesCompanion(
      data: Value(jsonEncode(toJson())),
    ).toColumns(nullToAbsent);
  }

  Prefs copyWith({
    bool? usesDynamicColor,
    Color? color,
    Locale? locale,
    Weights? weightUnit,
    Distance? distanceUnit,
    bool? showSuggestedRoutines,
    ThemeMode? themeMode,
    bool? tintExercises,
    NutritionLanguage? nutritionLanguage,
    NutritionCountry? nutritionCountry,
  }) {
    return Prefs(
      usesDynamicColor: usesDynamicColor ?? this.usesDynamicColor,
      color: color ?? this.color,
      locale: locale ?? this.locale,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      showSuggestedRoutines:
          showSuggestedRoutines ?? this.showSuggestedRoutines,
      themeMode: themeMode ?? this.themeMode,
      tintExercises: tintExercises ?? this.tintExercises,
      nutritionLanguage: nutritionLanguage ?? this.nutritionLanguage,
      nutritionCountry: nutritionCountry ?? this.nutritionCountry,
    );
  }
}

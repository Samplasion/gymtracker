import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/utils/extensions.dart';

class Prefs implements Insertable<Preference> {
  final bool usesDynamicColor;
  final Color color;
  final Locale locale;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool showSuggestedRoutines;

  const Prefs({
    required this.usesDynamicColor,
    required this.color,
    required this.locale,
    required this.weightUnit,
    required this.distanceUnit,
    required this.showSuggestedRoutines,
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
      };

  factory Prefs.fromJson(Map<String, dynamic> json) {
    final lang = (json['locale'] as List).map((v) => "$v").toList();
    return Prefs(
      usesDynamicColor: json['usesDynamicColor'],
      color: Color(json['color']),
      locale: Locale(lang[0], lang.getAt(1)),
      weightUnit:
          Weights.values.firstWhere((w) => w.name == json['weightUnit']),
      distanceUnit:
          Distance.values.firstWhere((d) => d.name == json['distanceUnit']),
      showSuggestedRoutines: json['showSuggestedRoutines'],
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
  }) {
    return Prefs(
      usesDynamicColor: usesDynamicColor ?? this.usesDynamicColor,
      color: color ?? this.color,
      locale: locale ?? this.locale,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      showSuggestedRoutines:
          showSuggestedRoutines ?? this.showSuggestedRoutines,
    );
  }
}

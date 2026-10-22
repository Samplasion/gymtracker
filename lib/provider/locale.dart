import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale.g.dart';

const kSystemLocaleSentinel = Locale("SYSTEM");

Locale _getPlatformLocale() {
  String _platformLocaleName = Platform.localeName;

  // Language code only
  if (_platformLocaleName.length == 2) {
    return Locale.fromSubtags(languageCode: _platformLocaleName);
  }

  // Language and country codes
  String _languageCode = _platformLocaleName.substring(
    0,
    _platformLocaleName.indexOf('_'),
  );
  String _countryCode = _platformLocaleName.substring(
    _platformLocaleName.indexOf('_') + 1,
  );

  return Locale.fromSubtags(
    languageCode: _languageCode,
    countryCode: _countryCode,
  );
}

final platformLocaleProvider = Provider<Locale>((_) {
  Locale _platformLocale = _getPlatformLocale();
  return _platformLocale;
});

final translations = {
  for (final locale in AppLocale.values) locale: locale.buildSync(),
};

@Riverpod(keepAlive: true)
class TranslationsNotifier extends _$TranslationsNotifier {
  /// Maps each language to its corresponding exercise explanations, by exercise ID.
  final Map<String, Map<String, String>> exerciseExplanations = {};

  @override
  Translations build() {
    return translations[getLocale()]!;
  }

  AppLocale getLocale() {
    return LocaleSettings.currentLocale;
  }

  void setLocale(Locale locale) {
    final parsed = AppLocaleUtils.parse(locale.languageCode);
    state = translations[parsed]!;
    LocaleSettings.setLocaleSync(parsed);
  }

  Future<void> loadExercises() async {
    final exercises = exerciseStandardLibrary.values
        .map((category) {
          return category.exercises.map((exercise) {
            final [_, category, _, id] = exercise.id.split(".");
            return (exercise.id, category, id);
          }).toList();
        })
        .expand((element) => element)
        .toList();

    for (final locale in AppLocale.values) {
      exerciseExplanations.putIfAbsent(locale.languageCode, () => {});

      for (final (fullID, category, id) in exercises) {
        try {
          final bundle = await rootBundle.loadString(
            'assets/exercises/$category/$id/${locale.languageCode}.md',
            cache: false,
          );
          exerciseExplanations[locale.languageCode]![fullID] = bundle;
        } catch (e) {
          continue;
        }
      }
    }
  }
}

@riverpod
String? exerciseExplanation(Ref ref, String exerciseID) {
  final locale = LocaleSettings.currentLocale;
  final explanations = ref
      .watch(translationsProvider.notifier)
      .exerciseExplanations;
  return explanations[locale.languageCode]?[exerciseID] ??
      explanations[AppLocale.en.languageCode]?[exerciseID];
}

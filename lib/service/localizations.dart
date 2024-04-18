import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:intl/intl.dart';

class GTLocalizations extends Translations with ChangeNotifier {
  @override
  final Map<String, Map<String, String>> keys = {};

  static final List<Locale> supportedLocales = [
    const Locale("en"),
    const Locale("it"),
  ];

  Map<String, String> flattenTranslations(Map<String, dynamic> json,
      [String prefix = '']) {
    final Map<String, String> translations = {};
    json.forEach((String key, dynamic value) {
      if (value is Map) {
        translations.addAll(
            flattenTranslations(value as Map<String, dynamic>, '$prefix$key.'));
      } else if (value is List) {
        for (var i = 0; i < value.length; i++) {
          translations.addAll(
              flattenTranslations({i.toString(): value[i]}, '$prefix$key.'));
        }
      } else {
        translations['$prefix$key'] = value.toString();
      }
    });
    return translations;
  }

  Future init([bool cache = true]) async {
    for (final locale in supportedLocales) {
      final bundle = await rootBundle
          .loadString('assets/i18n/${locale.languageCode}.json', cache: cache);
      keys[locale.languageCode] = flattenTranslations(jsonDecode(bundle));
    }
    Get.translations.clear();
    Get.addTranslations(keys);
    notifyListeners();
  }

  @visibleForTesting
  initTests(List<Locale> locales) async {
    for (final locale in locales) {
      final bundle = await rootBundle
          .loadString('assets/i18n/${locale.languageCode}.json');
      keys[locale.languageCode] = flattenTranslations(jsonDecode(bundle));
    }
    notifyListeners();
  }

  @override
  notifyListeners() {
    super.notifyListeners();
    Get.delete<GTLocalizations>();
    Get.put(this);
    logger.i("notified listeners");
  }

  /// Returns the first day of the week for the given [context].
  ///
  /// The returned value is converted to a format compatible with [DateTime.weekday].
  /// That is, the returned value is in the range 1 to 7, inclusive.
  static int firstDayOfWeekFor(BuildContext context) {
    final loc = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    return loc == 0 ? 7 : loc;
  }
}

DebugController get _debugController => Get.find<DebugController>();

extension Fallback on String {
  String get t {
    if (tr == this) {
      _debugController.addMissingKey(this);
      return this;
    }
    return tr;
  }

  String tByIndex(int index) {
    return "$this.$index".t;
  }

  String tByIndexWithParams(int index, Map<String, String> params) {
    return "$this.$index".tParams(params);
  }

  String tParams([Map<String, String> params = const {}]) {
    var trans = t;
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        trans = trans.replaceAll('@$key', value);
      });
    }
    return trans;
  }

  bool get existsAsTranslationKey {
    return Get.find<GTLocalizations>()
        .keys[Get.locale!.languageCode]!
        .containsKey(this);
  }
}

extension Plural on String {
  String plural(int howMany, {Map<String, String>? args}) {
    return Intl.plural(
      howMany,
      zero: "$this.zero",
      one: "$this.one",
      two: "$this.two",
      few: "$this.few",
      many: "$this.many",
      other: "$this.other",
      locale: Get.locale!.languageCode,
    ).tParams({
      "howMany": howMany.toString(),
      ...?args,
    }).replaceAll("%s", howMany.toString());
  }
}

extension ContextLocale on BuildContext {
  Locale get locale => Localizations.localeOf(this);
}

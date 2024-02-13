import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

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
      } else {
        translations['$prefix$key'] = value.toString();
      }
    });
    return translations;
  }

  init() async {
    for (final locale in supportedLocales) {
      final bundle =
          await rootBundle.loadString('assets/i18n/${locale.languageCode}.yml');
      keys[locale.languageCode] =
          flattenTranslations(jsonDecode(jsonEncode(loadYaml(bundle))));
    }
    notifyListeners();
  }

  @override
  notifyListeners() {
    super.notifyListeners();
    Get.delete<GTLocalizations>();
    Get.put(this);
    printInfo(info: "notified listeners");
  }
}

extension Fallback on String {
  String get t {
    if (tr == this) {
      Get.find<DebugController>().missingKeys.add(this);
      return this;
    }
    return tr;
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

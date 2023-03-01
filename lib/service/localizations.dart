import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
    // print(keys);
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
    ).trParams({
      "howMany": howMany.toString(),
      ...?args,
    }).replaceAll("%s", howMany.toString());
  }
}

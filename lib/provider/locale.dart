import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Locale _getPlatformLocale() {
  String _platformLocaleName = Platform.localeName;
  print("Platform Locale Name (Mobile): " + _platformLocaleName);

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
  print("Platform Locale: " + _platformLocale.toString());
  return _platformLocale;
});

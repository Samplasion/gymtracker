import 'dart:ui';

import 'package:get/get.dart';

import 'serviceable_controller.dart';

class SettingsController extends GetxController with ServiceableController {
  RxBool usesDynamicColor = false.obs;
  Rx<Locale?> locale = Get.locale.obs;

  void setUsesDynamicColor(bool usesDC) =>
      service.writeSetting("usesDynamicColor", usesDC);
  void setLocale(Locale locale) {
    Get.updateLocale(locale);
    service.writeSetting("locale", locale.languageCode);
  }

  @override
  void onServiceChange() {
    final storage = service.settingsStorage;
    usesDynamicColor(storage.read<bool>("usesDynamicColor") ?? false);
    locale(Locale(storage.read<String>("locale") ?? "en"));
  }
}

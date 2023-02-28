import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';

import '../controller/settings_controller.dart';
import 'settings/radio.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final currentLocale =
        (Get.locale ?? Get.deviceLocale ?? Get.fallbackLocale)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("settings.title".tr),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ValueBuilder<bool?>(
                initialValue: controller.usesDynamicColor.value,
                builder: (value, onChanged) => SwitchListTile(
                  title: Text("settings.options.useDynamicColor.label".tr),
                  value: value ?? false,
                  onChanged: onChanged,
                ),
                onUpdate: (v) => controller.setUsesDynamicColor(v ?? false),
              ),
              Obx(
                () => ValueBuilder<Locale?>(
                  initialValue: controller.locale.value,
                  builder: (value, onChange) => RadioModalTile(
                    title: Text("settings.options.locale.label".tr),
                    onChange: onChange,
                    values: {
                      for (final locale in GTLocalizations.supportedLocales)
                        locale: "locales.${locale.languageCode}".tr,
                    },
                    selectedValue: value,
                  ),
                  onUpdate: (v) => controller.setLocale(v ?? currentLocale),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

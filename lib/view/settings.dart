import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/settings/color.dart';
import 'package:gymtracker/view/settings/radio.dart';

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
            title: Text("settings.title".t),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (ColorService().supportsDynamicColor)
                ValueBuilder<bool?>(
                  initialValue: controller.usesDynamicColor.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title: Text("settings.options.useDynamicColor.label".t),
                    value: value ?? false,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) => controller.setUsesDynamicColor(v ?? false),
                ),
              AnimatedBuilder(
                animation: controller.service,
                builder: (context, _) {
                  final state = (!ColorService().supportsDynamicColor ||
                          !controller.usesDynamicColor.value)
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond;
                  return AnimatedCrossFade(
                    firstChild: Obx(
                      () => ValueBuilder<Color?>(
                        initialValue: controller.color.value,
                        builder: (value, onChange) => ColorModalTile(
                          title: Text("settings.options.color.label".t),
                          onChange: onChange,
                          selectedValue: value ?? Colors.blue,
                        ),
                        onUpdate: (v) => controller.setColor(v ?? Colors.blue),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: state,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              Obx(
                () => ValueBuilder<Locale?>(
                  initialValue: controller.locale.value,
                  builder: (value, onChange) => RadioModalTile(
                    title: Text("settings.options.locale.label".t),
                    onChange: onChange,
                    values: {
                      for (final locale in GTLocalizations.supportedLocales)
                        locale: "locales.${locale.languageCode}".t,
                    },
                    selectedValue: value,
                  ),
                  onUpdate: (v) => controller.setLocale(v ?? currentLocale),
                ),
              ),
              Obx(
                () => ValueBuilder<Weights?>(
                  initialValue: controller.weightUnit.value,
                  builder: (value, onChange) => RadioModalTile<Weights?>(
                    title: Text("settings.options.weightUnit.label".t),
                    onChange: onChange,
                    values: {
                      for (final weight in Weights.values)
                        weight: "weightUnits.${weight.name}".t,
                    },
                    selectedValue: value,
                  ),
                  onUpdate: (v) => controller.setWeightUnit(v ?? Weights.kg),
                ),
              ),
              ListTile(
                title: Text("settings.options.import.label".t),
                onTap: () async {
                  await controller.importSettings(context);
                },
              ),
              ListTile(
                title: Text("settings.options.export.label".t),
                onTap: () async {
                  await controller.exportSettings(context);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

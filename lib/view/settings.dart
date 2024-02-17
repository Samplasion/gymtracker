import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/cupertino/sliver_list_section.dart';
import 'package:gymtracker/view/platform/app_bar.dart';
import 'package:gymtracker/view/platform/list_tile.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';
import 'package:gymtracker/view/platform/scaffold.dart';
import 'package:gymtracker/view/settings/color.dart';
import 'package:gymtracker/view/settings/radio.dart';
import 'package:gymtracker/view/utils/platform_padded.dart';
import 'package:gymtracker/view/utils/restartable.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final platformController = Get.find<PlatformController>();
    final currentLocale =
        (Get.locale ?? Get.deviceLocale ?? Get.fallbackLocale)!;
    return PlatformScaffold(
      body: CustomScrollView(
        slivers: [
          PlatformSliverAppBar(
            title: Text("settings.title".t),
          ),
          PlatformPadded(
            sliver: PlatformBuilder(
              buildMaterial: (context, children) {
                return SliverList(
                  delegate: SliverChildListDelegate(children!),
                );
              },
              buildCupertino: (context, children) {
                return CupertinoListSection.insetGrouped(
                  children: children,
                );
              },
              child: [
                if (ColorService().supportsDynamicColor)
                  ValueBuilder<bool?>(
                    initialValue: controller.usesDynamicColor.value,
                    builder: (value, onChanged) => PlatformSwitchListTile(
                      title: Text("settings.options.useDynamicColor.label".t),
                      value: value ?? false,
                      onChanged: onChanged,
                      cupertinoIsNotched: true,
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
                            cupertinoIsNotched: true,
                          ),
                          onUpdate: (v) =>
                              controller.setColor(v ?? Colors.blue),
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
                      cupertinoIsNotched: true,
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
                      cupertinoIsNotched: true,
                    ),
                    onUpdate: (v) => controller.setWeightUnit(v ?? Weights.kg),
                  ),
                ),
                PlatformListTile(
                  cupertinoIsNotched: true,
                  title: Text("settings.options.import.label".t),
                  onTap: () async {
                    await controller.importSettings(context);
                  },
                ),
                PlatformListTile(
                  cupertinoIsNotched: true,
                  title: Text("settings.options.export.label".t),
                  onTap: () async {
                    await controller.exportSettings(context);
                  },
                ),
                if (platformController.supportsCupertino)
                  PlatformListTile(
                    cupertinoIsNotched: true,
                    title:
                        Text("settings.options.toggleDesignLanguage.label".t),
                    subtitle: Text(
                        "settings.options.toggleDesignLanguage.subtitle".t),
                    onTap: () async {
                      platformController.toggle();
                      Restartable.of(context)?.restart();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

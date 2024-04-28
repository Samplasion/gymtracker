import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/version.dart';
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
                          selectedValue: value ?? Prefs.defaultValue.color,
                        ),
                        onUpdate: (v) =>
                            controller.setColor(v ?? Prefs.defaultValue.color),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: state,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              ValueBuilder<bool?>(
                initialValue: controller.amoledMode.value,
                builder: (value, onChanged) => SwitchListTile(
                  title: Text(
                      "settings.options.amoledMode.label.${context.theme.brightness.name}"
                          .t),
                  value: value ?? Prefs.defaultValue.amoledMode,
                  onChanged: onChanged,
                ),
                onUpdate: (v) => controller
                    .setAmoledMode(v ?? Prefs.defaultValue.amoledMode),
              ),
              Obx(
                () => ValueBuilder<ThemeMode?>(
                  initialValue: controller.themeMode.value,
                  builder: (value, onChange) => RadioModalTile(
                    title: Text("settings.options.themeMode.label".t),
                    onChange: onChange,
                    values: {
                      for (final mode in ThemeMode.values)
                        mode:
                            "settings.options.themeMode.values.${mode.name}".t,
                    },
                    selectedValue: value ?? ThemeMode.system,
                  ),
                  onUpdate: (v) =>
                      controller.setThemeMode(v ?? ThemeMode.system),
                ),
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
              Obx(
                () => ValueBuilder<Distance?>(
                  initialValue: controller.distanceUnit.value,
                  builder: (value, onChange) => RadioModalTile<Distance?>(
                    title: Text("settings.options.distanceUnit.label".t),
                    onChange: onChange,
                    values: {
                      for (final distance in Distance.values)
                        distance: "distanceUnits.${distance.name}".t,
                    },
                    selectedValue: value,
                  ),
                  onUpdate: (v) => controller.setDistanceUnit(v ?? Distance.km),
                ),
              ),
              ValueBuilder<bool?>(
                initialValue: controller.showSuggestedRoutines.value,
                builder: (value, onChanged) => SwitchListTile(
                  title: Text("settings.options.showSuggestedRoutines.label".t),
                  value: value ?? false,
                  onChanged: onChanged,
                ),
                onUpdate: (v) =>
                    controller.setShowSuggestedRoutines(v ?? false),
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
              const Divider(),
              AboutListTileEx(
                applicationName: "appName".t,
                applicationVersion: "appInfo.version".tParams({
                  "version": VersionService().packageInfo.version,
                  "build": const String.fromEnvironment(
                    "BUILD",
                    defaultValue: "[NO_VALUE]",
                  ).replaceAll(
                    "[NO_VALUE]",
                    VersionService().packageInfo.buildNumber,
                  ),
                }),
                aboutBoxChildren: [
                  Text("appInfo.shortDescription".t),
                ],
                applicationIcon: const InAppIcon(),
                icon: const Icon(GymTrackerIcons.info),
                subtitle: Text("appInfo.version".tParams({
                  "version": VersionService().packageInfo.version,
                  "build": const String.fromEnvironment(
                    "BUILD",
                    defaultValue: "[NO_VALUE]",
                  ).replaceAll(
                    "[NO_VALUE]",
                    VersionService().packageInfo.buildNumber,
                  ),
                })),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class InAppIcon extends StatelessWidget {
  final double size;
  final double iconSize;

  const InAppIcon({
    this.size = 48,
    this.iconSize = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(13),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Icon(
          GymTrackerIcons.app_icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: iconSize,
        ),
      ],
    );
  }
}

class AboutListTileEx extends StatelessWidget {
  const AboutListTileEx({
    super.key,
    this.icon,
    this.child,
    this.subtitle,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.aboutBoxChildren,
    this.dense,
  });

  final Widget? icon;
  final Widget? child;
  final Widget? subtitle;
  final String? applicationName;
  final String? applicationVersion;
  final Widget? applicationIcon;
  final String? applicationLegalese;
  final List<Widget>? aboutBoxChildren;
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTile(
      leading: icon,
      title: child ??
          Text(MaterialLocalizations.of(context).aboutListTileTitle(
            applicationName ?? _defaultApplicationName(context),
          )),
      subtitle: subtitle,
      dense: dense,
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: aboutBoxChildren,
        );
      },
    );
  }

  String _defaultApplicationName(BuildContext context) {
    final Title? ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
    return ancestorTitle?.title ??
        Platform.resolvedExecutable.split(Platform.pathSeparator).last;
  }
}

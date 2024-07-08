part of 'settings.dart';

class AppearanceSettingsPane extends ControlledWidget<SettingsController> {
  const AppearanceSettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        (Get.locale ?? Get.deviceLocale ?? Get.fallbackLocale)!;
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("settings.panes.appearance".t),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
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
                          onUpdate: (v) => controller
                              .setColor(v ?? Prefs.defaultValue.color),
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                      crossFadeState: state,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
                Obx(
                  () => ValueBuilder<ThemeMode?>(
                    initialValue: controller.themeMode.value,
                    builder: (value, onChange) => RadioModalTile(
                      title: Text("settings.options.themeMode.label".t),
                      onChange: onChange,
                      values: {
                        for (final mode in ThemeMode.values)
                          mode: "settings.options.themeMode.values.${mode.name}"
                              .t,
                      },
                      selectedValue: value ?? ThemeMode.system,
                    ),
                    onUpdate: (v) =>
                        controller.setThemeMode(v ?? ThemeMode.system),
                  ),
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
                ValueBuilder<bool?>(
                  initialValue: controller.tintExercises.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title: Text("settings.options.tintExercises.label".t),
                    subtitle: Text("settings.options.tintExercises.subtitle".t),
                    value: value ?? Prefs.defaultValue.tintExercises,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) => controller
                      .setTintExercises(v ?? Prefs.defaultValue.tintExercises),
                ),
                ValueBuilder<bool?>(
                  initialValue: controller.showSuggestedRoutines.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title:
                        Text("settings.options.showSuggestedRoutines.label".t),
                    value: value ?? false,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) =>
                      controller.setShowSuggestedRoutines(v ?? false),
                ),
                Get.find<NotificationController>().settingsTile,
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverBottomSafeArea(),
          ],
        ),
      ),
    );
  }
}

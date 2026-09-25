part of 'settings.dart';

class AppearanceSettingsPane extends ControlledWidget<SettingsController> {
  const AppearanceSettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(context.t.settings.panes.appearance),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Obx(
                  () => ValueBuilder<Locale?>(
                    initialValue: controller.locale.value,
                    builder: (value, onChange) => RadioModalTile(
                      title: Text(context.t.settings.options.locale.label),
                      onChange: onChange,
                      values: {
                        kSystemLocaleSentinel:
                            context.t.settings.options.locale.values.system,
                        for (final locale in AppLocale.values)
                          locale.flutterLocale:
                              context.t.locales[locale.languageCode] ??
                              "UNKNOWN",
                      },
                      selectedValue: value,
                    ),
                    onUpdate: (v) => controller.setLocale(v),
                  ),
                ),
                if (ColorService().supportsDynamicColor)
                  ValueBuilder<bool?>(
                    initialValue: controller.usesDynamicColor.value,
                    builder: (value, onChanged) => SwitchListTile(
                      title: Text(
                        context.t.settings.options.useDynamicColor.label,
                      ),
                      value: value ?? false,
                      onChanged: onChanged,
                    ),
                    onUpdate: (v) => controller.setUsesDynamicColor(v ?? false),
                  ),
                AnimatedBuilder(
                  animation: controller.service,
                  builder: (context, _) {
                    final state =
                        (!ColorService().supportsDynamicColor ||
                            !controller.usesDynamicColor.value)
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond;
                    return AnimatedCrossFade(
                      firstChild: Obx(
                        () => ValueBuilder<Color?>(
                          initialValue: controller.color.value,
                          builder: (value, onChange) => ColorModalTile(
                            title: Text(context.t.settings.options.color.label),
                            onChange: onChange,
                            selectedValue: value ?? Prefs.defaultValue.color,
                          ),
                          onUpdate: (v) => controller.setColor(
                            v ?? Prefs.defaultValue.color,
                          ),
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
                      title: Text(context.t.settings.options.themeMode.label),
                      onChange: onChange,
                      values: {
                        for (final mode in ThemeMode.values)
                          mode:
                              context.t.settings.options.themeMode.values[mode
                                  .name] ??
                              "UNKNOWN",
                      },
                      selectedValue: value ?? ThemeMode.system,
                    ),
                    onUpdate: (v) =>
                        controller.setThemeMode(v ?? ThemeMode.system),
                  ),
                ),
                ValueBuilder<bool?>(
                  initialValue: controller.tintExercises.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title: Text(context.t.settings.options.tintExercises.label),
                    subtitle: Text(
                      context.t.settings.options.tintExercises.subtitle,
                    ),
                    value: value ?? Prefs.defaultValue.tintExercises,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) => controller.setTintExercises(
                    v ?? Prefs.defaultValue.tintExercises,
                  ),
                ),
                ValueBuilder<bool?>(
                  initialValue: controller.showSuggestedRoutines.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title: Text(
                      context.t.settings.options.showSuggestedRoutines.label,
                    ),
                    value: value ?? false,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) =>
                      controller.setShowSuggestedRoutines(v ?? false),
                ),
                ValueBuilder<bool?>(
                  initialValue: controller.defaultToSimpleWorkoutView.value,
                  builder: (value, onChanged) => SwitchListTile(
                    title: Text(
                      context
                          .t
                          .settings
                          .options
                          .defaultToSimpleWorkoutView
                          .label,
                    ),
                    subtitle: Text(
                      context
                          .t
                          .settings
                          .options
                          .defaultToSimpleWorkoutView
                          .subtitle,
                    ),
                    value:
                        value ?? Prefs.defaultValue.defaultToSimpleWorkoutView,
                    onChanged: onChanged,
                  ),
                  onUpdate: (v) => controller.setDefaultToSimpleWorkoutView(
                    v ?? Prefs.defaultValue.defaultToSimpleWorkoutView,
                  ),
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

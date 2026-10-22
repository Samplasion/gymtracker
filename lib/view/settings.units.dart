part of 'settings.dart';

class UnitsSettingsPane extends ConsumerWidget {
  const UnitsSettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(settingsControllerInstanceProvider);
    ref.watch(appPreferencesProvider);
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(context.t.settings.panes.units),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Builder(
                  builder: (context) => PreferenceControl<Weights?>(
                    initialValue: controller.weightUnit,
                    builder: (value, onChange) => RadioModalTile<Weights?>(
                      title: Text(context.t.settings.options.weightUnit.label),
                      onChange: onChange,
                      values: {
                        for (final weight in Weights.values)
                          weight:
                              context.t.weightUnits[weight.name] ?? "UNKNOWN",
                      },
                      selectedValue: value,
                    ),
                    onUpdate: (v) => controller.setWeightUnit(v ?? Weights.kg),
                  ),
                ),
                Builder(
                  builder: (context) => PreferenceControl<Distance?>(
                    initialValue: controller.distanceUnit,
                    builder: (value, onChange) => RadioModalTile<Distance?>(
                      title: Text(
                        context.t.settings.options.distanceUnit.label,
                      ),
                      onChange: onChange,
                      values: {
                        for (final distance in Distance.values)
                          distance:
                              context.t.distanceUnits[distance.name] ??
                              "UNKNOWN",
                      },
                      selectedValue: value,
                    ),
                    onUpdate: (v) =>
                        controller.setDistanceUnit(v ?? Distance.km),
                  ),
                ),
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

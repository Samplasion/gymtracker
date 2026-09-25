part of 'settings.dart';

class UnitsSettingsPane extends ControlledWidget<SettingsController> {
  const UnitsSettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
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
                Obx(
                  () => ValueBuilder<Weights?>(
                    initialValue: controller.weightUnit.value,
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
                Obx(
                  () => ValueBuilder<Distance?>(
                    initialValue: controller.distanceUnit.value,
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

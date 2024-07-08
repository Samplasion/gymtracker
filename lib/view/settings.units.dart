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
              title: Text("settings.panes.units".t),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
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

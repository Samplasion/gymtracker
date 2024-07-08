part of 'settings.dart';

class OpenFoodFactsSettingsPane extends ControlledWidget<SettingsController> {
  const OpenFoodFactsSettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("settings.panes.off".t),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Obx(
                  () => ValueBuilder<NutritionLanguage?>(
                    initialValue: controller.nutritionLanguage.value,
                    builder: (value, onChange) =>
                        RadioModalTile<NutritionLanguage?>(
                      title: Text("settings.options.nutritionLanguage".t),
                      onChange: onChange,
                      values: {
                        for (final lang in NutritionLanguage.sortedValues)
                          lang: lang.t,
                      },
                      selectedValue: value,
                    ),
                    onUpdate: (v) => controller.setNutritionLanguage(
                        v ?? Prefs.defaultValue.nutritionLanguage),
                  ),
                ),
                Obx(
                  () => ValueBuilder<NutritionCountry?>(
                    initialValue: controller.nutritionCountry.value,
                    builder: (value, onChange) =>
                        RadioModalTile<NutritionCountry?>(
                      title: Text("settings.options.nutritionCountry".t),
                      onChange: onChange,
                      values: {
                        for (final country in NutritionCountry.sortedValues)
                          country: country.t,
                      },
                      selectedValue: value,
                    ),
                    onUpdate: (v) => controller.setNutritionCountry(
                        v ?? Prefs.defaultValue.nutritionCountry),
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

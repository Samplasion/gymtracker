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
              title: Text(context.t.settings.panes.off),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Obx(
                  () => ValueBuilder<NutritionLanguage?>(
                    initialValue: controller.nutritionLanguage.value,
                    builder: (value, onChange) =>
                        RadioModalTile<NutritionLanguage?>(
                          title: Text(
                            context.t.settings.options.nutritionLanguage,
                          ),
                          onChange: onChange,
                          values: {
                            for (final lang
                                in NutritionLanguage.getSortedValues(
                                  t: context.t,
                                ))
                              lang: lang.t(t: context.t),
                          },
                          selectedValue: value,
                        ),
                    onUpdate: (v) => controller.setNutritionLanguage(
                      v ?? Prefs.defaultValue.nutritionLanguage,
                    ),
                  ),
                ),
                Obx(
                  () => ValueBuilder<NutritionCountry?>(
                    initialValue: controller.nutritionCountry.value,
                    builder: (value, onChange) =>
                        RadioModalTile<NutritionCountry?>(
                          title: Text(
                            context.t.settings.options.nutritionCountry,
                          ),
                          onChange: onChange,
                          values: {
                            for (final country
                                in NutritionCountry.getSortedValues(
                                  t: context.t,
                                ))
                              country: country.t(t: context.t),
                          },
                          selectedValue: value,
                        ),
                    onUpdate: (v) => controller.setNutritionCountry(
                      v ?? Prefs.defaultValue.nutritionCountry,
                    ),
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

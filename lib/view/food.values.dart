part of 'food.dart';

class AddFoodView extends StatefulWidget {
  final VagueFood food;
  final bool isEditing;
  final bool inheritAmount;

  const AddFoodView({
    super.key,
    required this.food,
    this.isEditing = false,
    this.inheritAmount = false,
  })  : assert(isEditing ? inheritAmount : true,
            "When editing, the amount must be inherited"),
        assert(isEditing ? food is Food : true,
            "When editing, the food must be a Food"),
        assert(inheritAmount ? food is Food : true,
            "When inheriting the amount, the food must be a Food");

  @override
  State<AddFoodView> createState() => _AddFoodViewState();
}

class _AddFoodViewState extends ControlledState<AddFoodView, FoodController> {
  bool get shouldInheritAmount => widget.inheritAmount || widget.isEditing;

  final formKey = GlobalKey<FormState>();

  late double amount = shouldInheritAmount ? (widget.food as Food).amount : 100;

  late var servingSize = widget.isEditing
      ? null
      : widget.food.servingSizes.firstWhereOrNull(
          (element) => element.amount == amount,
        );
  late var amountController = TextEditingController(
      text: controller.stringifyDouble(
          shouldInheritAmount ? (widget.food as Food).amount : amount));

  @override
  dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servingSizes = widget.food.servingSizes;
    final hasServingSizes = servingSizes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = colorScheme.surfaceContainerHigh;

    return Scaffold(
      appBar: AppBar(
        title: Text([
          if (widget.food.brand != null &&
              widget.food.brand != widget.food.name)
            widget.food.brand,
          widget.food.name,
        ].join(", ")),
        actions: [
          if (widget.food is Food)
            StreamBuilder(
              stream: controller.favorites$,
              builder: (BuildContext context, _) {
                final icon = controller.isFavorite(widget.food as Food)
                    ? GymTrackerIcons.remove_from_faves
                    : GymTrackerIcons.add_to_faves;
                return AnimatedRotation(
                  turns: controller.isFavorite(widget.food as Food) ? 0 : 2 / 5,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  child: IconButton(
                    icon: Icon(icon),
                    tooltip: controller.isFavorite(widget.food as Food)
                        ? "food.removeFavorite".t
                        : "food.addFavorite".t,
                    onPressed: () {
                      if (controller.isFavorite(widget.food as Food)) {
                        controller.removeFavorite(widget.food as Food);
                      } else {
                        controller.addFavorite(widget.food as Food);
                      }
                    },
                  ),
                );
              },
            ),
        ],
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: GradientBottomBar.wrap(
          context: context,
          child: Builder(
            builder: (context) {
              return Padding(
                padding: MediaQuery.paddingOf(context).copyWith(top: 0) +
                    const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasServingSizes) ...[
                        DropdownButtonFormField<ServingSize?>(
                          isExpanded: true,
                          decoration: GymTrackerInputDecoration(
                            labelText: "food.add.servingSize".t,
                          ),
                          value: servingSize,
                          items: [
                            ...servingSizes.map(
                              (servingSize) => DropdownMenuItem(
                                value: servingSize,
                                child: Text(
                                    "${(servingSize.name != null && servingSize.name!.trim().isNotEmpty) ? servingSize.name! : "food.add.unnamedServingSize".t} (${widget.food.unit.formatAmount(servingSize.amount)})"),
                              ),
                            ),
                            DropdownMenuItem(
                              value: null,
                              child: Text("food.add.custom".t),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              servingSize = value;
                              if (value != null) {
                                amount = value.amount;
                              } else {
                                amount = amountController.text.isEmpty
                                    ? 100
                                    : amountController.text.tryParseDouble() ??
                                        100;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (servingSize == null) ...[
                        _AmountFormField(
                          controller: amountController,
                          clarifyUnit: false,
                          suffix: Text(widget.food.unit.t),
                          onChanged: (value) {
                            setState(() {
                              amount = value.tryParseDouble() ?? 100;
                            });
                          },
                          restorationId: "_AddFoodViewState_amount",
                        ),
                        const SizedBox(height: 16),
                      ],
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              NutritionTable(
                                per100g: widget.food.nutritionalValuesPer100g,
                                amount: amount,
                                unit: widget.food.unit,
                              ),
                              if (widget.food.isDownloaded) ...[
                                const SizedBox(height: 16),
                                OpenFoodFactsTableAttribution(
                                    food: widget.food),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (kDebugMode)
                        Text("${widget.food.toJson()}", style: monospace),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: GradientBottomBar(
        color: gradientColor,
        center: true,
        buttons: [
          if (widget.isEditing &&
              controller.day$.value != DateTime.now().startOfDay)
            FilledButton.tonal(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final newFood = (widget.food as Food).copyWith(amount: amount);

                controller.copyToToday(newFood);
              },
              child: Text('food.edit.copyToToday'.t),
            ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (widget.isEditing) {
                final food = widget.food as Food;
                final updatedFood = food.copyWith(amount: amount);

                Get.back(result: updatedFood);
              } else {
                final food = Food(
                  name: widget.food.name,
                  brand: widget.food.brand,
                  amount: amount,
                  nutritionalValuesPer100g:
                      widget.food.nutritionalValuesPer100g,
                  servingSizes: widget.food.servingSizes,
                  isDownloaded: true,
                );

                Get.back(result: food);
              }
            },
            child:
                Text(widget.isEditing ? 'food.edit.edit'.t : 'food.add.add'.t),
          ),
        ],
      ),
    );
  }
}

class OpenFoodFactsTableAttribution extends ControlledWidget<FoodController> {
  const OpenFoodFactsTableAttribution({super.key, required this.food});

  final VagueFood food;

  @override
  Widget build(BuildContext context) {
    final canOpen = controller.canOpenOffPage(food);
    return MouseRegion(
      cursor: canOpen ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: canOpen
            ? () {
                controller.openOffPage(food);
              }
            : null,
        child: Text(
          "food.offAttribution".t,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: canOpen
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _AmountFormField extends StatelessWidget {
  const _AmountFormField({
    required this.controller,
    required this.onChanged,
    this.clarifyUnit = true,
    this.suffix,
    required this.restorationId,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final bool clarifyUnit;
  final Widget? suffix;
  final String restorationId;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: GymTrackerInputDecoration(
        labelText: clarifyUnit
            ? "food.add.amountWithClarifiedUnit".t
            : "food.add.amount".t,
        suffix: suffix,
      ),
      keyboardType: _kKeyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
      ],
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "food.add.amountEmpty".t;
        }
        if (value.tryParseDouble() == null) {
          return "food.add.amountInvalid".t;
        }
        final double parsedValue = value.parseDouble();
        if (parsedValue <= 0 || parsedValue.isNaN || parsedValue.isInfinite) {
          return "food.add.amountInvalid".t;
        }
        return null;
      },
    );
  }
}

class NutritionTable extends StatelessWidget {
  final NutritionValues per100g;
  final double amount;
  final NutritionUnit unit;

  const NutritionTable({
    super.key,
    required this.per100g,
    this.amount = 100,
    required this.unit,
  });

  static const verticalSpace = SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FoodController>();
    final nutritionalValues = per100g * (amount / 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "food.add.nutritionalValuesPerAmountWithUnit".tParams({
            "amount": stringifyDouble(amount,
                decimalSeparator: controller.decimalSeparator),
            "unit": unit.t,
          }),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        verticalSpace,
        NutritionRow(
          id: "calories",
          value: nutritionalValues.calories,
          bold: true,
        ),
        verticalSpace,
        NutritionRow(
          id: "protein",
          value: nutritionalValues.protein,
          bold: true,
        ),
        verticalSpace,
        NutritionRow(
          id: "carbs",
          value: nutritionalValues.carbs,
          bold: true,
        ),
        NutritionRow(
          id: "sugar",
          value: nutritionalValues.sugar,
        ),
        verticalSpace,
        NutritionRow(
          id: "fat",
          value: nutritionalValues.fat,
          bold: true,
        ),
        NutritionRow(
          id: "saturatedFat",
          value: nutritionalValues.saturatedFat,
        ),
        verticalSpace,
        if (nutritionalValues.salt != null)
          NutritionRow(
            id: "salt",
            value: nutritionalValues.salt!,
          ),
        if (nutritionalValues.sodium != null)
          NutritionRow(
            id: "sodium",
            value: nutritionalValues.sodium!,
          ),
        if (nutritionalValues.fiber != null)
          NutritionRow(
            id: "fiber",
            value: nutritionalValues.fiber!,
          ),
        if (nutritionalValues.addedSugars != null)
          NutritionRow(
            id: "addedSugars",
            value: nutritionalValues.addedSugars!,
          ),
        if (nutritionalValues.caffeine != null)
          NutritionRow(
            id: "caffeine",
            value: nutritionalValues.caffeine!,
          ),
        if (nutritionalValues.calcium != null)
          NutritionRow(
            id: "calcium",
            value: nutritionalValues.calcium!,
          ),
        if (nutritionalValues.iron != null)
          NutritionRow(
            id: "iron",
            value: nutritionalValues.iron!,
          ),
        if (nutritionalValues.vitaminC != null)
          NutritionRow(
            id: "vitaminC",
            value: nutritionalValues.vitaminC!,
          ),
        if (nutritionalValues.magnesium != null)
          NutritionRow(
            id: "magnesium",
            value: nutritionalValues.magnesium!,
          ),
        if (nutritionalValues.phosphorus != null)
          NutritionRow(
            id: "phosphorus",
            value: nutritionalValues.phosphorus!,
          ),
        if (nutritionalValues.potassium != null)
          NutritionRow(
            id: "potassium",
            value: nutritionalValues.potassium!,
          ),
        if (nutritionalValues.zinc != null)
          NutritionRow(
            id: "zinc",
            value: nutritionalValues.zinc!,
          ),
        if (nutritionalValues.copper != null)
          NutritionRow(
            id: "copper",
            value: nutritionalValues.copper!,
          ),
        if (nutritionalValues.selenium != null)
          NutritionRow(
            id: "selenium",
            value: nutritionalValues.selenium!,
          ),
        if (nutritionalValues.vitaminA != null)
          NutritionRow(
            id: "vitaminA",
            value: nutritionalValues.vitaminA!,
          ),
        if (nutritionalValues.vitaminE != null)
          NutritionRow(
            id: "vitaminE",
            value: nutritionalValues.vitaminE!,
          ),
        if (nutritionalValues.vitaminD != null)
          NutritionRow(
            id: "vitaminD",
            value: nutritionalValues.vitaminD!,
          ),
        if (nutritionalValues.vitaminB1 != null)
          NutritionRow(
            id: "vitaminB1",
            value: nutritionalValues.vitaminB1!,
          ),
        if (nutritionalValues.vitaminB2 != null)
          NutritionRow(
            id: "vitaminB2",
            value: nutritionalValues.vitaminB2!,
          ),
        if (nutritionalValues.vitaminPP != null)
          NutritionRow(
            id: "vitaminPP",
            value: nutritionalValues.vitaminPP!,
          ),
        if (nutritionalValues.vitaminB6 != null)
          NutritionRow(
            id: "vitaminB6",
            value: nutritionalValues.vitaminB6!,
          ),
        if (nutritionalValues.vitaminB12 != null)
          NutritionRow(
            id: "vitaminB12",
            value: nutritionalValues.vitaminB12!,
          ),
        if (nutritionalValues.vitaminB9 != null)
          NutritionRow(
            id: "vitaminB9",
            value: nutritionalValues.vitaminB9!,
          ),
        if (nutritionalValues.vitaminK != null)
          NutritionRow(
            id: "vitaminK",
            value: nutritionalValues.vitaminK!,
          ),
        if (nutritionalValues.cholesterol != null)
          NutritionRow(
            id: "cholesterol",
            value: nutritionalValues.cholesterol!,
          ),
        if (nutritionalValues.butyricAcid != null)
          NutritionRow(
            id: "butyricAcid",
            value: nutritionalValues.butyricAcid!,
          ),
        if (nutritionalValues.caproicAcid != null)
          NutritionRow(
            id: "caproicAcid",
            value: nutritionalValues.caproicAcid!,
          ),
        if (nutritionalValues.caprylicAcid != null)
          NutritionRow(
            id: "caprylicAcid",
            value: nutritionalValues.caprylicAcid!,
          ),
        if (nutritionalValues.capricAcid != null)
          NutritionRow(
            id: "capricAcid",
            value: nutritionalValues.capricAcid!,
          ),
        if (nutritionalValues.lauricAcid != null)
          NutritionRow(
            id: "lauricAcid",
            value: nutritionalValues.lauricAcid!,
          ),
        if (nutritionalValues.myristicAcid != null)
          NutritionRow(
            id: "myristicAcid",
            value: nutritionalValues.myristicAcid!,
          ),
        if (nutritionalValues.palmiticAcid != null)
          NutritionRow(
            id: "palmiticAcid",
            value: nutritionalValues.palmiticAcid!,
          ),
        if (nutritionalValues.stearicAcid != null)
          NutritionRow(
            id: "stearicAcid",
            value: nutritionalValues.stearicAcid!,
          ),
        if (nutritionalValues.oleicAcid != null)
          NutritionRow(
            id: "oleicAcid",
            value: nutritionalValues.oleicAcid!,
          ),
        if (nutritionalValues.linoleicAcid != null)
          NutritionRow(
            id: "linoleicAcid",
            value: nutritionalValues.linoleicAcid!,
          ),
        if (nutritionalValues.docosahexaenoicAcid != null)
          NutritionRow(
            id: "docosahexaenoicAcid",
            value: nutritionalValues.docosahexaenoicAcid!,
          ),
        if (nutritionalValues.eicosapentaenoicAcid != null)
          NutritionRow(
            id: "eicosapentaenoicAcid",
            value: nutritionalValues.eicosapentaenoicAcid!,
          ),
        if (nutritionalValues.erucicAcid != null)
          NutritionRow(
            id: "erucicAcid",
            value: nutritionalValues.erucicAcid!,
          ),
        if (nutritionalValues.monounsaturatedFat != null)
          NutritionRow(
            id: "monounsaturatedFat",
            value: nutritionalValues.monounsaturatedFat!,
          ),
        if (nutritionalValues.polyunsaturatedFat != null)
          NutritionRow(
            id: "polyunsaturatedFat",
            value: nutritionalValues.polyunsaturatedFat!,
          ),
        if (nutritionalValues.alcohol != null)
          NutritionRow(
            id: "alcohol",
            value: nutritionalValues.alcohol!,
          ),
        if (nutritionalValues.pantothenicAcid != null)
          NutritionRow(
            id: "pantothenicAcid",
            value: nutritionalValues.pantothenicAcid!,
          ),
        if (nutritionalValues.biotin != null)
          NutritionRow(
            id: "biotin",
            value: nutritionalValues.biotin!,
          ),
        if (nutritionalValues.chloride != null)
          NutritionRow(
            id: "chloride",
            value: nutritionalValues.chloride!,
          ),
        if (nutritionalValues.chromium != null)
          NutritionRow(
            id: "chromium",
            value: nutritionalValues.chromium!,
          ),
        if (nutritionalValues.fluoride != null)
          NutritionRow(
            id: "fluoride",
            value: nutritionalValues.fluoride!,
          ),
        if (nutritionalValues.iodine != null)
          NutritionRow(
            id: "iodine",
            value: nutritionalValues.iodine!,
          ),
        if (nutritionalValues.manganese != null)
          NutritionRow(
            id: "manganese",
            value: nutritionalValues.manganese!,
          ),
        if (nutritionalValues.molybdenum != null)
          NutritionRow(
            id: "molybdenum",
            value: nutritionalValues.molybdenum!,
          ),
        if (nutritionalValues.omega3 != null)
          NutritionRow(
            id: "omega3",
            value: nutritionalValues.omega3!,
          ),
        if (nutritionalValues.omega6 != null)
          NutritionRow(
            id: "omega6",
            value: nutritionalValues.omega6!,
          ),
        if (nutritionalValues.omega9 != null)
          NutritionRow(
            id: "omega9",
            value: nutritionalValues.omega9!,
          ),
        if (nutritionalValues.betaCarotene != null)
          NutritionRow(
            id: "betaCarotene",
            value: nutritionalValues.betaCarotene!,
          ),
        if (nutritionalValues.bicarbonate != null)
          NutritionRow(
            id: "bicarbonate",
            value: nutritionalValues.bicarbonate!,
          ),
        if (nutritionalValues.sugarAlcohol != null)
          NutritionRow(
            id: "sugarAlcohol",
            value: nutritionalValues.sugarAlcohol!,
          ),
        if (nutritionalValues.alphaLinolenicAcid != null)
          NutritionRow(
            id: "alphaLinolenicAcid",
            value: nutritionalValues.alphaLinolenicAcid!,
          ),
        if (nutritionalValues.arachidicAcid != null)
          NutritionRow(
            id: "arachidicAcid",
            value: nutritionalValues.arachidicAcid!,
          ),
        if (nutritionalValues.arachidonicAcid != null)
          NutritionRow(
            id: "arachidonicAcid",
            value: nutritionalValues.arachidonicAcid!,
          ),
        if (nutritionalValues.behenicAcid != null)
          NutritionRow(
            id: "behenicAcid",
            value: nutritionalValues.behenicAcid!,
          ),
        if (nutritionalValues.ceroticAcid != null)
          NutritionRow(
            id: "ceroticAcid",
            value: nutritionalValues.ceroticAcid!,
          ),
        if (nutritionalValues.dihomoGammaLinolenicAcid != null)
          NutritionRow(
            id: "dihomoGammaLinolenicAcid",
            value: nutritionalValues.dihomoGammaLinolenicAcid!,
          ),
        if (nutritionalValues.elaidicAcid != null)
          NutritionRow(
            id: "elaidicAcid",
            value: nutritionalValues.elaidicAcid!,
          ),
        if (nutritionalValues.gammaLinolenicAcid != null)
          NutritionRow(
            id: "gammaLinolenicAcid",
            value: nutritionalValues.gammaLinolenicAcid!,
          ),
        if (nutritionalValues.gondoicAcid != null)
          NutritionRow(
            id: "gondoicAcid",
            value: nutritionalValues.gondoicAcid!,
          ),
        if (nutritionalValues.lignocericAcid != null)
          NutritionRow(
            id: "lignocericAcid",
            value: nutritionalValues.lignocericAcid!,
          ),
        if (nutritionalValues.meadAcid != null)
          NutritionRow(
            id: "meadAcid",
            value: nutritionalValues.meadAcid!,
          ),
        if (nutritionalValues.melissicAcid != null)
          NutritionRow(
            id: "melissicAcid",
            value: nutritionalValues.melissicAcid!,
          ),
        if (nutritionalValues.montanicAcid != null)
          NutritionRow(
            id: "montanicAcid",
            value: nutritionalValues.montanicAcid!,
          ),
        if (nutritionalValues.nervonicAcid != null)
          NutritionRow(
            id: "nervonicAcid",
            value: nutritionalValues.nervonicAcid!,
          ),
        if (nutritionalValues.transFat != null)
          NutritionRow(
            id: "transFat",
            value: nutritionalValues.transFat!,
          ),
      ],
    );
  }
}

class NutritionRow extends StatelessWidget {
  final double value;
  final String id;
  final bool bold;

  const NutritionRow({
    super.key,
    required this.value,
    required this.id,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FoodController>();
    var stringifiedValue =
        stringifyDouble(value, decimalSeparator: controller.decimalSeparator);
    if (value < 0.01 && value != 0) {
      stringifiedValue = "<0${controller.decimalSeparator}01";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            "food.nutriments.$id".t,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$stringifiedValue ${"food.nutrimentUnits.${kNutritionValueToUnit[id]!.toCamelCase()}".t}"
              .trim(),
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class CustomAddFoodView extends StatefulWidget {
  final String? barcode;

  const CustomAddFoodView({super.key}) : barcode = null;

  const CustomAddFoodView.withBarcode({super.key, required this.barcode});

  @override
  State<CustomAddFoodView> createState() => _CustomAddFoodViewState();
}

class _CustomAddFoodViewState
    extends ControlledState<CustomAddFoodView, FoodController> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool expanded = false;
  final controllers = {
    "calories": TextEditingController(),
    "protein": TextEditingController(),
    "carbs": TextEditingController(),
    "sugar": TextEditingController(),
    "fat": TextEditingController(),
    "saturatedFat": TextEditingController(),
    "salt": TextEditingController(),
    "sodium": TextEditingController(),
    "fiber": TextEditingController(),
    "addedSugars": TextEditingController(),
    "caffeine": TextEditingController(),
    "calcium": TextEditingController(),
    "iron": TextEditingController(),
    "vitaminC": TextEditingController(),
    "magnesium": TextEditingController(),
    "phosphorus": TextEditingController(),
    "potassium": TextEditingController(),
    "zinc": TextEditingController(),
    "copper": TextEditingController(),
    "selenium": TextEditingController(),
    "vitaminA": TextEditingController(),
    "vitaminE": TextEditingController(),
    "vitaminD": TextEditingController(),
    "vitaminB1": TextEditingController(),
    "vitaminB2": TextEditingController(),
    "vitaminPP": TextEditingController(),
    "vitaminB6": TextEditingController(),
    "vitaminB12": TextEditingController(),
    "vitaminB9": TextEditingController(),
    "vitaminK": TextEditingController(),
    "cholesterol": TextEditingController(),
    "butyricAcid": TextEditingController(),
    "caproicAcid": TextEditingController(),
    "caprylicAcid": TextEditingController(),
    "capricAcid": TextEditingController(),
    "lauricAcid": TextEditingController(),
    "myristicAcid": TextEditingController(),
    "palmiticAcid": TextEditingController(),
    "stearicAcid": TextEditingController(),
    "oleicAcid": TextEditingController(),
    "linoleicAcid": TextEditingController(),
    "docosahexaenoicAcid": TextEditingController(),
    "eicosapentaenoicAcid": TextEditingController(),
    "erucicAcid": TextEditingController(),
    "monounsaturatedFat": TextEditingController(),
    "polyunsaturatedFat": TextEditingController(),
    "alcohol": TextEditingController(),
    "pantothenicAcid": TextEditingController(),
    "biotin": TextEditingController(),
    "chloride": TextEditingController(),
    "chromium": TextEditingController(),
    "fluoride": TextEditingController(),
    "iodine": TextEditingController(),
    "manganese": TextEditingController(),
    "molybdenum": TextEditingController(),
    "omega3": TextEditingController(),
    "omega6": TextEditingController(),
    "omega9": TextEditingController(),
    "betaCarotene": TextEditingController(),
    "bicarbonate": TextEditingController(),
    "sugarAlcohol": TextEditingController(),
    "alphaLinolenicAcid": TextEditingController(),
    "arachidicAcid": TextEditingController(),
    "arachidonicAcid": TextEditingController(),
    "behenicAcid": TextEditingController(),
    "ceroticAcid": TextEditingController(),
    "dihomoGammaLinolenicAcid": TextEditingController(),
    "elaidicAcid": TextEditingController(),
    "gammaLinolenicAcid": TextEditingController(),
    "gondoicAcid": TextEditingController(),
    "lignocericAcid": TextEditingController(),
    "meadAcid": TextEditingController(),
    "melissicAcid": TextEditingController(),
    "montanicAcid": TextEditingController(),
    "nervonicAcid": TextEditingController(),
    "transFat": TextEditingController(),
  };

  late final nameController = TextEditingController();
  late final brandController = TextEditingController();
  double amount = 100;
  late final amountController =
      TextEditingController(text: stringifyDouble(amount));
  NutritionUnit unit = NutritionUnit.G;

  final required = {
    "calories",
    "fat",
    "saturatedFat",
    "carbs",
    "sugar",
    "protein",
  };

  final alwaysShown = {
    "calories",
    "fat",
    "saturatedFat",
    "carbs",
    "sugar",
    "protein",
    "salt",
    "fiber",
  };

  @override
  dispose() {
    controllers.forEach((key, value) => value.dispose());
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = colorScheme.surfaceContainerHigh;
    return Scaffold(
      appBar: AppBar(
        title: Text("food.add.customFood.title".t),
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: GradientBottomBar.wrap(
          context: context,
          child: Builder(builder: (context) {
            return Padding(
              padding: MediaQuery.paddingOf(context).copyWith(top: 0) +
                  const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: GymTrackerInputDecoration(
                        labelText: "food.add.customFood.fields.name".t,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if ((value == null || value.trim().isEmpty)) {
                          return "food.add.nameEmpty".t;
                        }

                        return null;
                      },
                      restorationId: "_CustomAddFoodViewState_name",
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: brandController,
                      decoration: GymTrackerInputDecoration(
                        labelText: "food.add.customFood.fields.brand".t,
                      ),
                      restorationId: "_CustomAddFoodViewState_brand",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _AmountFormField(
                            controller: amountController,
                            clarifyUnit: false,
                            onChanged: (value) {
                              setState(() {
                                amount = value.tryParseDouble() ?? 100;
                              });
                            },
                            restorationId: "_CustomAddFoodViewState_amount",
                          ),
                        ),
                        const SizedBox(width: 8),
                        SegmentedButton<NutritionUnit>(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                // Reduce padding on mobile to compensate for the
                                // larger target size
                                vertical:
                                    Theme.of(context).materialTapTargetSize ==
                                            MaterialTapTargetSize.padded
                                        ? 14
                                        : 18,
                              ),
                            ),
                          ),
                          showSelectedIcon: false,
                          segments: <ButtonSegment<NutritionUnit>>[
                            ButtonSegment<NutritionUnit>(
                              label: Text("food.nutrimentUnits.g".t),
                              value: NutritionUnit.G,
                            ),
                            ButtonSegment<NutritionUnit>(
                              label: Text("food.nutrimentUnits.milliL".t),
                              value: NutritionUnit.MILLI_L,
                            ),
                          ],
                          onSelectionChanged: (value) {
                            setState(() {
                              unit = value.first;
                            });
                          },
                          selected: {unit},
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      "food.add.nutritionalValuesPerAmountWithUnit".tParams({
                        "amount": "100",
                        "unit": "food.nutrimentUnits.${unit.toCamelCase()}".t
                      }),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    for (var id in controllers.keys) ...[
                      Crossfade(
                        showSecond: alwaysShown.contains(id) || expanded,
                        firstChild: const SizedBox(),
                        secondChild: Column(
                          children: [
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controllers[id],
                              decoration: GymTrackerInputDecoration(
                                labelText:
                                    "${"food.nutriments.$id".t} (${"food.nutrimentUnits.${kNutritionValueToUnit[id]!.toCamelCase()}".t})",
                                suffix: Text(
                                    "food.nutrimentUnits.${kNutritionValueToUnit[id]!.toCamelCase()}"
                                        .t),
                                hintText: required.contains(id)
                                    ? null
                                    : "general.optional".t,
                              ),
                              keyboardType: _kKeyboardType,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (required.contains(id)) {
                                  if ((value == null || value.isEmpty)) {
                                    return "food.add.amountEmpty".t;
                                  }
                                } else {
                                  return null;
                                }
                                if (value.tryParseDouble() == null) {
                                  return "food.add.amountInvalid".t;
                                }
                                final double parsedValue = value.parseDouble();
                                if (parsedValue < 0 ||
                                    parsedValue.isNaN ||
                                    parsedValue.isInfinite) {
                                  return "food.add.amountInvalid".t;
                                }
                                return null;
                              },
                              restorationId: "_CustomAddFoodViewState_$id",
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Crossfade(
                      showSecond: !expanded,
                      firstChild: const SizedBox(),
                      secondChild: TextButton(
                        onPressed: () {
                          setState(() {
                            expanded = true;
                          });
                        },
                        child: Text("food.add.customFood.showMore".t),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: GradientBottomBar(
        color: gradientColor,
        center: true,
        buttons: [
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }

              final food = Food(
                name: nameController.text.trim(),
                brand: brandController.text.trim().isEmpty
                    ? null
                    : brandController.text.trim(),
                amount: amount,
                unit: unit,
                nutritionalValuesPer100g: NutritionValues.fromJson({
                  for (var id in controllers.keys)
                    if (controllers[id]!.text.isNotEmpty)
                      id: controllers[id]!.text.parseDouble(),
                }),
                barcode: widget.barcode,
              );

              if (widget.barcode != null) {
                controller.addCustomBarcodeFood(widget.barcode!, food);
              }

              Get.back(result: food);
            },
            child: Text('food.add.add'.t),
          ),
        ],
      ),
    );
  }
}

class SearchResultsView extends ControlledWidget<FoodController> {
  final Future<List<VagueFood>> foods;
  final bool showAddCustom;

  const SearchResultsView({
    super.key,
    required this.foods,
    this.showAddCustom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("food.search.title".t),
      ),
      body: FutureBuilder<List<VagueFood>>(
        future: foods,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          final foods = !isLoading && snapshot.hasData
              ? snapshot.data!
              : skeletonFoods(20).cast<VagueFood>();

          return Skeletonizer(
            enabled: isLoading,
            child: CustomScrollView(
              slivers: [
                SliverList.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return SafeArea(
                      bottom: false,
                      child: ListTile(
                        title: Text(food.name),
                        subtitle: food.brand == null ? null : Text(food.brand!),
                        onTap: () {
                          Get.back(result: food);
                        },
                      ),
                    );
                  },
                ),
                SliverSafeArea(
                  sliver: SliverList.list(children: [
                    ListTile(
                      title: Text(
                        "food.offAttribution".t,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          showAddCustom ? _AddCustomFoodFAB(closeView: () => Get.back()) : null,
    );
  }
}

class FoodBarcodeReaderView extends ControlledWidget<FoodController> {
  final void Function(Food) onFoodReceived;

  const FoodBarcodeReaderView({super.key, required this.onFoodReceived});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("food.barcodeReader.title".t), actions: [
        if (kDebugMode)
          IconButton(
            icon: const Icon(GymTrackerIcons.debug),
            onPressed: () async {
              // String imgUrl =
              //     "https://upload.wikimedia.org/wikipedia/commons/c/cb/Ean13.jpg";
              String imgUrl =
                  "https://barcode.orcascan.com/?type=ean13&data=8000965154468&fontsize=Fit&format=png";
              Code resultFromUrl = await zx.readBarcodeImageUrl(
                imgUrl,
                DecodeParams(
                  imageFormat: ImageFormat.rgb,
                  format: Format.linearCodes,
                  tryHarder: true,
                ),
              );
              handleCode(resultFromUrl);
            },
          ),
      ]),
      body: ReaderWidget(
        showToggleCamera: false,
        actionButtonsBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.5),
        codeFormat: Format.linearCodes,
        scannerOverlay: DynamicScannerOverlay(
          borderColor: context.theme.colorScheme.primary,
          borderRadius: 8,
          borderLength: 32,
          borderWidth: 4,
          cutOutSize: 0.85,
        ),
        showGallery: controller.permission$.value.gallery,
        onScan: (result) async {
          handleCode(result);
        },
      ),
      // Type by hand
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Go.off(
              () => ManualBarcodeInsertionScreen(handleCode: handleCode));
        },
        child: const Icon(GymTrackerIcons.keyboard),
      ),
    );
  }

  void handleCode(Code code) {
    logger.d((code.isValid, code.text));

    if (!code.isValid || code.text == null) {
      code.logger.w("Invalid code");
      return;
    }

    controller.searchFoodByBarcode(code.text!).then((food) {
      if (food != null) {
        onFoodReceived(food);
      }
    });
  }
}

class ManualBarcodeInsertionScreen extends StatefulWidget {
  final void Function(Code) handleCode;

  const ManualBarcodeInsertionScreen({super.key, required this.handleCode});

  @override
  State<ManualBarcodeInsertionScreen> createState() =>
      _ManualBarcodeInsertionScreenState();
}

class _ManualBarcodeInsertionScreenState
    extends State<ManualBarcodeInsertionScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  void ok() {
    if (!formKey.currentState!.validate()) return;

    final code = Code(
      isValid: true,
      text: controller.text,
    );
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.handleCode(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("food.barcodeReader.enterCode".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "food.barcodeReader.codeField.label".tr,
                ),
                onFieldSubmitted: (_) => ok(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "food.barcodeReader.codeField.empty".tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ok,
        child: const Icon(GymTrackerIcons.search),
      ),
    );
  }
}

class AddCombinedFoodView extends StatefulWidget {
  const AddCombinedFoodView({super.key});

  @override
  State<AddCombinedFoodView> createState() => _AddCombinedFoodViewState();
}

class _AddCombinedFoodViewState
    extends ControlledState<AddCombinedFoodView, FoodController> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController amountController =
      TextEditingController(text: "100");

  var amount = 100.0;
  var unit = NutritionUnit.G;
  var constituents = <Food>[];

  NutritionValues get nutritionalValues => NutritionValues.sum(
      constituents.map((food) => (food.amount, food.nutritionalValues)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("food.combine.title".t),
      ),
      extendBody: true,
      body: Form(
        key: formKey,
        child: GradientBottomBar.wrap(
          context: context,
          child: CustomScrollView(
            key: ValueKey(constituents),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      TextFormField(
                        controller: nameController,
                        decoration: GymTrackerInputDecoration(
                          labelText: "food.add.customFood.fields.name".t,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if ((value == null || value.trim().isEmpty)) {
                            return "food.add.nameEmpty".t;
                          }

                          return null;
                        },
                        restorationId: "_AddCombinedFoodViewState_name",
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: brandController,
                        decoration: GymTrackerInputDecoration(
                          labelText: "food.add.customFood.fields.brand".t,
                        ),
                        restorationId: "_AddCombinedFoodViewState_brand",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _AmountFormField(
                              controller: amountController,
                              clarifyUnit: false,
                              onChanged: (value) {
                                setState(() {
                                  amount = value.tryParseDouble() ?? 100;
                                });
                              },
                              restorationId: "_AddCombinedFoodViewState_amount",
                            ),
                          ),
                          const SizedBox(width: 8),
                          SegmentedButton<NutritionUnit>(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                  // Reduce padding on mobile to compensate for the
                                  // larger target size
                                  vertical:
                                      Theme.of(context).materialTapTargetSize ==
                                              MaterialTapTargetSize.padded
                                          ? 14
                                          : 18,
                                ),
                              ),
                            ),
                            showSelectedIcon: false,
                            segments: <ButtonSegment<NutritionUnit>>[
                              ButtonSegment<NutritionUnit>(
                                label: Text("food.nutrimentUnits.g".t),
                                value: NutritionUnit.G,
                              ),
                              ButtonSegment<NutritionUnit>(
                                label: Text("food.nutrimentUnits.milliL".t),
                                value: NutritionUnit.MILLI_L,
                              ),
                            ],
                            onSelectionChanged: (value) {
                              setState(() {
                                unit = value.first;
                              });
                            },
                            selected: {unit},
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _getSearchBar(),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemBuilder: (context, i) => FoodListTile(
                    key: ValueKey(constituents[i]),
                    food: constituents[i],
                    onDelete: () {
                      setState(() {
                        constituents.removeAt(i);
                      });
                    },
                    onTap: () {
                      controller
                          .showEditFoodViewForCombination(constituents[i])
                          .then((value) {
                        setState(() {
                          constituents[i] = value;
                        });
                      });
                    }),
                itemCount: constituents.length,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      if (constituents.isNotEmpty) ...[
                        const Divider(height: 32),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                NutritionTable(
                                  per100g: nutritionalValues,
                                  amount: amount,
                                  unit: unit,
                                ),
                                if (constituents
                                    .any((food) => food.isDownloaded)) ...[
                                  const SizedBox(height: 16),
                                  OpenFoodFactsTableAttribution(
                                    food: VagueFood(
                                      name: "",
                                      nutritionalValuesPer100g:
                                          nutritionalValues,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverBottomSafeArea(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GradientBottomBar(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        alignment: MainAxisAlignment.end,
        center: true,
        buttons: [
          FilledButton(
            onPressed: constituents.isEmpty
                ? null
                : () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final food = Food(
                      name: nameController.text.trim(),
                      brand: brandController.text.trim().isEmpty
                          ? null
                          : brandController.text.trim(),
                      amount: amount,
                      unit: unit,
                      nutritionalValuesPer100g: nutritionalValues,
                      isDownloaded:
                          constituents.any((food) => food.isDownloaded),
                    );

                    Get.back(result: food);
                  },
            child: Text('food.add.add'.t),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return SearchAnchorPlus(
      // searchController: searchController,
      suggestionsBuilder: _getSearchSuggestionBuilder(
        closeView: () => Get.back(),
        onFoodTap: (dtfood) {
          final food = dtfood.value;
          setState(() {
            constituents.add(food);
          });
        },
      ),
      hintText: 'food.searchBar.hint'.t,
      barTrailing: [
        IconButton(
          icon: const Icon(GymTrackerIcons.scan_barcode),
          tooltip: "food.barcodeReader.title".t,
          onPressed: () {
            controller.showScanBarcodeView().then((value) {
              if (value != null) {
                setState(() {
                  constituents.add(value);
                });
              }
            });
          },
        ),
      ],
      onSubmitted: (query) {
        controller.showSearchResultsViewForCombination(query).then((value) {
          if (value != null) {
            setState(() {
              constituents.add(value);
            });
          }
        });
      },
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      viewFloatingActionButton: _AddCustomFoodFAB(
        closeView: () => Get.back(),
      ),
    );
  }
}

extension on NutritionUnit {
  String get t => "food.nutrimentUnits.${toCamelCase()}".t;
  String formatAmount(double amount) =>
      "${stringifyDouble(amount, decimalSeparator: Get.find<FoodController>().decimalSeparator)} $t";
}

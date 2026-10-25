part of 'food.dart';

class AddFoodView extends ConsumerStatefulWidget {
  final VagueFood food;
  final bool isEditing;
  final bool inheritAmount;

  const AddFoodView({
    super.key,
    required this.food,
    this.isEditing = false,
    this.inheritAmount = false,
  }) : assert(
         isEditing ? inheritAmount : true,
         "When editing, the amount must be inherited",
       ),
       assert(
         isEditing ? food is Food : true,
         "When editing, the food must be a Food",
       ),
       assert(
         inheritAmount ? food is Food : true,
         "When inheriting the amount, the food must be a Food",
       );

  @override
  ConsumerState<AddFoodView> createState() => _AddFoodViewState();
}

class _AddFoodViewState extends ConsumerState<AddFoodView> {
  bool get shouldInheritAmount => widget.inheritAmount || widget.isEditing;

  final formKey = GlobalKey<FormState>();

  late double amount = shouldInheritAmount ? (widget.food as Food).amount : 100;
  late int pieces = shouldInheritAmount ? (widget.food as Food).pieces : 1;

  late var servingSize = widget.isEditing
      ? null
      : widget.food.servingSizes.firstWhereOrNull(
          (element) => element.amount == amount,
        );
  late final TextEditingController amountController;
  late final waterController = TextEditingController(
    text: widget.food.nutritionalValuesPer100g.water?.toString() ?? "",
  );

  bool _amountInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountInitialized) return;
    final decSep = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    ).symbols.DECIMAL_SEP;
    amountController = TextEditingController(
      text: stringifyDouble(
        shouldInheritAmount ? (widget.food as Food).amount : amount,
        decimalSeparator: decSep,
      ),
    );
    _amountInitialized = true;
  }

  @override
  dispose() {
    amountController.dispose();
    waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servingSizes = widget.food.servingSizes;
    final hasServingSizes = servingSizes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = colorScheme.surfaceContainerHigh;

    final selectedDate = ref.watch(foodSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          [
            if (widget.food.brand != null &&
                widget.food.brand != widget.food.name)
              widget.food.brand,
            widget.food.name,
          ].join(", "),
        ),
        actions: [
          if (widget.food is CatalogFood)
            IconButton(
              tooltip: context.t.food.catalog.report,
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => showCatalogReport(
                context,
                ref,
                (widget.food as CatalogFood).catalogId,
              ),
            ),
          if (widget.food is Food)
            Builder(
              builder: (BuildContext context) {
                final favorites =
                    ref.watch(favoriteFoodsStreamProvider).asData?.value ?? [];
                final isFavorite = favorites.any(
                  (f) => f.id == (widget.food as Food).id,
                );
                final icon = isFavorite
                    ? GTIcons.remove_from_faves
                    : GTIcons.add_to_faves;
                return AnimatedRotation(
                  turns: isFavorite ? 0 : 2 / 5,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  child: IconButton(
                    icon: Icon(icon),
                    tooltip: isFavorite
                        ? context.t.food.removeFavorite
                        : context.t.food.addFavorite,
                    onPressed: () async {
                      if (isFavorite) {
                        await ref
                            .read(foodProvider.notifier)
                            .removeFavorite(widget.food as Food);
                      } else {
                        await ref
                            .read(foodProvider.notifier)
                            .addFavorite(widget.food as Food);
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
                padding:
                    MediaQuery.paddingOf(context).copyWith(top: 0) +
                    const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: waterController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.t.hydration.waterPer100,
                        ),
                        validator: (text) {
                          if (text == null || text.trim().isEmpty) return null;
                          final value = text.tryParseDouble();
                          return value == null || !value.isFinite || value < 0
                              ? context.t.food.add.amountInvalid
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (hasServingSizes) ...[
                        DropdownButtonFormField<ServingSize?>(
                          isExpanded: true,
                          decoration: GymTrackerInputDecoration(
                            labelText: context.t.food.add.servingSize,
                          ),
                          value: servingSize,
                          items: [
                            ...servingSizes.map(
                              (servingSize) => DropdownMenuItem(
                                value: servingSize,
                                child: Text(
                                  "${(servingSize.name != null && servingSize.name!.trim().isNotEmpty) ? servingSize.name! : context.t.food.add.unnamedServingSize} (${widget.food.unit.formatAmount(servingSize.amount, context: context)})",
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: null,
                              child: Text(context.t.food.add.custom),
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
                          suffix: Text(widget.food.unit.t(context: context)),
                          onChanged: (value) {
                            setState(() {
                              amount = value.tryParseDouble() ?? 100;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      IntStepperFormField(
                        value: pieces,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            pieces = value;
                          });
                        },
                        decoration: GymTrackerInputDecoration(
                          labelText: context.t.food.add.pieces,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              NutritionTable(
                                per100g: widget.food.nutritionalValuesPer100g,
                                amount: amount * pieces,
                                unit: widget.food.unit,
                              ),
                              if (widget.food.downloadedFromOFF) ...[
                                const SizedBox(height: 16),
                                OpenFoodFactsTableAttribution(
                                  food: widget.food,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // if (kDebugMode)
                      //   Text("${widget.food.toJson()}", style: monospace),
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
          if (widget.isEditing && selectedDate != DateTime.now().startOfDay)
            FilledButton.tonal(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final newFood = (widget.food as Food).copyWith(amount: amount);

                await ref.read(foodProvider.notifier).copyToToday(newFood);
              },
              child: Text(context.t.food.edit.copyToToday),
            ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (widget.isEditing) {
                final food = widget.food as Food;
                final updatedFood = food.copyWith(
                  amount: amount,
                  pieces: pieces,
                );

                Go.back(result: updatedFood);
              } else {
                final food = Food(
                  name: widget.food.name,
                  brand: widget.food.brand,
                  amount: amount,
                  nutritionalValuesPer100g: NutritionValues.fromJson({
                    ...widget.food.nutritionalValuesPer100g.toJson(),
                    "water": waterController.text.tryParseDouble(),
                  }),
                  servingSizes: List.of(widget.food.servingSizes),
                  downloadedFromOFF: widget.food.downloadedFromOFF,
                  barcode: widget.food.barcode,
                  unit: widget.food.unit,
                  pieces: pieces,
                );

                Go.back(result: food);
              }
            },
            child: Text(
              widget.isEditing
                  ? context.t.food.edit.edit
                  : context.t.food.add.add,
            ),
          ),
        ],
      ),
    );
  }
}

class OpenFoodFactsTableAttribution extends StatelessWidget {
  const OpenFoodFactsTableAttribution({super.key, required this.food});

  final VagueFood food;

  @override
  Widget build(BuildContext context) {
    final canOpen = food.url != null;
    return MouseRegion(
      cursor: canOpen ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: canOpen
            ? () {
                launchUrl(Uri.parse(food.url!));
              }
            : null,
        child: Text(
          context.t.food.offAttribution,
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
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final bool clarifyUnit;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: GymTrackerInputDecoration(
        labelText: clarifyUnit
            ? context.t.food.add.amountWithClarifiedUnit
            : context.t.food.add.amount,
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
          return context.t.food.add.amountEmpty;
        }
        if (value.tryParseDouble() == null) {
          return context.t.food.add.amountInvalid;
        }
        final double parsedValue = value.parseDouble();
        if (parsedValue <= 0 || parsedValue.isNaN || parsedValue.isInfinite) {
          return context.t.food.add.amountInvalid;
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
  final bool _showHeader;

  const NutritionTable({
    super.key,
    required this.per100g,
    this.amount = 100,
    required this.unit,
  }) : _showHeader = true;

  const NutritionTable.arbitrary({
    super.key,
    required NutritionValues nutritionValues,
    required this.unit,
  }) : per100g = nutritionValues,
       amount = 100,
       _showHeader = false;

  static const verticalSpace = SizedBox(height: 12);

  @override
  Widget build(BuildContext context) {
    final decSep = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    ).symbols.DECIMAL_SEP;
    final nutritionalValues = per100g * (amount / 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showHeader) ...[
          Text(
            context.t.food.add.nutritionalValuesPerAmountWithUnit(
              amount: stringifyDouble(amount, decimalSeparator: decSep),
              unit: unit.t(context: context),
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          verticalSpace,
        ],
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
        NutritionRow(id: "carbs", value: nutritionalValues.carbs, bold: true),
        NutritionRow(id: "sugar", value: nutritionalValues.sugar),
        verticalSpace,
        NutritionRow(id: "fat", value: nutritionalValues.fat, bold: true),
        NutritionRow(id: "saturatedFat", value: nutritionalValues.saturatedFat),
        verticalSpace,
        if (nutritionalValues.water != null)
          NutritionRow(id: "water", value: nutritionalValues.water!),
        if (nutritionalValues.salt != null)
          NutritionRow(id: "salt", value: nutritionalValues.salt!),
        if (nutritionalValues.sodium != null)
          NutritionRow(id: "sodium", value: nutritionalValues.sodium!),
        if (nutritionalValues.fiber != null)
          NutritionRow(id: "fiber", value: nutritionalValues.fiber!),
        if (nutritionalValues.addedSugars != null)
          NutritionRow(
            id: "addedSugars",
            value: nutritionalValues.addedSugars!,
          ),
        if (nutritionalValues.caffeine != null)
          NutritionRow(id: "caffeine", value: nutritionalValues.caffeine!),
        if (nutritionalValues.calcium != null)
          NutritionRow(id: "calcium", value: nutritionalValues.calcium!),
        if (nutritionalValues.iron != null)
          NutritionRow(id: "iron", value: nutritionalValues.iron!),
        if (nutritionalValues.vitaminC != null)
          NutritionRow(id: "vitaminC", value: nutritionalValues.vitaminC!),
        if (nutritionalValues.magnesium != null)
          NutritionRow(id: "magnesium", value: nutritionalValues.magnesium!),
        if (nutritionalValues.phosphorus != null)
          NutritionRow(id: "phosphorus", value: nutritionalValues.phosphorus!),
        if (nutritionalValues.potassium != null)
          NutritionRow(id: "potassium", value: nutritionalValues.potassium!),
        if (nutritionalValues.zinc != null)
          NutritionRow(id: "zinc", value: nutritionalValues.zinc!),
        if (nutritionalValues.copper != null)
          NutritionRow(id: "copper", value: nutritionalValues.copper!),
        if (nutritionalValues.selenium != null)
          NutritionRow(id: "selenium", value: nutritionalValues.selenium!),
        if (nutritionalValues.vitaminA != null)
          NutritionRow(id: "vitaminA", value: nutritionalValues.vitaminA!),
        if (nutritionalValues.vitaminE != null)
          NutritionRow(id: "vitaminE", value: nutritionalValues.vitaminE!),
        if (nutritionalValues.vitaminD != null)
          NutritionRow(id: "vitaminD", value: nutritionalValues.vitaminD!),
        if (nutritionalValues.vitaminB1 != null)
          NutritionRow(id: "vitaminB1", value: nutritionalValues.vitaminB1!),
        if (nutritionalValues.vitaminB2 != null)
          NutritionRow(id: "vitaminB2", value: nutritionalValues.vitaminB2!),
        if (nutritionalValues.vitaminPP != null)
          NutritionRow(id: "vitaminPP", value: nutritionalValues.vitaminPP!),
        if (nutritionalValues.vitaminB6 != null)
          NutritionRow(id: "vitaminB6", value: nutritionalValues.vitaminB6!),
        if (nutritionalValues.vitaminB12 != null)
          NutritionRow(id: "vitaminB12", value: nutritionalValues.vitaminB12!),
        if (nutritionalValues.vitaminB9 != null)
          NutritionRow(id: "vitaminB9", value: nutritionalValues.vitaminB9!),
        if (nutritionalValues.vitaminK != null)
          NutritionRow(id: "vitaminK", value: nutritionalValues.vitaminK!),
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
          NutritionRow(id: "capricAcid", value: nutritionalValues.capricAcid!),
        if (nutritionalValues.lauricAcid != null)
          NutritionRow(id: "lauricAcid", value: nutritionalValues.lauricAcid!),
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
          NutritionRow(id: "oleicAcid", value: nutritionalValues.oleicAcid!),
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
          NutritionRow(id: "erucicAcid", value: nutritionalValues.erucicAcid!),
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
          NutritionRow(id: "alcohol", value: nutritionalValues.alcohol!),
        if (nutritionalValues.pantothenicAcid != null)
          NutritionRow(
            id: "pantothenicAcid",
            value: nutritionalValues.pantothenicAcid!,
          ),
        if (nutritionalValues.biotin != null)
          NutritionRow(id: "biotin", value: nutritionalValues.biotin!),
        if (nutritionalValues.chloride != null)
          NutritionRow(id: "chloride", value: nutritionalValues.chloride!),
        if (nutritionalValues.chromium != null)
          NutritionRow(id: "chromium", value: nutritionalValues.chromium!),
        if (nutritionalValues.fluoride != null)
          NutritionRow(id: "fluoride", value: nutritionalValues.fluoride!),
        if (nutritionalValues.iodine != null)
          NutritionRow(id: "iodine", value: nutritionalValues.iodine!),
        if (nutritionalValues.manganese != null)
          NutritionRow(id: "manganese", value: nutritionalValues.manganese!),
        if (nutritionalValues.molybdenum != null)
          NutritionRow(id: "molybdenum", value: nutritionalValues.molybdenum!),
        if (nutritionalValues.omega3 != null)
          NutritionRow(id: "omega3", value: nutritionalValues.omega3!),
        if (nutritionalValues.omega6 != null)
          NutritionRow(id: "omega6", value: nutritionalValues.omega6!),
        if (nutritionalValues.omega9 != null)
          NutritionRow(id: "omega9", value: nutritionalValues.omega9!),
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
          NutritionRow(id: "meadAcid", value: nutritionalValues.meadAcid!),
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
          NutritionRow(id: "transFat", value: nutritionalValues.transFat!),
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
    final decSep = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    ).symbols.DECIMAL_SEP;
    var stringifiedValue = stringifyDouble(value, decimalSeparator: decSep);
    if (value < 0.01 && value != 0) {
      stringifiedValue = "<0${decSep}01";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            context.t.food.nutriments[id] ?? "UNKNOWN",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$stringifiedValue ${context.t.food.nutrimentUnits[kNutritionValueToUnit[id]!.toCamelCase()]}"
              .trim(),
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class CustomAddFoodView extends ConsumerStatefulWidget {
  final String? barcode;
  final NutritionCategory? category;

  const CustomAddFoodView({super.key, required this.category}) : barcode = null;

  const CustomAddFoodView.withBarcode({
    super.key,
    required this.barcode,
    required this.category,
  });

  @override
  ConsumerState<CustomAddFoodView> createState() => _CustomAddFoodViewState();
}

class _CustomAddFoodViewState extends ConsumerState<CustomAddFoodView> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool expanded = false;
  final controllers = {
    "calories": TextEditingController(),
    "protein": TextEditingController(),
    "carbs": TextEditingController(),
    "sugar": TextEditingController(),
    "fat": TextEditingController(),
    "saturatedFat": TextEditingController(),
    "water": TextEditingController(),
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
  bool submitToCatalog = true;
  bool saving = false;
  double amount = 100;
  int pieces = 1;
  late final amountController = TextEditingController(
    text: stringifyDouble(amount),
  );
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
    final catalogOwner = ref.watch(currentUserIdProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = colorScheme.surfaceContainerHigh;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.food.add.customFood.title)),
      extendBody: true,
      body: SingleChildScrollView(
        child: GradientBottomBar.wrap(
          context: context,
          child: Builder(
            builder: (context) {
              return Padding(
                padding:
                    MediaQuery.paddingOf(context).copyWith(top: 0) +
                    const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: GymTrackerInputDecoration(
                          labelText: context.t.food.add.customFood.fields.name,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if ((value == null || value.trim().isEmpty)) {
                            return context.t.food.add.nameEmpty;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: brandController,
                        decoration: GymTrackerInputDecoration(
                          labelText: context.t.food.add.customFood.fields.brand,
                        ),
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          SegmentedButton<NutritionUnit>(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
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
                                label: Text(
                                  context.t.food.nutrimentUnits['g']!,
                                ),
                                value: NutritionUnit.G,
                              ),
                              ButtonSegment<NutritionUnit>(
                                label: Text(
                                  context.t.food.nutrimentUnits['milliL']!,
                                ),
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
                      const SizedBox(height: 8),
                      IntStepperFormField(
                        value: pieces,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            pieces = value;
                          });
                        },
                        decoration: GymTrackerInputDecoration(
                          labelText: context.t.food.add.pieces,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        key: const ValueKey('submit-to-catalog'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.t.food.catalog.submitAlso),
                        subtitle: Text(
                          catalogOwner == null
                              ? context.t.food.catalog.loginToSubmit
                              : context.t.food.catalog.publicNotice,
                        ),
                        value: submitToCatalog && catalogOwner != null,
                        onChanged: catalogOwner == null || saving
                            ? null
                            : (value) {
                                setState(
                                  () => submitToCatalog = value ?? false,
                                );
                              },
                      ),
                      const Divider(height: 32),
                      Text(
                        context.t.food.add.nutritionalValuesPerAmountWithUnit(
                          amount: "100",
                          unit:
                              context.t.food.nutrimentUnits[unit
                                  .toCamelCase()] ??
                              "UNKNOWN",
                        ),
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
                                      "${context.t.food.nutriments[id]} (${context.t.food.nutrimentUnits[kNutritionValueToUnit[id]!.toCamelCase()] ?? "UNKNOWN"})",
                                  suffix: Text(
                                    context
                                            .t
                                            .food
                                            .nutrimentUnits[kNutritionValueToUnit[id]!
                                            .toCamelCase()] ??
                                        "UNKNOWN",
                                  ),
                                  hintText: required.contains(id)
                                      ? null
                                      : context.t.general.optional,
                                ),
                                keyboardType: _kKeyboardType,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (required.contains(id)) {
                                    if ((value == null || value.isEmpty)) {
                                      return context.t.food.add.amountEmpty;
                                    }
                                  } else {
                                    return null;
                                  }
                                  if (value.tryParseDouble() == null) {
                                    return context.t.food.add.amountInvalid;
                                  }
                                  final double parsedValue = value
                                      .parseDouble();
                                  if (parsedValue < 0 ||
                                      parsedValue.isNaN ||
                                      parsedValue.isInfinite) {
                                    return context.t.food.add.amountInvalid;
                                  }
                                  return null;
                                },
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
                          onPressed: () async {
                            setState(() {
                              expanded = true;
                            });
                          },
                          child: Text(context.t.food.add.customFood.showMore),
                        ),
                      ),
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
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (saving) return;
              setState(() => saving = true);
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
                pieces: pieces,
                category: widget.category?.name,
              );

              if (widget.barcode != null) {
                await ref
                    .read(foodProvider.notifier)
                    .addCustomBarcodeFood(
                      widget.barcode!,
                      food,
                      widget.category,
                    );
              }

              if (submitToCatalog && catalogOwner != null) {
                try {
                  await ref
                      .read(catalogOutboxProvider)
                      .enqueue(catalogOwner, food);
                } catch (error, stack) {
                  globalLogger.w(
                    'Could not queue explicit catalog submission',
                    error: error,
                    stackTrace: stack,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.t.food.catalog.queueFailed),
                      ),
                    );
                  }
                }
              }
              if (!context.mounted) return;
              Navigator.of(context).pop(food);
            },
            child: Text(context.t.food.add.add),
          ),
        ],
      ),
    );
  }
}

class SearchResultsView extends ConsumerWidget {
  final Future<List<VagueFood>> foods;
  final bool showAddCustom;
  final NutritionCategory? category;

  const SearchResultsView({
    super.key,
    required this.foods,
    this.showAddCustom = true,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.food.search.title)),
      body: FutureBuilder<List<VagueFood>>(
        future: foods,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ErrorViewComponent(
                    title:
                        snapshot.error is DioException &&
                            (snapshot.error as DioException).type ==
                                DioExceptionType.badResponse
                        ? context.t.food.search.error.serverError
                        : context.t.food.search.error.generic,
                    error: snapshot.error,
                  ),
                ),
              ],
            );
          }

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
                        trailing: food is CatalogFood
                            ? IconButton(
                                tooltip: context.t.food.catalog.report,
                                icon: const Icon(Icons.flag_outlined),
                                onPressed: () => showCatalogReport(
                                  context,
                                  ref,
                                  food.catalogId,
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop(food);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: showAddCustom
          ? _AddCustomFoodFAB(
              closeView: () => Navigator.of(context).pop(),
              category: category,
              onFoodAdded: (food) async {
                Navigator.of(context).pop(food);
              },
            )
          : null,
    );
  }
}

class FoodBarcodeReaderView extends ConsumerStatefulWidget {
  final void Function(Food) onFoodReceived;

  const FoodBarcodeReaderView({super.key, required this.onFoodReceived});

  @override
  ConsumerState<FoodBarcodeReaderView> createState() =>
      _FoodBarcodeReaderViewState();
}

class _FoodBarcodeReaderViewState extends ConsumerState<FoodBarcodeReaderView>
    with WidgetsBindingObserver {
  final controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: .back,
    autoStart: false,
    formats: [.ean8, .ean13, .upcA, .upcE],
  );

  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_rawHandleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  void dispose() {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    EasyDebounce.cancel('barcode');
    unawaited(controller.dispose());
    // Dispose the widget itself.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_rawHandleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.food.barcodeReader.title),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(GTIcons.debug),
              onPressed: () async {
                handleCode(context, ref, "8000965154468");
              },
            ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetectError: (Object error, StackTrace stackTrace) {
          Go.snack("$error");
        },
        placeholderBuilder: (context) {
          return Center(child: GBLoadingIndicator());
        },
        overlayBuilder: (context, _) {
          final windowSize = MediaQuery.of(context).size;
          final smallestSide = math.min(windowSize.width, windowSize.height);
          final size = Size(smallestSide * 0.8, smallestSide * 0.4);
          return ClipPath(
            clipper: InvertedClipper(windowSize: size),
            child: Container(color: Colors.black54),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Go.to(
            () => ManualBarcodeInsertionScreen(
              handleCode: (code) {
                if (!mounted) return;
                handleCode(context, ref, code);
                Navigator.of(context).pop();
              },
            ),
          );
        },
        child: const Icon(GTIcons.keyboard),
      ),
    );
  }

  void _rawHandleBarcode(BarcodeCapture result) async {
    if (!mounted || result.barcodes.isEmpty) return;
    EasyDebounce.debounce("barcode", const Duration(milliseconds: 2500), () {
      if (mounted) {
        unawaited(handleCode(context, ref, result.barcodes.first.rawValue));
      }
    });
  }

  bool _handlingCode = false;

  Future<void> handleCode(
    BuildContext context,
    WidgetRef ref,
    String? code,
  ) async {
    if (!mounted) return;
    if (code == null) {
      logger.w("Invalid code");
      return;
    }

    if (_handlingCode) return;
    _handlingCode = true;
    return searchFoodByBarcode(context, ref, code)
        .then((food) async {
          if (!mounted) return;
          if (food == null) {
            logger.w("No food found for barcode $code");
            return;
          }
          widget.onFoodReceived(food);
        })
        .whenComplete(() => _handlingCode = false);
  }
}

class InvertedClipper extends CustomClipper<Path> {
  final Size windowSize;

  InvertedClipper({required this.windowSize});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: windowSize.width,
            height: windowSize.height,
          ),
          const Radius.circular(16),
        ),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ManualBarcodeInsertionScreen extends StatefulWidget {
  final void Function(String?) handleCode;

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

    final code = controller.text;
    Go.back();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.handleCode(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.food.barcodeReader.enterCode)),
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
                  labelText: context.t.food.barcodeReader.codeField.label,
                ),
                onFieldSubmitted: (_) => ok(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.t.food.barcodeReader.codeField.empty;
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
        child: const Icon(GTIcons.search),
      ),
    );
  }
}

class AddCombinedFoodView extends ConsumerStatefulWidget {
  const AddCombinedFoodView({super.key, required this.category});

  final NutritionCategory? category;

  @override
  ConsumerState<AddCombinedFoodView> createState() =>
      _AddCombinedFoodViewState();
}

class _AddCombinedFoodViewState extends ConsumerState<AddCombinedFoodView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController amountController = TextEditingController(
    text: "100",
  );

  var amount = 100.0;
  var unit = NutritionUnit.G;
  var constituents = <Food>[];

  NutritionValues get nutritionalValues => NutritionValues.sum(
    constituents.map((food) => (food.amount, food.nutritionalValues)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.food.combine.title)),
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
                  delegate: SliverChildListDelegate.fixed([
                    TextFormField(
                      controller: nameController,
                      decoration: GymTrackerInputDecoration(
                        labelText: context.t.food.add.customFood.fields.name,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if ((value == null || value.trim().isEmpty)) {
                          return context.t.food.add.nameEmpty;
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: brandController,
                      decoration: GymTrackerInputDecoration(
                        labelText: context.t.food.add.customFood.fields.brand,
                      ),
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        SegmentedButton<NutritionUnit>(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
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
                              label: Text(context.t.food.nutrimentUnits['g']!),
                              value: NutritionUnit.G,
                            ),
                            ButtonSegment<NutritionUnit>(
                              label: Text(
                                context.t.food.nutrimentUnits['milliL']!,
                              ),
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
                  ]),
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
                    showAddFoodView(context, constituents[i]).then((
                      value,
                    ) async {
                      if (value != null) {
                        setState(() {
                          constituents[i] = value;
                        });
                      }
                    });
                  },
                ),
                itemCount: constituents.length,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
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
                              if (constituents.any(
                                (food) => food.downloadedFromOFF,
                              )) ...[
                                const SizedBox(height: 16),
                                OpenFoodFactsTableAttribution(
                                  food: VagueFood(
                                    name: "",
                                    nutritionalValuesPer100g: nutritionalValues,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
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
                      downloadedFromOFF: constituents.any(
                        (food) => food.downloadedFromOFF,
                      ),
                    );

                    Go.back(result: food);
                  },
            child: Text(context.t.food.add.add),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return SearchAnchorPlus(
      suggestionsBuilder: _getSearchSuggestionBuilder(
        ref: ref,
        closeView: () => Go.back(),
        onFoodTap: (dtfood) {
          final food = dtfood.value;
          setState(() {
            constituents.add(food);
          });
        },
      ),
      hintText: context.t.food.searchBar.hint,
      barTrailing: [
        IconButton(
          icon: const Icon(GTIcons.scan_barcode),
          tooltip: context.t.food.barcodeReader.title,
          onPressed: () async {
            showScanBarcodeView(context, ref).then((value) async {
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
        showSearchResultsViewForCombination(context, ref, query).then((
          value,
        ) async {
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
        closeView: () => Go.back(),
        category: widget.category,
        onFoodAdded: (food) async {
          if (food != null) {
            setState(() {
              constituents.add(food);
            });
          }
        },
      ),
    );
  }
}

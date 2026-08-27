part of 'food.dart';

class ChangeGoalScreen extends ConsumerStatefulWidget {
  const ChangeGoalScreen({super.key});

  @override
  ConsumerState<ChangeGoalScreen> createState() => _ChangeGoalScreenState();
}

class _ChangeGoalScreenState extends ConsumerState<ChangeGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dailyCaloriesController;
  late final TextEditingController _fatPercentageController;
  late final TextEditingController _carbsPercentageController;
  late final TextEditingController _proteinPercentageController;

  @override
  void initState() {
    super.initState();
    final oldGoal = ref.read(nutritionGoalForSelectedDateProvider);
    final decimalSep = NumberFormat.decimalPattern(Get.locale?.languageCode).symbols.DECIMAL_SEP;
    _dailyCaloriesController = TextEditingController(
      text: stringifyDouble(oldGoal.dailyCalories, decimalSeparator: decimalSep),
    );
    _fatPercentageController = TextEditingController(
      text: stringifyDouble(oldGoal.fatPercentage, decimalSeparator: decimalSep),
    );
    _carbsPercentageController = TextEditingController(
      text: stringifyDouble(oldGoal.carbsPercentage, decimalSeparator: decimalSep),
    );
    _proteinPercentageController = TextEditingController(
      text: stringifyDouble(oldGoal.proteinPercentage, decimalSeparator: decimalSep),
    );
  }

  @override
  void dispose() {
    _dailyCaloriesController.dispose();
    _fatPercentageController.dispose();
    _carbsPercentageController.dispose();
    _proteinPercentageController.dispose();
    super.dispose();
  }

  Widget _buildEffectText() {
    final fx = ref.watch(nutritionGoalDateRangeProvider);
    if (fx == null) {
      return const SizedBox();
    }
    String s;
    String fmt(DateTime d) => DateFormat.yMd().format(d);
    if (fx.to == null) {
      s = "food.nutritionGoal.effect.from".tParams({
        "from": fmt(fx.from!),
      });
    } else {
      s = "food.nutritionGoal.effect.range".tParams({
        "from": fmt(fx.from!),
        "to": fmt(fx.to!),
      });
    }

    return Text(s, style: context.theme.textTheme.labelLarge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('food.nutritionGoals.change.title'.t), actions: [
        IconButton(
          icon: const Icon(GTIcons.history),
          tooltip: "food.nutritionGoals.history.title".t,
          onPressed: () {
            showGoalHistory(context);
          },
        ),
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0) +
              MediaQuery.of(context).padding.copyWith(
                    top: 0,
                    bottom: 0,
                  ),
          child: Form(
            key: _formKey,
            onChanged: () {
              setState(() {});
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _dailyCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'food.nutritionGoals.change.calories.label'.t),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "food.nutritionGoals.change.calories.empty".t;
                    }
                    if (value.tryParseDouble() == null) {
                      return "food.nutritionGoals.change.calories.invalid".t;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fatPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText:
                          'food.nutritionGoals.change.fatPercentage.label'.t),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "food.nutritionGoals.change.fatPercentage.empty".t;
                    }
                    if (value.tryParseDouble() == null) {
                      return "food.nutritionGoals.change.fatPercentage.invalid"
                          .t;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return "food.nutritionGoals.change.fatPercentage.invalid"
                          .t;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbsPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText:
                          'food.nutritionGoals.change.carbsPercentage.label'.t),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "food.nutritionGoals.change.carbsPercentage.empty"
                          .t;
                    }
                    if (value.tryParseDouble() == null) {
                      return "food.nutritionGoals.change.carbsPercentage.invalid"
                          .t;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return "food.nutritionGoals.change.carbsPercentage.invalid"
                          .t;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _proteinPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText:
                          'food.nutritionGoals.change.proteinPercentage.label'
                              .t),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "food.nutritionGoals.change.proteinPercentage.empty"
                          .t;
                    }
                    if (value.tryParseDouble() == null) {
                      return "food.nutritionGoals.change.proteinPercentage.invalid"
                          .t;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return "food.nutritionGoals.change.proteinPercentage.invalid"
                          .t;
                    }
                    return null;
                  },
                ),
                _buildSumText(
                  _fatPercentageController.text.tryParseDouble() ?? 0,
                  _carbsPercentageController.text.tryParseDouble() ?? 0,
                  _proteinPercentageController.text.tryParseDouble() ?? 0,
                ),
                const SizedBox(height: 16),
                _buildEffectText(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(GTIcons.save),
        label: Text('food.nutritionGoals.change.save'.t),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final dailyCalories = _dailyCaloriesController.text.parseDouble();
      final fatPercentage = _fatPercentageController.text.parseDouble();
      final carbsPercentage = _carbsPercentageController.text.parseDouble();
      final proteinPercentage = _proteinPercentageController.text.parseDouble();

      final newGoal = NutritionGoal.fromPercentages(
        dailyCalories: dailyCalories,
        fatPercentage: fatPercentage,
        carbsPercentage: carbsPercentage,
        proteinPercentage: proteinPercentage,
      );

      ref.read(nutritionGoalProvider.notifier).saveNewGoal(newGoal);

      Get.back();
    }
  }

  Widget _buildSumText(double f, double c, double p) {
    if (doubleEquality(100, f + c + p, epsilon: 1.5)) return const SizedBox();

    final terms = [f, c, p]
        .map((e) => NumberFormat.decimalPercentPattern(
                locale: Get.locale?.languageCode, decimalDigits: 2)
            .format(e / 100))
        .toList()
        .join(" + ");
    final res = NumberFormat.decimalPercentPattern(
            locale: Get.locale?.languageCode, decimalDigits: 2)
        .format((f + c + p) / 100);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        "$terms = $res",
        style: context.theme.textTheme.labelSmall!.copyWith(
          color: context.theme.colorScheme.tertiary,
        ),
      ),
    );
  }
}

class GoalHistoryView extends ConsumerWidget {
  const GoalHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsSeq = ref.watch(nutritionGoalsStreamProvider).asData?.value ??
        DateSequence<NutritionGoal>.fromList([]);
    final keys = goalsSeq.keys.toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("food.nutritionGoals.history.title".t),
            pinned: true,
          ),
          if (keys.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text("food.nutritionGoals.history.empty".t),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final key = keys[index];
                  final goal = goalsSeq[key];
                  final formattedDate =
                      DateFormat.yMEd(Get.locale?.languageCode).format(key);
                  return ListTile(
                    title: Text(
                        "food.nutritionGoals.history.calories".tParams({
                      "calories": NutritionUnit.KCAL
                          .formatAmount(goal.dailyCalories),
                    })),
                    subtitle: Text.rich(TextSpan(children: [
                      TextSpan(
                          text:
                              "$formattedDate \u2013 ${"food.nutritionGoals.history.tapToView".t}"),
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: "food.nutritionGoals.history.macros".tParams({
                          "fat": NumberFormat.decimalPercentPattern(
                                  locale: Get.locale?.languageCode,
                                  decimalDigits: 2)
                              .format(goal.fatPercentage / 100),
                          "carbs": NumberFormat.decimalPercentPattern(
                                  locale: Get.locale?.languageCode,
                                  decimalDigits: 2)
                              .format(goal.carbsPercentage / 100),
                          "protein": NumberFormat.decimalPercentPattern(
                                  locale: Get.locale?.languageCode,
                                  decimalDigits: 2)
                              .format(goal.proteinPercentage / 100),
                        }),
                      ),
                    ])),
                    trailing: const Icon(GTIcons.lt_chevron),
                    onTap: () {
                      ref.read(foodSelectedDateProvider.notifier).setDate(key);
                      Go.popUntil((route) => route.isFirst);
                    },
                  );
                },
                childCount: keys.length,
              ),
            ),
        ],
      ),
    );
  }
}

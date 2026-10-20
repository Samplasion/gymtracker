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
    final decimalSep = NumberFormat.decimalPattern(
      Get.locale?.languageCode,
    ).symbols.DECIMAL_SEP;
    _dailyCaloriesController = TextEditingController(
      text: stringifyDouble(
        oldGoal.dailyCalories,
        decimalSeparator: decimalSep,
      ),
    );
    _fatPercentageController = TextEditingController(
      text: stringifyDouble(
        oldGoal.fatPercentage,
        decimalSeparator: decimalSep,
      ),
    );
    _carbsPercentageController = TextEditingController(
      text: stringifyDouble(
        oldGoal.carbsPercentage,
        decimalSeparator: decimalSep,
      ),
    );
    _proteinPercentageController = TextEditingController(
      text: stringifyDouble(
        oldGoal.proteinPercentage,
        decimalSeparator: decimalSep,
      ),
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
      s = context.t.food.nutritionGoal.effect.from(from: fmt(fx.from!));
    } else {
      s = context.t.food.nutritionGoal.effect.range(
        from: fmt(fx.from!),
        to: fmt(fx.to!),
      );
    }

    return Text(s, style: context.theme.textTheme.labelLarge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.food.nutritionGoals.change.title),
        actions: [
          IconButton(
            icon: const Icon(GTIcons.history),
            tooltip: context.t.food.nutritionGoals.history.title,
            onPressed: () async {
              showGoalHistory(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0) +
              MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
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
                    labelText:
                        context.t.food.nutritionGoals.change.calories.label,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .calories
                          .empty;
                    }
                    if (value.tryParseDouble() == null) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .calories
                          .invalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fatPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context
                        .t
                        .food
                        .nutritionGoals
                        .change
                        .fatPercentage
                        .label,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .fatPercentage
                          .empty;
                    }
                    if (value.tryParseDouble() == null) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .fatPercentage
                          .invalid;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .fatPercentage
                          .invalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbsPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context
                        .t
                        .food
                        .nutritionGoals
                        .change
                        .carbsPercentage
                        .label,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .carbsPercentage
                          .empty;
                    }
                    if (value.tryParseDouble() == null) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .carbsPercentage
                          .invalid;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .carbsPercentage
                          .invalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _proteinPercentageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context
                        .t
                        .food
                        .nutritionGoals
                        .change
                        .proteinPercentage
                        .label,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .proteinPercentage
                          .empty;
                    }
                    if (value.tryParseDouble() == null) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .proteinPercentage
                          .invalid;
                    }
                    final double parsedValue = value.parseDouble();
                    if (parsedValue < 0 || parsedValue > 100) {
                      return context
                          .t
                          .food
                          .nutritionGoals
                          .change
                          .proteinPercentage
                          .invalid;
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
        label: Text(context.t.food.nutritionGoals.change.save),
      ),
    );
  }

  Future<void> _submitForm() async {
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

      await ref.read(nutritionGoalProvider.notifier).saveNewGoal(newGoal);

      Get.back();
    }
  }

  Widget _buildSumText(double f, double c, double p) {
    if (doubleEquality(100, f + c + p, epsilon: 1.5)) return const SizedBox();

    final terms = [f, c, p]
        .map(
          (e) => NumberFormat.decimalPercentPattern(
            locale: Get.locale?.languageCode,
            decimalDigits: 2,
          ).format(e / 100),
        )
        .toList()
        .join(" + ");
    final res = NumberFormat.decimalPercentPattern(
      locale: Get.locale?.languageCode,
      decimalDigits: 2,
    ).format((f + c + p) / 100);
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
    final goalsSeq =
        ref.watch(nutritionGoalsStreamProvider).asData?.value ??
        DateSequence<NutritionGoal>.fromList([]);
    final keys = goalsSeq.keys.toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(context.t.food.nutritionGoals.history.title),
            pinned: true,
          ),
          if (keys.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(context.t.food.nutritionGoals.history.empty),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final key = keys[index];
                final goal = goalsSeq[key];
                final formattedDate = DateFormat.yMEd(
                  Get.locale?.languageCode,
                ).format(key);
                return ListTile(
                  title: Text(
                    context.t.food.nutritionGoals.history.calories(
                      calories: NutritionUnit.KCAL.formatAmount(
                        goal.dailyCalories,
                        context: context,
                      ),
                    ),
                  ),
                  subtitle: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "$formattedDate \u2013 ${context.t.food.nutritionGoals.history.tapToView}",
                        ),
                        const TextSpan(text: "\n"),
                        TextSpan(
                          text: context.t.food.nutritionGoals.history.macros(
                            fat: NumberFormat.decimalPercentPattern(
                              locale: Get.locale?.languageCode,
                              decimalDigits: 2,
                            ).format(goal.fatPercentage / 100),
                            carbs: NumberFormat.decimalPercentPattern(
                              locale: Get.locale?.languageCode,
                              decimalDigits: 2,
                            ).format(goal.carbsPercentage / 100),
                            protein: NumberFormat.decimalPercentPattern(
                              locale: Get.locale?.languageCode,
                              decimalDigits: 2,
                            ).format(goal.proteinPercentage / 100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () {
                    ref.read(foodSelectedDateProvider.notifier).setDate(key);
                    Go.popUntil((route) => route.isFirst);
                  },
                );
              }, childCount: keys.length),
            ),
        ],
      ),
    );
  }
}

part of 'food.dart';

String _recipeNumber(BuildContext context, num value) =>
    NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(value);

String? _positiveRecipeValue(BuildContext context, String? text) {
  final value = text?.tryParseDouble();
  return value == null || !value.isFinite || value <= 0
      ? context.t.food.recipes.invalid
      : null;
}

Future<RecipeIngredient?> _weighIngredient(
  BuildContext context,
  Food food, {
  double? gramsPerMl,
}) async {
  final item = RecipeIngredient(food: food, gramsPerMl: gramsPerMl);
  if (food.unit != NutritionUnit.MILLI_L) {
    item.validate();
    return item;
  }
  final grams = await showDialog<double>(
    context: context,
    builder: (_) => _LiquidMassDialog(item: item),
  );
  if (grams == null) return null;
  final result = RecipeIngredient(
    food: food,
    gramsPerMl: grams / item.quantity,
  );
  result.validate();
  return result;
}

class _LiquidMassDialog extends StatefulWidget {
  const _LiquidMassDialog({required this.item});
  final RecipeIngredient item;
  @override
  State<_LiquidMassDialog> createState() => _LiquidMassDialogState();
}

class _LiquidMassDialogState extends State<_LiquidMassDialog> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(
    text: widget.item.gramsPerMl == null ? '' : widget.item.mass.toString(),
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.t.food.recipes;
    return AlertDialog(
      title: Text(s.liquidMass),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.item.food.name}: ${_recipeNumber(context, widget.item.quantity)} ml',
              ),
              const SizedBox(height: 8),
              Text(s.liquidHint),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                autofocus: true,
                keyboardType: _kKeyboardType,
                decoration: InputDecoration(
                  labelText: s.equivalentMass,
                  hintText: '${_recipeNumber(context, widget.item.quantity)} g',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? null
                    : _positiveRecipeValue(context, v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(
                context,
                _controller.text.trim().isEmpty
                    ? widget.item.quantity
                    : _controller.text.tryParseDouble(),
              );
            }
          },
          child: Text(s.confirm),
        ),
      ],
    );
  }
}

class RecipeListView extends ConsumerStatefulWidget {
  const RecipeListView({super.key, this.picking = false});
  final bool picking;
  @override
  ConsumerState<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends ConsumerState<RecipeListView> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final s = context.t.food.recipes;
    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      floatingActionButton: FloatingActionButton(
        tooltip: s.create,
        onPressed: () => Go.to(() => const RecipeEditorView()),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: s.search,
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: ref
                .watch(recipesProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(recipesProvider),
                      child: Text(s.failed),
                    ),
                  ),
                  data: (recipes) {
                    final matches =
                        recipes
                            .where((r) => r.name.toLowerCase().contains(_query))
                            .toList()
                          ..sort(
                            (a, b) => a.name.toLowerCase().compareTo(
                              b.name.toLowerCase(),
                            ),
                          );
                    if (matches.isEmpty) return Center(child: Text(s.empty));
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final recipe = matches[index];
                        return ListTile(
                          leading: const Icon(Icons.menu_book_outlined),
                          title: Text(recipe.name),
                          subtitle: Text(
                            '${recipe.servings} ${s.servings.toLowerCase()} · ${_recipeNumber(context, recipe.servingMass)} g',
                          ),
                          onTap: () async {
                            final food = await Go.to<Food>(
                              () => RecipeDetailView(
                                recipeId: recipe.id,
                                picking: widget.picking,
                              ),
                            );
                            if (food != null &&
                                context.mounted &&
                                widget.picking) {
                              Navigator.pop(context, food);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailView extends ConsumerWidget {
  const RecipeDetailView({
    super.key,
    required this.recipeId,
    this.picking = false,
  });
  final String recipeId;
  final bool picking;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.t.food.recipes;
    final state = ref.watch(recipesProvider);
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(s.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(s.title)),
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(recipesProvider),
            child: Text(s.failed),
          ),
        ),
      );
    }
    final recipe = state.asData?.value
        .where((r) => r.id == recipeId)
        .firstOrNull;
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.title)),
        body: Center(child: Text(s.empty)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(s.choose),
        actions: [
          IconButton(
            tooltip: s.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Go.to(() => RecipeEditorView(base: recipe)),
          ),
          IconButton(
            tooltip: s.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final repository = ref.read(recipesRepositoryProvider);
              final owner = repository.db.currentUserId;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(s.delete),
                  content: Text(s.deletePrompt),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(s.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(s.delete),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;
              try {
                if (repository.db.currentUserId != owner) {
                  throw StateError('Account changed');
                }
                await repository.remove(recipe.id);
                if (context.mounted) Navigator.pop(context);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(s.failed)));
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 32,
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.name,
                        style: context.theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.people_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              '${recipe.servings} ${s.servings.toLowerCase()}',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(Icons.scale_outlined, size: 18),
                            label: Text(
                              '${_recipeNumber(context, recipe.mass)} g',
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${_recipeNumber(context, recipe.perServing.calories)} kcal · ${s.perServing.toLowerCase()}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!recipe.description.asQuillDocument().isEmpty())
                  _RecipeEditorSection(
                    icon: Icons.notes_rounded,
                    title: s.description,
                    children: [MaybeRichText(text: recipe.description)],
                  ),
                _RecipeEditorSection(
                  icon: Icons.shopping_basket_outlined,
                  title: s.ingredients,
                  trailing: Chip(
                    label: Text('${recipe.ingredients.length}'),
                    side: BorderSide.none,
                  ),
                  children: [
                    for (
                      var index = 0;
                      index < recipe.ingredients.length;
                      index++
                    ) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              context.theme.colorScheme.secondaryContainer,
                          foregroundColor:
                              context.theme.colorScheme.onSecondaryContainer,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(recipe.ingredients[index].food.name),
                        subtitle: Text(
                          '${_recipeNumber(context, recipe.ingredients[index].quantity)} ${serializeUnit(recipe.ingredients[index].food.unit)}',
                        ),
                        trailing: Text(
                          '${_recipeNumber(context, recipe.ingredients[index].mass)} g',
                          style: context.theme.textTheme.labelLarge,
                        ),
                      ),
                      if (index < recipe.ingredients.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
                if (!recipe.instructions.asQuillDocument().isEmpty())
                  _RecipeEditorSection(
                    icon: Icons.soup_kitchen_outlined,
                    title: s.instructions,
                    children: [MaybeRichText(text: recipe.instructions)],
                  ),
                _RecipeNutritionCard(recipe: recipe, initiallyExpanded: true),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: Text(s.add),
                onPressed: () async {
                  final repository = ref.read(recipesRepositoryProvider);
                  final owner = repository.db.currentUserId;
                  final date = ref.read(foodSelectedDateProvider);
                  final food = await showRecipeAmount(context, recipe);
                  if (food == null || !context.mounted) return;
                  if (owner != repository.db.currentUserId) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(s.accountChanged)));
                    return;
                  }
                  if (picking) {
                    Navigator.pop(context, food);
                    return;
                  }
                  try {
                    await ref.read(foodProvider.notifier).addFood(date, food);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.t.food.picker.addedNotice),
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(s.failed)));
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeSummary extends StatelessWidget {
  const _RecipeSummary({required this.recipe});
  final Recipe recipe;
  @override
  Widget build(BuildContext context) {
    final s = context.t.food.recipes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${s.automaticMass}: ${_recipeNumber(context, recipe.ingredientMass)} g',
        ),
        Text('${s.total}: ${_recipeNumber(context, recipe.mass)} g'),
        Text(s.total, style: context.theme.textTheme.titleMedium),
        NutritionTable(
          per100g: recipe.per100g,
          amount: recipe.mass,
          unit: NutritionUnit.G,
        ),
        if (recipe.servings > 1) ...[
          const SizedBox(height: 24),
          Text(
            '${s.perServing}: ${_recipeNumber(context, recipe.servingMass)} g',
            style: context.theme.textTheme.titleMedium,
          ),
          NutritionTable(
            per100g: recipe.per100g,
            amount: recipe.servingMass,
            unit: NutritionUnit.G,
          ),
        ],
        if (recipe.ingredients.any((i) => i.food.downloadedFromOFF))
          OpenFoodFactsTableAttribution(
            food: VagueFood(
              name: recipe.name,
              nutritionalValuesPer100g: recipe.per100g,
            ),
          ),
      ],
    );
  }
}

String _recipeInputNumber(BuildContext context, double value) {
  final nearest = value.roundToDouble();
  final normalized = nearest > 0 && (value - nearest).abs() < 1e-7
      ? nearest
      : value;
  final format =
      NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
        ..turnOffGrouping()
        ..maximumFractionDigits = 12;
  return format.format(normalized);
}

Future<Food?> showRecipeAmount(BuildContext context, Recipe recipe) =>
    showDialog<Food>(
      context: context,
      builder: (_) => _RecipeAmountDialog(recipe: recipe),
    );

class _RecipeAmountDialog extends StatefulWidget {
  const _RecipeAmountDialog({required this.recipe});
  final Recipe recipe;
  @override
  State<_RecipeAmountDialog> createState() => _RecipeAmountDialogState();
}

class _RecipeAmountDialogState extends State<_RecipeAmountDialog> {
  final _controller = TextEditingController(text: '1');
  final _form = GlobalKey<FormState>();
  bool _byGrams = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(double delta) {
    final current = _controller.text.tryParseDouble();
    final next = (current != null && current.isFinite ? current : 1) + delta;
    if (next <= 0 || !next.isFinite) return;
    setState(() => _controller.text = _recipeInputNumber(context, next));
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final s = context.t.food.recipes;
    final value = _controller.text.tryParseDouble();
    final valid = value != null && value.isFinite && value > 0;
    final grams = valid ? (_byGrams ? value : value * recipe.servingMass) : 0.0;
    final nutrients = valid && grams.isFinite
        ? recipe.per100g * (grams / 100)
        : null;
    return AlertDialog(
      constraints: const BoxConstraints(maxWidth: 460),
      title: Row(
        children: [
          Icon(
            Icons.restaurant_outlined,
            color: context.theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(recipe.name)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.restaurant_outlined),
                      label: Text(s.portions),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.scale_outlined),
                      label: Text(s.grams),
                    ),
                  ],
                  selected: {_byGrams},
                  onSelectionChanged: (selection) => setState(() {
                    final oldValue = _controller.text.tryParseDouble();
                    final next = selection.first;
                    if (oldValue != null && oldValue.isFinite && oldValue > 0) {
                      final converted = next
                          ? oldValue * recipe.servingMass
                          : oldValue / recipe.servingMass;
                      if (converted.isFinite) {
                        _controller.text = _recipeInputNumber(
                          context,
                          converted,
                        );
                      }
                    }
                    _byGrams = next;
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (!_byGrams) ...[
                      IconButton.filledTonal(
                        tooltip: s.decreaseQuantity,
                        onPressed: valid && value > 1 ? () => _step(-1) : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: _kKeyboardType,
                        textAlign: _byGrams
                            ? TextAlign.start
                            : TextAlign.center,
                        style: context.theme.textTheme.titleLarge,
                        decoration: InputDecoration(
                          labelText: _byGrams ? s.grams : s.portions,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (v) => _positiveRecipeValue(context, v),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (!_byGrams) ...[
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        tooltip: s.increaseQuantity,
                        onPressed: () => _step(1),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${s.perServing}: ${_recipeNumber(context, recipe.servingMass)} g',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (nutrients != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_recipeNumber(context, grams)} g',
                          style: context.theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_recipeNumber(context, nutrients.calories)} kcal',
                          style: context.theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _macro(context, 'protein', nutrients.protein),
                            _macro(context, 'carbs', nutrients.carbs),
                            _macro(context, 'fat', nutrients.fat),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            if (_form.currentState!.validate() && grams.isFinite && grams > 0) {
              Navigator.pop(context, recipe.toFood(grams: grams));
            }
          },
          label: Text(s.add),
        ),
      ],
    );
  }

  Widget _macro(BuildContext context, String nutrient, double value) =>
      Expanded(
        child: Column(
          children: [
            Text(
              '${_recipeNumber(context, value)} g',
              style: context.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.t.food.nutriments[nutrient]!,
              style: context.theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class RecipeEditorView extends ConsumerStatefulWidget {
  const RecipeEditorView({super.key, this.base});
  final Recipe? base;
  @override
  ConsumerState<RecipeEditorView> createState() => _RecipeEditorViewState();
}

class _RecipeEditorViewState extends ConsumerState<RecipeEditorView> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.base?.name);
  late final _servings = TextEditingController(
    text: '${widget.base?.servings ?? 1}',
  );
  late final _mass = TextEditingController(
    text: widget.base?.finalMass?.toString() ?? '',
  );
  late final QuillController _description = quillControllerFromText(
    widget.base?.description,
  );
  late final QuillController _instructions = quillControllerFromText(
    widget.base?.instructions,
  );
  late final _ingredients = [...?widget.base?.ingredients];
  late final String _id = widget.base?.id ?? const Uuid().v4();
  late final RecipesRepository _repository;
  late final String? _owner;
  bool _saving = false;
  bool _saved = false;
  late String _initial;

  Recipe _value() => Recipe(
    id: _id,
    name: _name.text.trim(),
    description: jsonEncode(_description.document.toDelta().toJson()),
    instructions: jsonEncode(_instructions.document.toDelta().toJson()),
    servings: int.tryParse(_servings.text) ?? 0,
    finalMass: _mass.text.trim().isEmpty ? null : _mass.text.tryParseDouble(),
    ingredients: _ingredients,
  );

  @override
  void initState() {
    super.initState();
    _repository = ref.read(recipesRepositoryProvider);
    _owner = _repository.db.currentUserId;
    _initial = jsonEncode(_value().toJson());
  }

  @override
  void dispose() {
    _name.dispose();
    _servings.dispose();
    _mass.dispose();
    _description.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final s = context.t.food.recipes;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.requiredIngredients)));
      return;
    }
    if (_repository.db.currentUserId != _owner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.accountChanged)));
      return;
    }
    setState(() => _saving = true);
    try {
      await _repository.save(_value());
      if (mounted) {
        setState(() => _saved = true);
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.failed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.t.food.recipes;
    final recipe = _value();
    final preview =
        _ingredients.isNotEmpty &&
        recipe.servings >= 1 &&
        recipe.servings <= 32 &&
        (_mass.text.trim().isEmpty ||
            _positiveRecipeValue(context, _mass.text) == null);
    return PopScope(
      canPop: _saved,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _saving) return;
        if (jsonEncode(_value().toJson()) == _initial) {
          setState(() => _saved = true);
          Navigator.pop(context);
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(s.discard),
            content: Text(s.discardBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(s.discardAction),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          setState(() => _saved = true);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.base == null ? s.create : s.edit),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(s.save),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: AbsorbPointer(
                absorbing: _saving,
                child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_saving) const LinearProgressIndicator(),
                            _RecipeEditorSection(
                              icon: Icons.restaurant_menu_rounded,
                              title: s.details,
                              children: [
                                TextFormField(
                                  controller: _name,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: context.theme.textTheme.titleLarge,
                                  decoration: _decoration(s.name),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? s.requiredName
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                GTRichTextEditor(
                                  controller: _description,
                                  decoration: _decoration(s.description),
                                ),
                              ],
                            ),
                            _RecipeEditorSection(
                              icon: Icons.shopping_basket_outlined,
                              title: s.ingredients,
                              trailing: _ingredients.isEmpty
                                  ? null
                                  : Chip(
                                      label: Text('${_ingredients.length}'),
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide.none,
                                    ),
                              children: [
                                if (_ingredients.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      s.ingredientsHint,
                                      style: context.theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: context
                                                .theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                for (
                                  var index = 0;
                                  index < _ingredients.length;
                                  index++
                                ) ...[
                                  _ingredientTile(index),
                                  if (index < _ingredients.length - 1)
                                    const Divider(height: 1),
                                ],
                                if (_ingredients.isNotEmpty)
                                  const SizedBox(height: 12),
                                FilledButton.tonalIcon(
                                  icon: const Icon(Icons.add),
                                  label: Text(s.addIngredient),
                                  onPressed: _addIngredients,
                                ),
                              ],
                            ),
                            _RecipeEditorSection(
                              icon: Icons.pie_chart_outline_rounded,
                              title: s.yieldTitle,
                              children: [
                                TextFormField(
                                  controller: _servings,
                                  keyboardType: TextInputType.number,
                                  decoration: _decoration(s.servings).copyWith(
                                    prefixIcon: const Icon(
                                      Icons.people_outline_rounded,
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) {
                                    final n = int.tryParse(v ?? '');
                                    return n == null || n < 1 || n > 32
                                        ? s.invalidServings
                                        : null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _mass,
                                  keyboardType: _kKeyboardType,
                                  decoration: _decoration(s.finalMass).copyWith(
                                    helperText: s.massHint,
                                    helperMaxLines: 3,
                                    prefixIcon: const Icon(
                                      Icons.scale_outlined,
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? null
                                      : _positiveRecipeValue(context, v),
                                ),
                                if (preview) ...[
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(
                                          Icons.scale_outlined,
                                          size: 18,
                                        ),
                                        label: Text(
                                          '${_recipeNumber(context, recipe.mass)} g · ${s.total.toLowerCase()}',
                                        ),
                                      ),
                                      if (recipe.servings > 1)
                                        Chip(
                                          avatar: const Icon(
                                            Icons.restaurant_outlined,
                                            size: 18,
                                          ),
                                          label: Text(
                                            '${_recipeNumber(context, recipe.servingMass)} g · ${s.perServing.toLowerCase()}',
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            _RecipeEditorSection(
                              icon: Icons.soup_kitchen_outlined,
                              title: s.instructions,
                              children: [
                                GTRichTextEditor(
                                  controller: _instructions,
                                  decoration: _decoration(s.instructions),
                                ),
                              ],
                            ),
                            if (preview) _RecipeNutritionCard(recipe: recipe),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (MediaQuery.viewInsetsOf(context).bottom > 0)
              Material(
                color: context.theme.colorScheme.surfaceContainer,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => FocusScope.of(context).unfocus(),
                      child: Text(context.t.food.picker.done),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    alignLabelWithHint: true,
    filled: true,
    fillColor: context.theme.colorScheme.surfaceContainerLowest,
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: context.theme.colorScheme.outlineVariant),
    ),
  );

  Future<void> _addIngredients() async {
    await Go.to(
      () => FoodPickerView(
        allowCombine: false,
        onAdd: (food) async {
          final item = await _weighIngredient(
            context,
            food.copyWith(id: const Uuid().v4()),
          );
          if (item == null || !mounted) throw const _FoodSelectionCancelled();
          setState(() => _ingredients.add(item));
          return item.food;
        },
        onRemove: (food) async {
          if (mounted) {
            setState(
              () => _ingredients.removeWhere((i) => i.food.id == food.id),
            );
          }
        },
      ),
    );
  }

  Widget _ingredientTile(int index) {
    final item = _ingredients[index];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.theme.colorScheme.secondaryContainer,
        foregroundColor: context.theme.colorScheme.onSecondaryContainer,
        child: Text('${index + 1}'),
      ),
      title: Text(item.food.name),
      subtitle: Text(
        '${_recipeNumber(context, item.quantity)} ${serializeUnit(item.food.unit)} · ${_recipeNumber(context, item.mass)} g',
      ),
      trailing: IconButton(
        tooltip: context.t.food.recipes.delete,
        icon: const Icon(Icons.delete_outline),
        onPressed: () => setState(() => _ingredients.removeAt(index)),
      ),
      onTap: () async {
        final food = await showAddFoodView(
          context,
          item.food,
          inheritAmount: true,
          isEditing: true,
        );
        if (food == null || !mounted) return;
        final changed = await _weighIngredient(
          context,
          food.copyWith(id: item.food.id),
          gramsPerMl: item.gramsPerMl,
        );
        if (changed != null && mounted) {
          setState(() => _ingredients[index] = changed);
        }
      },
    );
  }
}

class _RecipeEditorSection extends StatelessWidget {
  const _RecipeEditorSection({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return GTSectionCard(
      icon: icon,
      title: title,
      trailing: trailing,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _RecipeNutritionCard extends StatelessWidget {
  const _RecipeNutritionCard({
    required this.recipe,
    this.initiallyExpanded = false,
  });
  final Recipe recipe;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    final s = context.t.food.recipes;
    return M3EExpandableCardColumn.builder(
      itemCount: 1,
      initiallyExpanded: initiallyExpanded ? const {0} : const {},
      style: M3EExpandableStyle(
        color:
            context.theme.cardTheme.color ??
            context.theme.colorScheme.surfaceContainerLow,
        border: BorderSide(
          color: context.theme.colorScheme.outlineVariant.withValues(
            alpha: 0.5,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 16),
        headerPadding: const EdgeInsets.all(20),
        headerAlignment: CrossAxisAlignment.center,
        bodyPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      ),
      headerBuilder: (context, index, progress) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.insights_outlined,
              size: 22,
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.nutrition,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_recipeNumber(context, recipe.perServing.calories)} kcal · ${s.perServing.toLowerCase()}',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // The card already animates/clips its body height. Avoid a
      // second height animation and keep the summary in the header.
      bodyBuilder: (context, index, progress) => progress <= 0
          ? const SizedBox.shrink()
          : _RecipeSummary(recipe: recipe),
    );
  }
}

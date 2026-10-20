part of 'food.dart';

class FoodCategoryList extends ConsumerWidget {
  const FoodCategoryList({super.key});

  Color? getFabBackgroundColor(BuildContext context, bool canUpdate) =>
      canUpdate
      ? null
      : Theme.of(context).buttonTheme.getDisabledFillColor(
          MaterialButton(onPressed: () async {}),
        );
  Color? getFabForegroundColor(BuildContext context, bool canUpdate) =>
      canUpdate
      ? null
      : Theme.of(context).buttonTheme.getDisabledTextColor(
          MaterialButton(onPressed: () async {}),
        );
  MouseCursor? getFabMouseCursor(BuildContext context, bool canUpdate) =>
      canUpdate ? SystemMouseCursors.click : SystemMouseCursors.basic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUpdate = ref.watch(foodCanUpdateCategoriesProvider);
    final foodCategories = ref
        .watch(categoriesForSelectedDateProvider)
        .values
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(context.t.food.categoryList.title),
            pinned: true,
          ),
          if (!canUpdate)
            const _UnmodifiableCategoriesAlert()
          else
            const _DateRangeBanner(),
          if (foodCategories.isEmpty) ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(context.t.food.categoryList.empty)),
            ),
          ] else ...[
            const _NonFulfillingSumBanner(),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = foodCategories[index];
                return Slidable(
                  key: ValueKey(category),
                  endActionPane: ActionPane(
                    extentRatio: 1 / 3,
                    dragDismissible: false,
                    motion: const BehindMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          await ref
                              .read(nutritionCategoryProvider.notifier)
                              .removeCategory(category);
                        },
                        backgroundColor: context.theme.colorScheme.error,
                        foregroundColor: context.theme.colorScheme.onError,
                        icon: GTIcons.delete_forever,
                        label: context.t.actions.remove,
                      ),
                    ],
                  ),
                  child: FoodCategoryListTile(category: category),
                );
              }, childCount: foodCategories.length),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: canUpdate
            ? () async {
                final cat = await showAddCategoryView(context, ref);
                if (cat != null) {
                  await ref
                      .read(nutritionCategoryProvider.notifier)
                      .addCategory(cat);
                }
              }
            : null,
        icon: GTIcons.compound.add_food_category,
        label: Text(context.t.food.categoryList.add),
        disabledElevation: 0,
        backgroundColor: getFabBackgroundColor(context, canUpdate),
        foregroundColor: getFabForegroundColor(context, canUpdate),
        mouseCursor: getFabMouseCursor(context, canUpdate),
      ),
    );
  }
}

class FoodCategoryListTile extends ConsumerWidget {
  const FoodCategoryListTile({super.key, required this.category});

  final NutritionCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUpdate = ref.watch(foodCanUpdateCategoriesProvider);
    final goal = ref.watch(nutritionGoalForSelectedDateProvider);

    return ListTile(
      leading: Icon(category.icon.iconData),
      title: Text(category.name),
      subtitle: Text(
        context.t.food.categoryList.dailyPercentage(
          percentage: category.dailyPercentage.toString(),
          calories: NutritionUnit.KCAL.formatAmount(
            goal.dailyCalories * category.dailyPercentage / 100,
            context: context,
          ),
        ),
      ),
      trailing: canUpdate ? const Icon(GTIcons.lt_chevron) : null,
      onTap: canUpdate
          ? () {
              editCategory(context, ref, category);
            }
          : null,
    );
  }
}

class _UnmodifiableCategoriesAlert extends StatelessWidget {
  const _UnmodifiableCategoriesAlert();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AlertBanner(
            title: context.t.food.categoryList.unmodifiable.title,
            text: Text(context.t.food.categoryList.unmodifiable.text),
            color: GTMaterialColor.warning,
          ),
        ),
      ),
    );
  }
}

class _DateRangeBanner extends ConsumerWidget {
  const _DateRangeBanner();

  Widget _buildEffectText(BuildContext context, WidgetRef ref) {
    final fx = ref.watch(categoriesDateRangeProvider)!;
    String s;
    String fmt(DateTime d) => DateFormat.yMd().format(d);
    if (fx.to == null) {
      s = context.t.food.categoryEditor.effect.from(from: fmt(fx.from!));
    } else {
      s = context.t.food.categoryEditor.effect.range(
        from: fmt(fx.from!),
        to: fmt(fx.to!),
      );
    }

    return Text(s);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectRange = ref.watch(categoriesDateRangeProvider);
    if (effectRange == null) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AlertBanner(
            title: context.t.food.categoryEditor.effect.title,
            text: _buildEffectText(context, ref),
          ),
        ),
      ),
    );
  }
}

class _NonFulfillingSumBanner extends ConsumerWidget {
  const _NonFulfillingSumBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesForSelectedDateProvider);
    final sum = categories.values
        .map((e) => e.dailyPercentage)
        .fold(0, (a, b) => a + b);
    if (sum == 100) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: AlertBanner(
            color: GTMaterialColor.warning,
            title: context.t.food.categoryEditor.nonFulfillingSum.title,
            text: Text(
              "${categories.values.map((e) => NumberFormat.percentPattern(context.locale.languageCode).format(e.dailyPercentage / 100)).join(" + ")} = ${NumberFormat.percentPattern(context.locale.languageCode).format(sum / 100)}",
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCategoryEditorView extends ConsumerStatefulWidget {
  final NutritionCategory? oldCategory;

  const FoodCategoryEditorView.clean({super.key}) : oldCategory = null;

  const FoodCategoryEditorView.edit(NutritionCategory category, {super.key})
    : oldCategory = category;

  @override
  ConsumerState<FoodCategoryEditorView> createState() =>
      _FoodCategoryEditorViewState();
}

class _FoodCategoryEditorViewState
    extends ConsumerState<FoodCategoryEditorView> {
  late final _nameController = TextEditingController(
    text: widget.oldCategory?.name,
  );
  late var _dailyPercentage = widget.oldCategory?.dailyPercentage ?? 1;
  late var _icon =
      widget.oldCategory?.icon ?? NutritionCategoryIcon.fork_and_spoon;

  final _formKey = GlobalKey<FormState>();

  late final isEditing = widget.oldCategory != null;

  @override
  Widget build(BuildContext context) {
    final gradientColor = Theme.of(context).colorScheme.surfaceContainerHigh;
    final goal = ref.watch(nutritionGoalForSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.oldCategory == null
              ? context.t.food.categoryEditor.title.add
              : context.t.food.categoryEditor.title.edit,
        ),
      ),
      extendBody: true,
      body: GradientBottomBar.wrap(
        context: context,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: GymTrackerInputDecoration(
                  labelText: context.t.food.categoryEditor.name,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context
                        .t
                        .food
                        .categoryEditor
                        .fields
                        .name
                        .errors
                        .empty;
                  }
                  final isUnique = ref.read(
                    isUniqueCategoryNameProvider(value),
                  );
                  if (!isEditing && !isUnique) {
                    return context
                        .t
                        .food
                        .categoryEditor
                        .fields
                        .name
                        .errors
                        .unique;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              IntStepperFormField(
                value: _dailyPercentage,
                onChanged: (value) => value == null
                    ? null
                    : setState(() => _dailyPercentage = value.toInt()),
                min: 1,
                max: 100,
                decoration: GymTrackerInputDecoration(
                  labelText: context.t.food.categoryEditor.dailyPercentage,
                ),
                labelBuilder: (value) =>
                    "${NumberFormat.percentPattern(context.locale.languageCode).format(value / 100)} (${NutritionUnit.KCAL.formatAmount(goal.dailyCalories * value / 100, context: context)})",
              ),
              const SizedBox(height: 16),
              InkWell(
                mouseCursor: WidgetStateMouseCursor.clickable,
                borderRadius: BorderRadius.circular(
                  kGymTrackerInputBorderRadius,
                ),
                onTap: () {
                  showDialog<NutritionCategoryIcon>(
                    context: context,
                    builder: (context) => NutritionCategoryIconPicker(
                      initialIcon: _icon,
                      onIconChanged: (icon) => setState(() {
                        _icon = icon;
                      }),
                      title: Text(context.t.food.categoryEditor.icon),
                    ),
                  );
                },
                child: InputDecorator(
                  decoration: GymTrackerInputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                    labelText: context.t.food.categoryEditor.icon,
                  ),
                  child: ListTile(
                    title: Text(context.t.food.categoryEditor.icon),
                    leading: Icon(_icon.iconData),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.standard,
                    mouseCursor: MouseCursor.defer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GradientBottomBar(
        color: gradientColor,
        center: true,
        buttons: [
          FilledButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final category = NutritionCategory(
                name: _nameController.text,
                dailyPercentage: _dailyPercentage,
                icon: _icon,
              );
              Navigator.of(context).pop(category);
            },
            child: Text(context.t.food.categoryEditor.save),
          ),
        ],
      ),
    );
  }
}

class FoodCategoryFoodsView extends ConsumerWidget {
  final NutritionCategory category;

  const FoodCategoryFoodsView({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(foodsForCategoryProvider(category));
    final selectedDate = ref.watch(foodSelectedDateProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(category.name), pinned: true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildOFFSearchBar(context, ref),
            ),
          ),
          if (foods.isEmpty) ...[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(context.t.food.categoryFoods.empty)),
            ),
          ] else ...[
            SliverToBoxAdapter(child: _buildStatsRow(foods, context: context)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final food = foods[index];
                return FoodListTile(
                  food: food,
                  onTap: () {
                    showEditFoodView(context, ref, food);
                  },
                  onDelete: () async {
                    await ref
                        .read(foodProvider.notifier)
                        .removeFood(selectedDate, food);
                  },
                );
              }, childCount: foods.length),
            ),
            SliverList.list(
              children: [
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        NutritionTable.arbitrary(
                          nutritionValues: _getNutritionValues(foods),
                          unit: NutritionUnit.G,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }

  NutritionValues _getNutritionValues(List<Food> foods) {
    return foods.fold<NutritionValues>(
      NutritionValues.zero,
      (previousValue, element) => previousValue + element.nutritionalValues,
    );
  }

  Widget _buildStatsRow(List<Food> foods, {required BuildContext context}) {
    final totals = foods.fold<(double, double, double, double)>(
      (0, 0, 0, 0),
      (previousValue, element) => (
        previousValue.$1 + element.nutritionalValues.calories,
        previousValue.$2 + element.nutritionalValues.protein,
        previousValue.$3 + element.nutritionalValues.carbs,
        previousValue.$4 + element.nutritionalValues.fat,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: StatsRow(
        stats: [
          Stats(
            value: NutritionUnit.KCAL.formatAmount(totals.$1, context: context),
            label: context.t.food.nutriments['calories']!,
          ),
          Stats(
            value: kNutritionValueToUnit["protein"]!.formatAmount(
              totals.$2,
              context: context,
            ),
            label: context.t.food.nutriments['protein']!,
          ),
          Stats(
            value: kNutritionValueToUnit["carbs"]!.formatAmount(
              totals.$3,
              context: context,
            ),
            label: context.t.food.nutriments['carbs']!,
          ),
          Stats(
            value: kNutritionValueToUnit["fat"]!.formatAmount(
              totals.$4,
              context: context,
            ),
            label: context.t.food.nutriments['fat']!,
          ),
        ],
      ),
    );
  }

  Widget _buildOFFSearchBar(BuildContext context, WidgetRef ref) {
    return SearchAnchorPlus(
      suggestionsBuilder: _getSearchSuggestionBuilder(
        ref: ref,
        closeView: () => Get.back(),
        onFoodTap: (dtfood) {
          showAddFoodView(context, dtfood.value).then((food) async {
            if (food != null) {
              final selectedDate = ref.read(foodSelectedDateProvider);
              await ref
                  .read(foodProvider.notifier)
                  .addFood(selectedDate, food, category: category);
            }
          });
        },
      ),
      hintText: context.t.food.searchBar.hint,
      barTrailing: [
        IconButton(
          icon: const Icon(GTIcons.combine),
          tooltip: context.t.food.combine.title,
          onPressed: () async {
            showCombineFoodsView(context, ref, category: category).then((
              food,
            ) async {
              if (food != null) {
                final selectedDate = ref.read(foodSelectedDateProvider);
                await ref
                    .read(foodProvider.notifier)
                    .addFood(selectedDate, food, category: category);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(GTIcons.scan_barcode),
          tooltip: context.t.food.barcodeReader.title,
          onPressed: () async {
            showScanBarcodeView(context, ref).then((food) async {
              if (food != null) {
                final selectedDate = ref.read(foodSelectedDateProvider);
                await ref
                    .read(foodProvider.notifier)
                    .addFood(selectedDate, food, category: category);
              }
            });
          },
        ),
      ],
      onSubmitted: (query) {
        showSearchResultsView(
          context,
          ref,
          query,
          category: category,
        ).then((value) => print("${value?.toJson()}"));
      },
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      viewFloatingActionButton: _AddCustomFoodFAB(
        closeView: () => Navigator.of(context).pop(),
        category: category,
        onFoodAdded: (food) async {
          if (food != null) {
            final selectedDate = ref.read(foodSelectedDateProvider);
            await ref
                .read(foodProvider.notifier)
                .addFood(selectedDate, food, category: category);
          }
        },
      ),
    );
  }
}

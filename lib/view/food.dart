import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/colors.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart' hide ContextThemingUtils;
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/gradient_bottom_bar.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/components/stats.dart';
import 'package:gymtracker/view/components/subscription_nag.dart';
import 'package:gymtracker/view/components/tweened_builder.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_picker.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/int_stepper_form_field.dart';
import 'package:gymtracker/view/utils/nutrition_category_icon_picker.dart';
import 'package:gymtracker/view/utils/search_anchor_plus.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:relative_time/relative_time.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';

part 'food.categories.dart';
part 'food.goals.dart';
part 'food.search.dart';
part 'food.values.dart';

const _kKeyboardType = TextInputType.numberWithOptions(
  decimal: true,
  signed: true,
);

Future<Food?> showAddFoodView(
  BuildContext context,
  VagueFood food, {
  bool inheritAmount = false,
  bool isEditing = false,
}) {
  return Go.to<Food?>(
    () => AddFoodView(
      food: food,
      inheritAmount: inheritAmount,
      isEditing: isEditing,
    ),
  );
}

Future<void> showEditFoodView(
  BuildContext context,
  WidgetRef ref,
  Food food,
) async {
  final edited = await showAddFoodView(
    context,
    food,
    inheritAmount: true,
    isEditing: true,
  );
  if (edited != null) {
    final selectedDate = ref.read(foodSelectedDateProvider);
    ref.read(foodProvider.notifier).updateFood(selectedDate, edited);
  }
}

Future<Food?> showAddCustomFoodView(
  BuildContext context,
  WidgetRef ref, {
  NutritionCategory? category,
  String? barcode,
}) {
  return Go.to<Food?>(
    () => barcode != null
        ? CustomAddFoodView.withBarcode(barcode: barcode, category: category)
        : CustomAddFoodView(category: category),
  );
}

Future<Food?> showScanBarcodeView(
  BuildContext context,
  WidgetRef ref, {
  NutritionCategory? category,
}) {
  final completer = Completer<Food?>();
  Go.to<void>(
    () => FoodBarcodeReaderView(
      onFoodReceived: (food) {
        if (!completer.isCompleted) completer.complete(food);
      },
    ),
  );
  return completer.future;
}

Future<Food?> searchFoodByBarcode(
  BuildContext context,
  WidgetRef ref,
  String barcode, {
  NutritionCategory? category,
}) async {
  final customBarcodeFoods =
      (ref.read(customBarcodeFoodsStreamProvider).asData?.value
          as List<Food>?) ??
      [];
  final localFood = customBarcodeFoods.firstWhereOrNull((f) => f.id == barcode);
  if (localFood != null) {
    final added = await showAddFoodView(context, localFood);
    return added;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: GBLoadingIndicator()),
  );

  try {
    final res = await ref.read(
      searchOpenFoodFactsByBarcodeProvider(barcode).future,
    );
    if (context.mounted) Get.back();

    if (res != null) {
      if (context.mounted) {
        final added = await showAddFoodView(context, res);
        return added;
      }
    } else {
      if (context.mounted) {
        final added = await showAddCustomFoodView(
          context,
          ref,
          category: category,
          barcode: barcode,
        );
        return added;
      }
    }
  } catch (e) {
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) {
      final added = await showAddCustomFoodView(
        context,
        ref,
        category: category,
        barcode: barcode,
      );
      return added;
    }
  }
}

Future<VagueFood?> showSearchResultsView(
  BuildContext context,
  WidgetRef ref,
  String query, {
  NutritionCategory? category,
}) {
  return Go.to<VagueFood?>(
    () => SearchResultsView(
      foods: ref.read(searchOpenFoodFactsProvider(query).future),
      category: category,
    ),
  );
}

Future<Food?> showSearchResultsViewForCombination(
  BuildContext context,
  WidgetRef ref,
  String query,
) {
  return Go.to<Food?>(
    () => SearchResultsView(
      foods: ref.read(searchOpenFoodFactsProvider(query).future),
      category: null,
    ),
  );
}

Future<Food?> showCombineFoodsView(
  BuildContext context,
  WidgetRef ref, {
  NutritionCategory? category,
}) {
  return Go.to<Food?>(() => AddCombinedFoodView(category: category));
}

Future<void> showDatePicker(BuildContext context, WidgetRef ref) async {
  final selectedDate = ref.read(foodSelectedDateProvider);
  final foodLogs = ref.read(foodLogsStreamProvider).asData?.value ?? [];
  final datesWithLogs = foodLogs.map((e) => e.date.startOfDay).toSet();
  final date = await Go.to<DateTime?>(
    () => DatePickerPlus(
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      markDate: (date) => datesWithLogs.contains(date.startOfDay),
    ),
  );
  if (date != null) {
    ref.read(foodSelectedDateProvider.notifier).setDate(date);
  }
}

Future<void> showNutritionGoalView(BuildContext context) {
  return Go.to(() => const ChangeGoalScreen());
}

Future<void> showGoalHistory(BuildContext context) {
  return Go.to(() => const GoalHistoryView());
}

Future<NutritionCategory?> showAddCategoryView(
  BuildContext context,
  WidgetRef ref,
) {
  return Go.to<NutritionCategory?>(() => const FoodCategoryEditorView.clean());
}

Future<NutritionCategory?> editCategory(
  BuildContext context,
  WidgetRef ref,
  NutritionCategory category,
) {
  return Go.to<NutritionCategory?>(() => FoodCategoryEditorView.edit(category));
}

Future<void> showCategoryFoodsView(
  BuildContext context,
  NutritionCategory category,
) {
  return Go.to(() => FoodCategoryFoodsView(category: category));
}

class FoodView extends ConsumerStatefulWidget {
  const FoodView({super.key});

  @override
  ConsumerState<FoodView> createState() => _FoodViewState();
}

class _FoodViewState extends ConsumerState<FoodView> {
  final searchController = SearchController();

  final eatenKey = GlobalKey();
  final gaugeKey = GlobalKey();
  final goalKey = GlobalKey();

  final macroTile1Key = GlobalKey();
  final macroTile2Key = GlobalKey();
  final macroTile3Key = GlobalKey();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    const kBottomCalBarHeight = 48;
    final bottomNavigationBarHeight =
        kBottomCalBarHeight + safeArea.bottom + 16;
    final bottomPaddingWithFAB =
        bottomNavigationBarHeight + kFloatingActionButtonMargin + 56;
    final searchBar = _buildOFFSearchBar();

    final selectedDate = ref.watch(foodSelectedDateProvider);
    final nutritionGoal = ref.watch(nutritionGoalForSelectedDateProvider);
    final foodsAsync = ref.watch(foodLogsStreamProvider);
    final isLoading = foodsAsync.isLoading;
    final foodsList = ref.watch(foodsForSelectedDateProvider);
    final foods = foodsList.isEmpty && isLoading
        ? skeletonFoods(10)
        : foodsList.reversed.toList();

    return Scaffold(
      body: ProBuilder(
        builder: (context, subscriptionInfo) {
          final isUnsubbed =
              subscriptionInfo == null || !subscriptionInfo.hasProFeatures;
          final isTooFar =
              selectedDate.isBefore(
                DateTime.now().startOfDay.subtract(const Duration(days: 7)),
              ) ||
              selectedDate.isAfter(
                DateTime.now().startOfDay.add(const Duration(days: 7)),
              );
          final shouldDisable = isUnsubbed && isTooFar;

          getCalorieGauge(bool showSpacers, bool applySafeArea) => _getCalGauge(
            applySafeArea,
            context,
            showSpacers,
            foods,
            nutritionGoal,
          );

          var goals = [
            FoodNutritionalSingleGoalSDButton(
              text: "food.home.carbs".t,
              value: foods.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.nutritionalValues.carbs,
              ),
              goal: nutritionGoal.dailyCarbs,
              key: macroTile1Key,
            ),
            FoodNutritionalSingleGoalSDButton(
              text: "food.home.protein".t,
              value: foods.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.nutritionalValues.protein,
              ),
              goal: nutritionGoal.dailyProtein,
              key: macroTile2Key,
            ),
            FoodNutritionalSingleGoalSDButton(
              text: "food.home.fat".t,
              value: foods.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.nutritionalValues.fat,
              ),
              goal: nutritionGoal.dailyFat,
              key: macroTile3Key,
            ),
          ];

          final categories = ref.watch(categoriesForSelectedDateProvider);

          return Skeletonizer(
            enabled: isLoading,
            child: CustomScrollView(
              slivers: [
                const _FoodDayAppBar(),
                SliverStack(
                  children: [
                    SliverIgnorePointer(
                      ignoring: shouldDisable,
                      sliver: MultiSliver(
                        children: [
                          SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: 16),
                              if (Breakpoints.currentBreakpoint > Breakpoints.l)
                                SafeArea(
                                  bottom: false,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: getCalorieGauge(true, false),
                                        ),
                                        Card(
                                          child: SizedBox(
                                            width: 300,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: goals,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else ...[
                                getCalorieGauge(false, true),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final breakpoint =
                                            Breakpoints.currentBreakpoint;
                                        final actualGoals = goals
                                            .map(
                                              (goal) => SizedBox(
                                                width:
                                                    constraints.maxWidth /
                                                    (goals.length + 0.5),
                                                child: goal,
                                              ),
                                            )
                                            .toList();
                                        return Card(
                                          margin: EdgeInsets.zero,
                                          child: SizedBox(
                                            child: breakpoint == Breakpoints.xxs
                                                ? Column(
                                                    children: goals.separated(
                                                      separatorBuilder: (_) =>
                                                          Divider(
                                                            color: context
                                                                .theme
                                                                .colorScheme
                                                                .outlineVariant,
                                                          ),
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: actualGoals.separated(
                                                      separatorBuilder: (_) =>
                                                          const _FauxVerticalDivider(),
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16) +
                                    MediaQuery.of(
                                      context,
                                    ).padding.copyWith(top: 0, bottom: 0),
                                child: Skeleton.leaf(child: searchBar),
                              ),
                              const SizedBox(height: 24),
                            ]),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ).copyWith(bottom: categories.isEmpty ? 0 : 16),
                            sliver: SliverStack(
                              children: [
                                SliverPositioned.fill(
                                  child: Card(margin: EdgeInsets.zero),
                                ),
                                _HomeFoodCategoryList(),
                              ],
                            ),
                          ),
                          const _HomeUnassignedFoodsList(),
                          SliverToBoxAdapter(
                            child: SizedBox(height: bottomPaddingWithFAB),
                          ),
                        ],
                      ),
                    ),
                    if (shouldDisable) ...[
                      SliverPositioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ),
                      SliverFillRemaining(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SubscriptionNag(
                              stringKey: "food",
                              shouldHide: (_) => false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: GradientBottomBar(
        alignment: MainAxisAlignment.spaceBetween,
        center: true,
        buttons: [
          IconButton(
            icon: const Icon(GTIcons.previousDay),
            onPressed: () {
              ref.read(foodSelectedDateProvider.notifier).previousDay();
            },
          ),
          IconButton(
            icon: const Icon(GTIcons.showDatePicker),
            onPressed: () {
              showDatePicker(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(GTIcons.nextDay),
            onPressed: () {
              ref.read(foodSelectedDateProvider.notifier).nextDay();
            },
          ),
        ],
      ),
    );
  }

  Card _getCalGauge(
    bool applySafeArea,
    BuildContext context,
    bool showSpacers,
    List<Food> foods,
    NutritionGoal nutritionGoal,
  ) {
    final eaten = FoodNutritionGaugeInfoSideView(
      value: foods.fold<double>(
        0,
        (previousValue, element) =>
            previousValue + element.nutritionalValues.calories,
      ),
      text: "food.home.eaten".t,
      key: eatenKey,
    );
    final gauge = FoodNutritionEatenCaloriesGauge(
      value: foods.fold<double>(
        0,
        (previousValue, element) =>
            previousValue + element.nutritionalValues.calories,
      ),
      goal: nutritionGoal.dailyCalories,
      key: gaugeKey,
    );
    final goal = FoodNutritionGaugeInfoSideView(
      value: nutritionGoal.dailyCalories,
      text: "food.home.goal".t,
      key: goalKey,
    );

    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 16) +
          (applySafeArea
              ? MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0)
              : EdgeInsets.zero),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("food.home.calories".t),
            const SizedBox(height: 16),
            if (showSpacers) const Spacer(),
            // ResponsiveBuilder(
            //   builder: (context, breakpoint) {
            if (Breakpoints.currentBreakpoint > Breakpoints.s)
              //       return
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(child: eaten),
                      Flexible(
                        flex: Breakpoints.currentBreakpoint >= Breakpoints.l
                            ? 1
                            : 2,
                        child: Container(),
                      ),
                      Flexible(child: goal),
                    ],
                  ),
                  gauge,
                ],
              )
            else
              Column(
                children: [
                  gauge,
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [eaten, goal],
                  ),
                ],
              ),
            if (showSpacers) const Spacer(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOFFSearchBar() {
    return SearchAnchorPlus(
      searchController: searchController,
      suggestionsBuilder: _getSearchSuggestionBuilder(
        ref: ref,
        closeView: () => Get.back(),
        onFoodTap: (dtfood) {
          showAddFoodView(context, dtfood.value).then((food) {
            if (food != null) {
              final selectedDate = ref.read(foodSelectedDateProvider);
              ref.read(foodProvider.notifier).addFood(selectedDate, food);
            }
          });
        },
      ),
      hintText: 'food.searchBar.hint'.t,
      barTrailing: [
        IconButton(
          icon: const Icon(GTIcons.combine),
          tooltip: "food.combine.title".t,
          onPressed: () {
            showCombineFoodsView(context, ref).then((food) {
              if (food != null) {
                final selectedDate = ref.read(foodSelectedDateProvider);
                ref.read(foodProvider.notifier).addFood(selectedDate, food);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(GTIcons.scan_barcode),
          tooltip: "food.barcodeReader.title".t,
          onPressed: () {
            showScanBarcodeView(context, ref).then((food) {
              if (food != null) {
                final selectedDate = ref.read(foodSelectedDateProvider);
                ref.read(foodProvider.notifier).addFood(selectedDate, food);
              }
            });
          },
        ),
      ],
      onSubmitted: (query) {
        showSearchResultsView(context, ref, query).then((food) {
          if (food == null) return;
          if (context.mounted) {
            Go.to(() => AddFoodView(food: food)).then((added) {
              if (added != null) {
                final selectedDate = ref.read(foodSelectedDateProvider);
                ref.read(foodProvider.notifier).addFood(selectedDate, added);
              }
            });
          }
        });
      },
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      viewFloatingActionButton: _AddCustomFoodFAB(
        closeView: () => Get.back(),
        onFoodAdded: (food) {
          if (food != null) {
            final selectedDate = ref.read(foodSelectedDateProvider);
            ref.read(foodProvider.notifier).addFood(selectedDate, food);
          }
        },
      ),
    );
  }
}

class _FauxVerticalDivider extends StatelessWidget {
  const _FauxVerticalDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 48,
      child: Center(
        child: Container(
          width: 1,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeUnassignedFoodsList extends ConsumerWidget {
  const _HomeUnassignedFoodsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unassigned = ref.watch(unassignedFoodsForSelectedDateProvider);
    final selectedDate = ref.watch(foodSelectedDateProvider);
    return SliverList.builder(
      itemCount: unassigned.length,
      itemBuilder: (context, index) {
        final food = unassigned[index];
        return FoodListTile(
          key: ValueKey(food),
          food: food,
          onTap: () {
            showEditFoodView(context, ref, food);
          },
          onDelete: () {
            ref.read(foodProvider.notifier).removeFood(selectedDate, food);
          },
        );
      },
    );
  }
}

class _HomeFoodCategoryList extends ConsumerWidget {
  const _HomeFoodCategoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodCategories = ref
        .watch(categoriesForSelectedDateProvider)
        .values
        .toList();
    return SliverList.builder(
      itemCount: foodCategories.length,
      itemBuilder: (context, index) {
        final category = foodCategories[index];
        return Material(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(index == 0 ? 13 : 0),
            bottom: Radius.circular(
              index == foodCategories.length - 1 ? 13 : 0,
            ),
          ),
          color: Colors.transparent,
          child: _HomeFoodCategoryListTile(
            key: ValueKey(category),
            category: category,
          ),
        );
      },
    );
  }
}

class FoodListTile extends ConsumerWidget {
  const FoodListTile({
    super.key,
    required this.food,
    required this.onTap,
    required this.onDelete,
  });

  final Food food;
  final void Function() onTap;
  final void Function() onDelete;

  String get pieces {
    if (food.pieces == 1) return "";
    return "${food.pieces} × ";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites =
        ref.watch(favoriteFoodsStreamProvider).asData?.value ?? [];
    final isFavorite = favorites.any((f) => f.id == food.id);

    return Slidable(
      key: ValueKey(food),
      endActionPane: ActionPane(
        extentRatio: 1 / 3,
        dragDismissible: false,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: context.theme.colorScheme.error,
            foregroundColor: context.theme.colorScheme.onError,
            icon: GTIcons.delete_forever,
            label: 'actions.remove'.t,
          ),
        ],
      ),
      child: ListTile(
        title: Text.rich(
          TextSpan(
            children: [
              if (isFavorite) ...[
                WidgetSpan(
                  child: Icon(
                    GTIcons.favorite,
                    size: 14,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                const TextSpan(text: " "),
              ],
              TextSpan(text: food.name),
            ],
          ),
        ),
        subtitle: Text(
          "${food.brand != null ? "${food.brand}, " : ""}${food.unit.formatAmount(food.amount, pieces: food.pieces)}",
        ),
        trailing: Text(
          "${food.nutritionalValues.calories.round()} ${"food.nutrimentUnits.kcal".t}",
          style: context.theme.textTheme.bodyMedium,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _HomeFoodCategoryListTile extends ConsumerWidget {
  final NutritionCategory category;

  const _HomeFoodCategoryListTile({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryFoods = ref.watch(foodsForCategoryProvider(category));
    final goal = ref.watch(nutritionGoalForSelectedDateProvider);
    final categoryMax =
        category.dailyPercentage * goal.dailyCalories.toDouble() / 100;
    final categoryCalories = categoryFoods.fold<double>(
      0,
      (previousValue, element) =>
          previousValue + element.nutritionalValues.calories,
    );
    final progress = categoryMax == 0 ? 0.0 : categoryCalories / categoryMax;

    final subtitleParts = [
      "${NutritionUnit.KCAL.formatAmount(categoryCalories, showUnit: false)} / ${NutritionUnit.KCAL.formatAmount(categoryMax)}",
      if (categoryFoods.isNotEmpty) categoryFoods.map((e) => e.name).join(", "),
    ];

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: RadialGauge(
          value: progress.clamp(0.025, 1),
          axis: GaugeAxis(
            min: 0,
            max: 1,
            sweepDegrees: 270,
            style: GaugeAxisStyle(
              thickness: 4,
              background: context.theme.colorScheme.surfaceContainerHighest,
            ),
            progressBar: GaugeProgressBar.rounded(
              color: progress < 0.025
                  ? Colors.transparent
                  : context.theme.colorScheme.primary,
            ),
            pointer: const GaugePointer.circle(
              radius: 0,
              color: Colors.transparent,
            ),
          ),
          child: Icon(category.icon.iconData, size: 20),
        ),
      ),
      title: Text(category.name),
      subtitle: Text(
        subtitleParts.join(", "),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        NumberFormat.decimalPercentPattern(
          decimalDigits: 0,
          locale: Get.locale?.languageCode,
        ).format(progress),
        style: context.theme.textTheme.bodyMedium,
      ),
      onTap: () {
        showCategoryFoodsView(context, category);
      },
    );
  }
}

SearchSuggestionBuilder _getSearchSuggestionBuilder({
  required WidgetRef ref,
  required void Function() closeView,
  required void Function(DateTagged<Food>) onFoodTap,
}) {
  return (BuildContext context, SearchController searchController) {
    final foodLogs = ref.watch(foodLogsStreamProvider).asData?.value ?? [];
    final foods = foodLogs.map((fv) => fv.value).toList();
    if (searchController.text.isEmpty) {
      var searchHistory = foods.reversed
          .map((e) => e.name)
          .toSet()
          .take(10)
          .toList();
      if (searchHistory.isNotEmpty) {
        return [
          ...searchHistory.map((term) {
            return ListTile(
              leading: const Icon(GTIcons.history),
              title: Text(term),
              trailing: RotatedBox(
                quarterTurns: -1,
                child: IconButton(
                  icon: const Icon(Icons.arrow_outward_rounded),
                  onPressed: () {
                    searchController.text = term;
                    searchController.selection = TextSelection.collapsed(
                      offset: searchController.text.length,
                    );
                  },
                ),
              ),
            );
          }),
        ];
      }

      return [ListTile(title: Text("food.searchBar.noHistory".t))];
    }

    final res = ref.watch(foodSuggestionsProvider(searchController.text));
    if (res.isEmpty) {
      return [
        ListTile(
          title: Text(
            "food.searchBar.noResults".tParams({
              "query": searchController.text,
            }),
          ),
        ),
      ];
    }
    return [
      const SizedBox(height: 8),
      ...res.map<Widget>((dtfood) {
        return _SearchFoodWithMacros(
          dtfood: dtfood,
          onTap: () {
            closeView();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              onFoodTap(dtfood);
            });
          },
        );
      }),
      const SizedBox(height: 8),
    ];
  };
}

class _FoodDayAppBar extends ConsumerWidget {
  const _FoodDayAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relativeDayText = ref.watch(foodRelativeDayTextProvider(context));
    return SliverAppBar.large(
      actions: [
        IconButton(
          icon: const Icon(GTIcons.food_categories),
          tooltip: "food.categoryList.title".t,
          onPressed: () {
            Go.to(() => const FoodCategoryList());
          },
        ),
        IconButton(
          icon: const Icon(GTIcons.nutrition_goal),
          tooltip: "food.nutritionGoals.change.title".t,
          onPressed: () {
            showNutritionGoalView(context);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Skeleton.keep(
          child: Text.rich(
            TextSpan(children: [TextSpan(text: relativeDayText)]),
          ),
        ),
      ),
    );
  }
}

class FoodNutritionGaugeInfoSideView extends StatelessWidget {
  final double value;
  final String text;

  const FoodNutritionGaugeInfoSideView({
    super.key,
    required this.value,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8, width: 8),
        TweenedDoubleBuilder(
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 750),
          value: value,
          builder: (context, aValue) {
            return Text(
              "${aValue.round()}",
              style: Theme.of(context).textTheme.bodyLarge,
            );
          },
        ),
      ],
    );
  }
}

class FoodNutritionEatenCaloriesGauge extends StatelessWidget {
  final double value;
  final double goal;

  const FoodNutritionEatenCaloriesGauge({
    super.key,
    required this.value,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Skeleton.shade(
      child: TweenedDoubleBuilder(
        curve: Curves.elasticOut,
        duration: const Duration(seconds: 2),
        value: value / goal,
        builder: (context, value) {
          return RadialGauge(
            radius: 100,
            // Clamp the value to the goal, but make sure it's at least at 2% of the
            // goal so that the gauge doesn't break visually
            // We clamp the value (despite the library already clamping it) to
            // make sure that the gauge doesn't break when animating (since it
            // appears the library doesn't do a very good job at clamping the
            // value anyways)
            value: value.clamp((2 / 100).clamp(0, 0.75), 1),
            axis: GaugeAxis(
              min: 0,
              max: 1,
              sweepDegrees: 270,
              style: GaugeAxisStyle(
                thickness: 12,
                background: context.theme.colorScheme.surfaceContainerHighest,
              ),
              progressBar: GaugeProgressBar.rounded(
                color: context.theme.colorScheme.primary,
              ),
              pointer: const GaugePointer.circle(
                radius: 0,
                color: Colors.transparent,
              ),
            ),
            child: Skeleton.replace(
              replacement: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Bone.text(
                    words: 1,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Bone.text(
                    words: 1,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Crossfade(
                    firstChild: Text(
                      "food.home.remainingCal".t,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    secondChild: Text(
                      "food.home.overCal".t,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    showSecond: this.value > goal,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 8),
                  TweenedDoubleBuilder(
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 750),
                    value: this.value,
                    builder: (context, aValue) {
                      return RadialGaugeLabel(
                        value: (goal - aValue).abs(),
                        style: Theme.of(context).textTheme.displaySmall,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The name of this class stands for "Nutritional Single-Goal Speed Dial
/// Button". It's a button that displays a single nutritional goal (like carbs,
/// protein, or fat) and shows the progress towards that goal in a linear
/// progress bar.
class FoodNutritionalSingleGoalSDButton extends StatelessWidget {
  final String text;
  final double value;
  final double goal;

  const FoodNutritionalSingleGoalSDButton({
    super.key,
    required this.text,
    required this.value,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: NumberFormat.decimalPercentPattern(
        decimalDigits: 0,
        locale: Get.locale?.languageCode,
      ).format(value / goal),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${value.round()} / ${goal.round()} ${NutritionUnit.G.t}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Skeleton.leaf(
              child: TweenedDoubleBuilder(
                curve: Curves.elasticOut,
                duration: const Duration(seconds: 2),
                value: value,
                builder: (context, value) {
                  final sdc = SpeedDialConfiguration.maybeOf(context);
                  final hzPadding = sdc == null
                      ? 8.0
                      : sdc.crossAxisCount == 1
                      ? 8.0
                      : 0.0;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: hzPadding),
                    child: LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(8),
                      value: value / goal,
                      minHeight: 8,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

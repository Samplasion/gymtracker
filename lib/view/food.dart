import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
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
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/gradient_bottom_bar.dart';
import 'package:gymtracker/view/components/stats.dart';
import 'package:gymtracker/view/components/tweened_builder.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/int_stepper_form_field.dart';
import 'package:gymtracker/view/utils/nutrition_category_icon_picker.dart';
import 'package:gymtracker/view/utils/search_anchor_plus.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

part 'food.categories.dart';
part 'food.goals.dart';
part 'food.search.dart';
part 'food.values.dart';

const _kKeyboardType = TextInputType.numberWithOptions(
  decimal: true,
  signed: true,
);

class FoodView extends StatefulWidget {
  const FoodView({super.key});

  @override
  State<FoodView> createState() => _FoodViewState();
}

class _FoodViewState extends ControlledState<FoodView, FoodController> {
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
    return Scaffold(
      body: StreamBuilder(
        stream: controller.goals$,
        builder: (context, _) {
          return StreamBuilder(
            stream: controller.day$,
            builder: (context, _) {
              return StreamBuilder(
                stream: controller.foods$,
                builder: (context, connection) {
                  final nutritionGoal = controller.getGoal();
                  final isLoading = !connection.hasData ||
                      connection.connectionState == ConnectionState.waiting;

                  final foods = connection.data
                          ?.where((food) =>
                              food.date.isSameDay(controller.day$.value))
                          .map((fv) => fv.value)
                          .toList()
                          .reversed
                          .toList() ??
                      skeletonFoods(10);

                  getCalorieGauge(bool showSpacers, bool applySafeArea) =>
                      _getCalGauge(
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
                              previousValue + element.nutritionalValues.carbs),
                      goal: nutritionGoal.dailyCarbs,
                      key: macroTile1Key,
                    ),
                    FoodNutritionalSingleGoalSDButton(
                      text: "food.home.protein".t,
                      value: foods.fold<double>(
                          0,
                          (previousValue, element) =>
                              previousValue +
                              element.nutritionalValues.protein),
                      goal: nutritionGoal.dailyProtein,
                      key: macroTile2Key,
                    ),
                    FoodNutritionalSingleGoalSDButton(
                      text: "food.home.fat".t,
                      value: foods.fold<double>(
                          0,
                          (previousValue, element) =>
                              previousValue + element.nutritionalValues.fat),
                      goal: nutritionGoal.dailyFat,
                      key: macroTile3Key,
                    ),
                  ];

                  return Skeletonizer(
                    enabled: isLoading,
                    child: CustomScrollView(
                      slivers: [
                        const _FoodDayAppBar(),
                        SliverList(
                            delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          if (Breakpoints.currentBreakpoint > Breakpoints.l)
                            SafeArea(
                              bottom: false,
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: getCalorieGauge(true, false)),
                                    SizedBox(
                                      width: 256,
                                      child: Column(
                                        children: goals.separated(
                                            separatorBuilder: (_) =>
                                                const SizedBox(height: 16)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                getCalorieGauge(false, true),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: SpeedDial(
                                      spacing: 8,
                                      crossAxisCountBuilder: (breakpoint) =>
                                          switch (breakpoint) {
                                        Breakpoints.xxs => 1,
                                        _ => 3,
                                      },
                                      buttonHeight: (_) =>
                                          kSpeedDialButtonHeight * 1.8,
                                      buttons: goals,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16) +
                                    MediaQuery.of(context)
                                        .padding
                                        .copyWith(top: 0, bottom: 0),
                            child: Skeleton.leaf(child: searchBar),
                          ),
                          const SizedBox(height: 24),
                        ])),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16)
                              .copyWith(
                                  bottom: controller.getCategories().isEmpty
                                      ? 0
                                      : 16),
                          sliver: SliverStack(
                            children: const [
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
                  );
                },
              );
            },
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: GradientBottomBar(
        alignment: MainAxisAlignment.spaceBetween,
        center: true,
        buttons: [
          // Back, calendar, forward
          IconButton(
            icon: const Icon(GTIcons.previousDay),
            onPressed: () {
              controller.previousDay();
            },
          ),
          IconButton(
            icon: const Icon(GTIcons.showDatePicker),
            onPressed: () {
              controller.showDatePicker();
            },
          ),
          IconButton(
            icon: const Icon(GTIcons.nextDay),
            onPressed: () {
              controller.nextDay();
            },
          ),
        ],
      ),
    );
  }

  Card _getCalGauge(bool applySafeArea, BuildContext context, bool showSpacers,
      List<Food> foods, NutritionGoal nutritionGoal) {
    final eaten = FoodNutritionGaugeInfoSideView(
      value: foods.fold<double>(
          0,
          (previousValue, element) =>
              previousValue + element.nutritionalValues.calories),
      text: "food.home.eaten".t,
      key: eatenKey,
    );
    final gauge = FoodNutritionEatenCaloriesGauge(
      value: foods.fold<double>(
          0,
          (previousValue, element) =>
              previousValue + element.nutritionalValues.calories),
      goal: nutritionGoal.dailyCalories,
      key: gaugeKey,
    );
    final goal = FoodNutritionGaugeInfoSideView(
      value: nutritionGoal.dailyCalories,
      text: "food.home.goal".t,
      key: goalKey,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16) +
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
                      Flexible(child: goal)
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
        closeView: () => Get.back(),
        onFoodTap: (dtfood) {
          controller.showAddFoodView(dtfood.value).then((food) {
            if (food != null) {
              controller.addFood(controller.day$.value, food);
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
            controller.showCombineFoodsView().then((food) {
              if (food != null) {
                controller.addFood(controller.day$.value, food);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(GTIcons.scan_barcode),
          tooltip: "food.barcodeReader.title".t,
          onPressed: () {
            controller.showScanBarcodeView().then((food) {
              if (food != null) {
                controller.addFood(controller.day$.value, food);
              }
            });
          },
        ),
      ],
      onSubmitted: (query) {
        controller.showSearchResultsView(query);
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

class _HomeUnassignedFoodsList extends ControlledWidget<FoodController> {
  const _HomeUnassignedFoodsList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.foods$,
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: controller.categories$,
          builder: (context, snapshot) {
            return StreamBuilder(
              stream: controller.day$,
              builder: (context, snapshot) {
                final unassigned = controller.getUnassignedFoods();
                return SliverList.builder(
                  itemCount: unassigned.length,
                  itemBuilder: (context, index) {
                    final food = unassigned[index];
                    return FoodListTile(
                      key: ValueKey(food),
                      food: food,
                      onTap: () {
                        controller.showEditFoodView(food);
                      },
                      onDelete: () {
                        controller.removeFood(controller.day$.value, food);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HomeFoodCategoryList extends ControlledWidget<FoodController> {
  const _HomeFoodCategoryList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.categories$,
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: controller.day$,
          builder: (context, snapshot) {
            final foodCategories = controller.getCategories().values.toList();
            return SliverList.builder(
              itemCount: foodCategories.length,
              itemBuilder: (context, index) {
                final category = foodCategories[index];
                return Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(index == 0 ? 13 : 0),
                    bottom: Radius.circular(
                        index == foodCategories.length - 1 ? 13 : 0),
                  ),
                  color: Colors.transparent,
                  child: _HomeFoodCategoryListTile(
                    key: ValueKey(category),
                    category: category,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class FoodListTile extends ControlledWidget<FoodController> {
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
  Widget build(BuildContext context) {
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
      child: StreamBuilder(
        stream: controller.favorites$,
        builder: (context, snapshot) {
          return ListTile(
            title: Text.rich(TextSpan(children: [
              if (controller.isFavorite(food)) ...[
                WidgetSpan(
                  child: Icon(GTIcons.favorite,
                      size: 14, color: Theme.of(context).colorScheme.tertiary),
                  alignment: PlaceholderAlignment.middle,
                ),
                const TextSpan(text: " "),
              ],
              TextSpan(text: food.name),
            ])),
            subtitle: Text(
              "${food.brand != null ? "${food.brand}, " : ""}${food.unit.formatAmount(food.amount, pieces: food.pieces)}",
            ),
            trailing: Text(
              "${food.nutritionalValues.calories.round()} ${"food.nutrimentUnits.kcal".t}",
              style: context.theme.textTheme.bodyMedium,
            ),
            onTap: onTap,
          );
        },
      ),
    );
  }
}

class _HomeFoodCategoryListTile extends ControlledWidget<FoodController> {
  final NutritionCategory category;

  const _HomeFoodCategoryListTile({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.day$,
      builder: (context, _) {
        return StreamBuilder(
          stream: controller.foods$,
          builder: (context, _) {
            final categoryFoods = controller.getFoodsForCategory(category);
            final categoryMax = category.dailyPercentage *
                controller.getGoal().dailyCalories.toDouble() /
                100;
            final categoryCalories = categoryFoods.fold<double>(
                0,
                (previousValue, element) =>
                    previousValue + element.nutritionalValues.calories);
            final progress = categoryCalories / categoryMax;

            final subtitleParts = [
              "${NutritionUnit.KCAL.formatAmount(categoryCalories, showUnit: false)} / ${NutritionUnit.KCAL.formatAmount(categoryMax)}",
              if (categoryFoods.isNotEmpty)
                categoryFoods.map((e) => e.name).join(", "),
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
                    degrees: 270,
                    style: GaugeAxisStyle(
                      thickness: 4,
                      background:
                          context.theme.colorScheme.surfaceContainerHighest,
                    ),
                    progressBar: GaugeProgressBar.rounded(
                      // The rounded bar isn't properly clipped for small values
                      color: progress < 0.025
                          ? Colors.transparent
                          : context.theme.colorScheme.primary,
                    ),
                    pointer: const GaugePointer.circle(
                        radius: 0, color: Colors.transparent),
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
                        decimalDigits: 0, locale: Get.locale?.languageCode)
                    .format(progress),
                style: context.theme.textTheme.bodyMedium,
              ),
              onTap: () {
                controller.showCategoryFoodsView(category);
              },
            );
          },
        );
      },
    );
  }
}

SearchSuggestionBuilder _getSearchSuggestionBuilder({
  required void Function() closeView,
  required void Function(DateTagged<Food>) onFoodTap,
}) {
  final controller = Get.find<FoodController>();
  return (BuildContext context, SearchController searchController) {
    final foods = controller.foods$.value.map((fv) => fv.value).toList();
    if (searchController.text.isEmpty) {
      var searchHistory =
          foods.reversed.map((e) => e.name).toSet().take(10).toList();
      if (searchHistory.isNotEmpty) {
        return [
          ...searchHistory.map((term) {
            return ListTile(
              leading: const Icon(GTIcons.history),
              title: Text(term),
              trailing: RotatedBox(
                quarterTurns: -1,
                child: IconButton(
                  // FIXME: Hardcoded icon (for now)
                  icon: const Icon(Icons.arrow_outward_rounded),
                  onPressed: () {
                    searchController.text = term;
                    searchController.selection = TextSelection.collapsed(
                        offset: searchController.text.length);
                  },
                ),
              ),
            );
          }),
        ];
      }

      return [
        ListTile(
          title: Text("food.searchBar.noHistory".t),
        )
      ];
    }

    final res = controller.getSuggestions(searchController.text);
    if (res.isEmpty) {
      return [
        ListTile(
          title: Text("food.searchBar.noResults".tParams({
            "query": searchController.text,
          })),
        )
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
      const SizedBox(height: 8)
    ];
  };
}

class _FoodDayAppBar extends ControlledWidget<FoodController> {
  const _FoodDayAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      leading: const Skeleton.keep(child: SkeletonDrawerButton()),
      actions: [
        IconButton(
          icon: const Icon(GTIcons.food_categories),
          tooltip: "food.categoryList.title".t,
          onPressed: () {
            // controller.showNutritionGoalView();
            Go.to(() => const FoodCategoryList());
          },
        ),
        IconButton(
          icon: const Icon(GTIcons.nutrition_goal),
          tooltip: "food.nutritionGoals.change.title".t,
          onPressed: () {
            controller.showNutritionGoalView();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Skeleton.keep(
          child: StreamBuilder(
            stream: controller.day$,
            builder: (context, snapshot) {
              return Text.rich(TextSpan(children: [
                TextSpan(text: controller.relativeDayText),
                const TextSpan(text: " "),
                const WidgetSpan(
                  child: BetaBadge(),
                  alignment: PlaceholderAlignment.aboveBaseline,
                  baseline: TextBaseline.alphabetic,
                ),
              ]));
            },
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
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
        value: value,
        builder: (context, aValue) {
          return RadialGauge(
            radius: 100,
            // Clamp the value to the goal, but make sure it's at least at 2% of the
            // goal so that the gauge doesn't break visually
            value: aValue.clamp((goal * 2 / 100).clamp(0, 75), goal),
            axis: GaugeAxis(
              min: 0,
              max: goal,
              degrees: 270,
              style: GaugeAxisStyle(
                thickness: 12,
                background: context.theme.colorScheme.surfaceContainerHighest,
              ),
              progressBar: GaugeProgressBar.rounded(
                color: context.theme.colorScheme.primary,
              ),
              pointer: const GaugePointer.circle(
                  radius: 0, color: Colors.transparent),
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
                    showSecond: value > goal,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 8),
                  TweenedDoubleBuilder(
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 750),
                    value: value,
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
      child: CustomSpeedDialButton(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

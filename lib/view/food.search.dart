part of 'food.dart';

class _AddCustomFoodFAB extends ControlledWidget<FoodController> {
  final NutritionCategory? category;

  const _AddCustomFoodFAB({required this.closeView, this.category});

  final void Function() closeView;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text("food.addCustom.title".t),
      icon: const Icon(GymTrackerIcons.add_food),
      onPressed: () {
        closeView();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          controller.showAddCustomFoodView(category: category);
        });
      },
    );
  }
}

class _SearchFoodWithMacros extends ControlledWidget<FoodController> {
  final DateTagged<Food> dtfood;
  final void Function()? onTap;

  const _SearchFoodWithMacros({required this.dtfood, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = dtfood.date;
    final food = dtfood.value;

    final subtitlePieces = [
      if (food.brand != null) food.brand,
      food.unit.formatAmount(food.amount, pieces: food.pieces),
    ];

    var color = GTMaterialColor.primary;
    var icon = GymTrackerIcons.history;

    if (controller.isFavorite(food)) {
      color = GTMaterialColor.tertiary;
      icon = GymTrackerIcons.favorite;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: color.getBackground(context),
                foregroundColor: color.getForeground(context),
                child: Icon(icon),
              ),
              title: Text(food.name),
              subtitle: Text(subtitlePieces.join(", ")),
              trailing: Text(
                controller.getRelativeTime(date),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              titleAlignment: ListTileTitleAlignment.titleHeight,
              mouseCursor: MouseCursor.defer,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: StatsRow(
                stats: [
                  Stats(
                    label: "food.nutriments.carbs".t,
                    value: kNutritionValueToUnit["carbs"]!
                        .formatAmount(food.nutritionalValues.carbs),
                  ),
                  Stats(
                    label: "food.nutriments.protein".t,
                    value: kNutritionValueToUnit["protein"]!
                        .formatAmount(food.nutritionalValues.protein),
                  ),
                  Stats(
                    label: "food.nutriments.fat".t,
                    value: kNutritionValueToUnit["fat"]!
                        .formatAmount(food.nutritionalValues.fat),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTagged<Food>>('food', dtfood));
  }
}

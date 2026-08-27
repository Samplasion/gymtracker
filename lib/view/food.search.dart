part of 'food.dart';

class _AddCustomFoodFAB extends ConsumerWidget {
  final NutritionCategory? category;

  const _AddCustomFoodFAB({
    required this.closeView,
    this.category,
    required this.onFoodAdded,
  });

  final void Function() closeView;
  final void Function(Food?) onFoodAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      label: Text("food.addCustom.title".t),
      icon: const Icon(GTIcons.add_food),
      onPressed: () {
        closeView();
        SchedulerBinding.instance.addPostFrameCallback((_) {
          showAddCustomFoodView(context, ref, category: category).then((food) {
            onFoodAdded(food);
          });
        });
      },
    );
  }
}

class _SearchFoodWithMacros extends ConsumerWidget {
  final DateTagged<Food> dtfood;
  final void Function()? onTap;

  const _SearchFoodWithMacros({required this.dtfood, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = dtfood.date;
    final food = dtfood.value;

    final subtitlePieces = [
      if (food.brand != null) food.brand,
      food.unit.formatAmount(food.amount, pieces: food.pieces),
    ];

    final favorites =
        ref.watch(favoriteFoodsStreamProvider).asData?.value ?? [];
    final isFavorite = favorites.any((f) => f.id == food.id);

    var color = GTMaterialColor.primary;
    var icon = GTIcons.history;

    if (isFavorite) {
      color = GTMaterialColor.tertiary;
      icon = GTIcons.favorite;
    }

    final relativeTime = date.relativeTime(
      context,
      timeUnits: [TimeUnit.day, TimeUnit.week, TimeUnit.month, TimeUnit.year],
    );

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
                relativeTime,
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
                    value: kNutritionValueToUnit["carbs"]!.formatAmount(
                      food.nutritionalValues.carbs,
                    ),
                  ),
                  Stats(
                    label: "food.nutriments.protein".t,
                    value: kNutritionValueToUnit["protein"]!.formatAmount(
                      food.nutritionalValues.protein,
                    ),
                  ),
                  Stats(
                    label: "food.nutriments.fat".t,
                    value: kNutritionValueToUnit["fat"]!.formatAmount(
                      food.nutritionalValues.fat,
                    ),
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

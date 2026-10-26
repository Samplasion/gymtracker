part of 'food.dart';

class _AddCustomFoodFAB extends ConsumerWidget {
  final NutritionCategory? category;

  const _AddCustomFoodFAB({
    this.closeSearchView = true,
    this.category,
    required this.onFoodAdded,
  });

  final bool closeSearchView;
  final void Function(Food?) onFoodAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      label: Text(context.t.food.addCustom.title),
      icon: const Icon(GTIcons.add_food),
      onPressed: () async {
        // Search opens on the nearest navigator, which can be the shell's
        // navigator rather than Go's root navigator.
        if (closeSearchView) Navigator.of(context).pop();
        final food = await showAddCustomFoodView(
          context,
          ref,
          category: category,
        );
        onFoodAdded(food);
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
      food.unit.formatAmount(
        food.amount,
        pieces: food.pieces,
        context: context,
      ),
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
                    label: context.t.food.nutriments['carbs']!,
                    value: kNutritionValueToUnit["carbs"]!.formatAmount(
                      food.nutritionalValues.carbs,
                      context: context,
                    ),
                  ),
                  Stats(
                    label: context.t.food.nutriments['protein']!,
                    value: kNutritionValueToUnit["protein"]!.formatAmount(
                      food.nutritionalValues.protein,
                      context: context,
                    ),
                  ),
                  Stats(
                    label: context.t.food.nutriments['fat']!,
                    value: kNutritionValueToUnit["fat"]!.formatAmount(
                      food.nutritionalValues.fat,
                      context: context,
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

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

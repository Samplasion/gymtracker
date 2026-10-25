import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/water_history.dart';

const waterPresets = [50, 100, 150, 200, 250, 500, 1000];

class HydrationCard extends ConsumerWidget {
  const HydrationCard({super.key});

  Future<double?> _customAmount(BuildContext context) async {
    final t = context.t.hydration;
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    try {
      return await showDialog<double>(
        context: context,
        builder: (dialogContext) {
          void submit() {
            if (!form.currentState!.validate()) return;
            Navigator.pop(
              dialogContext,
              double.parse(controller.text.replaceAll(',', '.')),
            );
          }

          return AlertDialog(
            title: Text(t.custom),
            content: Form(
              key: form,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: t.amount),
                validator: (text) {
                  final value = double.tryParse(
                    (text ?? '').replaceAll(',', '.'),
                  );
                  return value == null || !value.isFinite || value <= 0
                      ? t.invalid
                      : null;
                },
                onFieldSubmitted: (_) => submit(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(t.cancel),
              ),
              FilledButton(onPressed: submit, child: Text(t.save)),
            ],
          );
        },
      );
    } finally {
      Future<void>.delayed(
        const Duration(milliseconds: 300),
        controller.dispose,
      );
    }
  }

  Future<void> _addWater(BuildContext context, WidgetRef ref) async {
    final owner = ref.read(currentUserIdProvider);
    final date = ref.read(foodSelectedDateProvider);
    final amount = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .75,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  context.t.hydration.add,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final amount in waterPresets)
                ListTile(
                  leading: const Icon(Icons.local_drink_outlined),
                  title: Text(
                    NutritionUnit.MILLI_L.formatAmount(
                      amount.toDouble(),
                      context: context,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetContext, amount.toDouble()),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.t.hydration.custom),
                onTap: () async {
                  final custom = await _customAmount(sheetContext);
                  if (custom != null && sheetContext.mounted) {
                    Navigator.pop(sheetContext, custom);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (amount == null ||
        !context.mounted ||
        ref.read(currentUserIdProvider) != owner) {
      return;
    }
    final now = DateTime.now();
    final stamp = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
    );
    await performHydrationAction(
      context,
      ref,
      () => ref
          .read(hydrationRepositoryProvider)
          .save(milliliters: amount.toDouble(), time: stamp),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.hydration;
    final entriesState = ref.watch(waterEntriesProvider);
    final entries = ref.watch(selectedWaterEntriesProvider);
    final drinking = entries.fold(0.0, (sum, entry) => sum + entry.milliliters);
    final fromFood = ref.watch(foodWaterProvider);
    final goal = ref.watch(nutritionGoalForSelectedDateProvider).dailyWater;
    final showPermissionBanner =
        ref.watch(hydrationPageVisitProvider).asData?.value ?? false;
    final permissionDenied =
        ref.watch(hydrationPermissionProvider).asData?.value ==
        HydrationPermission.denied;
    final selected = ref.watch(foodSelectedDateProvider);
    final now = DateTime.now();
    final future = DateTime(
      selected.year,
      selected.month,
      selected.day,
    ).isAfter(DateTime(now.year, now.month, now.day));
    String format(double amount) =>
        NutritionUnit.MILLI_L.formatAmount(amount, context: context);
    final total = drinking + fromFood;
    final progress = goal != null && goal > 0
        ? (total / goal).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      margin: .zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: t.history,
                  icon: const Icon(GTIcons.history),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WaterHistoryView(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: t.add,
                  icon: GTIcons.compound.add_water,
                  onPressed: future || !entriesState.hasValue
                      ? null
                      : () => _addWater(context, ref),
                ),
              ],
            ),
            if (entriesState.hasError)
              Text(t.error)
            else ...[
              Text(
                format(total),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('${t.drinking}: ${format(drinking)}'),
              if (fromFood > 0) Text('${t.food}: ${format(fromFood)}'),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: entriesState.isLoading ? null : progress,
                semanticsLabel: '${t.title}: ${format(total)}',
              ),
              const SizedBox(height: 8),
              Text(
                goal == null ? t.noGoal : '${format(total)} / ${format(goal)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (showPermissionBanner && permissionDenied)
              AlertBanner(
                title: context.t.settings.options.health.label,
                text: Text(t.permissionDenied),
                icon: const Icon(GTIcons.notification_dialog),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:intl/intl.dart';

Future<void> performHydrationAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
) async {
  final backup = ref.read(backupSchedulerProvider);
  final sync = ref.read(hydrationSyncProvider);
  try {
    await action();
    backup.schedule();
    await sync.process();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.hydration.error)));
    }
  }
}

Future<void> _editWaterEntry(
  BuildContext context,
  WidgetRef ref,
  WaterEntry entry,
) async {
  final owner = ref.read(currentUserIdProvider);
  final t = context.t.hydration;
  var time = TimeOfDay.fromDateTime(entry.time);
  DateTime timestamp(TimeOfDay value) {
    final sameTime =
        value.hour == entry.time.hour && value.minute == entry.time.minute;
    return DateTime(
      entry.time.year,
      entry.time.month,
      entry.time.day,
      value.hour,
      value.minute,
      sameTime ? entry.time.second : 0,
      sameTime ? entry.time.millisecond : 0,
      sameTime ? entry.time.microsecond : 0,
    );
  }

  final controller = TextEditingController(
    text: NumberFormat(
      '0.###',
      Localizations.localeOf(context).languageCode,
    ).format(entry.milliliters),
  );
  final form = GlobalKey<FormState>();
  final result = await showDialog<(double, TimeOfDay)>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(t.edit),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: t.amount),
                validator: (text) {
                  final value = double.tryParse(
                    (text ?? '').replaceAll(',', '.'),
                  );
                  return value == null || !value.isFinite || value <= 0
                      ? t.invalid
                      : null;
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text('${t.time}: ${time.format(context)}'),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null && context.mounted) {
                    setState(() => time = picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              final stamp = timestamp(time);
              if (stamp.isAfter(DateTime.now())) {
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(SnackBar(content: Text(t.future)));
                return;
              }
              Navigator.pop(dialogContext, (
                double.parse(controller.text.replaceAll(',', '.')),
                time,
              ));
            },
            child: Text(t.save),
          ),
        ],
      ),
    ),
  );
  Future<void>.delayed(const Duration(milliseconds: 300), controller.dispose);
  if (result == null ||
      !context.mounted ||
      ref.read(currentUserIdProvider) != owner) {
    return;
  }
  await performHydrationAction(
    context,
    ref,
    () => ref
        .read(hydrationRepositoryProvider)
        .save(id: entry.id, milliliters: result.$1, time: timestamp(result.$2)),
  );
}

class WaterHistoryView extends ConsumerWidget {
  const WaterHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.hydration;
    final state = ref.watch(waterEntriesProvider);
    final entries = ref.watch(selectedWaterEntriesProvider).reversed.toList();
    final date = ref.watch(foodSelectedDateProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.history)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              DateFormat.yMMMMEEEEd(
                Localizations.localeOf(context).languageCode,
              ).format(date),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.hasError
                ? Center(child: Text(t.error))
                : entries.isEmpty
                ? Center(child: Text(t.empty))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        leading: const Icon(Icons.local_drink_outlined),
                        title: Text(
                          NutritionUnit.MILLI_L.formatAmount(
                            entry.milliliters,
                            context: context,
                          ),
                        ),
                        subtitle: Text(DateFormat.Hm().format(entry.time)),
                        onTap: () => _editWaterEntry(context, ref, entry),
                        trailing: IconButton(
                          tooltip: t.delete,
                          icon: const Icon(GTIcons.delete),
                          onPressed: () => performHydrationAction(
                            context,
                            ref,
                            () => ref
                                .read(hydrationRepositoryProvider)
                                .remove(entry.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/online.dart';

Future<void> showCatalogReport(
  BuildContext context,
  WidgetRef ref,
  String foodId,
) async {
  final strings = context.t.food.catalog;
  if (ref.read(currentUserIdProvider) == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.loginToReport)));
    return;
  }
  final owner = ref.read(currentUserIdProvider);
  final result = await showDialog<({String reason, String details})>(
    context: context,
    builder: (_) => const _CatalogReportDialog(),
  );
  if (result == null || !context.mounted || !ref.context.mounted) return;
  if (ref.read(currentUserIdProvider) != owner) return;
  try {
    final client = ref.read(foodCatalogClientProvider);
    final session = client.auth.currentSession;
    if (session == null || session.user.id != owner) return;
    await client
        .rpc(
          'report_catalog_food',
          params: {
            'food_id': foodId,
            'reason': result.reason,
            'details': result.details,
          },
        )
        .setHeader('Authorization', 'Bearer ${session.accessToken}');
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.reportSent)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.reportFailed)));
    }
  }
}

class _CatalogReportDialog extends StatefulWidget {
  const _CatalogReportDialog();
  @override
  State<_CatalogReportDialog> createState() => _CatalogReportDialogState();
}

class _CatalogReportDialogState extends State<_CatalogReportDialog> {
  final form = GlobalKey<FormState>();
  final details = TextEditingController();
  String reason = 'nutrition';
  @override
  void dispose() {
    details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.t.food.catalog;
    return AlertDialog(
      title: Text(strings.report),
      content: SizedBox(
        width: 420,
        child: Form(
          key: form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: reason,
                  isExpanded: true,
                  items: strings.reasons.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, maxLines: 2),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => reason = value!),
                ),
                TextFormField(
                  controller: details,
                  decoration: InputDecoration(labelText: strings.details),
                  maxLength: 2000,
                  maxLines: 4,
                  validator: (value) =>
                      reason == 'other' &&
                          (value == null || value.trim().isEmpty)
                      ? strings.detailsRequired
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              Navigator.pop(context, (
                reason: reason,
                details: details.text.trim(),
              ));
            }
          },
          child: Text(strings.sendReport),
        ),
      ],
    );
  }
}

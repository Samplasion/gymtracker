import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/online.dart';

class CatalogSubmissionsView extends ConsumerWidget {
  const CatalogSubmissionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.t.food.catalog;
    final owner = ref.watch(currentUserIdProvider);
    final requests = ref.watch(catalogSubmissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.submissions)),
      body: owner == null
          ? Center(child: Text(strings.loginToSubmit))
          : requests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(strings.loadFailed)),
              data: (rows) => rows.isEmpty
                  ? Center(child: Text(strings.noSubmissions))
                  : ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return ListTile(
                          title: Text(row.definition['name'] as String),
                          subtitle: Text(
                            strings.statuses[row.status] ?? row.status,
                          ),
                          trailing:
                              row.status == 'pending' || row.status == 'failed'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: strings.retry,
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () async {
                                        await ref
                                            .read(catalogOutboxProvider)
                                            .retry(owner, row.operationId);
                                        if (ref.context.mounted) {
                                          unawaited(
                                            ref
                                                .read(catalogDeliveryProvider)
                                                .process(),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      tooltip: strings.cancel,
                                      icon: const Icon(Icons.close),
                                      onPressed: () => ref
                                          .read(catalogOutboxProvider)
                                          .cancel(owner, row.operationId),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    ),
            ),
    );
  }
}

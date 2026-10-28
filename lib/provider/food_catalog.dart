import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/service/catalog_delivery.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final foodCatalogClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final catalogOutboxProvider = Provider<CatalogOutbox>(
  (ref) => CatalogOutbox(ref.watch(appDatabaseProvider)),
);
final catalogDeliveryProvider = Provider<CatalogDelivery>((ref) {
  final client = ref.watch(foodCatalogClientProvider);
  final outbox = ref.watch(catalogOutboxProvider);
  final delivery = CatalogDelivery(
    outbox: outbox,
    activeOwner: () {
      final owner = client.auth.currentUser?.id;
      return outbox.db.currentUserId == owner ? owner : null;
    },
    submitCreateOnly: (owner, id, food) async {
      final session = client.auth.currentSession;
      if (session == null ||
          session.user.id != owner ||
          outbox.db.currentUserId != owner) {
        throw StateError('Account changed before catalog submission');
      }
      return Map<String, dynamic>.from(
        await client
            .rpc(
              'create_catalog_food',
              params: {'operation_id': id, 'definition': food},
            )
            .setHeader('Authorization', 'Bearer ${session.accessToken}'),
      );
    },
    submit: (owner, id, food) async {
      final session = client.auth.currentSession;
      if (session == null ||
          session.user.id != owner ||
          outbox.db.currentUserId != owner) {
        throw StateError('Account changed before catalog submission');
      }
      return Map<String, dynamic>.from(
        await client
            .rpc(
              'submit_catalog_food',
              params: {'operation_id': id, 'definition': food},
            )
            .setHeader('Authorization', 'Bearer ${session.accessToken}'),
      );
    },
  );
  ref.onDispose(delivery.dispose);
  return delivery;
});

final catalogWorkerProvider = Provider<void>((ref) {
  void process() {
    if (ref.read(currentUserIdProvider) == null) return;
    unawaited(
      Future<void>.sync(
        () => ref.read(catalogDeliveryProvider).process(),
      ).catchError((Object error, StackTrace stack) {
        globalLogger.w(
          'Catalog delivery deferred',
          error: error,
          stackTrace: stack,
        );
      }),
    );
  }

  ref.listen(currentUserIdProvider, (_, _) => process());
  final timer = Timer.periodic(const Duration(seconds: 30), (_) => process());
  final lifecycle = AppLifecycleListener(onResume: process);
  ref.onDispose(() {
    timer.cancel();
    lifecycle.dispose();
  });
  process();
});

final catalogSubmissionsProvider =
    StreamProvider.autoDispose<List<CatalogSubmissionRequest>>((ref) {
      final owner = ref.watch(currentUserIdProvider);
      if (owner == null) return Stream.value([]);
      return ref.watch(catalogOutboxProvider).watch(owner);
    });

final searchFoodCatalogProvider = FutureProvider.autoDispose
    .family<List<VagueFood>, String>((ref, query) async {
      if (query.trim().isEmpty) return [];
      final rows = await ref
          .watch(foodCatalogClientProvider)
          .rpc('search_food_catalog', params: {'query': query.trim()});
      return (rows as List)
          .map((r) => CatalogFood.fromRow(Map<String, dynamic>.from(r)))
          .toList();
    });
final searchFoodCatalogByBarcodeProvider = FutureProvider.autoDispose
    .family<VagueFood?, String>((ref, barcode) async {
      if (barcode.trim().isEmpty) return null;
      final rows = await ref
          .watch(foodCatalogClientProvider)
          .rpc('search_food_catalog', params: {'barcode': barcode.trim()});
      return (rows as List).isEmpty
          ? null
          : CatalogFood.fromRow(Map<String, dynamic>.from(rows.first));
    });

/// Fail closed when offline, on old servers, or when provenance is unknown.
final catalogEligibilityProvider = FutureProvider.autoDispose
    .family<String, Food>((ref, food) async {
      if (food.origin != 'personal' ||
          food.catalogId != null ||
          food.downloadedFromOFF) {
        return 'uncertain';
      }
      final owner = ref.watch(currentUserIdProvider);
      if (owner == null) return 'uncertain';
      final submissions = ref.watch(catalogSubmissionsProvider);
      // A loading or failed outbox cannot prove that no equivalent request exists.
      final requests = submissions.asData?.value;
      if (requests == null) return 'uncertain';
      if (requests.any(
        (r) =>
            !const {'cancelled', 'failed'}.contains(r.status) &&
            sameCatalogDefinition(r.definition, food),
      )) {
        return 'uncertain';
      }
      try {
        final client = ref.watch(foodCatalogClientProvider);
        final result = await client.rpc(
          'catalog_food_eligibility',
          params: {'definition': catalogDefinition(food)},
        );
        return const {'absent', 'present', 'uncertain'}.contains(result)
            ? result as String
            : 'uncertain';
      } catch (_) {
        return 'uncertain';
      }
    });

/// Loaded only after expanding the initial search results in the picker.
final remainingFoodCatalogProvider = FutureProvider.autoDispose
    .family<List<VagueFood>, String>((ref, query) async {
      final client = ref.watch(foodCatalogClientProvider);
      final foods = <VagueFood>[];
      // The search RPC supports offsets through 10000. Keep within that range.
      for (var offset = 50; offset <= 10000; offset += 50) {
        final rows =
            await client.rpc(
                  'search_food_catalog',
                  params: {
                    'query': query.trim(),
                    'result_limit': 50,
                    'result_offset': offset,
                  },
                )
                as List;
        foods.addAll(
          rows.map((r) => CatalogFood.fromRow(Map<String, dynamic>.from(r))),
        );
        if (rows.length < 50 || !ref.mounted) break;
      }
      return foods;
    });

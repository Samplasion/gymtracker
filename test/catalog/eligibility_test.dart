import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const personal = Food(
  name: 'Personal milk',
  origin: 'personal',
  amount: 37.5,
  pieces: 3,
  unit: NutritionUnit.MILLI_L,
  nutritionalValuesPer100g: NutritionValues.zero,
);

void main() {
  test('provenance round-trips and historical definitions remain unknown', () {
    expect(Food.fromJson(personal.toJson()).origin, 'personal');
    expect(personal.copyWith(amount: 250).origin, 'personal');
    final old = {...personal.toJson()}..remove('origin');
    expect(Food.fromJson(old).origin, isNull);
    final catalog = personal.copyWith(
      origin: 'catalog',
      catalogId: 'catalog-id',
    );
    expect(
      Food.fromJson(catalog.toJson()).copyWith(amount: 50).catalogId,
      'catalog-id',
    );
    expect(catalog, isNot(personal));
    expect(catalogDefinition(catalog).keys, isNot(contains('catalogId')));
    expect(catalogDefinition(catalog).keys, isNot(contains('origin')));
  });

  for (final outcome in ['absent', 'present', 'uncertain', 'missing-server']) {
    test('eligibility $outcome sends only values per 100 ml', () async {
      final requests = <Request>[];
      final client = SupabaseClient(
        'https://catalog.test',
        'key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((r) async {
          requests.add(r);
          return Response(
            outcome == 'missing-server'
                ? '{"message":"missing RPC"}'
                : jsonEncode(outcome),
            outcome == 'missing-server' ? 404 : 200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWithValue('A'),
          catalogSubmissionsProvider.overrideWith((ref) => Stream.value([])),
          foodCatalogClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await client.dispose();
      });
      final outboxSubscription = container.listen(
        catalogSubmissionsProvider,
        (_, _) {},
      );
      addTearDown(outboxSubscription.close);
      await container.read(catalogSubmissionsProvider.future);
      final subscription = container.listen(
        catalogEligibilityProvider(personal),
        (_, _) {},
      );
      addTearDown(subscription.close);
      expect(
        await container.read(catalogEligibilityProvider(personal).future),
        outcome == 'missing-server' ? 'uncertain' : outcome,
      );
      expect(requests.single.url.path, '/rest/v1/rpc/catalog_food_eligibility');
      final definition = jsonDecode(requests.single.body)['definition'] as Map;
      expect(definition['unit'], 'ml');
      expect(
        definition['nutritionalValuesPer100g'],
        personal.nutritionalValuesPer100g.toJson(),
      );
      expect(definition.keys, isNot(contains('amount')));
      expect(definition.keys, isNot(contains('pieces')));
    });
  }

  test(
    'guest, external, catalog, and unknown origins cannot publish',
    () async {
      final container = ProviderContainer(
        overrides: [currentUserIdProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);
      for (final food in [
        personal,
        personal.copyWith(origin: null),
        personal.copyWith(origin: 'catalog'),
        personal.copyWith(downloadedFromOFF: true),
      ]) {
        expect(
          await container.read(catalogEligibilityProvider(food).future),
          'uncertain',
        );
      }
    },
  );

  for (final status in [
    'pending',
    'sending',
    'published',
    'duplicate',
    'already_present',
    'cancelled_unknown',
  ]) {
    test(
      'equivalent $status submission hides publication despite another portion',
      () async {
        final request = CatalogSubmissionRequest({
          'operation_id': 'op',
          'owner': 'A',
          'status': status,
          'error': null,
          'attempts': 0,
          'definition': jsonEncode(
            catalogDefinition(personal.copyWith(amount: 500)),
          ),
        });
        final container = ProviderContainer(
          overrides: [
            currentUserIdProvider.overrideWithValue('A'),
            catalogSubmissionsProvider.overrideWith(
              (ref) => Stream.value([request]),
            ),
          ],
        );
        addTearDown(container.dispose);
        final outboxSubscription = container.listen(
          catalogSubmissionsProvider,
          (_, _) {},
        );
        addTearDown(outboxSubscription.close);
        await container.read(catalogSubmissionsProvider.future);
        final subscription = container.listen(
          catalogEligibilityProvider(personal),
          (_, _) {},
        );
        addTearDown(subscription.close);
        expect(
          await container.read(catalogEligibilityProvider(personal).future),
          'uncertain',
        );
      },
    );
  }
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const food = Food(
    name: 'Milk',
    amount: 100,
    barcode: '00123456',
    nutritionalValuesPer100g: NutritionValues.zero,
  );
  test('expanded catalog loads all remaining pages in stable order', () async {
    final offsets = <int>[];
    final client = SupabaseClient(
      'https://catalog.test',
      'key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        final params = jsonDecode(request.body) as Map;
        final offset = params['result_offset'] as int;
        offsets.add(offset);
        expect(params['query'], 'Milk');
        expect(params['result_limit'], 50);
        return Response(
          jsonEncode([
            for (var i = offset; i < (offset == 50 ? 100 : 103); i++)
              {'id': 'result-$i', 'version': 1, 'food': food.toJson()},
          ]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final container = ProviderContainer(
      overrides: [foodCatalogClientProvider.overrideWithValue(client)],
    );
    final subscription = container.listen(
      remainingFoodCatalogProvider(' Milk '),
      (_, _) {},
    );
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await client.dispose();
    });
    final results = await container.read(
      remainingFoodCatalogProvider(' Milk ').future,
    );
    expect(offsets, [50, 100]);
    expect(results, hasLength(53));
    expect((results.first as CatalogFood).catalogId, 'result-50');
    expect((results.last as CatalogFood).catalogId, 'result-102');
  });

  test('old JSON retains OFF provenance and copyWith wire schema', () {
    final old = {...food.toJson(), 'isDownloaded': true};
    final decoded = Food.fromJson(old);
    expect(decoded.downloadedFromOFF, isTrue);
    expect(decoded.toJson(), old);
    expect(decoded.copyWith(amount: 200).downloadedFromOFF, isTrue);
    expect(decoded.toJson().containsKey('downloadedFromOFF'), isFalse);
  });
  test(
    'text and barcode use Supabase; complete snapshots omit catalog identity',
    () async {
      final requests = <Request>[];
      final client = SupabaseClient(
        'https://catalog.test',
        'key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient((r) async {
          requests.add(r);
          return Response(
            jsonEncode([
              {'id': 'server-id', 'version': 2, 'food': food.toJson()},
            ]),
            200,
            request: r,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      final c = ProviderContainer(
        overrides: [foodCatalogClientProvider.overrideWithValue(client)],
      );
      addTearDown(() async {
        c.dispose();
        await client.dispose();
      });
      final found =
          (await c.read(searchFoodCatalogProvider(' Milk ').future)).single
              as CatalogFood;
      expect(found.catalogId, 'server-id');
      expect(found.toJson().keys, isNot(contains('catalogId')));
      expect(jsonDecode(requests.last.body), {'query': 'Milk'});
      expect(requests.last.url.path, '/rest/v1/rpc/search_food_catalog');
      final barcode = await c.read(
        searchFoodCatalogByBarcodeProvider(' 00123456 ').future,
      );
      expect(barcode?.barcode, '00123456');
      expect(jsonDecode(requests.last.body), {'barcode': '00123456'});
      expect(await c.read(searchFoodCatalogProvider(' ').future), isEmpty);
      expect(requests, hasLength(2));
    },
  );
  test(
    'hydration foods come only from the backend and keep catalog identity',
    () async {
      LocaleSettings.setLocaleSync(AppLocale.it);
      addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
      var fail = false;
      var rows = <Map<String, dynamic>>[];
      final client = SupabaseClient(
        'https://catalog.test',
        'key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
        httpClient: MockClient(
          (request) async => Response(
            fail
                ? '{"code":"test","message":"Catalog unavailable"}'
                : jsonEncode(rows),
            fail ? 400 : 200,
            headers: {'content-type': 'application/json'},
            request: request,
          ),
        ),
      );
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [foodCatalogClientProvider.overrideWithValue(client)],
      );
      addTearDown(() async {
        container.dispose();
        await client.dispose();
      });
      expect(
        await container.read(searchFoodCatalogProvider('Acqua').future),
        isEmpty,
      );
      rows = [
        {
          'id': 'backend-cucumber',
          'version': 1,
          'food': VagueFood(
            name: 'Cetriolo',
            nutritionalValuesPer100g: NutritionValues.fromJson({
              ...NutritionValues.zero.toJson(),
              'water': 95.23,
            }),
          ).toJson(),
        },
      ];
      final result =
          (await container.read(
                searchFoodCatalogProvider('Cetriolo').future,
              )).single
              as CatalogFood;
      expect(result.catalogId, 'backend-cucumber');
      expect(result.nutritionalValuesPer100g.water, 95.23);
      fail = true;
      final failureSubscription = container.listen(
        searchFoodCatalogProvider('Anguria'),
        (_, _) {},
      );
      await expectLater(
        container.read(searchFoodCatalogProvider('Anguria').future),
        throwsA(isA<PostgrestException>()),
      );
      failureSubscription.close();
    },
  );
}

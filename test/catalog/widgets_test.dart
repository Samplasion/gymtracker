import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/food_catalog.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/service/catalog_delivery.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';

class _FailingOutbox extends CatalogOutbox {
  _FailingOutbox(super.db);
  @override
  Future<String> enqueue(
    String owner,
    VagueFood food, {
    bool createOnly = false,
  }) async => throw StateError('Local queue unavailable');
}

void main() {
  late GTDatabaseImpl db;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('A');
  });
  tearDown(() async {
    await db.close();
    await LocaleSettings.setLocale(AppLocale.en);
  });

  Widget app(Widget child, {String? owner = 'A'}) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      currentUserIdProvider.overrideWithValue(owner),
      favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
    ],
    child: TranslationProvider(
      child: MaterialApp(
        navigatorKey: Go.navigatorKey,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppLocaleUtils.supportedLocales,
        home: child,
      ),
    ),
  );

  for (final scenario in [
    (consent: false, fail: false),
    (consent: true, fail: false),
    (consent: true, fail: true),
  ]) {
    final consent = scenario.consent;
    testWidgets(
      'manual creation consent=$consent queueFailure=${scenario.fail}',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            currentUserIdProvider.overrideWithValue('A'),
            catalogDeliveryProvider.overrideWithValue(
              CatalogDelivery(
                outbox: CatalogOutbox(db),
                activeOwner: () => null,
                submit: (_, _, _) async => {'outcome': 'published'},
              ),
            ),
            if (scenario.fail)
              catalogOutboxProvider.overrideWithValue(_FailingOutbox(db)),
          ],
        );
        addTearDown(container.dispose);
        Food? returned;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TranslationProvider(
              child: MaterialApp(
                navigatorKey: Go.navigatorKey,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                supportedLocales: AppLocaleUtils.supportedLocales,
                home: Builder(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () async {
                        returned = await Navigator.of(context).push<Food>(
                          MaterialPageRoute(
                            builder: (_) => consent
                                ? const CustomAddFoodView.withBarcode(
                                    barcode: '00123456',
                                    category: null,
                                  )
                                : const CustomAddFoodView(category: null),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          final label = field.decoration?.labelText;
          if (label == t.food.add.customFood.fields.name) {
            field.controller!.text = 'Widget food';
          } else if (label != t.food.add.customFood.fields.brand &&
              field.controller!.text.isEmpty) {
            field.controller!.text = '0';
          }
        }
        await tester.tap(
          consent
              ? find.widgetWithText(FilledButton, t.food.picker.save)
              : find.widgetWithText(TextButton, t.food.picker.savePrivate),
        );
        await tester.pumpAndSettle();
        if (scenario.fail) {
          expect(returned, isNull);
          expect(find.byType(CustomAddFoodView), findsOneWidget);
        } else {
          expect(returned?.name, 'Widget food');
        }
        expect(
          await tester.runAsync(() => db.select(db.catalogSubmissions).get()),
          hasLength(consent && !scenario.fail ? 1 : 0),
        );
        await tester.pump();
      },
    );
  }

  testWidgets('guest has public and personal save actions', (tester) async {
    await tester.pumpWidget(
      app(const CustomAddFoodView(category: null), owner: null),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(FilledButton, t.food.picker.save),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextButton, t.food.picker.savePrivate),
      findsOneWidget,
    );
    expect(find.byType(CheckboxListTile), findsNothing);
  });

  for (final eligible in [false, true]) {
    testWidgets('share menu visible only with verified absence: $eligible', (
      tester,
    ) async {
      const food = Food(
        name: 'Personal food',
        origin: 'personal',
        amount: 250,
        nutritionalValuesPer100g: NutritionValues.zero,
      );
      var checks = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('A'),
            favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
            catalogSubmissionsProvider.overrideWith((ref) => Stream.value([])),
            catalogEligibilityProvider(food).overrideWith((ref) async {
              checks++;
              return eligible && checks == 1 ? 'absent' : 'present';
            }),
          ],
          child: app(AddFoodView(food: food)),
        ),
      );
      await tester.pumpAndSettle();
      if (eligible) {
        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.food.picker.share));
        await tester.pumpAndSettle();
        expect(find.text(t.food.picker.alreadyPresent), findsOneWidget);
        expect(
          await tester.runAsync(() => db.select(db.catalogSubmissions).get()),
          isEmpty,
        );
      } else {
        expect(find.byType(PopupMenuButton<String>), findsNothing);
      }
    });
  }

  testWidgets('adding a catalog food returns a complete independent snapshot', (
    tester,
  ) async {
    final product = CatalogFood.fromRow({
      'id': 'catalog-id',
      'version': 1,
      'food': {
        'name': 'Milk',
        'brand': 'Brand',
        'barcode': '00123456',
        'unit': 'ml',
        'isDownloaded': false,
        'servingSizes': [
          {'name': 'Glass', 'amount': 200},
        ],
        'nutritionalValuesPer100g': const NutritionValues(
          calories: 45,
          fat: 1,
          saturatedFat: 0,
          carbs: 5,
          sugar: 5,
          protein: 3,
          calcium: 120,
        ).toJson(),
      },
    });
    Food? returned;
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                returned = await Navigator.of(context).push<Food>(
                  MaterialPageRoute(builder: (_) => AddFoodView(food: product)),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, t.food.add.add));
    await tester.pumpAndSettle();
    expect(returned?.nutritionalValuesPer100g.calcium, 120);
    expect(returned?.servingSizes, product.servingSizes);
    expect(identical(returned?.servingSizes, product.servingSizes), isFalse);
    expect(returned?.barcode, '00123456');
    expect(returned?.downloadedFromOFF, isFalse);
    expect(returned?.catalogId, 'catalog-id');
    expect(returned?.origin, 'catalog');
  });
}

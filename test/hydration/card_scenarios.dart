import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/hydration_card.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/water_history.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

import 'hydration_test.dart' show FakeHydrationHealth;

class _Backup extends Mock implements BackupScheduler {}

class _WaterRepository extends HydrationRepository {
  _WaterRepository(super.db);
  final entries = BehaviorSubject<List<WaterEntry>>.seeded([]);
  @override
  Stream<List<WaterEntry>> watch(String? owner) => entries.stream;
  @override
  Future<void> save({
    required double milliliters,
    required DateTime time,
    String? id,
  }) async {
    final key = id ?? '${entries.value.length}';
    entries.add([
      ...entries.value.where((e) => e.id != key),
      WaterEntry(id: key, milliliters: milliliters, time: time),
    ]);
  }

  @override
  Future<void> remove(String id) async {
    entries.add(entries.value.where((e) => e.id != id).toList());
  }
}

class _FoodsRepository extends FoodsRepository {
  _FoodsRepository(super.db);
  final goals = BehaviorSubject<List<TaggedNutritionGoal>>.seeded([]);
  final foods = BehaviorSubject<List<DateTagged<Food>>>.seeded([]);
  @override
  Stream<List<TaggedNutritionGoal>> watchNutritionGoals() => goals.stream;
  @override
  Stream<List<DateTagged<Food>>> watchFoods() => foods.stream;
  @override
  Future<void> addNutritionGoal(TaggedNutritionGoal goal) async {
    goals.add([goal]);
  }
}

class _Sync extends HydrationSync {
  _Sync(super.db) : super(health: FakeHydrationHealth());
  @override
  Future<void> process() async {}
}

Future<void> exerciseHydrationCard(WidgetTester tester) async {
  final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
  final service = _Sync(db);
  final water = _WaterRepository(db);
  final foods = _FoodsRepository(db);
  final scope = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      hydrationRepositoryProvider.overrideWithValue(water),
      foodsRepositoryProvider.overrideWithValue(foods),
      currentUserIdProvider.overrideWith((ref) => null),
      hydrationSyncProvider.overrideWithValue(service),
      hydrationPageVisitProvider.overrideWith((ref) async => true),
      backupSchedulerProvider.overrideWithValue(_Backup()),
    ],
  );
  Future<void> settle() async {
    await tester.pump();

    await tester.pumpAndSettle();
  }

  try {
    LocaleSettings.setLocaleSync(AppLocale.it);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: scope,
        child: TranslationProvider(
          child: MaterialApp(
            navigatorKey: Go.navigatorKey,
            locale: AppLocale.it.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Scaffold(
              body: Builder(
                builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ChangeGoalScreen(),
                          ),
                        ),
                        child: const Text('Modifica obiettivi'),
                      ),
                      const HydrationCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle();
    expect(find.text('Acqua'), findsOneWidget);
    expect(find.text('0 ml'), findsOneWidget);
    service.permissionStatus.add(HydrationPermission.denied);
    await settle();
    expect(find.byType(AlertBanner), findsOneWidget);
    service.permissionStatus.add(HydrationPermission.granted);
    await settle();
    expect(find.byType(AlertBanner), findsNothing);
    expect(find.text('Collega a Salute'), findsNothing);
    expect(find.byTooltip('Imposta obiettivo'), findsNothing);
    expect(find.byType(ExpansionTile), findsNothing);
    await tester.tap(find.byTooltip('Aggiungi acqua'));
    await settle();
    expect(find.byType(BottomSheet), findsOneWidget);
    for (final amount in [50, 100, 150, 200, 250, 500, 1000]) {
      expect(find.text('$amount ml'), findsOneWidget);
    }
    await tester.tap(find.text('250 ml'));
    await settle();
    expect(find.text('250 ml'), findsOneWidget);
    expect(find.text('Acqua bevuta: 250 ml'), findsOneWidget);
    await tester.tap(find.byTooltip('Aggiungi acqua'));
    await settle();
    await tester.tap(find.text('100 ml'));
    await settle();
    expect(find.text('350 ml'), findsOneWidget);
    expect(find.text('100 ml'), findsNothing);
    await tester.tap(find.byTooltip('Aggiungi acqua'));
    await settle();
    await tester.ensureVisible(find.text('Quantità personalizzata'));
    await settle();
    await tester.tap(find.text('Quantità personalizzata'));
    await settle();
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text('Salva'));
    await settle();
    expect(find.text('Inserisci una quantità positiva valida'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '125,5');
    await tester.tap(find.text('Salva'));
    await settle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('475,5 ml'), findsOneWidget);
    await tester.tap(find.byTooltip('Cronologia acqua'));
    await settle();
    expect(find.text('125,5 ml'), findsOneWidget);
    await tester.tap(find.byTooltip('Elimina').first);
    await settle();
    await tester.tap(find.byTooltip('Indietro'));
    await settle();
    expect(find.text('350 ml'), findsOneWidget);

    foods.foods.add([
      DateTagged(
        date: DateTime.now(),
        value: Food(
          id: 'food',
          name: 'Cucumber',
          amount: 200,
          nutritionalValuesPer100g: NutritionValues.fromJson({
            ...NutritionValues.zero.toJson(),
            'water': 90,
          }),
        ),
      ),
    ]);
    await settle();
    expect(find.text('530 ml'), findsOneWidget);
    expect(find.text('Dagli alimenti: 180 ml'), findsOneWidget);
    await tester.tap(find.text('Modifica obiettivi'));
    await settle();
    final waterField = find.byType(TextFormField).last;
    await tester.ensureVisible(waterField);
    await tester.enterText(waterField, '-1');
    await tester.tap(find.byType(FloatingActionButton));
    await settle();
    expect(find.text('Inserisci una quantità positiva valida'), findsOneWidget);
    await tester.enterText(waterField, '2000');
    await tester.tap(find.byType(FloatingActionButton));
    await settle();
    expect(find.text('530 ml / 2000 ml'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      530 / 2000,
    );
    await tester.tap(find.byTooltip('Cronologia acqua'));
    await settle();
    expect(find.byType(WaterHistoryView), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
    await tester.tap(find.text('100 ml'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '125,5');
    await tester.tap(find.text('Salva'));
    await settle();
    expect(find.text('125,5 ml'), findsOneWidget);
    // History is newest first, so the modified second glass remains first.
    await tester.tap(find.byTooltip('Elimina').first);
    await settle();
    expect(find.text('125,5 ml'), findsNothing);
    await tester.tap(find.byTooltip('Indietro'));
    await settle();
    expect(find.text('430 ml'), findsOneWidget);
    expect(find.text('Acqua bevuta: 250 ml'), findsOneWidget);
    expect(find.text('250 ml'), findsNothing);
    await tester.tap(find.text('Modifica obiettivi'));
    await settle();
    final goalField = find.byType(TextFormField).last;
    expect(tester.widget<TextFormField>(goalField).controller!.text, '2000');
    await tester.ensureVisible(goalField);
    await tester.enterText(goalField, '');
    await tester.tap(find.byType(FloatingActionButton));
    await settle();
    expect(find.text('Nessun obiettivo impostato'), findsOneWidget);
    expect(foods.goals.value.single.value.dailyWater, isNull);
    expect(foods.goals.value.single.value.dailyCalories, 2000);
    scope
        .read(foodSelectedDateProvider.notifier)
        .setDate(DateTime.now().add(const Duration(days: 1)));
    await settle();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == 'Aggiungi acqua',
            ),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  } finally {
    await tester.pumpWidget(const SizedBox());
    scope.dispose();
    service.dispose();
    await water.entries.close();
    await foods.goals.close();
    await foods.foods.close();
    await db.close();
    LocaleSettings.setLocaleSync(AppLocale.en);
  }
}

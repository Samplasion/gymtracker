import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/food.dart';

Widget localizedApp(AppLocale locale, Widget child) {
  return ProviderScope(
    overrides: [
      favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
    ],
    child: TranslationProvider(
      child: MaterialApp(
        locale: locale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  tearDown(() => LocaleSettings.setLocale(AppLocale.en));

  for (final locale in [AppLocale.en, AppLocale.it]) {
    testWidgets('food quantities use translated units in ${locale.name}', (
      tester,
    ) async {
      await LocaleSettings.setLocale(locale);
      for (final unit in [NutritionUnit.G, NutritionUnit.MILLI_L]) {
        await tester.pumpWidget(
          localizedApp(
            locale,
            FoodListTile(
              food: Food(
                name: 'Food',
                nutritionalValuesPer100g: NutritionValues.zero,
                amount: 12.5,
                pieces: 2,
                unit: unit,
              ),
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
        await tester.pump();

        final amount = locale == AppLocale.it ? '12,5' : '12.5';
        final symbol = unit == NutritionUnit.G
            ? 'g'
            : locale == AppLocale.it
            ? 'ml'
            : 'mL';
        expect(find.text('2 × $amount $symbol'), findsOneWidget);
        expect(find.textContaining('Closure'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('macro goals display grams in ${locale.name}', (tester) async {
      await LocaleSettings.setLocale(locale);
      await tester.pumpWidget(
        localizedApp(
          locale,
          const FoodNutritionalSingleGoalSDButton(
            text: 'Protein',
            value: 25,
            goal: 100,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('25 / 100 g'), findsOneWidget);
      expect(find.textContaining('Closure'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

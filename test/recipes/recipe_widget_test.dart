import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/repository/recipes.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/recipe.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/food.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart' as expressive;
import '../test_helpers/widget_test_app.dart';

const nutrition = NutritionValues(
  calories: 100,
  fat: 2,
  saturatedFat: 1,
  carbs: 10,
  sugar: 3,
  protein: 5,
);
const ingredient = Food(
  id: 'ingredient',
  name: 'Rice',
  amount: 200,
  nutritionalValuesPer100g: nutrition,
);
Recipe meal() => Recipe(
  id: 'meal',
  name: 'Rice bowl',
  servings: 2,
  description: '[{"insert":"A simple meal\\n"}]',
  instructions: '[{"insert":"Cook rice\\n"}]',
  ingredients: const [RecipeIngredient(food: ingredient)],
);

class RecordingRecipes extends RecipesRepository {
  RecordingRecipes(super.db);
  final saved = <Recipe>[];
  @override
  Future<void> save(Recipe value) async {
    value.validate();
    saved.add(value);
  }
}

void main() {
  setUpAll(initTestLocalizations);
  late GTDatabaseImpl db;
  late RecordingRecipes repository;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    repository = RecordingRecipes(db);
  });
  tearDown(() => db.close());
  Widget app(Widget child, {List<Recipe>? recipes}) => ProviderScope(
    overrides: [
      favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
      recipesRepositoryProvider.overrideWithValue(repository),
      recipesProvider.overrideWith((ref) => Stream.value(recipes ?? [meal()])),
      foodLogsStreamProvider.overrideWith(
        (ref) => Stream.value([
          DateTagged(date: DateTime(2026, 10, 28), value: ingredient),
        ]),
      ),
    ],
    child: WidgetTestApp(child: child),
  );

  testWidgets(
    'quantity dialog defaults to one serving, accepts fractions and grams',
    (tester) async {
      Food? result;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showRecipeAmount(context, meal());
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '1',
      );
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.widgetWithText(FilledButton, t.food.recipes.add));
      await tester.pumpAndSettle();
      expect(find.text(t.food.recipes.invalid), findsOneWidget);
      expect(result, isNull);
      await tester.enterText(find.byType(TextFormField), '0.5');
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.food.recipes.grams));
      await tester.pumpAndSettle();
      expect(
        double.parse(
          tester
              .widget<TextFormField>(find.byType(TextFormField))
              .controller!
              .text,
        ),
        50,
      );
      await tester.tap(find.widgetWithText(FilledButton, t.food.recipes.add));
      await tester.pumpAndSettle();
      expect(result!.amount, 50);
      expect(result!.nutritionalValues.calories, 50);
    },
  );

  testWidgets(
    'recipe action precedes More and inserts exactly one selected portion',
    (tester) async {
      final added = <Food>[];
      await tester.pumpWidget(
        app(
          FoodPickerView(
            allowRecipes: true,
            onAdd: (food) async {
              added.add(food);
              return food.copyWith(id: 'new');
            },
            onRemove: (_) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text(t.food.recipes.choose)).dx,
        lessThan(tester.getCenter(find.text(t.food.picker.more)).dx),
      );
      await tester.tap(find.text(t.food.recipes.choose));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rice bowl'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, t.food.recipes.add);
      await tester.scrollUntilVisible(
        button,
        500,
        scrollable: find
            .descendant(
              of: find.byType(RecipeDetailView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, t.food.recipes.add),
        ),
      );
      await tester.pumpAndSettle();
      expect(added, hasLength(1));
      expect(added.single.name, 'Rice bowl');
      expect(added.single.amount, 100);
      expect(find.byType(FoodPickerView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'recipe register searches names and displays formatted instructions',
    (tester) async {
      await tester.pumpWidget(app(const RecipeListView()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(SearchBar), 'absent');
      await tester.pumpAndSettle();
      expect(find.text(t.food.recipes.empty), findsOneWidget);
      await tester.enterText(find.byType(SearchBar), 'RICE');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rice bowl'));
      await tester.pumpAndSettle();
      expect(find.byType(QuillEditor), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('editor validates serving bounds and saves both Quill fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (_) => TextButton(
            onPressed: () => Go.to(() => RecipeEditorView(base: meal())),
            child: const Text('Edit'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final servings = find.widgetWithText(
      TextFormField,
      t.food.recipes.servings,
    );
    await tester.ensureVisible(servings);
    await tester.enterText(servings, '33');
    await tester.tap(find.widgetWithText(TextButton, t.food.recipes.save));
    await tester.pumpAndSettle();
    expect(find.text(t.food.recipes.invalidServings), findsOneWidget);
    expect(repository.saved, isEmpty);
    await tester.enterText(servings, '32');
    await tester.tap(find.widgetWithText(TextButton, t.food.recipes.save));
    await tester.pumpAndSettle();
    expect(repository.saved, hasLength(1));
    expect(repository.saved.single.servings, 32);
    expect(repository.saved.single.description, meal().description);
    expect(repository.saved.single.instructions, meal().instructions);
    expect(find.text('Edit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'composing a recipe adds ingredients without touching the diary',
    (tester) async {
      await tester.pumpWidget(app(const RecipeEditorView()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(t.food.recipes.addIngredient));
      await tester.tap(find.text(t.food.recipes.addIngredient));
      await tester.pumpAndSettle();
      expect(find.text(t.food.recipes.choose), findsNothing);
      final row = find.ancestor(
        of: find.text('Rice'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: row, matching: find.byIcon(Icons.add)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Rice'), findsOneWidget);
      expect(repository.saved, isEmpty);
      expect(await tester.runAsync(() => db.watchFoods().first), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'liquid combination asks for mass and uses grams for the result',
    (tester) async {
      const milk = Food(
        name: 'Milk',
        amount: 100,
        unit: NutritionUnit.MILLI_L,
        nutritionalValuesPer100g: nutrition,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
            foodLogsStreamProvider.overrideWith(
              (ref) => Stream.value([
                DateTagged(date: DateTime(2026, 10, 28), value: milk),
              ]),
            ),
          ],
          child: const WidgetTestApp(
            child: AddCombinedFoodView(category: null),
          ),
        ),
      );
      await tester.tap(find.text(t.food.picker.title));
      await tester.pumpAndSettle();
      final row = find.ancestor(
        of: find.text('Milk'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: row, matching: find.byIcon(Icons.add)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(t.food.recipes.liquidMass), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '80');
      await tester.tap(find.text(t.food.recipes.confirm));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(AddCombinedFoodView));
      expect(state.amount, 80);
      expect(state.unit, NutritionUnit.G);
      expect((state.nutritionalValues as NutritionValues).calories, 125);
      expect(tester.takeException(), isNull);
    },
  );
  for (final servings in [1, 2]) {
    testWidgets('$servings servings display only distinct nutrition tables', (
      tester,
    ) async {
      final recipe = Recipe.fromJson({
        ...meal().toJson(),
        'servings': servings,
      });
      await tester.pumpWidget(
        app(const RecipeDetailView(recipeId: 'meal'), recipes: [recipe]),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NutritionTable), findsNWidgets(servings == 1 ? 1 : 2));
    });
  }

  testWidgets(
    'liquid weight is optional and volume and hint use the device locale',
    (tester) async {
      const milk = Food(
        name: 'Milk',
        amount: 1234.5,
        unit: NutritionUnit.MILLI_L,
        nutritionalValuesPer100g: nutrition,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteFoodsStreamProvider.overrideWith((ref) => Stream.value([])),
            foodLogsStreamProvider.overrideWith(
              (ref) => Stream.value([
                DateTagged(date: DateTime(2026, 10, 28), value: milk),
              ]),
            ),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              navigatorKey: Go.navigatorKey,
              locale: const Locale('it', 'IT'),
              supportedLocales: const [Locale('it', 'IT')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const AddCombinedFoodView(category: null),
            ),
          ),
        ),
      );
      await tester.tap(find.text(t.food.picker.title));
      await tester.pumpAndSettle();
      final row = find.ancestor(
        of: find.text('Milk'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: row, matching: find.byIcon(Icons.add)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Milk: 1.234,5 ml'), findsOneWidget);
      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.controller!.text, isEmpty);
      expect(find.text('1.234,5 g'), findsOneWidget);
      await tester.tap(find.text(t.food.recipes.confirm));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(AddCombinedFoodView));
      expect(state.amount, 1234.5);
      expect(
        (state.nutritionalValues as NutritionValues).calories,
        closeTo(100, 1e-9),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'nutrition expandable keeps its subtitle visible and contains the full expanded table',
    (tester) async {
      final recipe = Recipe(
        id: 'meal',
        name: 'Rice bowl',
        ingredients: [
          RecipeIngredient(
            food: ingredient.copyWith(
              nutritionalValuesPer100g: NutritionValues.fromJson({
                ...nutrition.toJson(),
                'calcium': 180.0,
              }),
            ),
          ),
        ],
      );
      await tester.pumpWidget(app(RecipeEditorView(base: recipe)));
      await tester.pumpAndSettle();
      final card = find.byType(M3EExpandableCardColumn);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      final subtitle = find.text(
        '200 kcal · ${t.food.recipes.perServing.toLowerCase()}',
      );
      final material = find
          .descendant(of: card, matching: find.byType(expressive.Material))
          .first;
      var bounds = tester.getRect(material);
      expect(tester.getRect(subtitle).top, greaterThanOrEqualTo(bounds.top));
      expect(tester.getRect(subtitle).bottom, lessThanOrEqualTo(bounds.bottom));
      expect(find.byType(NutritionTable), findsNothing);
      await tester.tap(find.text(t.food.recipes.nutrition));
      await tester.pumpAndSettle();
      bounds = tester.getRect(material);
      expect(find.byType(NutritionTable), findsOneWidget);
      expect(
        tester.getRect(find.byType(NutritionTable)).bottom,
        lessThanOrEqualTo(bounds.bottom - 20),
      );
      await tester.tap(find.text(t.food.recipes.nutrition));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(subtitle).bottom,
        lessThanOrEqualTo(tester.getRect(material).bottom),
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final input in ['0.5', '0,5']) {
    testWidgets('portion stepper accepts $input and formats integer amounts', (
      tester,
    ) async {
      Food? result;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showRecipeAmount(context, meal());
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), input);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(t.food.recipes.increaseQuantity));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '1.5',
      );
      await tester.tap(find.byTooltip(t.food.recipes.decreaseQuantity));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '0.5',
      );
      await tester.tap(find.text(t.food.recipes.grams));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '50',
      );
      await tester.tap(find.text(t.food.recipes.portions));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '1');
      await tester.tap(find.byTooltip(t.food.recipes.increaseQuantity));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '2',
      );
      await tester.tap(find.widgetWithText(FilledButton, t.food.recipes.add));
      await tester.pumpAndSettle();
      expect(result!.amount, 200);
    });
  }

  for (final grams in [100.000000000001, 100.25]) {
    testWidgets(
      'gram input preserves fractions and hides floating point noise for $grams',
      (tester) async {
        final recipe = Recipe.fromJson({
          ...meal().toJson(),
          'finalMass': grams * 2,
        });
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showRecipeAmount(context, recipe),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.food.recipes.grams));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField))
              .controller!
              .text,
          grams == 100.25 ? '100.25' : '100',
        );
      },
    );
  }

  testWidgets(
    'editor keeps focus on scroll and provides Done above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          Builder(
            builder: (_) => TextButton(
              onPressed: () => Go.to(() => RecipeEditorView(base: meal())),
              child: const Text('Edit'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final name = find.widgetWithText(TextFormField, t.food.recipes.name);
      await tester.showKeyboard(name);
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final editable = tester.widget<EditableText>(
        find.descendant(of: name, matching: find.byType(EditableText)),
      );
      expect(editable.focusNode.hasFocus, isTrue);
      final scroll = find
          .descendant(
            of: find.byType(RecipeEditorView),
            matching: find.byType(SingleChildScrollView),
          )
          .first;
      await tester.drag(scroll, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(editable.focusNode.hasFocus, isTrue);
      final done = find.widgetWithText(TextButton, t.food.picker.done);
      expect(done, findsOneWidget);
      expect(
        tester.getRect(done).bottom,
        lessThanOrEqualTo(
          tester.view.physicalSize.height / tester.view.devicePixelRatio - 220,
        ),
      );
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(editable.focusNode.hasFocus, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}

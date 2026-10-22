import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/struct/request_cache.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';
import 'package:uuid/uuid.dart';

part 'food.g.dart';

const kNameBrandSeparator = "\n\n\n\n~\n\n\n\n";

typedef FoodPermissions = ({bool camera, bool gallery});

// -----------------------------------------------------------------------------
// Selected Date Providers
// -----------------------------------------------------------------------------

@riverpod
class FoodSelectedDate extends _$FoodSelectedDate {
  @override
  DateTime build() => DateTime.now().startOfDay;

  void setDate(DateTime date) {
    state = date.startOfDay;
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1)).startOfDay;
  }

  void nextDay() {
    state = state.add(const Duration(days: 1)).startOfDay;
  }

  bool canGoToPreviousDay() => state.isAfter(DateTime(2000));
  bool canGoToNextDay() =>
      state.isBefore(DateTime(2100).subtract(const Duration(days: 1)));
}

@riverpod
String foodRelativeDayText(Ref ref, BuildContext context) {
  final date = ref.watch(foodSelectedDateProvider);
  final today = DateTime.now().startOfDay;
  final diff = today.difference(date.startOfDay).inDays;

  String string;
  if (diff.abs() >= 2) {
    string = DateFormat.yMEd(
      Localizations.localeOf(context).languageCode,
    ).format(date);
  } else {
    var trt = date.relativeTime(context, timeUnits: [TimeUnit.day]);
    var todayRt = today.relativeTime(context, timeUnits: [TimeUnit.day]);
    if (diff < 0 && trt == todayRt) {
      string = date
          .add(const Duration(days: 1))
          .relativeTime(context, timeUnits: [TimeUnit.day]);
    } else {
      string = trt;
    }
  }

  return string[0].toUpperCase() + string.substring(1);
}

@riverpod
bool foodCanUpdateCategories(Ref ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return date.isAfterOrAtSameMomentAs(DateTime.now().startOfDay);
}

// -----------------------------------------------------------------------------
// Food Logs Providers
// -----------------------------------------------------------------------------

@riverpod
Stream<List<DateTagged<Food>>> foodLogsStream(Ref ref) {
  return ref.watch(foodsRepositoryProvider).watchFoods();
}

@riverpod
List<Food> foodsForDate(Ref ref, DateTime date) {
  final logs = ref.watch(foodLogsStreamProvider).asData?.value ?? [];
  return logs.where((e) => e.date.isSameDay(date)).map((e) => e.value).toList();
}

@riverpod
List<DateTagged<Food>> taggedFoodsForDate(Ref ref, DateTime date) {
  final logs = ref.watch(foodLogsStreamProvider).asData?.value ?? [];
  return logs.where((e) => e.date.isSameDay(date)).toList();
}

@riverpod
List<Food> foodsForSelectedDate(Ref ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return ref.watch(foodsForDateProvider(date));
}

@riverpod
List<DateTagged<Food>> taggedFoodsForSelectedDate(Ref ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return ref.watch(taggedFoodsForDateProvider(date));
}

@riverpod
Stream<List<Food>> favoriteFoodsStream(Ref ref) {
  return ref.watch(foodsRepositoryProvider).watchFavoriteFoods();
}

@riverpod
Stream<Map<String, Food>> customBarcodeFoodsStream(Ref ref) {
  return ref.watch(foodsRepositoryProvider).watchCustomBarcodeFoods();
}

@riverpod
List<DateTagged<Food>> foodSuggestions(Ref ref, String query) {
  final logs = ref.watch(foodLogsStreamProvider).asData?.value ?? [];
  final uniqueChoices = EqualitySet.from(_FoodEquality(), logs.reversed);
  return extractTop<DateTagged<Food>>(
    query: query,
    choices: uniqueChoices.toList(),
    limit: 20,
    getter: (food) => "${food.value.name} ${food.value.brand ?? ""}",
  ).map((e) => e.choice).toList();
}

@riverpod
class FoodNotifier extends _$FoodNotifier {
  @override
  void build() {}

  Future<void> addFood(
    DateTime dateTime,
    Food food, {
    NutritionCategory? category,
  }) async {
    await ref
        .read(foodsRepositoryProvider)
        .addFood(
          DateTagged(
            date: dateTime.startOfDay,
            value: food.copyWith(
              id: const Uuid().v4(),
              category: category?.name,
            ),
          ),
        );
    // TODO: Move this stuff to the Event system so that we don't have to call the Coordinator directly
    ref.read(achievementTriggerProvider)(AchievementTrigger.food);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> removeFood(DateTime dateTime, Food food) async {
    await ref
        .read(foodsRepositoryProvider)
        .removeFood(DateTagged(date: dateTime.startOfDay, value: food));
    ref.read(achievementTriggerProvider)(AchievementTrigger.food);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> updateFood(DateTime dateTime, Food updatedFood) async {
    final dayFoods = ref.read(foodsForDateProvider(dateTime));
    if (!dayFoods.any((element) => element.id == updatedFood.id)) return;

    await ref
        .read(foodsRepositoryProvider)
        .updateFood(DateTagged(date: dateTime, value: updatedFood));
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> copyToToday(Food food) async {
    final today = DateTime.now().startOfDay;
    await addFood(today, food);
    ref.read(foodSelectedDateProvider.notifier).setDate(today);
  }

  Future<void> addFavorite(Food food) async {
    await ref.read(foodsRepositoryProvider).addFavoriteFood(food);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> removeFavorite(Food food) async {
    await ref.read(foodsRepositoryProvider).removeFavoriteFood(food);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> addCustomBarcodeFood(
    String barcode,
    Food food,
    NutritionCategory? category,
  ) async {
    await ref
        .read(foodsRepositoryProvider)
        .addCustomBarcodeFood(barcode, food.copyWith(category: category?.name));
  }
}

// -----------------------------------------------------------------------------
// Nutrition Goals Providers
// -----------------------------------------------------------------------------

@riverpod
Stream<DateSequence<NutritionGoal>> nutritionGoalsStream(Ref ref) {
  return ref.watch(foodsRepositoryProvider).watchNutritionGoals().map((goals) {
    return DateSequence.fromList(
      goals +
          [
            if (goals.isEmpty)
              TaggedNutritionGoal(
                date: DateTime.now().startOfDay,
                value: NutritionGoal.defaultGoal,
              ),
          ],
    );
  });
}

@riverpod
NutritionGoal nutritionGoalForDate(Ref ref, DateTime date) {
  final goalsSeq =
      ref.watch(nutritionGoalsStreamProvider).asData?.value ??
      DateSequence.fromList([
        TaggedNutritionGoal(
          date: DateTime.now().startOfDay,
          value: NutritionGoal.defaultGoal,
        ),
      ]);
  return goalsSeq[date.startOfDay];
}

@riverpod
NutritionGoal nutritionGoalForSelectedDate(Ref ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return ref.watch(nutritionGoalForDateProvider(date));
}

@riverpod
DateRange? nutritionGoalDateRange(Ref ref) {
  final goalsSeq = ref.watch(nutritionGoalsStreamProvider).asData?.value;
  if (goalsSeq == null || goalsSeq.isEmpty) return null;
  final selectedDate = ref.watch(foodSelectedDateProvider);
  final date = goalsSeq.surroundingDates(selectedDate);
  return date.copyWith(from: Some(selectedDate));
}

@riverpod
class NutritionGoalNotifier extends _$NutritionGoalNotifier {
  @override
  void build() {}

  Future<void> saveNewGoal(NutritionGoal newGoal) async {
    final selectedDate = ref.read(foodSelectedDateProvider);
    await ref
        .read(foodsRepositoryProvider)
        .addNutritionGoal(
          TaggedNutritionGoal(date: selectedDate.startOfDay, value: newGoal),
        );
    ref.read(backupSchedulerProvider).schedule();
  }
}

// -----------------------------------------------------------------------------
// Categories Providers
// -----------------------------------------------------------------------------

@riverpod
Stream<DateSequence<Map<String, NutritionCategory>>> nutritionCategoriesStream(
  Ref ref,
) {
  return ref.watch(foodsRepositoryProvider).watchNutritionCategories();
}

@riverpod
Map<String, NutritionCategory> categoriesForDate(Ref ref, DateTime date) {
  final seq = ref.watch(nutritionCategoriesStreamProvider).asData?.value;
  if (seq == null || seq.isEmpty) return {};
  return seq[date.startOfDay];
}

@riverpod
Map<String, NutritionCategory> categoriesForSelectedDate(Ref ref) {
  final date = ref.watch(foodSelectedDateProvider);
  return ref.watch(categoriesForDateProvider(date));
}

@riverpod
List<Food> unassignedFoodsForSelectedDate(Ref ref) {
  final categories = ref.watch(categoriesForSelectedDateProvider);
  final names = categories.keys.toSet();
  final foods = ref.watch(foodsForSelectedDateProvider);
  return foods
      .where((food) => food.category == null || !names.contains(food.category))
      .toList();
}

@riverpod
List<Food> foodsForCategory(
  Ref ref,
  NutritionCategory category, {
  DateTime? reference,
}) {
  final DateTime date = reference ?? ref.watch(foodSelectedDateProvider);
  final foods = ref.watch(foodsForDateProvider(date));
  return foods.where((food) => food.category == category.name).toList();
}

@riverpod
DateRange? categoriesDateRange(Ref ref) {
  final seq = ref.watch(nutritionCategoriesStreamProvider).asData?.value;
  if (seq == null || seq.isEmpty) return null;
  final date = ref.watch(foodSelectedDateProvider);
  final range = seq.surroundingDates(date);
  return range.copyWith(from: Some(date));
}

@riverpod
bool isUniqueCategoryName(Ref ref, String value) {
  final date = ref.watch(foodSelectedDateProvider);
  final categories = ref.watch(categoriesForDateProvider(date));
  return !categories.containsKey(value);
}

@riverpod
class NutritionCategoryNotifier extends _$NutritionCategoryNotifier {
  @override
  void build() {}

  Future<void> addCategory(NutritionCategory category) async {
    final date = ref.read(foodSelectedDateProvider);
    final categoriesSeq =
        ref.read(nutritionCategoriesStreamProvider).asData?.value ??
        DateSequence.empty();
    if (categoriesSeq.isNotEmpty &&
        categoriesSeq[date.startOfDay].containsKey(category.name)) {
      throw StateError("Category already exists");
    }
    await ref
        .read(foodsRepositoryProvider)
        .addNutritionCategory(date.startOfDay, category);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> removeCategory(NutritionCategory category) async {
    final date = ref.read(foodSelectedDateProvider);
    await ref
        .read(foodsRepositoryProvider)
        .removeNutritionCategory(date.startOfDay, category.name);
    ref.read(backupSchedulerProvider).schedule();
  }

  Future<void> updateCategory(
    String oldName,
    NutritionCategory category,
  ) async {
    final date = ref.read(foodSelectedDateProvider);
    await ref
        .read(foodsRepositoryProvider)
        .updateNutritionCategory(date.startOfDay, oldName, category);
    ref.read(backupSchedulerProvider).schedule();
  }
}

// -----------------------------------------------------------------------------
// Permissions Provider
// -----------------------------------------------------------------------------

@riverpod
class FoodPermissionsNotifier extends _$FoodPermissionsNotifier {
  @override
  FutureOr<FoodPermissions> build() async {
    return _getPermissions();
  }

  Future<FoodPermissions> _getPermissions() async {
    if (Platform.isMacOS) {
      return (camera: true, gallery: true);
    } else {
      Map<Permission, PermissionStatus> statuses = {
        Permission.camera: await Permission.camera.status,
        Permission.photos: await Permission.photos.status,
      };
      return (
        camera: statuses[Permission.camera]!.isGranted,
        gallery: statuses[Permission.photos]!.isGranted,
      );
    }
  }

  Future<void> recheck() async {
    state = await AsyncValue.guard(_getPermissions);
  }

  Future<void> requestPermission(Permission perm) async {
    logger.d("Requesting permission: $perm");
    try {
      final status = await perm.request();
      if (status.isGranted) {
        logger.i("Permission granted: $perm");
      } else if (status.isPermanentlyDenied) {
        logger.w("Permission permanently denied: $perm");
        openAppSettings();
      } else {
        logger.w("Permission denied: $perm");
      }

      final current = state.asData?.value ?? (camera: false, gallery: false);
      state = AsyncValue.data((
        camera: perm == Permission.camera ? status.isGranted : current.camera,
        gallery: perm == Permission.photos ? status.isGranted : current.gallery,
      ));
    } catch (e) {
      logger.e("Error requesting permission: $e");
    }
  }
}

@riverpod
bool showFoodPermissionsSettingsTile(Ref ref) {
  final perms = ref.watch(foodPermissionsProvider).asData?.value;
  if (perms == null) return false;
  return !(perms.camera && perms.gallery);
}

// -----------------------------------------------------------------------------
// OpenFoodFacts & Search
// -----------------------------------------------------------------------------

final _offSearch = RequestCache<String, List<VagueFood>>(
  const Duration(minutes: 5),
);
final _offBarcode = RequestCache<String, VagueFood?>(const Duration(hours: 24));

@riverpod
Future<List<VagueFood>> searchOpenFoodFacts(Ref ref, String query) async {
  if (query.trim().isEmpty) return [];
  globalLogger.d("Initiating OFF search for $query");
  final settingsController = ref.watch(settingsControllerProvider);
  final key =
      '${query.trim().toLowerCase()}/${settingsController.nutritionLanguage}/${settingsController.nutritionCountry}';
  return _offSearch.get(key, () async {
    final result = await searchOFF(
      query.trim(),
      language: settingsController.nutritionLanguage.offApiLanguage,
      country: settingsController.nutritionCountry.offApiCountry,
    );
    final foods = (result.products ?? [])
        .map(
          (p) => _offFoodToGTFood(
            p,
            language: settingsController.nutritionLanguage.offApiLanguage,
          ),
        )
        .toList();
    globalLogger.d("Found ${foods.length} foods for $query");
    return foods;
  });
}

/// Helper function to search OFF using API v1
Future<SearchResult> searchOFF(
  String query, {
  required OpenFoodFactsLanguage language,
  required OpenFoodFactsCountry? country,
}) async {
  final uri = Uri.https("search.openfoodfacts.org", "/search", {
    "q": "$query lang:\"${language.code}\"",
    "langs": language.code,
    "page_size": "50",
    "page": "1",
  });

  globalLogger.d("Searching OpenFoodFacts with URI: $uri");
  // final res = await Dio().getUri(uri);
  // final data = res.data as Map<String, dynamic>;

  // if (data.containsKey("hits")) {
  //   final products = data["hits"] as List<dynamic>;
  //   for (final product in products) {
  //     if (product is Map<String, dynamic>) {
  //       product.remove("packagings");
  //     }
  //   }
  // }

  // return SearchResult.fromJson(data);
  ProductSearchQueryConfiguration configuration =
      ProductSearchQueryConfiguration(
        language: language,
        country: country,
        parametersList: <Parameter>[
          SearchTerms(terms: [query]),
        ],
        version: .v3,
      );

  SearchResult result = await OpenFoodAPIClient.searchProducts(
    null,
    configuration,
  );

  return result;
}

VagueFood _offFoodToGTFood(
  Product product, {
  String? barcode,
  required OpenFoodFactsLanguage language,
}) {
  final nameBrand = product
      .getProductNameBrand(language, kNameBrandSeparator)
      .split(kNameBrandSeparator);
  final name = nameBrand.first;
  final brand = nameBrand.length > 1 && nameBrand.last.trim().isNotEmpty
      ? nameBrand.last
      : null;

  final liquidRegex = RegExp(r"(?:\d|\b)(ml|l|cl)\b");
  final isLikelyToBeLiquid =
      (product.quantity != null &&
          product.quantity!.toLowerCase().contains(liquidRegex)) ||
      (product.servingSize != null &&
          product.servingSize!.toLowerCase().contains(liquidRegex));
  final unit = isLikelyToBeLiquid ? NutritionUnit.MILLI_L : NutritionUnit.G;

  return VagueFood(
    name: name,
    brand: brand,
    servingSizes: [
      if (product.packagingQuantity != null && product.packagingQuantity! > 0)
        ServingSize(
          amount: product.packagingQuantity!,
          name:
              product.packagingTextInLanguages?[language] ??
              (product.packagingTextInLanguages?.values.toList() as List?)
                  ?.getAt(0),
        ),
      if (product.servingQuantity != null)
        ServingSize(
          amount: product.servingQuantity!,
          name: product.servingSize,
        ),
    ],
    nutritionalValuesPer100g: NutritionValues.fromOFFNutrimentsPer100g(
      product.nutriments ?? Nutriments.empty(),
    ),
    isDownloaded: true,
    unit: unit,
    barcode: barcode ?? product.barcode,
  );
}

@riverpod
Future<VagueFood?> searchOpenFoodFactsByBarcode(Ref ref, String barcode) async {
  globalLogger.d("Searching OpenFoodFacts for barcode: $barcode");
  final settingsController = ref.watch(settingsControllerProvider);
  final key =
      '$barcode/${settingsController.nutritionLanguage}/${settingsController.nutritionCountry}';
  return _offBarcode.get(key, () async {
    final product = await OpenFoodAPIClient.getProductV3(
      ProductQueryConfiguration(
        barcode,
        version: .v3,
        language: settingsController.nutritionLanguage.offApiLanguage,
        country: settingsController.nutritionCountry.offApiCountry,
      ),
    );

    if (product.product == null) {
      globalLogger.d("No product found for barcode: $barcode");
      return null;
    }
    final food = _offFoodToGTFood(
      product.product!,
      barcode: barcode,
      language: settingsController.nutritionLanguage.offApiLanguage,
    );
    globalLogger.d("Found product for barcode: $barcode -> ${food.name}");
    return food;
  });
}

// -----------------------------------------------------------------------------
// Native Sync Listener (Eager & KeepAlive)
// -----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
void foodNativeSync(Ref ref) {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: "Gym Bro/${ref.watch(versionServiceProvider).packageInfo.version}",
    version: ref.watch(versionServiceProvider).packageInfo.version,
    system: "${Platform.operatingSystem} ${Platform.operatingSystemVersion}",
  );

  final today = DateTime.now().startOfDay;
  // Observe the derived values: raw-stream callbacks can run before their
  // dependents have invalidated and would send the previous totals.
  ref.watch(foodsForDateProvider(today));
  ref.watch(nutritionGoalForDateProvider(today));
  ref.watch(categoriesForDateProvider(today));

  final now = DateTime.now();
  final midnight = Timer(
    DateTime(now.year, now.month, now.day + 1).difference(now),
    ref.invalidateSelf,
  );
  final lifecycle = AppLifecycleListener(onResume: ref.invalidateSelf);
  ref.onDispose(() {
    midnight.cancel();
    lifecycle.dispose();
  });
  _updateNativeData(ref, today);
}

void _updateNativeData(Ref ref, DateTime now) {
  globalLogger.i("Syncing food data to native services.");
  final goal = ref.read(nutritionGoalForDateProvider(now));
  final foods = ref.read(foodsForDateProvider(now));
  final categories = ref.read(categoriesForDateProvider(now));

  final foodProteinIntake = foods.fold<double>(
    0,
    (previousValue, element) =>
        previousValue + element.nutritionalValues.protein,
  );
  final foodCarbsIntake = foods.fold<double>(
    0,
    (previousValue, element) => previousValue + element.nutritionalValues.carbs,
  );
  final foodFatsIntake = foods.fold<double>(
    0,
    (previousValue, element) => previousValue + element.nutritionalValues.fat,
  );

  ref
      .read(nativeServiceProvider)
      .setFoodParameters(
        NativeFoodStateMessage(
          calorieGoal: goal.dailyCalories,
          calorieIntake: foods.fold<double>(
            0,
            (previousValue, element) =>
                previousValue + element.nutritionalValues.calories,
          ),
          categories: categories.values.map((c) {
            final foodsForCategory = foods
                .where((food) => food.category == c.name)
                .toList();

            double proteinSum = 0, carbsSum = 0, fatsSum = 0;

            for (final food in foodsForCategory) {
              proteinSum += food.nutritionalValues.protein;
              carbsSum += food.nutritionalValues.carbs;
              fatsSum += food.nutritionalValues.fat;
            }

            return NativeFoodCategory(
              name: c.name,
              emoji: c.icon.emoji,
              nutritionSplit: NativeFoodNutritionSplit(
                protein: proteinSum,
                proteinGoal: goal.dailyProtein * c.dailyPercentage / 100,
                carbs: carbsSum,
                carbsGoal: goal.dailyCarbs * c.dailyPercentage / 100,
                fats: fatsSum,
                fatsGoal: goal.dailyFat * c.dailyPercentage / 100,
              ),
            );
          }).toList(),
          totalNutritionSplit: NativeFoodNutritionSplit(
            protein: foodProteinIntake,
            proteinGoal: goal.dailyProtein,
            carbs: foodCarbsIntake,
            carbsGoal: goal.dailyCarbs,
            fats: foodFatsIntake,
            fatsGoal: goal.dailyFat,
          ),
        ),
      );
}

class _FoodEquality implements Equality<DateTagged<Food>> {
  @override
  bool equals(DateTagged<Food> e1, DateTagged<Food> e2) {
    return e1.value
        .copyWith(amount: 100, id: "")
        .equalsForSearch(e2.value.copyWith(amount: 100, id: ""));
  }

  @override
  int hash(DateTagged<Food> e) {
    return e.value.hashCodeForSearch;
  }

  @override
  bool isValidKey(Object? o) {
    return o is DateTagged<Food>;
  }
}

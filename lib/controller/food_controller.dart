import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' as utils show stringifyDouble;
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/food.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:relative_time/relative_time.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

typedef _Permissions = ({bool camera, bool gallery});

const kNameBrandSeparator = "\n\n\n\n~\n\n\n\n";

class FoodController extends GetxController with ServiceableController {
  final day$ = BehaviorSubject<DateTime>.seeded(DateTime.now().startOfDay);
  final foods$ = BehaviorSubject<List<DateTagged<Food>>>.seeded([]);
  final goals$ = BehaviorSubject<DateSequence<NutritionGoal>>.seeded(
    DateSequence.fromList([
      TaggedNutritionGoal(
        date: DateTime.now().startOfDay,
        value: NutritionGoal.defaultGoal,
      ),
    ]),
  );
  final customBarcodes$ = BehaviorSubject<Map<String, Food>>.seeded({});
  final favorites$ = BehaviorSubject<List<Food>>.seeded([]);
  final categories$ =
      BehaviorSubject<DateSequence<Map<String, NutritionCategory>>>.seeded(
          DateSequence.empty());
  final permission$ = BehaviorSubject<_Permissions>.seeded((
    camera: false,
    gallery: false,
  ));

  bool _isScanningBarcode = false;

  String get relativeDayText {
    if (day$.valueOrNull == null) return "food.title".t;

    final today = DateTime.now().startOfDay;

    var target = day$.value;
    final diff = today.difference(target.startOfDay).inDays;

    String string;
    if (diff.abs() >= 2) {
      string = DateFormat.yMEd(Get.locale?.languageCode).format(day$.value);
    } else {
      var trt = target.relativeTime(Get.context!, timeUnits: [TimeUnit.day]);
      var todayRt = today.relativeTime(Get.context!, timeUnits: [TimeUnit.day]);
      if (diff < 0 && trt == todayRt) {
        string = target
            .add(const Duration(days: 1))
            .relativeTime(Get.context!, timeUnits: [TimeUnit.day]);
      } else {
        string = trt;
      }
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  String get decimalSeparator =>
      NumberFormat.decimalPattern(Get.locale?.languageCode).symbols.DECIMAL_SEP;

  bool get canUpdateCategories {
    return day$.value.isAfterOrAtSameMomentAs(DateTime.now()
            .startOfDay) /*  &&
        foods$.value.where((food) => food.date.isSameDay(day$.value)).isEmpty */
        ;
  }

  DateTime? get firstDay => foods$.value.isEmpty
      ? null
      : (foods$.value.toList()
            ..sort((a, b) {
              return a.date.compareTo(b.date);
            }))
          .first
          .date;

  DateTime? get lastDay => foods$.value.isEmpty
      ? null
      : (foods$.value.toList()
            ..sort((a, b) {
              return b.date.compareTo(a.date);
            }))
          .first
          .date;

  final showSettingsTileStream = BehaviorSubject<bool>.seeded(true);
  material.Widget get settingsTile {
    return material.StreamBuilder(
      stream: showSettingsTileStream,
      builder: (_, snapshot) {
        final show = snapshot.data ?? true;
        if (!show) {
          return const material.SizedBox.shrink();
        }
        return material.Column(
          children: [
            if (!permission$.value.camera)
              material.ListTile(
                leading: const material.Icon(GTIcons.camera),
                title: material.Text("food.addCustomFood.permission.camera".t),
                subtitle: material.Text("settings.permissions.tapToRequest".t),
                onTap: () {
                  requestPermission(Permission.camera);
                },
              ),
            if (!permission$.value.gallery)
              material.ListTile(
                leading: const material.Icon(GTIcons.gallery),
                title: material.Text("food.addCustomFood.permission.gallery".t),
                subtitle: material.Text("settings.permissions.tapToRequest".t),
                onTap: () {
                  requestPermission(Permission.photos);
                },
              ),
          ],
        );
      },
    );
  }

  @override
  void onServiceChange() {}

  @override
  void onInit() {
    super.onInit();

    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: "appName".t,
      version: VersionService().packageInfo.version,
      system: "${Platform.operatingSystem} ${Platform.operatingSystemVersion}",
    );
    service.foods$
      ..pipe(foods$)
      ..listen((foods) {
        logger.d("Foods updated with ${foods.length} items");
        Get.find<Coordinator>()
            .maybeUnlockAchievements(AchievementTrigger.food);
      });
    service.nutritionGoals$.listen((goals) {
      logger.d("Goals updated with ${goals.length} items");
      goals$.add(DateSequence.fromList(goals +
          [
            if (goals.isEmpty)
              TaggedNutritionGoal(
                date: DateTime.now().startOfDay,
                value: NutritionGoal.defaultGoal,
              ),
          ]));
    });
    service.favoriteFoods$
      ..pipe(favorites$)
      ..listen((foods) {
        logger.d("Favorite foods updated with ${foods.length} items");
      });
    service.customBarcodeFoods$
      ..pipe(customBarcodes$)
      ..listen((foods) {
        logger.d("Custom barcode foods updated with ${foods.length} items");
      });
    service.nutritionCategories$
      ..pipe(categories$)
      ..listen((categories) {
        logger.d("Categories updated with ${categories.length} items");
      });
    permission$
        .map((t) => !(t.camera && t.gallery))
        .pipe(showSettingsTileStream);
    _getPermissions().then(permission$.add);
  }

  String getRelativeTime(DateTime date) =>
      date.relativeTime(Get.context!, timeUnits: [
        TimeUnit.day,
        TimeUnit.week,
        TimeUnit.month,
        TimeUnit.year,
      ]);

  List<DateTagged<Food>> getSuggestions(String query) {
    final uniqueChoices = EqualitySet.from(
      _FoodEquality(),
      foods$.value.reversed,
    );
    final results = extractTop<DateTagged<Food>>(
      query: query,
      choices: uniqueChoices.toList(),
      limit: 20,
      getter: (food) => "${food.value.name} ${food.value.brand ?? ""}",
    ).map((e) => e.choice).toList();
    return results;
  }

  Future<List<VagueFood>> search(String query) async {
    final completer = Completer<List<VagueFood>>();
    final terms = [/* query, */ ...query.split(" ")];
    logger.d("Initiating OFF search for $query with terms $terms");
    // final result = await OpenFoodAPIClient.searchProducts(
    //   null,
    //   ProductSearchQueryConfiguration(
    //     language: OpenFoodFactsLanguage./* ... */,
    //     country: OpenFoodFactsCountry./* ... */,
    //     parametersList: [
    //       SearchTerms(terms: terms),
    //     ],
    //     version: ProductQueryVersion.v3,
    //   ),
    // );
    final result = await searchOFF(query);
    final foods = (result.products ?? []).map(_offFoodToGTFood).toList();
    logger.d("Found ${foods.length} foods for $query");
    completer.complete(foods);
    return completer.future;
  }

  VagueFood _offFoodToGTFood(Product product, {String? barcode}) {
    final nameBrand = product
        .getProductNameBrand(
            settingsController.nutritionLanguage.value.offApiLanguage,
            kNameBrandSeparator)
        .split(kNameBrandSeparator);
    final name = nameBrand.first;
    final brand = nameBrand.length > 1 && nameBrand.last.trim().isNotEmpty
        ? nameBrand.last
        : null;

    final liquidRegex = RegExp(r"(?:\d|\b)(ml|l|cl)\b");
    final isLikelyToBeLiquid = (product.quantity != null &&
            product.quantity!.toLowerCase().contains(liquidRegex)) ||
        (product.servingSize != null &&
            product.servingSize!.toLowerCase().contains(liquidRegex));
    final unit = isLikelyToBeLiquid ? NutritionUnit.MILLI_L : NutritionUnit.G;

    logger.t((
      isLikelyToBeLiquid,
      unit,
      (
        product.quantity,
        (product.quantity ?? "").toLowerCase().contains(liquidRegex),
        product.servingSize,
        (product.servingSize ?? "").toLowerCase().contains(liquidRegex)
      )
    ));

    return VagueFood(
      name: name,
      brand: brand,
      servingSizes: [
        if (product.packagingQuantity != null && product.packagingQuantity! > 0)
          ServingSize(
            amount: product.packagingQuantity!,
            name: product.packagingTextInLanguages?[settingsController
                    .nutritionLanguage.value.offApiLanguage] ??
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

  Future<Food?> showAddFoodView(
    VagueFood food, {
    bool replaceCurrent = false,
  }) async {
    bldr() => AddFoodView(food: food, inheritAmount: food is Food);
    if (replaceCurrent) {
      return Go.off(bldr);
    } else {
      return Go.to(bldr);
    }
  }

  void showEditFoodView(Food food) async {
    final updatedFood = await Go.to(
        () => AddFoodView(food: food, isEditing: true, inheritAmount: true));
    if (updatedFood != null) {
      updateFood(
        day$.value,
        updatedFood,
      );
    }
  }

  Future<Food> showEditFoodViewForCombination(Food food) async {
    final updatedFood = await Go.to(
        () => AddFoodView(food: food, isEditing: true, inheritAmount: true));
    if (updatedFood != null) {
      return updatedFood;
    } else {
      return food;
    }
  }

  void showAddCustomFoodView({NutritionCategory? category}) {
    Go.to(() => const CustomAddFoodView()).then((value) {
      if (value != null) {
        addFood(day$.value, value, category: category);
      }
    });
  }

  Future<Food?> showAddCustomFoodViewWithBarcode(String barcode) {
    return Go.to(() => CustomAddFoodView.withBarcode(barcode: barcode));
  }

  Future<Food?> showScanBarcodeView() {
    Completer<Food?> completer = Completer();
    if (permission$.value.camera) {
      _isScanningBarcode = false;
      Go.to(() => FoodBarcodeReaderView(
            onFoodReceived: (food) {
              completer.complete(food);
            },
          ));
    } else {
      logger.w("Permission status: ${permission$.value}");
      material.showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => material.PopScope(
          canPop: false,
          child: material.SimpleDialog(
            title: material.Text("food.addCustomFood.permission.title".t),
            // contentPadding: EdgeInsets.zero,
            children: [
              if (!permission$.value.camera)
                material.ListTile(
                  leading: const material.Icon(GTIcons.camera),
                  title:
                      material.Text("food.addCustomFood.permission.camera".t),
                ),
              if (!permission$.value.gallery)
                material.ListTile(
                  leading: const material.Icon(GTIcons.gallery),
                  title:
                      material.Text("food.addCustomFood.permission.gallery".t),
                ),
              OverflowBar(
                children: [
                  material.TextButton(
                    onPressed: Get.back,
                    child: material.Text(
                        material.MaterialLocalizations.of(context)
                            .closeButtonLabel),
                  ),
                  material.TextButton(
                    child: material.Text(
                        "food.addCustomFood.permission.openAppSettings".t),
                    onPressed: () async {
                      openAppSettings();
                      completer.complete(null);
                      Get.back();
                    },
                  ),
                  material.TextButton(
                    child: material.Text(
                        "food.addCustomFood.permission.recheck".t),
                    onPressed: () async {
                      _getPermissions()
                          .then(permission$.add)
                          .then((_) => Get.back())
                          .then((_) {
                        completer.complete(showScanBarcodeView());
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return completer.future;
  }

  Future<Food?> searchFoodByBarcode(String barcode) async {
    if (_isScanningBarcode) return null;

    if (customBarcodes$.value.containsKey(barcode)) {
      final food = customBarcodes$.value[barcode]!;
      return showAddFoodView(food);
    }

    _isScanningBarcode = true;

    // Show loading dialog
    material.showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => const material.PopScope(
        canPop: false,
        child: material.Center(
          child: material.CircularProgressIndicator(),
        ),
      ),
    );

    SearchResult? result;

    try {
      result = await timeoutFuture(
        const Duration(seconds: 10),
        OpenFoodAPIClient.searchProducts(
          null,
          ProductSearchQueryConfiguration(
            language: settingsController.nutritionLanguage.value.offApiLanguage,
            country: settingsController.nutritionCountry.value.offApiCountry,
            parametersList: [
              BarcodeParameter(barcode),
            ],
            version: ProductQueryVersion.v3,
          ),
        ),
      );
    } catch (e) {
      logger.e("Error while searching for barcode $barcode: $e");
      Go.dialog(
        "food.barcodeReader.scanResult.error.title".t,
        "food.barcodeReader.scanResult.error.text".t,
      );
      return null;
    }

    Get.back();

    // Wait frame
    await Future.delayed(const Duration(milliseconds: 100));

    _isScanningBarcode = false;

    if (result == null) return null;

    if (result.products == null || result.products!.isEmpty) {
      final completer = Completer<Food?>();
      material.showDialog(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => material.PopScope(
          canPop: false,
          child: material.AlertDialog(
            title: material.Text(
                "food.barcodeReader.scanResult.noProductFound.title".t),
            content: material.Text(
                "food.barcodeReader.scanResult.noProductFound.text".tParams({
              "barcode": barcode,
            })),
            actions: [
              material.TextButton(
                onPressed: () {
                  completer.complete(null);
                  Get.back();
                },
                child: material.Text(material.MaterialLocalizations.of(context)
                    .closeButtonLabel),
              ),
              material.TextButton(
                onPressed: () {
                  Get.back();
                  showAddCustomFoodViewWithBarcode(barcode).then((value) {
                    completer.complete(value);
                  });
                },
                child: material.Text(
                    "food.barcodeReader.scanResult.noProductFound.createNew".t),
              ),
            ],
          ),
        ),
      );
      return completer.future;
    } else if (result.products!.length == 1) {
      final product = result.products!.first;
      final food = _offFoodToGTFood(product, barcode: barcode);
      return showAddFoodView(food);
    } else {
      final completer = Completer<Food?>();
      Go.to(() => SearchResultsView(
            foods: Future.value(
                result!.products!.map((e) => _offFoodToGTFood(e)).toList()),
            showAddCustom: false,
          )).then((value) {
        if (value == null) {
          completer.complete(null);
          return;
        }
        completer.complete(showAddFoodView(value));
      });
      return completer.future;
    }
  }

  void addFood(DateTime dateTime, Food food, {NutritionCategory? category}) {
    service.addFood(DateTagged(
      date: dateTime.startOfDay,
      value: food.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category?.name,
      ),
    ));
    coordinator.scheduleBackup();
  }

  void removeFood(DateTime dateTime, Food food) {
    service.removeFood(DateTagged(
      date: dateTime.startOfDay,
      value: food,
    ));
    coordinator.scheduleBackup();
  }

  void updateFood(DateTime value, Food updatedFood) {
    final dayFoods = foods$.value.where((element) => element.date == value);
    if (!dayFoods.any((element) => element.value.id == updatedFood.id)) return;

    service.updateFood(DateTagged(
      date: value,
      value: updatedFood,
    ));
    coordinator.scheduleBackup();
  }

  void previousDay() {
    day$.add(day$.value.subtract(const Duration(days: 1)));
  }

  void showDatePicker() {
    material
        .showDatePicker(
      context: Get.context!,
      initialDate: day$.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2099, 12, 31),
    )
        .then((value) {
      if (value != null) {
        day$.add(value.startOfDay);
      }
    });
  }

  void setDate(DateTime key) {
    day$.add(key);
  }

  void nextDay() {
    day$.add(day$.value.add(const Duration(days: 1)));
  }

  void showSearchResultsView(String query,
      {NutritionCategory? category}) async {
    final future = search(query);
    final food =
        await Go.to<VagueFood?>(() => SearchResultsView(foods: future));
    if (food != null) {
      showAddFoodView(food).then((value) {
        if (value != null) {
          addFood(day$.value, value, category: category);
        }
      });
    }
  }

  Future<Food?> showSearchResultsViewForCombination(String query) async {
    final future = search(query);
    final food =
        await Go.to<VagueFood?>(() => SearchResultsView(foods: future));
    if (food != null) {
      return showAddFoodView(food);
    }
  }

  Future<_Permissions> _getPermissions() async {
    if (Platform.isMacOS) {
      // On MacOS, we can't use the camera
      // who cares, it's the debug os anyway
      return (camera: true, gallery: true);
      // return (camera: false, gallery: false);
    } else {
      Map<Permission, PermissionStatus> statuses = {
        Permission.camera: await Permission.camera.status,
        Permission.photos: await Permission.photos.status,
      };

      final camera = statuses[Permission.camera]!.isGranted;
      final gallery = statuses[Permission.photos]!.isGranted;

      return (camera: camera, gallery: gallery);
    }
  }

  NutritionGoal getGoal() {
    final date = day$.value.startOfDay;
    final goals = goals$.value;
    return goals[date];
  }

  Map<String, NutritionCategory> getCategories() {
    final date = day$.value.startOfDay;
    final categories = categories$.value;
    if (categories.isEmpty) return {};
    return categories[date];
  }

  bool canOpenOffPage(VagueFood food) => food.url != null;
  void openOffPage(VagueFood food) {
    final url = food.url;
    if (!canOpenOffPage(food)) return;

    launchUrl(Uri.parse(url!));
  }

  Future<void> requestPermission(Permission perm) async {
    final status = await perm.request();
    if (status.isGranted) {
      logger.i("Permission granted: $perm");
    } else if (status.isPermanentlyDenied) {
      logger.w("Permission permanently denied: $perm");
      openAppSettings();
    } else {
      logger.w("Permission denied: $perm");
    }

    permission$.add((
      camera: perm == Permission.camera
          ? status.isGranted
          : permission$.value.camera,
      gallery: perm == Permission.photos
          ? status.isGranted
          : permission$.value.gallery,
    ));
  }

  void showNutritionGoalView() {
    Go.to(() => const ChangeGoalScreen());
  }

  DateRange? getDateRange() {
    if (goals$.value.isEmpty) return null;
    final date = goals$.value.surroundingDates(day$.value);
    return date.copyWith(
      from: Some(day$.value),
    );
  }

  DateRange? getDateRangeForCategories() {
    if (categories$.value.isEmpty) return null;
    final date = categories$.value.surroundingDates(day$.value);
    return date.copyWith(
      from: Some(day$.value),
    );
  }

  void saveNewGoal(NutritionGoal newGoal) {
    service.addNutritionGoal(TaggedNutritionGoal(
      date: day$.value.startOfDay,
      value: newGoal,
    ));
    coordinator.scheduleBackup();
  }

  void showGoalHistory() {
    Go.to(() => const GoalHistoryView());
  }

  String stringifyDouble(double value) {
    return utils.stringifyDouble(value, decimalSeparator: decimalSeparator);
  }

  String formatDate(DateTime key) {
    return DateFormat.yMEd(Get.locale?.languageCode).format(key);
  }

  void removeFavorite(Food food) {
    service.removeFavoriteFood(food);
    coordinator.scheduleBackup();
  }

  void addFavorite(Food food) {
    service.addFavoriteFood(food);
    coordinator.scheduleBackup();
  }

  bool isFavorite(Food food) {
    return Set.from(favorites$.value.map((f) => f.id)).contains(food.id);
  }

  void addCustomBarcodeFood(String s, Food food) {
    service.addCustomBarcodeFood(s, food);
  }

  Future<Food?> showCombineFoodsView() {
    return Go.to(() => const AddCombinedFoodView());
  }

  void copyToToday(Food food) {
    final today = DateTime.now().startOfDay;
    final foodCopy = food.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    addFood(today, foodCopy);
    Get.back();
    setDate(today);
  }

  void addCategory(NutritionCategory category) {
    final date = day$.value;
    if (categories$.value.isNotEmpty &&
        categories$.value[date.startOfDay].containsKey(category.name)) {
      throw StateError("Category already exists");
    }
    service.setNutritionCategoriesForDay(
      date.startOfDay,
      {
        ...(categories$.value.isEmpty
            ? {}
            : categories$.value[date.startOfDay]),
        category.name: category
      },
    );
    coordinator.scheduleBackup();
  }

  void removeCategory(NutritionCategory category) {
    final date = day$.value;
    service.setNutritionCategoriesForDay(
      date.startOfDay,
      {
        for (final entry in categories$.value[date.startOfDay].entries)
          if (entry.key != category.name) entry.key: entry.value
      },
    );
    coordinator.scheduleBackup();
  }

  Future<NutritionCategory?> showAddCategoryView() {
    return Go.to(() => const FoodCategoryEditorView.clean());
  }

  bool isUniqueCategoryName(String value) {
    if (categories$.value.isEmpty) return true;
    return !categories$.value[day$.value.startOfDay].containsKey(value);
  }

  Future<void> editCategory(String oldName, NutritionCategory category) async {
    final cat = await Go.to(() => FoodCategoryEditorView.edit(category));
    if (cat != null) {
      final date = day$.value;
      service.setNutritionCategoriesForDay(
        date.startOfDay,
        {
          for (final entry in categories$.value[date.startOfDay].entries)
            if (entry.key != oldName) entry.key: entry.value else cat.name: cat
        },
      );
    }
  }

  List<Food> getFoodsForCategory(NutritionCategory category) {
    return getFoods().where((food) => food.category == category.name).toList();
  }

  List<Food> getUnassignedFoods() {
    final categories = getCategories();
    final names = categories.keys.toSet();
    return getFoods()
        .where(
            (food) => food.category == null || !names.contains(food.category))
        .toList();
  }

  Iterable<Food> getFoods() {
    return foods$.value
        .where((element) => element.date.isSameDay(day$.value))
        .map((e) => e.value);
  }

  void showCategoryFoodsView(NutritionCategory category) {
    Go.to(() => FoodCategoryFoodsView(category: category));
  }

  List<DateTagged<Food>> getFoodsForDay(DateTime day) {
    return foods$.value
        .where((element) => element.date.isSameDay(day))
        .toList();
  }
}

/// Search for a product on OpenFoodFacts using the
/// v1 API in order to use full text queries.
Future<SearchResult> searchOFF(
  String query, {
  OpenFoodFactsLanguage? language,
  OpenFoodFactsCountry? country,
}) async {
  language ??= settingsController.nutritionLanguage.value.offApiLanguage;
  country ??= settingsController.nutritionCountry.value.offApiCountry;

  final uri = Uri.https(
    "world.openfoodfacts.org",
    "/cgi/search.pl",
    {
      "search_terms": query,
      "search_simple": "1",
      "action": "process",
      "json": "1",
      "cc": country?.offTag,
      "lc": language.code,
    },
  );

  final res = await Dio().getUri(uri);

  /* {"count":0,"page":1,"page_count":0,"page_size":50,"products":[],"skip":0} */
  final data = res.data as Map<String, dynamic>;

  // Fix errors caused by the use of API v1
  // Remove 'packagings' key from all products
  if (data.containsKey("products")) {
    final products = data["products"] as List<dynamic>;
    for (final product in products) {
      if (product is Map<String, dynamic>) {
        product.remove("packagings");
      }
    }
  }

  return SearchResult.fromJson(data);
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

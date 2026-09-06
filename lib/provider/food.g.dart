// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FoodSelectedDate)
final foodSelectedDateProvider = FoodSelectedDateProvider._();

final class FoodSelectedDateProvider
    extends $NotifierProvider<FoodSelectedDate, DateTime> {
  FoodSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSelectedDateHash();

  @$internal
  @override
  FoodSelectedDate create() => FoodSelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$foodSelectedDateHash() => r'4052508a9c1bc8761572bba52724f1fbb82940a2';

abstract class _$FoodSelectedDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(foodRelativeDayText)
final foodRelativeDayTextProvider = FoodRelativeDayTextFamily._();

final class FoodRelativeDayTextProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  FoodRelativeDayTextProvider._({
    required FoodRelativeDayTextFamily super.from,
    required BuildContext super.argument,
  }) : super(
         retry: null,
         name: r'foodRelativeDayTextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodRelativeDayTextHash();

  @override
  String toString() {
    return r'foodRelativeDayTextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as BuildContext;
    return foodRelativeDayText(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FoodRelativeDayTextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodRelativeDayTextHash() =>
    r'28e8262d32c0bf2c9d1c1d01c5a4ccf2e92d7907';

final class FoodRelativeDayTextFamily extends $Family
    with $FunctionalFamilyOverride<String, BuildContext> {
  FoodRelativeDayTextFamily._()
    : super(
        retry: null,
        name: r'foodRelativeDayTextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FoodRelativeDayTextProvider call(BuildContext context) =>
      FoodRelativeDayTextProvider._(argument: context, from: this);

  @override
  String toString() => r'foodRelativeDayTextProvider';
}

@ProviderFor(foodCanUpdateCategories)
final foodCanUpdateCategoriesProvider = FoodCanUpdateCategoriesProvider._();

final class FoodCanUpdateCategoriesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  FoodCanUpdateCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodCanUpdateCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodCanUpdateCategoriesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return foodCanUpdateCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$foodCanUpdateCategoriesHash() =>
    r'41590801d88583035b314fc6f9a905dd8d4520c9';

@ProviderFor(foodLogsStream)
final foodLogsStreamProvider = FoodLogsStreamProvider._();

final class FoodLogsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DateTagged<Food>>>,
          List<DateTagged<Food>>,
          Stream<List<DateTagged<Food>>>
        >
    with
        $FutureModifier<List<DateTagged<Food>>>,
        $StreamProvider<List<DateTagged<Food>>> {
  FoodLogsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodLogsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodLogsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<DateTagged<Food>>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DateTagged<Food>>> create(Ref ref) {
    return foodLogsStream(ref);
  }
}

String _$foodLogsStreamHash() => r'6f4a8b050a020b76ce15c7d6cf38048458f25e33';

@ProviderFor(foodsForDate)
final foodsForDateProvider = FoodsForDateFamily._();

final class FoodsForDateProvider
    extends $FunctionalProvider<List<Food>, List<Food>, List<Food>>
    with $Provider<List<Food>> {
  FoodsForDateProvider._({
    required FoodsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'foodsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodsForDateHash();

  @override
  String toString() {
    return r'foodsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Food> create(Ref ref) {
    final argument = this.argument as DateTime;
    return foodsForDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Food> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Food>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FoodsForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodsForDateHash() => r'2068c4f836f3894769518a4066ba25ef8382ce0d';

final class FoodsForDateFamily extends $Family
    with $FunctionalFamilyOverride<List<Food>, DateTime> {
  FoodsForDateFamily._()
    : super(
        retry: null,
        name: r'foodsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FoodsForDateProvider call(DateTime date) =>
      FoodsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'foodsForDateProvider';
}

@ProviderFor(taggedFoodsForDate)
final taggedFoodsForDateProvider = TaggedFoodsForDateFamily._();

final class TaggedFoodsForDateProvider
    extends
        $FunctionalProvider<
          List<DateTagged<Food>>,
          List<DateTagged<Food>>,
          List<DateTagged<Food>>
        >
    with $Provider<List<DateTagged<Food>>> {
  TaggedFoodsForDateProvider._({
    required TaggedFoodsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'taggedFoodsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taggedFoodsForDateHash();

  @override
  String toString() {
    return r'taggedFoodsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<DateTagged<Food>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DateTagged<Food>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return taggedFoodsForDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTagged<Food>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTagged<Food>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaggedFoodsForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taggedFoodsForDateHash() =>
    r'0a7b64de66baed5a7c19fd8ac7255369246f3ab0';

final class TaggedFoodsForDateFamily extends $Family
    with $FunctionalFamilyOverride<List<DateTagged<Food>>, DateTime> {
  TaggedFoodsForDateFamily._()
    : super(
        retry: null,
        name: r'taggedFoodsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaggedFoodsForDateProvider call(DateTime date) =>
      TaggedFoodsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'taggedFoodsForDateProvider';
}

@ProviderFor(foodsForSelectedDate)
final foodsForSelectedDateProvider = FoodsForSelectedDateProvider._();

final class FoodsForSelectedDateProvider
    extends $FunctionalProvider<List<Food>, List<Food>, List<Food>>
    with $Provider<List<Food>> {
  FoodsForSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodsForSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodsForSelectedDateHash();

  @$internal
  @override
  $ProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Food> create(Ref ref) {
    return foodsForSelectedDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Food> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Food>>(value),
    );
  }
}

String _$foodsForSelectedDateHash() =>
    r'310bbd82f0bd235f398fffb4ded0e9a285ac9599';

@ProviderFor(taggedFoodsForSelectedDate)
final taggedFoodsForSelectedDateProvider =
    TaggedFoodsForSelectedDateProvider._();

final class TaggedFoodsForSelectedDateProvider
    extends
        $FunctionalProvider<
          List<DateTagged<Food>>,
          List<DateTagged<Food>>,
          List<DateTagged<Food>>
        >
    with $Provider<List<DateTagged<Food>>> {
  TaggedFoodsForSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taggedFoodsForSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taggedFoodsForSelectedDateHash();

  @$internal
  @override
  $ProviderElement<List<DateTagged<Food>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DateTagged<Food>> create(Ref ref) {
    return taggedFoodsForSelectedDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTagged<Food>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTagged<Food>>>(value),
    );
  }
}

String _$taggedFoodsForSelectedDateHash() =>
    r'e6f9c70eaff3ab504050cde0869e8f34525d0482';

@ProviderFor(favoriteFoodsStream)
final favoriteFoodsStreamProvider = FavoriteFoodsStreamProvider._();

final class FavoriteFoodsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Food>>,
          List<Food>,
          Stream<List<Food>>
        >
    with $FutureModifier<List<Food>>, $StreamProvider<List<Food>> {
  FavoriteFoodsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteFoodsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteFoodsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Food>> create(Ref ref) {
    return favoriteFoodsStream(ref);
  }
}

String _$favoriteFoodsStreamHash() =>
    r'b458c79cd3930b9e57080a574afb06e92794293f';

@ProviderFor(customBarcodeFoodsStream)
final customBarcodeFoodsStreamProvider = CustomBarcodeFoodsStreamProvider._();

final class CustomBarcodeFoodsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Food>>,
          Map<String, Food>,
          Stream<Map<String, Food>>
        >
    with
        $FutureModifier<Map<String, Food>>,
        $StreamProvider<Map<String, Food>> {
  CustomBarcodeFoodsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customBarcodeFoodsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customBarcodeFoodsStreamHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Food>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Food>> create(Ref ref) {
    return customBarcodeFoodsStream(ref);
  }
}

String _$customBarcodeFoodsStreamHash() =>
    r'5314f7c172877fe5b59b8063f2d846962013fe04';

@ProviderFor(foodSuggestions)
final foodSuggestionsProvider = FoodSuggestionsFamily._();

final class FoodSuggestionsProvider
    extends
        $FunctionalProvider<
          List<DateTagged<Food>>,
          List<DateTagged<Food>>,
          List<DateTagged<Food>>
        >
    with $Provider<List<DateTagged<Food>>> {
  FoodSuggestionsProvider._({
    required FoodSuggestionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'foodSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodSuggestionsHash();

  @override
  String toString() {
    return r'foodSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<DateTagged<Food>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DateTagged<Food>> create(Ref ref) {
    final argument = this.argument as String;
    return foodSuggestions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTagged<Food>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTagged<Food>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FoodSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodSuggestionsHash() => r'baf00dade704a1edb838b906cc8b3e337e1f0bfe';

final class FoodSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<List<DateTagged<Food>>, String> {
  FoodSuggestionsFamily._()
    : super(
        retry: null,
        name: r'foodSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FoodSuggestionsProvider call(String query) =>
      FoodSuggestionsProvider._(argument: query, from: this);

  @override
  String toString() => r'foodSuggestionsProvider';
}

@ProviderFor(FoodNotifier)
final foodProvider = FoodNotifierProvider._();

final class FoodNotifierProvider extends $NotifierProvider<FoodNotifier, void> {
  FoodNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodNotifierHash();

  @$internal
  @override
  FoodNotifier create() => FoodNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$foodNotifierHash() => r'50a97b91e893350f8a0ca819271be9cd9dffb78e';

abstract class _$FoodNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(nutritionGoalsStream)
final nutritionGoalsStreamProvider = NutritionGoalsStreamProvider._();

final class NutritionGoalsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateSequence<NutritionGoal>>,
          DateSequence<NutritionGoal>,
          Stream<DateSequence<NutritionGoal>>
        >
    with
        $FutureModifier<DateSequence<NutritionGoal>>,
        $StreamProvider<DateSequence<NutritionGoal>> {
  NutritionGoalsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalsStreamHash();

  @$internal
  @override
  $StreamProviderElement<DateSequence<NutritionGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DateSequence<NutritionGoal>> create(Ref ref) {
    return nutritionGoalsStream(ref);
  }
}

String _$nutritionGoalsStreamHash() =>
    r'd7bc1ab72fe64ddfdd40617d54eade39f7111d73';

@ProviderFor(nutritionGoalForDate)
final nutritionGoalForDateProvider = NutritionGoalForDateFamily._();

final class NutritionGoalForDateProvider
    extends $FunctionalProvider<NutritionGoal, NutritionGoal, NutritionGoal>
    with $Provider<NutritionGoal> {
  NutritionGoalForDateProvider._({
    required NutritionGoalForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'nutritionGoalForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalForDateHash();

  @override
  String toString() {
    return r'nutritionGoalForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<NutritionGoal> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NutritionGoal create(Ref ref) {
    final argument = this.argument as DateTime;
    return nutritionGoalForDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionGoal value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionGoal>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionGoalForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nutritionGoalForDateHash() =>
    r'bb9f547789eb9e1e7776a7070ef91da4dc4b1c62';

final class NutritionGoalForDateFamily extends $Family
    with $FunctionalFamilyOverride<NutritionGoal, DateTime> {
  NutritionGoalForDateFamily._()
    : super(
        retry: null,
        name: r'nutritionGoalForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NutritionGoalForDateProvider call(DateTime date) =>
      NutritionGoalForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'nutritionGoalForDateProvider';
}

@ProviderFor(nutritionGoalForSelectedDate)
final nutritionGoalForSelectedDateProvider =
    NutritionGoalForSelectedDateProvider._();

final class NutritionGoalForSelectedDateProvider
    extends $FunctionalProvider<NutritionGoal, NutritionGoal, NutritionGoal>
    with $Provider<NutritionGoal> {
  NutritionGoalForSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalForSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalForSelectedDateHash();

  @$internal
  @override
  $ProviderElement<NutritionGoal> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NutritionGoal create(Ref ref) {
    return nutritionGoalForSelectedDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NutritionGoal value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NutritionGoal>(value),
    );
  }
}

String _$nutritionGoalForSelectedDateHash() =>
    r'2569ac93a13de61eada53c3c0cc9963891078004';

@ProviderFor(nutritionGoalDateRange)
final nutritionGoalDateRangeProvider = NutritionGoalDateRangeProvider._();

final class NutritionGoalDateRangeProvider
    extends $FunctionalProvider<DateRange?, DateRange?, DateRange?>
    with $Provider<DateRange?> {
  NutritionGoalDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalDateRangeHash();

  @$internal
  @override
  $ProviderElement<DateRange?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateRange? create(Ref ref) {
    return nutritionGoalDateRange(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRange? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRange?>(value),
    );
  }
}

String _$nutritionGoalDateRangeHash() =>
    r'ed33c504cc42f9dbe6b6ce61f2568d2d3777a950';

@ProviderFor(NutritionGoalNotifier)
final nutritionGoalProvider = NutritionGoalNotifierProvider._();

final class NutritionGoalNotifierProvider
    extends $NotifierProvider<NutritionGoalNotifier, void> {
  NutritionGoalNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionGoalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionGoalNotifierHash();

  @$internal
  @override
  NutritionGoalNotifier create() => NutritionGoalNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$nutritionGoalNotifierHash() =>
    r'561d21951c908e43fe44c03ee0c6a2b67ffc611a';

abstract class _$NutritionGoalNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(nutritionCategoriesStream)
final nutritionCategoriesStreamProvider = NutritionCategoriesStreamProvider._();

final class NutritionCategoriesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateSequence<Map<String, NutritionCategory>>>,
          DateSequence<Map<String, NutritionCategory>>,
          Stream<DateSequence<Map<String, NutritionCategory>>>
        >
    with
        $FutureModifier<DateSequence<Map<String, NutritionCategory>>>,
        $StreamProvider<DateSequence<Map<String, NutritionCategory>>> {
  NutritionCategoriesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionCategoriesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionCategoriesStreamHash();

  @$internal
  @override
  $StreamProviderElement<DateSequence<Map<String, NutritionCategory>>>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<DateSequence<Map<String, NutritionCategory>>> create(Ref ref) {
    return nutritionCategoriesStream(ref);
  }
}

String _$nutritionCategoriesStreamHash() =>
    r'5764482af5a4238632084a3279f92632c2e2ef3f';

@ProviderFor(categoriesForDate)
final categoriesForDateProvider = CategoriesForDateFamily._();

final class CategoriesForDateProvider
    extends
        $FunctionalProvider<
          Map<String, NutritionCategory>,
          Map<String, NutritionCategory>,
          Map<String, NutritionCategory>
        >
    with $Provider<Map<String, NutritionCategory>> {
  CategoriesForDateProvider._({
    required CategoriesForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'categoriesForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesForDateHash();

  @override
  String toString() {
    return r'categoriesForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, NutritionCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, NutritionCategory> create(Ref ref) {
    final argument = this.argument as DateTime;
    return categoriesForDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, NutritionCategory> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, NutritionCategory>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesForDateHash() => r'1af58afe6681cca7be2aba90344cbf14fd2f06af';

final class CategoriesForDateFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, NutritionCategory>, DateTime> {
  CategoriesForDateFamily._()
    : super(
        retry: null,
        name: r'categoriesForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoriesForDateProvider call(DateTime date) =>
      CategoriesForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'categoriesForDateProvider';
}

@ProviderFor(categoriesForSelectedDate)
final categoriesForSelectedDateProvider = CategoriesForSelectedDateProvider._();

final class CategoriesForSelectedDateProvider
    extends
        $FunctionalProvider<
          Map<String, NutritionCategory>,
          Map<String, NutritionCategory>,
          Map<String, NutritionCategory>
        >
    with $Provider<Map<String, NutritionCategory>> {
  CategoriesForSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesForSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesForSelectedDateHash();

  @$internal
  @override
  $ProviderElement<Map<String, NutritionCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, NutritionCategory> create(Ref ref) {
    return categoriesForSelectedDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, NutritionCategory> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, NutritionCategory>>(
        value,
      ),
    );
  }
}

String _$categoriesForSelectedDateHash() =>
    r'decf030febe332f87650c1728b8ec6217d7fc4a0';

@ProviderFor(unassignedFoodsForSelectedDate)
final unassignedFoodsForSelectedDateProvider =
    UnassignedFoodsForSelectedDateProvider._();

final class UnassignedFoodsForSelectedDateProvider
    extends $FunctionalProvider<List<Food>, List<Food>, List<Food>>
    with $Provider<List<Food>> {
  UnassignedFoodsForSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unassignedFoodsForSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unassignedFoodsForSelectedDateHash();

  @$internal
  @override
  $ProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Food> create(Ref ref) {
    return unassignedFoodsForSelectedDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Food> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Food>>(value),
    );
  }
}

String _$unassignedFoodsForSelectedDateHash() =>
    r'326124df57e0c850359eb9db2e505ff74e0e6b7e';

@ProviderFor(foodsForCategory)
final foodsForCategoryProvider = FoodsForCategoryFamily._();

final class FoodsForCategoryProvider
    extends $FunctionalProvider<List<Food>, List<Food>, List<Food>>
    with $Provider<List<Food>> {
  FoodsForCategoryProvider._({
    required FoodsForCategoryFamily super.from,
    required (NutritionCategory, {DateTime? reference}) super.argument,
  }) : super(
         retry: null,
         name: r'foodsForCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodsForCategoryHash();

  @override
  String toString() {
    return r'foodsForCategoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<Food>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Food> create(Ref ref) {
    final argument =
        this.argument as (NutritionCategory, {DateTime? reference});
    return foodsForCategory(ref, argument.$1, reference: argument.reference);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Food> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Food>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FoodsForCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodsForCategoryHash() => r'66fb988b63cc9620faed2256bd539887c08dc091';

final class FoodsForCategoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<Food>,
          (NutritionCategory, {DateTime? reference})
        > {
  FoodsForCategoryFamily._()
    : super(
        retry: null,
        name: r'foodsForCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FoodsForCategoryProvider call(
    NutritionCategory category, {
    DateTime? reference,
  }) => FoodsForCategoryProvider._(
    argument: (category, reference: reference),
    from: this,
  );

  @override
  String toString() => r'foodsForCategoryProvider';
}

@ProviderFor(categoriesDateRange)
final categoriesDateRangeProvider = CategoriesDateRangeProvider._();

final class CategoriesDateRangeProvider
    extends $FunctionalProvider<DateRange?, DateRange?, DateRange?>
    with $Provider<DateRange?> {
  CategoriesDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesDateRangeHash();

  @$internal
  @override
  $ProviderElement<DateRange?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateRange? create(Ref ref) {
    return categoriesDateRange(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRange? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRange?>(value),
    );
  }
}

String _$categoriesDateRangeHash() =>
    r'79eee983cbb8eb369720ff64c4681c360012a6aa';

@ProviderFor(isUniqueCategoryName)
final isUniqueCategoryNameProvider = IsUniqueCategoryNameFamily._();

final class IsUniqueCategoryNameProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsUniqueCategoryNameProvider._({
    required IsUniqueCategoryNameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isUniqueCategoryNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isUniqueCategoryNameHash();

  @override
  String toString() {
    return r'isUniqueCategoryNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isUniqueCategoryName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsUniqueCategoryNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isUniqueCategoryNameHash() =>
    r'69eae1d22d33684341ffafd26fe9f5ccc99d0c1f';

final class IsUniqueCategoryNameFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsUniqueCategoryNameFamily._()
    : super(
        retry: null,
        name: r'isUniqueCategoryNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsUniqueCategoryNameProvider call(String value) =>
      IsUniqueCategoryNameProvider._(argument: value, from: this);

  @override
  String toString() => r'isUniqueCategoryNameProvider';
}

@ProviderFor(NutritionCategoryNotifier)
final nutritionCategoryProvider = NutritionCategoryNotifierProvider._();

final class NutritionCategoryNotifierProvider
    extends $NotifierProvider<NutritionCategoryNotifier, void> {
  NutritionCategoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nutritionCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nutritionCategoryNotifierHash();

  @$internal
  @override
  NutritionCategoryNotifier create() => NutritionCategoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$nutritionCategoryNotifierHash() =>
    r'3a7b874b365af41a2e665ffaf3e6e901c4a31bb2';

abstract class _$NutritionCategoryNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FoodPermissionsNotifier)
final foodPermissionsProvider = FoodPermissionsNotifierProvider._();

final class FoodPermissionsNotifierProvider
    extends $AsyncNotifierProvider<FoodPermissionsNotifier, FoodPermissions> {
  FoodPermissionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodPermissionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodPermissionsNotifierHash();

  @$internal
  @override
  FoodPermissionsNotifier create() => FoodPermissionsNotifier();
}

String _$foodPermissionsNotifierHash() =>
    r'737ae1c14e5d8d85d6cc4ed68cfe1c4f6813e690';

abstract class _$FoodPermissionsNotifier
    extends $AsyncNotifier<FoodPermissions> {
  FutureOr<FoodPermissions> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FoodPermissions>, FoodPermissions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FoodPermissions>, FoodPermissions>,
              AsyncValue<FoodPermissions>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(showFoodPermissionsSettingsTile)
final showFoodPermissionsSettingsTileProvider =
    ShowFoodPermissionsSettingsTileProvider._();

final class ShowFoodPermissionsSettingsTileProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  ShowFoodPermissionsSettingsTileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showFoodPermissionsSettingsTileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showFoodPermissionsSettingsTileHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return showFoodPermissionsSettingsTile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showFoodPermissionsSettingsTileHash() =>
    r'9d26a7300470f72b717284d2e95b75ae6af97499';

@ProviderFor(searchOpenFoodFacts)
final searchOpenFoodFactsProvider = SearchOpenFoodFactsFamily._();

final class SearchOpenFoodFactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VagueFood>>,
          List<VagueFood>,
          FutureOr<List<VagueFood>>
        >
    with $FutureModifier<List<VagueFood>>, $FutureProvider<List<VagueFood>> {
  SearchOpenFoodFactsProvider._({
    required SearchOpenFoodFactsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchOpenFoodFactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchOpenFoodFactsHash();

  @override
  String toString() {
    return r'searchOpenFoodFactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VagueFood>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VagueFood>> create(Ref ref) {
    final argument = this.argument as String;
    return searchOpenFoodFacts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchOpenFoodFactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchOpenFoodFactsHash() =>
    r'ad3dd398cff9b9a5526856d7490d40c94619cce8';

final class SearchOpenFoodFactsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VagueFood>>, String> {
  SearchOpenFoodFactsFamily._()
    : super(
        retry: null,
        name: r'searchOpenFoodFactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchOpenFoodFactsProvider call(String query) =>
      SearchOpenFoodFactsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchOpenFoodFactsProvider';
}

@ProviderFor(searchOpenFoodFactsByBarcode)
final searchOpenFoodFactsByBarcodeProvider =
    SearchOpenFoodFactsByBarcodeFamily._();

final class SearchOpenFoodFactsByBarcodeProvider
    extends
        $FunctionalProvider<
          AsyncValue<VagueFood?>,
          VagueFood?,
          FutureOr<VagueFood?>
        >
    with $FutureModifier<VagueFood?>, $FutureProvider<VagueFood?> {
  SearchOpenFoodFactsByBarcodeProvider._({
    required SearchOpenFoodFactsByBarcodeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchOpenFoodFactsByBarcodeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchOpenFoodFactsByBarcodeHash();

  @override
  String toString() {
    return r'searchOpenFoodFactsByBarcodeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VagueFood?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VagueFood?> create(Ref ref) {
    final argument = this.argument as String;
    return searchOpenFoodFactsByBarcode(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchOpenFoodFactsByBarcodeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchOpenFoodFactsByBarcodeHash() =>
    r'792e4030ed0d138dd669ad65767c46cf3b39431c';

final class SearchOpenFoodFactsByBarcodeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VagueFood?>, String> {
  SearchOpenFoodFactsByBarcodeFamily._()
    : super(
        retry: null,
        name: r'searchOpenFoodFactsByBarcodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchOpenFoodFactsByBarcodeProvider call(String barcode) =>
      SearchOpenFoodFactsByBarcodeProvider._(argument: barcode, from: this);

  @override
  String toString() => r'searchOpenFoodFactsByBarcodeProvider';
}

@ProviderFor(foodNativeSync)
final foodNativeSyncProvider = FoodNativeSyncProvider._();

final class FoodNativeSyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  FoodNativeSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodNativeSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodNativeSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return foodNativeSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$foodNativeSyncHash() => r'4dca5be5aabc7abe08a9e21ad1f5d061966a8ae9';

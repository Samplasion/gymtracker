// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(achievementCatalog)
final achievementCatalogProvider = AchievementCatalogProvider._();

final class AchievementCatalogProvider
    extends
        $FunctionalProvider<
          Map<String, Achievement>,
          Map<String, Achievement>,
          Map<String, Achievement>
        >
    with $Provider<Map<String, Achievement>> {
  AchievementCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementCatalogHash();

  @$internal
  @override
  $ProviderElement<Map<String, Achievement>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Achievement> create(Ref ref) {
    return achievementCatalog(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Achievement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Achievement>>(value),
    );
  }
}

String _$achievementCatalogHash() =>
    r'fbc06e496d02122992d40c2db8c83bcbd1080ad0';

@ProviderFor(achievementsController)
final achievementsControllerProvider = AchievementsControllerProvider._();

final class AchievementsControllerProvider
    extends
        $FunctionalProvider<
          AchievementsController,
          AchievementsController,
          AchievementsController
        >
    with $Provider<AchievementsController> {
  AchievementsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementsControllerHash();

  @$internal
  @override
  $ProviderElement<AchievementsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AchievementsController create(Ref ref) {
    return achievementsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementsController>(value),
    );
  }
}

String _$achievementsControllerHash() =>
    r'4fc767f8605fb8e0cbf0af9ed52ebe8dafd5be7c';

@ProviderFor(achievementTrigger)
final achievementTriggerProvider = AchievementTriggerProvider._();

final class AchievementTriggerProvider
    extends
        $FunctionalProvider<
          void Function(AchievementTrigger),
          void Function(AchievementTrigger),
          void Function(AchievementTrigger)
        >
    with $Provider<void Function(AchievementTrigger)> {
  AchievementTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementTriggerHash();

  @$internal
  @override
  $ProviderElement<void Function(AchievementTrigger)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  void Function(AchievementTrigger) create(Ref ref) {
    return achievementTrigger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void Function(AchievementTrigger) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void Function(AchievementTrigger)>(
        value,
      ),
    );
  }
}

String _$achievementTriggerHash() =>
    r'502131625519b219fe0e94629ce5ee5cd0b1b602';

@ProviderFor(achievementCompletions)
final achievementCompletionsProvider = AchievementCompletionsProvider._();

final class AchievementCompletionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementCompletion>>,
          List<AchievementCompletion>,
          Stream<List<AchievementCompletion>>
        >
    with
        $FutureModifier<List<AchievementCompletion>>,
        $StreamProvider<List<AchievementCompletion>> {
  AchievementCompletionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementCompletionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementCompletionsHash();

  @$internal
  @override
  $StreamProviderElement<List<AchievementCompletion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AchievementCompletion>> create(Ref ref) {
    return achievementCompletions(ref);
  }
}

String _$achievementCompletionsHash() =>
    r'29ae7c6d4dd24e91106593e7170e5d2acf9c05ea';

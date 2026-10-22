// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(historyWorkouts)
final historyWorkoutsProvider = HistoryWorkoutsProvider._();

final class HistoryWorkoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workout>>,
          List<Workout>,
          Stream<List<Workout>>
        >
    with $FutureModifier<List<Workout>>, $StreamProvider<List<Workout>> {
  HistoryWorkoutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyWorkoutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyWorkoutsHash();

  @$internal
  @override
  $StreamProviderElement<List<Workout>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Workout>> create(Ref ref) {
    return historyWorkouts(ref);
  }
}

String _$historyWorkoutsHash() => r'c02e0f30cd6572442daea4215c426c0c563f55e2';

@ProviderFor(customExercises)
final customExercisesProvider = CustomExercisesProvider._();

final class CustomExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          Stream<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $StreamProvider<List<Exercise>> {
  CustomExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customExercisesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customExercisesHash();

  @$internal
  @override
  $StreamProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Exercise>> create(Ref ref) {
    return customExercises(ref);
  }
}

String _$customExercisesHash() => r'b57b615943b539bacf26153c328a6037a6c582af';

@ProviderFor(routineSuggestions)
final routineSuggestionsProvider = RoutineSuggestionsProvider._();

final class RoutineSuggestionsProvider
    extends
        $FunctionalProvider<
          List<RoutineSuggestion>,
          List<RoutineSuggestion>,
          List<RoutineSuggestion>
        >
    with $Provider<List<RoutineSuggestion>> {
  RoutineSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineSuggestionsHash();

  @$internal
  @override
  $ProviderElement<List<RoutineSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<RoutineSuggestion> create(Ref ref) {
    return routineSuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RoutineSuggestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RoutineSuggestion>>(value),
    );
  }
}

String _$routineSuggestionsHash() =>
    r'6180af0ffd822a051462bcf4aa037e9a92d4c18f';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercises_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exercisesController)
final exercisesControllerProvider = ExercisesControllerProvider._();

final class ExercisesControllerProvider
    extends
        $FunctionalProvider<
          ExercisesController,
          ExercisesController,
          ExercisesController
        >
    with $Provider<ExercisesController> {
  ExercisesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exercisesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exercisesControllerHash();

  @$internal
  @override
  $ProviderElement<ExercisesController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExercisesController create(Ref ref) {
    return exercisesController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExercisesController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExercisesController>(value),
    );
  }
}

String _$exercisesControllerHash() =>
    r'97a8e061f5fd4b4a0aea659a88311d492ea15794';

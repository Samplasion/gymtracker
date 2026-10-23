// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WorkoutController)
final workoutControllerProvider = WorkoutControllerProvider._();

final class WorkoutControllerProvider
    extends $NotifierProvider<WorkoutController, WorkoutState?> {
  WorkoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutControllerHash();

  @$internal
  @override
  WorkoutController create() => WorkoutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutState?>(value),
    );
  }
}

String _$workoutControllerHash() => r'4aace7e70b57156b36824fa76e3483f9a4b18145';

abstract class _$WorkoutController extends $Notifier<WorkoutState?> {
  WorkoutState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkoutState?, WorkoutState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkoutState?, WorkoutState?>,
              WorkoutState?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

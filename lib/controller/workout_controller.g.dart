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

String _$workoutControllerHash() => r'ea0ff93cba3b674fb8c7361de23c43b4df91ed39';

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

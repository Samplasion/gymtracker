// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routinesStream)
final routinesStreamProvider = RoutinesStreamProvider._();

final class RoutinesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workout>>,
          List<Workout>,
          Stream<List<Workout>>
        >
    with $FutureModifier<List<Workout>>, $StreamProvider<List<Workout>> {
  RoutinesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Workout>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Workout>> create(Ref ref) {
    return routinesStream(ref);
  }
}

String _$routinesStreamHash() => r'3e9ce9f3c96a962288bb5eff0e8698f13633263f';

@ProviderFor(foldersStream)
final foldersStreamProvider = FoldersStreamProvider._();

final class FoldersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GTRoutineFolder>>,
          List<GTRoutineFolder>,
          Stream<List<GTRoutineFolder>>
        >
    with
        $FutureModifier<List<GTRoutineFolder>>,
        $StreamProvider<List<GTRoutineFolder>> {
  FoldersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foldersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foldersStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<GTRoutineFolder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GTRoutineFolder>> create(Ref ref) {
    return foldersStream(ref);
  }
}

String _$foldersStreamHash() => r'214728d02084b8eea920221eb8753385e665d530';

@ProviderFor(routinesByFolder)
final routinesByFolderProvider = RoutinesByFolderProvider._();

final class RoutinesByFolderProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<Workout>>>,
          AsyncValue<Map<String, List<Workout>>>,
          AsyncValue<Map<String, List<Workout>>>
        >
    with $Provider<AsyncValue<Map<String, List<Workout>>>> {
  RoutinesByFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesByFolderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesByFolderHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Map<String, List<Workout>>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Map<String, List<Workout>>> create(Ref ref) {
    return routinesByFolder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Map<String, List<Workout>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<Map<String, List<Workout>>>>(value),
    );
  }
}

String _$routinesByFolderHash() => r'81742b7a04100706d232ee97d513adb7f0276fd4';

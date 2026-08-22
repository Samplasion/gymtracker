// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FriendNotifier)
final friendProvider = FriendNotifierProvider._();

final class FriendNotifierProvider
    extends $AsyncNotifierProvider<FriendNotifier, FriendState> {
  FriendNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendNotifierHash();

  @$internal
  @override
  FriendNotifier create() => FriendNotifier();
}

String _$friendNotifierHash() => r'1e9c55658067972e34e4dcbd1019af54965ea17c';

abstract class _$FriendNotifier extends $AsyncNotifier<FriendState> {
  FutureOr<FriendState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FriendState>, FriendState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FriendState>, FriendState>,
              AsyncValue<FriendState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(friendPublicData)
final friendPublicDataProvider = FriendPublicDataFamily._();

final class FriendPublicDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<FriendPublicData>,
          FriendPublicData,
          FutureOr<FriendPublicData>
        >
    with $FutureModifier<FriendPublicData>, $FutureProvider<FriendPublicData> {
  FriendPublicDataProvider._({
    required FriendPublicDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'friendPublicDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$friendPublicDataHash();

  @override
  String toString() {
    return r'friendPublicDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FriendPublicData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FriendPublicData> create(Ref ref) {
    final argument = this.argument as String;
    return friendPublicData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendPublicDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendPublicDataHash() => r'f758e55d6bb62eaca28031089093d71ff078bc15';

final class FriendPublicDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FriendPublicData>, String> {
  FriendPublicDataFamily._()
    : super(
        retry: null,
        name: r'friendPublicDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FriendPublicDataProvider call(String friendId) =>
      FriendPublicDataProvider._(argument: friendId, from: this);

  @override
  String toString() => r'friendPublicDataProvider';
}

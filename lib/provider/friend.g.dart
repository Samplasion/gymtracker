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

String _$friendNotifierHash() => r'd3c44b61e328bc24925ab836ad4579ad972efc5d';

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

String _$friendPublicDataHash() => r'9db5522846ad962e272808809392cb7b59f96b56';

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

@ProviderFor(userIdentity)
final userIdentityProvider = UserIdentityFamily._();

final class UserIdentityProvider
    extends $FunctionalProvider<AsyncValue<Friend>, Friend, FutureOr<Friend>>
    with $FutureModifier<Friend>, $FutureProvider<Friend> {
  UserIdentityProvider._({
    required UserIdentityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userIdentityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userIdentityHash();

  @override
  String toString() {
    return r'userIdentityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Friend> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Friend> create(Ref ref) {
    final argument = this.argument as String;
    return userIdentity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserIdentityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userIdentityHash() => r'0a5aab956b9f4425f321c778236294dc1df32b59';

final class UserIdentityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Friend>, String> {
  UserIdentityFamily._()
    : super(
        retry: null,
        name: r'userIdentityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserIdentityProvider call(String id) =>
      UserIdentityProvider._(argument: id, from: this);

  @override
  String toString() => r'userIdentityProvider';
}

@ProviderFor(userAvatar)
final userAvatarProvider = UserAvatarFamily._();

final class UserAvatarProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  UserAvatarProvider._({
    required UserAvatarFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userAvatarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userAvatarHash();

  @override
  String toString() {
    return r'userAvatarProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return userAvatar(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAvatarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAvatarHash() => r'5d09afef04b6ab7f79a49b209552dfdb9000fe55';

final class UserAvatarFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  UserAvatarFamily._()
    : super(
        retry: null,
        name: r'userAvatarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserAvatarProvider call(String id) =>
      UserAvatarProvider._(argument: id, from: this);

  @override
  String toString() => r'userAvatarProvider';
}

@ProviderFor(userSearch)
final userSearchProvider = UserSearchFamily._();

final class UserSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Friend>>,
          List<Friend>,
          FutureOr<List<Friend>>
        >
    with $FutureModifier<List<Friend>>, $FutureProvider<List<Friend>> {
  UserSearchProvider._({
    required UserSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSearchHash();

  @override
  String toString() {
    return r'userSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Friend>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Friend>> create(Ref ref) {
    final argument = this.argument as String;
    return userSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSearchHash() => r'cfc732ba2f8df312ea8f2356fdb7daf95b1fee7e';

final class UserSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Friend>>, String> {
  UserSearchFamily._()
    : super(
        retry: null,
        name: r'userSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserSearchProvider call(String query) =>
      UserSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'userSearchProvider';
}

@ProviderFor(IdentityEpoch)
final identityEpochProvider = IdentityEpochProvider._();

final class IdentityEpochProvider
    extends $NotifierProvider<IdentityEpoch, int> {
  IdentityEpochProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityEpochProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityEpochHash();

  @$internal
  @override
  IdentityEpoch create() => IdentityEpoch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$identityEpochHash() => r'ace3729e27a8a9838d831408545ac3c8028b3d60';

abstract class _$IdentityEpoch extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

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

String _$friendNotifierHash() => r'ad51f78c0af54bb86abf15acbe75c1c70ee74eed';

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

String _$friendPublicDataHash() => r'1bcfd16e5ba0e09f2f87b69392e20520280e4ef0';

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

String _$userIdentityHash() => r'aa10e14b91495b97240d22f2cc1873c6d341ef26';

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

/// Independent signals keep cache writers from depending on their consumers.
/// Each signal lives only while the corresponding user is observed.

@ProviderFor(UserCacheRevision)
final userCacheRevisionProvider = UserCacheRevisionFamily._();

/// Independent signals keep cache writers from depending on their consumers.
/// Each signal lives only while the corresponding user is observed.
final class UserCacheRevisionProvider
    extends
        $NotifierProvider<UserCacheRevision, ({int contents, int identity})> {
  /// Independent signals keep cache writers from depending on their consumers.
  /// Each signal lives only while the corresponding user is observed.
  UserCacheRevisionProvider._({
    required UserCacheRevisionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userCacheRevisionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userCacheRevisionHash();

  @override
  String toString() {
    return r'userCacheRevisionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserCacheRevision create() => UserCacheRevision();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int contents, int identity}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int contents, int identity})>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserCacheRevisionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userCacheRevisionHash() => r'ea37714031cd774a728a54b7960b7615cdfb649e';

/// Independent signals keep cache writers from depending on their consumers.
/// Each signal lives only while the corresponding user is observed.

final class UserCacheRevisionFamily extends $Family
    with
        $ClassFamilyOverride<
          UserCacheRevision,
          ({int contents, int identity}),
          ({int contents, int identity}),
          ({int contents, int identity}),
          String
        > {
  UserCacheRevisionFamily._()
    : super(
        retry: null,
        name: r'userCacheRevisionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Independent signals keep cache writers from depending on their consumers.
  /// Each signal lives only while the corresponding user is observed.

  UserCacheRevisionProvider call(String id) =>
      UserCacheRevisionProvider._(argument: id, from: this);

  @override
  String toString() => r'userCacheRevisionProvider';
}

/// Independent signals keep cache writers from depending on their consumers.
/// Each signal lives only while the corresponding user is observed.

abstract class _$UserCacheRevision
    extends $Notifier<({int contents, int identity})> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  ({int contents, int identity}) build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({int contents, int identity}),
              ({int contents, int identity})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({int contents, int identity}),
                ({int contents, int identity})
              >,
              ({int contents, int identity}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Feed observers receive mutations without starting a separate relation read.

@ProviderFor(FriendshipChanges)
final friendshipChangesProvider = FriendshipChangesProvider._();

/// Feed observers receive mutations without starting a separate relation read.
final class FriendshipChangesProvider
    extends $NotifierProvider<FriendshipChanges, Set<String>?> {
  /// Feed observers receive mutations without starting a separate relation read.
  FriendshipChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendshipChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendshipChangesHash();

  @$internal
  @override
  FriendshipChanges create() => FriendshipChanges();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>?>(value),
    );
  }
}

String _$friendshipChangesHash() => r'18bc0decde342f99c092f808db382bb70a071b3f';

/// Feed observers receive mutations without starting a separate relation read.

abstract class _$FriendshipChanges extends $Notifier<Set<String>?> {
  Set<String>? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>?, Set<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>?, Set<String>?>,
              Set<String>?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

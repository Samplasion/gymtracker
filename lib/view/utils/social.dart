import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserAccountIcon extends ConsumerWidget {
  const UserAccountIcon({super.key, this.id, this.radius});

  final String? id;
  final double? radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emptyChild = Skeleton.leaf(
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        radius: radius,
        child: const Icon(Icons.person),
      ),
    );
    if (id == null) {
      return emptyChild;
    }
    final avatar = ref.watch(userAvatarProvider(id!));
    return avatar.when(
      loading: () => emptyChild,
      error: (_, __) => emptyChild,
      data: (url) => url == null
          ? emptyChild
          : Image.network(
              url,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, sync) => CircleAvatar(
                radius: radius,
                child: ClipOval(child: child),
              ),
              errorBuilder: (context, error, stack) => emptyChild,
            ),
    );
  }
}

class UserNameText extends ConsumerWidget {
  const UserNameText({super.key, this.id});
  final String? id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) return const Text('Unknown User');
    return ref
        .watch(userIdentityProvider(id!))
        .when(
          data: (f) => Text(f.fullName ?? f.username),
          error: (_, __) => const Text('Unknown User'),
          loading: () => const Text('Loading...'),
        );
  }
}

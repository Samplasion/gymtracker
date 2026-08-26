import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/model/friend.dart';
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
    ref.watch(friendProvider);
    final avatarUrl = ref.read(friendProvider.notifier).getAvatar(id!);
    return FutureBuilder<String?>(
      future: avatarUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return emptyChild;
        }
        if (snapshot.hasError || snapshot.data == null) {
          return emptyChild;
        }
        final url = snapshot.data!;
        return Image.network(
          url,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            return CircleAvatar(
              radius: radius,
              child: ClipOval(clipBehavior: .antiAlias, child: child),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return emptyChild;
          },
        );
      },
    );
  }
}

class UserNameText extends ConsumerWidget {
  const UserNameText({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return Text("Unknown User");
    }
    final friendPublicData = ref
        .read(friendProvider.notifier)
        .getFriendPublicData(id!);
    return FutureBuilder<FriendPublicData?>(
      future: friendPublicData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Text("Unknown User");
        }
        final data = snapshot.data!;
        return Text(data.friend.fullName ?? data.friend.username);
      },
    );
  }
}

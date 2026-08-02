import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserAccountIcon extends ConsumerWidget {
  const UserAccountIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Skeleton.leaf(
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.person),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/components/icon_grid.dart';
import 'package:gymtracker/view/utils/social.dart';

class UserAvatar extends ConsumerWidget {
  final String id;
  final double? radius;

  const UserAvatar({required this.id, this.radius, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserAccountIcon(id: id, radius: radius);
  }
}

class UserHeader extends StatelessWidget {
  final OnlineAccount account;

  const UserHeader({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    const height = 348.0;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SizedBox(
            height: height - 48,
            child: IconGrid(
              bigScale: 2,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: const Icon(GTIcons.app_icon),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 32,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: UserAccountIcon(id: account.id, radius: 64),
            ),
          ),
        ],
      ),
    );
  }
}

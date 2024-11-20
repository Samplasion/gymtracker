import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/online_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/components/icon_grid.dart';

class UserAvatar extends StatelessWidget {
  final String id;
  final double? radius;

  const UserAvatar({required this.id, this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Get.find<OnlineController>().getAvatarUrl(id),
      builder: (context, snapshot) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: snapshot.hasData && snapshot.data != null
              ? NetworkImage(snapshot.data!.toString())
              : null,
          child: snapshot.hasData && snapshot.data != null
              ? null
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth / 2;
                    return Icon(
                      GTIcons.account,
                      size: size,
                    );
                  },
                ),
        );
      },
    );
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
              child: UserAvatar(id: account.id, radius: 64),
            ),
          ),
        ],
      ),
    );
  }
}
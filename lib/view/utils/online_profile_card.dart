import 'package:flutter/material.dart';
import 'package:gymtracker/controller/online_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/online.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/me.dart';

class OnlineProfileCard extends ControlledWidget<OnlineController> {
  const OnlineProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OnlineAccount?>(
      stream: controller.account,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (snapshot.data == null) {
          return _buildLoggedOut();
        }

        return _buildLoggedIn(snapshot.data!);
      },
    );
  }

  Widget _buildLoggedOut() {
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(GTIcons.account),
        ),
        title: Text("login.upsell.title".t),
        subtitle: Text("login.upsell.subtitle".t),
        onTap: () {
          Go.to(() => const AuthScreen());
        },
        trailing: const Icon(GTIcons.lt_chevron),
      ),
    );
  }

  Widget _buildLoggedIn(OnlineAccount account) {
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: UserAvatar(id: account.id),
        title: Text(account.name),
        subtitle: account.email != null ? Text(account.email!) : null,
        onTap: () {
          Go.to(() => const MeProfilePage());
        },
        trailing: const Icon(GTIcons.lt_chevron),
      ),
    );
  }
}

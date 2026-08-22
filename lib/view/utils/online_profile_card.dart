import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/social.dart';

class OnlineProfileCard extends ConsumerWidget {
  const OnlineProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(onlineProvider);

    return accountAsync.when(
      data: (account) {
        if (account == null) {
          return _buildLoggedOut();
        }
        return _buildLoggedIn(account);
      },
      loading: () => Container(),
      error: (error, _) => Container(),
    );
  }

  Widget _buildLoggedOut() {
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(GTIcons.account)),
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
        leading: UserAccountIcon(id: account.id),
        title: Text(account.fullName ?? account.name),
        subtitle: Text(account.name),
        onTap: () {
          Go.to(() => UserProfilePage(userID: account.id));
        },
        trailing: const Icon(GTIcons.lt_chevron),
      ),
    );
  }
}

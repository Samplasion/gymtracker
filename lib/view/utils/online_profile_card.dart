import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/section_card.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/social.dart';

class OnlineProfileCard extends ConsumerWidget {
  const OnlineProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(onlineProvider);
    return accountAsync.when(
      data: (account) => account == null
          ? GTSectionCard(
              icon: GTIcons.account,
              title: context.t.login.upsell.title,
              subtitle: context.t.login.upsell.subtitle,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Go.to(() => const AuthScreen()),
            )
          : _buildLoggedIn(context, account),
      loading: () => const GTSectionCard(child: LinearProgressIndicator()),
      error: (error, _) => GTSectionCard(
        icon: GTIcons.account,
        title: context.t.errorView.subtitle,
        child: Semantics(
          liveRegion: true,
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(onlineProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.t.error.retry),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedIn(BuildContext context, OnlineAccount account) {
    final theme = Theme.of(context);
    return GTSectionCard(
      onTap: () => Go.to(() => UserProfilePage(userID: account.id)),
      child: Row(
        children: [
          UserAccountIcon(id: account.id),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.fullName ?? account.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  account.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

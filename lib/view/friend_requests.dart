import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/social.dart';

class FriendRequestsPage extends ConsumerWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendStateAsync = ref.watch(friendProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("friendRequests.title".t),
      ),
      body: friendStateAsync.when(
        data: (friendState) {
          final requests = friendState.pendingReceived;
          if (requests.isEmpty) {
            return Center(
              child: ContentUnavailableView(
                icon: const Icon(GTIcons.friend_requests),
                title: Text("friendRequests.empty.title".t),
                description: Text("friendRequests.empty.text".t),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendProvider);
            },
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final friend = requests[index];
                return _FriendRequestTile(friend: friend);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

class _FriendRequestTile extends ConsumerWidget {
  final Friend friend;

  const _FriendRequestTile({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(friendProvider.notifier);

    return ListTile(
      onTap: () {
        Go.to(() => UserProfilePage(userID: friend.id));
      },
      leading: UserAccountIcon(id: friend.id),
      title: UserNameText(id: friend.id),
      subtitle: Text("friendRequests.subtitle".t),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () async {
              await notifier.acceptFriendRequest(friend.id);
            },
            child: Text("userProfile.accept".t),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              await notifier.declineFriendRequest(friend.id);
            },
            child: Text("userProfile.reject".t),
          ),
        ],
      ),
    );
  }
}

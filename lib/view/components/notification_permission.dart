import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';

class NotificationPermissionTile extends ConsumerWidget {
  const NotificationPermissionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show =
        ref.watch(notificationPermissionsProvider).value?.showSettingsTile ??
        true;
    if (!show) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(GTIcons.notification_dialog),
      title: Text(context.t.settings.options.notifications.label),
      subtitle: Text(context.t.settings.permissions.tapToRequest),
      onTap: ref.read(notificationControllerProvider).requestPermission,
    );
  }
}

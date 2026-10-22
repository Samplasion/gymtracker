import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';

class HealthPermissionTile extends ConsumerWidget {
  const HealthPermissionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(healthPermissionProvider).value == true) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: const Icon(GTIcons.notification_dialog),
      title: Text(context.t.settings.options.health.label),
      subtitle: Text(context.t.settings.permissions.tapToRequest),
      onTap: ref.read(healthControllerProvider).requestPermission,
    );
  }
}

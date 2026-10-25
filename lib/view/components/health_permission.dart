import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthPermissionTile extends ConsumerWidget {
  const HealthPermissionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsWaterPermission = ref.watch(hydrationNeedsPermissionProvider);
    if (ref.watch(healthPermissionProvider).value == true &&
        !needsWaterPermission) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: const Icon(GTIcons.notification_dialog),
      title: Text(context.t.settings.options.health.label),
      subtitle: Text(context.t.settings.permissions.tapToRequest),
      onTap: () async {
        final denied =
            ref.read(hydrationPermissionProvider).asData?.value ==
            HydrationPermission.denied;
        await ref.read(healthControllerProvider).requestPermission();
        if (!context.mounted) return;
        await ref.read(hydrationSyncProvider).enable();
        if (!context.mounted) return;
        if (denied &&
            ref.read(hydrationSyncProvider).permissionStatus.value ==
                HydrationPermission.denied) {
          await openAppSettings();
        }
      },
    );
  }
}

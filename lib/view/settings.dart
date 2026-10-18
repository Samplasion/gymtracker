import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Rx, ContextExtensionss;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/sync_status.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/legacy_workout_recovery.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/master_detail.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:gymtracker/view/settings/color.dart';
import 'package:gymtracker/view/settings/radio.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:intl/intl.dart';

part 'settings.advanced.dart';
part 'settings.appearance.dart';
part 'settings.off.dart';
part 'settings.permissions.dart';
part 'settings.units.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(onlineProvider).value;
    var appVersion = context.t.appInfo.version(
      version: VersionService().packageInfo.version,
      build: const String.fromEnvironment(
        "BUILD",
        defaultValue: "[NO_VALUE]",
      ).replaceAll("[NO_VALUE]", VersionService().packageInfo.buildNumber),
    );

    return StreamBuilder<Object>(
      stream: Get.find<Coordinator>().showPermissionTilesStream,
      initialData: true,
      builder: (context, snapshot) {
        final showPermissionsTile = snapshot.data == true;

        return MasterDetailView(
          appBarTitle: Text(context.t.settings.title),
          items: [
            MasterItem(
              Text(context.t.settings.panes.appearance),
              leading: const Icon(GTIcons.appearance),
              detailsBuilder: (_) => const AppearanceSettingsPane(),
            ),
            MasterItem(
              Text(context.t.settings.panes.units),
              leading: const Icon(GTIcons.units),
              detailsBuilder: (_) => const UnitsSettingsPane(),
            ),
            MasterItem(
              Text(context.t.settings.panes.off),
              leading: const Icon(GTIcons.food),
              detailsBuilder: (_) => const OpenFoodFactsSettingsPane(),
            ),
            if (showPermissionsTile)
              MasterItem(
                Text(context.t.settings.panes.permissions),
                leading: const Icon(GTIcons.permissions),
                detailsBuilder: (_) => const PermissionsSettingsPane(),
              ),
            const MasterItemWidget(child: Divider()),
            MasterItem(
              Text(context.t.settings.advanced.title),
              subtitle: Text(context.t.settings.advanced.subtitle),
              leading: const Icon(GTIcons.advanced),
              trailing: const Icon(GTIcons.lt_chevron),
              detailsBuilder: (_) => const AdvancedSettingsView(),
            ),
            MasterItem(
              Text(context.t.settings.pro.title),
              leading: GTIcons.compound.pro,
              onTap: () {
                Get.find<PurchasesController>().presentCustomerCenter();
              },
            ),
            MasterItem(
              Text(
                MaterialLocalizations.of(
                  context,
                ).aboutListTileTitle(context.t.appName),
              ),
              leading: const Icon(GTIcons.info),
              subtitle: Text(appVersion),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: context.t.appName,
                  applicationVersion: appVersion,
                  children: [Text(context.t.appInfo.shortDescription)],
                  applicationIcon: const InAppIcon.proportional(),
                );
              },
            ),
            if (account != null) ...[
              const MasterItemWidget(child: Divider()),
              MasterItem(
                Text(context.t.settings.logout),
                subtitle: Text("@${account.name}"),
                leading: const Icon(GTIcons.exit),
                trailing: const Icon(GTIcons.lt_chevron),
                onTap: () async {
                  final exit = await Go.confirm(
                    context.t.settings.logoutWarning.title,
                    context.t.settings.logoutWarning.content,
                  );
                  if (!exit) return;
                  ref.read(onlineProvider.notifier).logout();
                  if (context.mounted) {
                    Go.replaceStack(() => const OnboardingScreen());
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

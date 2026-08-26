import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Rx, ContextExtensionss;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
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
    var appVersion = "appInfo.version".tParams({
      "version": VersionService().packageInfo.version,
      "build": const String.fromEnvironment(
        "BUILD",
        defaultValue: "[NO_VALUE]",
      ).replaceAll("[NO_VALUE]", VersionService().packageInfo.buildNumber),
    });

    return StreamBuilder<Object>(
      stream: Get.find<Coordinator>().showPermissionTilesStream,
      initialData: true,
      builder: (context, snapshot) {
        final showPermissionsTile = snapshot.data == true;

        return MasterDetailView(
          appBarTitle: Text("settings.title".t),
          items: [
            MasterItem(
              Text("settings.panes.appearance".t),
              leading: const Icon(GTIcons.appearance),
              detailsBuilder: (_) => const AppearanceSettingsPane(),
            ),
            MasterItem(
              Text("settings.panes.units".t),
              leading: const Icon(GTIcons.units),
              detailsBuilder: (_) => const UnitsSettingsPane(),
            ),
            MasterItem(
              Text("settings.panes.off".t),
              leading: const Icon(GTIcons.food),
              detailsBuilder: (_) => const OpenFoodFactsSettingsPane(),
            ),
            if (showPermissionsTile)
              MasterItem(
                Text("settings.panes.permissions".t),
                leading: const Icon(GTIcons.permissions),
                detailsBuilder: (_) => const PermissionsSettingsPane(),
              ),
            const MasterItemWidget(child: Divider()),
            MasterItem(
              Text("settings.advanced.title".t),
              subtitle: Text("settings.advanced.subtitle".t),
              leading: const Icon(GTIcons.advanced),
              trailing: const Icon(GTIcons.lt_chevron),
              detailsBuilder: (_) => const AdvancedSettingsView(),
            ),
            MasterItem(
              Text("settings.pro.title".t),
              leading: GTIcons.compound.pro,
              onTap: () {
                Get.find<PurchasesController>().presentCustomerCenter();
              },
            ),
            MasterItem(
              Text(
                MaterialLocalizations.of(
                  context,
                ).aboutListTileTitle("appName".t),
              ),
              leading: const Icon(GTIcons.info),
              subtitle: Text(appVersion),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "appName".t,
                  applicationVersion: appVersion,
                  children: [Text("appInfo.shortDescription".t)],
                  applicationIcon: const InAppIcon.proportional(),
                );
              },
            ),
            if (account != null) ...[
              const MasterItemWidget(child: Divider()),
              MasterItem(
                Text("settings.logout".t),
                subtitle: Text("@${account.name}"),
                leading: const Icon(GTIcons.exit),
                trailing: const Icon(GTIcons.lt_chevron),
                onTap: () async {
                  final exit = await Go.confirm(
                    "settings.logoutWarning.title".t,
                    "settings.logoutWarning.content".t,
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

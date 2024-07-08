import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Rx;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/food_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/service/color.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/master_detail.dart';
import 'package:gymtracker/view/settings/color.dart';
import 'package:gymtracker/view/settings/radio.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';

part 'settings.appearance.dart';
part 'settings.off.dart';
part 'settings.permissions.dart';
part 'settings.units.dart';

class SettingsView extends ControlledWidget<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    var appVersion = "appInfo.version".tParams({
      "version": VersionService().packageInfo.version,
      "build": const String.fromEnvironment(
        "BUILD",
        defaultValue: "[NO_VALUE]",
      ).replaceAll(
        "[NO_VALUE]",
        VersionService().packageInfo.buildNumber,
      ),
    });

    return StreamBuilder<Object>(
      stream: Get.find<Coordinator>().showPermissionTilesStream,
      initialData: true,
      builder: (context, snapshot) {
        final showPermissionsTile = snapshot.data == true;

        return MasterDetailView(
          appBarTitle: Text("settings.title".t),
          leading: const SkeletonDrawerButton(),
          items: [
            MasterItem(
              "settings.panes.appearance".t,
              leading: const Icon(GymTrackerIcons.appearance),
              detailsBuilder: (_) => const AppearanceSettingsPane(),
            ),
            MasterItem(
              "settings.panes.units".t,
              leading: const Icon(GymTrackerIcons.units),
              detailsBuilder: (_) => const UnitsSettingsPane(),
            ),
            MasterItem(
              "settings.panes.off".t,
              leading: const Icon(GymTrackerIcons.food),
              detailsBuilder: (_) => const OpenFoodFactsSettingsPane(),
            ),
            if (showPermissionsTile)
              MasterItem(
                "settings.panes.permissions".t,
                leading: const Icon(GymTrackerIcons.permissions),
                detailsBuilder: (_) => const PermissionsSettingsPane(),
              ),
            const MasterItemWidget(child: Divider()),
            MasterItem(
              "settings.advanced.title".t,
              subtitle: "settings.advanced.subtitle".t,
              leading: const Icon(GymTrackerIcons.advanced),
              trailing: const Icon(GymTrackerIcons.lt_chevron),
              detailsBuilder: (_) => const AdvancedSettingsView(),
            ),
            MasterItem(
              MaterialLocalizations.of(context).aboutListTileTitle("appName".t),
              leading: const Icon(GymTrackerIcons.info),
              subtitle: appVersion,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "appName".t,
                  applicationVersion: appVersion,
                  children: [
                    Text("appInfo.shortDescription".t),
                  ],
                  applicationIcon: const InAppIcon.proportional(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class AdvancedSettingsView extends ControlledWidget<SettingsController> {
  const AdvancedSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("settings.advanced.title".t),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  title: Text("settings.options.import.label".t),
                  leading: const Icon(GymTrackerIcons.import),
                  trailing: const Icon(GymTrackerIcons.lt_chevron),
                  onTap: () async {
                    await controller.importSettings(context);
                  },
                ),
                ListTile(
                  title: Text("settings.options.export.label".t),
                  leading: const Icon(GymTrackerIcons.export),
                  trailing: const Icon(GymTrackerIcons.lt_chevron),
                  onTap: () async {
                    await controller.exportSettings(context);
                  },
                ),
                if (controller.canExportRaw)
                  ListTile(
                    title: Text("settings.options.exportSQL.label".t),
                    subtitle: Text("settings.options.exportSQL.text".t),
                    leading: const Icon(GymTrackerIcons.export),
                    trailing: const Icon(GymTrackerIcons.lt_chevron),
                    onTap: () async {
                      await controller.exportRawDatabase(context);
                    },
                  ),
                const Divider(),
                ListTile(
                  title: Text("settings.advanced.options.logs.title".t),
                  leading: const Icon(GymTrackerIcons.logs),
                  trailing: const Icon(GymTrackerIcons.lt_chevron),
                  onTap: () async {
                    await controller.showLogs();
                  },
                ),
                ListTile(
                  title: Text("settings.advanced.options.migrations.title".t),
                  leading: const Icon(GymTrackerIcons.migration),
                  trailing: const Icon(GymTrackerIcons.lt_chevron),
                  onTap: () async {
                    await controller.showMigrations();
                  },
                ),
              ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            const SliverBottomSafeArea(),
          ],
        ),
      ),
    );
  }
}

part of 'settings.dart';

class PermissionsSettingsPane extends ControlledWidget<SettingsController> {
  const PermissionsSettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("settings.panes.permissions".t),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Get.find<NotificationController>().settingsTile,
                const FoodPermissionsSettingsTile(),
                Get.find<HealthController>().settingsTile,
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

class FoodPermissionsSettingsTile extends ConsumerWidget {
  const FoodPermissionsSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(showFoodPermissionsSettingsTileProvider);
    if (!show) return const SizedBox.shrink();

    final perms = ref.watch(foodPermissionsProvider).asData?.value ??
        (camera: false, gallery: false);

    return Column(
      children: [
        if (!perms.camera)
          ListTile(
            leading: const Icon(GTIcons.camera),
            title: Text("food.addCustomFood.permission.camera".t),
            subtitle: Text("settings.permissions.tapToRequest".t),
            onTap: () {
              ref
                  .read(foodPermissionsProvider.notifier)
                  .requestPermission(Permission.camera);
            },
          ),
        if (!perms.gallery)
          ListTile(
            leading: const Icon(GTIcons.gallery),
            title: Text("food.addCustomFood.permission.gallery".t),
            subtitle: Text("settings.permissions.tapToRequest".t),
            onTap: () {
              ref
                  .read(foodPermissionsProvider.notifier)
                  .requestPermission(Permission.photos);
            },
          ),
      ],
    );
  }
}

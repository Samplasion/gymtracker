part of 'settings.dart';

class PermissionsSettingsPane extends ConsumerWidget {
  const PermissionsSettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(context.t.settings.panes.permissions),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const NotificationPermissionTile(),
                const FoodPermissionsSettingsTile(),
                const HealthPermissionTile(),
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

    final perms =
        ref.watch(foodPermissionsProvider).asData?.value ??
        (camera: false, gallery: false);

    return Column(
      children: [
        if (!perms.camera)
          ListTile(
            leading: const Icon(GTIcons.camera),
            title: Text(context.t.food.addCustomFood.permission.camera),
            subtitle: Text(context.t.settings.permissions.tapToRequest),
            onTap: () {
              ref
                  .read(foodPermissionsProvider.notifier)
                  .requestPermission(Permission.camera);
            },
          ),
        if (!perms.gallery)
          ListTile(
            leading: const Icon(GTIcons.gallery),
            title: Text(context.t.food.addCustomFood.permission.gallery),
            subtitle: Text(context.t.settings.permissions.tapToRequest),
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

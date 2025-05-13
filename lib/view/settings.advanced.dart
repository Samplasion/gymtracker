part of 'settings.dart';

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
                  leading: const Icon(GTIcons.import),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.importSettings(context);
                  },
                ),
                Builder(builder: (context) {
                  return ListTile(
                    title: Text("settings.options.export.label".t),
                    leading: const Icon(GTIcons.export),
                    trailing: const Icon(GTIcons.lt_chevron),
                    onTap: () async {
                      await controller.exportSettings(context);
                    },
                  );
                }),
                if (controller.canExportRaw)
                  Builder(builder: (context) {
                    return ListTile(
                      title: Text("settings.options.exportSQL.label".t),
                      subtitle: Text("settings.options.exportSQL.text".t),
                      leading: const Icon(GTIcons.export),
                      trailing: const Icon(GTIcons.lt_chevron),
                      onTap: () async {
                        await controller.exportRawDatabase(context);
                      },
                    );
                  }),
                const Divider(),
                ListTile(
                  title: Text("settings.advanced.options.logs.title".t),
                  leading: const Icon(GTIcons.logs),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.showLogs();
                  },
                ),
                ListTile(
                  title: Text("settings.advanced.options.migrations.title".t),
                  leading: const Icon(GTIcons.migration),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.showMigrations();
                  },
                ),
                ListTile(
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "settings.advanced.options.backups.title".t),
                      ],
                    ),
                  ),
                  leading: const Icon(GTIcons.backup),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.showBackups();
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

class BackupListView extends StatefulWidget {
  const BackupListView({super.key});

  @override
  State<BackupListView> createState() => _BackupListViewState();
}

class _BackupListViewState
    extends ControlledState<BackupListView, DatabaseService> {
  late Stream<List<DatabaseBackup>> backupsStream = controller.listBackups();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsView(
        child: StreamBuilder<List<DatabaseBackup>>(
          stream: backupsStream,
          builder: (context, snapshot) {
            Widget _s(Widget c) => Scaffold(
                  appBar: AppBar(),
                  body: DetailsView(
                    child: c,
                  ),
                );

            if (snapshot.hasError) {
              return _s(Center(
                child: Text(snapshot.error.toString()),
              ));
            }

            if (!snapshot.hasData) {
              return _s(const Center(
                child: CircularProgressIndicator(),
              ));
            }

            final backups = snapshot.data!;

            return CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text("settings.advanced.options.backups.title".t),
                  leading: MDVConfiguration.backButtonOf(context),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final backup = backups[index];
                      return ListTile(
                        title: Text(DateFormat.yMd(context.locale.languageCode)
                            .add_Hms()
                            .format(backup.date)),
                        subtitle:
                            Text(backup.size.readableFileSize(base1024: true)),
                        trailing: IconButton(
                          icon: const Icon(GTIcons.delete),
                          onPressed: () async {
                            final delete = await Go.confirm(
                              "settings.advanced.options.backups.delete.title"
                                  .t,
                              "settings.advanced.options.backups.delete.confirm"
                                  .t,
                            );

                            if (delete) {
                              await Go.futureDialog(
                                future: () async {
                                  await controller.deleteBackup(backup);
                                },
                                title:
                                    "settings.advanced.options.backups.deleting",
                              );
                            }
                          },
                        ),
                        onTap: () async {
                          final restore = await Go.confirm(
                            "settings.advanced.options.backups.restore.title".t,
                            "settings.advanced.options.backups.restore.confirm"
                                .t,
                          );

                          if (restore) {
                            await Go.futureDialog(
                              future: () async {
                                await controller.restoreBackup(backup);
                              },
                              title:
                                  "settings.advanced.options.backups.restoring",
                            );
                          }
                        },
                      );
                    },
                    childCount: backups.length,
                  ),
                ),
                // Add a button to create a new backup
                SliverList(
                  delegate: SliverChildListDelegate([
                    ListTile(
                      title: Text("settings.advanced.options.backups.create".t),
                      leading: const Icon(GTIcons.backup),
                      onTap: () async {
                        await Go.futureDialog(
                          future: () async {
                            await controller.createBackup();
                          },
                          title: "settings.advanced.options.backups.creating",
                        );
                      },
                    ),
                  ]),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                const SliverBottomSafeArea(),
              ],
            );
          },
        ),
      ),
    );
  }
}

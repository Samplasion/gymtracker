part of 'settings.dart';

class AdvancedSettingsView extends ConsumerWidget {
  const AdvancedSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(onlineProvider).value;
    final controller = Get.find<SettingsController>();

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
                Builder(
                  builder: (context) {
                    return ListTile(
                      title: Text("settings.options.export.label".t),
                      leading: const Icon(GTIcons.export),
                      trailing: const Icon(GTIcons.lt_chevron),
                      onTap: () async {
                        await controller.exportSettings(context);
                      },
                    );
                  },
                ),
                if (controller.canExportRaw)
                  Builder(
                    builder: (context) {
                      return ListTile(
                        title: Text("settings.options.exportSQL.label".t),
                        subtitle: Text("settings.options.exportSQL.text".t),
                        leading: const Icon(GTIcons.export),
                        trailing: const Icon(GTIcons.lt_chevron),
                        onTap: () async {
                          await controller.exportRawDatabase(context);
                        },
                      );
                    },
                  ),
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
                          text: "settings.advanced.options.backups.title".t,
                        ),
                      ],
                    ),
                  ),
                  leading: const Icon(GTIcons.backup),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.showBackups();
                  },
                ),
                const SyncStatusListTile(),
                if (account != null) ...[
                  Divider(),
                  ListTile(
                    title: Text("settings.advanced.deleteAccount.title".t),
                    subtitle: Text("@${account.name}"),
                    leading: const Icon(GTIcons.delete_forever),
                    trailing: const Icon(GTIcons.lt_chevron),
                    onTap: () async {
                      final exit = await Go.confirm(
                        "settings.advanced.deleteAccount.warning.title".t,
                        "settings.advanced.deleteAccount.warning.content".t,
                      );
                      if (!exit) return;
                      final controller = TextEditingController();
                      final username = await Go.textPrompt(
                        "settings.advanced.deleteAccount.confirmation.title".t,
                        "settings.advanced.deleteAccount.confirmation.content"
                            .tParams({"username": account.name}),
                        controller: controller,
                        hintText:
                            "settings.advanced.deleteAccount.confirmation.hint"
                                .t,
                        transformText: (text) => text,
                        validator: (text) {
                          if (text != null &&
                              text.trim().isNotEmpty &&
                              text != account.name) {
                            return "settings.advanced.deleteAccount.confirmation.error.mismatch"
                                .t;
                          }
                          return null;
                        },
                      );
                      if (account.name != username) return;
                      await Go.futureDialog(
                        future: () =>
                            ref.read(onlineProvider.notifier).deleteAccount(),
                        title: "settings.advanced.deleteAccount.deleting".t,
                      );
                      if (context.mounted) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Go.replaceStack(() => const OnboardingScreen());
                        });
                      }
                    },
                  ),
                ],
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
              body: DetailsView(child: c),
            );

            if (snapshot.hasError) {
              return _s(Center(child: Text(snapshot.error.toString())));
            }

            if (!snapshot.hasData) {
              return _s(const Center(child: GBLoadingIndicator()));
            }

            final backups = snapshot.data!;

            return CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: Text("settings.advanced.options.backups.title".t),
                  leading: MDVConfiguration.backButtonOf(context),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final backup = backups[index];
                    return ListTile(
                      title: Text(
                        DateFormat.yMd(
                          context.locale.languageCode,
                        ).add_Hms().format(backup.date),
                      ),
                      subtitle: Text(
                        backup.size.readableFileSize(base1024: true),
                      ),
                      trailing: IconButton(
                        icon: const Icon(GTIcons.delete),
                        onPressed: () async {
                          final delete = await Go.confirm(
                            "settings.advanced.options.backups.delete.title".t,
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
                          "settings.advanced.options.backups.restore.confirm".t,
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
                  }, childCount: backups.length),
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

class SyncStatusListTile extends ConsumerStatefulWidget {
  const SyncStatusListTile({super.key});

  @override
  ConsumerState<SyncStatusListTile> createState() => _SyncStatusListTileState();
}

class _SyncStatusListTileState extends ConsumerState<SyncStatusListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);
    final account = ref.watch(onlineProvider).value;

    if (syncStatus.isSyncing) {
      if (!_animController.isAnimating) {
        _animController.repeat();
      }
    } else {
      if (_animController.isAnimating) {
        _animController.stop();
        _animController.reset();
      }
    }

    final Widget leading;
    if (syncStatus.isSyncing) {
      leading = RotationTransition(
        turns: _animController,
        child: const Icon(GTIcons.sync),
      );
    } else if (syncStatus.hasError) {
      leading = Icon(
        GTIcons.sync_problem,
        color: context.colorScheme.error,
      );
    } else {
      leading = const Icon(GTIcons.sync);
    }

    final String subtitleText;
    if (syncStatus.isSyncing) {
      subtitleText = "settings.advanced.options.sync.status.syncing".t;
    } else {
      final statusPrefix = syncStatus.hasError
          ? "settings.advanced.options.sync.status.failed".t
          : "settings.advanced.options.sync.status.notSyncing".t;
      if (account == null) {
        subtitleText =
            "$statusPrefix • ${"settings.advanced.options.sync.notLoggedIn".t}";
      } else if (syncStatus.lastSync != null) {
        final formattedDate = DateFormat.yMd(
          context.locale.languageCode,
        ).add_Hms().format(syncStatus.lastSync!);
        subtitleText =
            "$statusPrefix • ${"settings.advanced.options.sync.lastSync".tParams({"date": formattedDate})}";
      } else {
        subtitleText =
            "$statusPrefix • ${"settings.advanced.options.sync.never".t}";
      }
    }

    final canSync = !syncStatus.isSyncing && account != null;

    return ListTile(
      title: Text("settings.advanced.options.sync.title".t),
      subtitle: Text(subtitleText),
      leading: leading,
      onTap: canSync
          ? () {
              final lastSync = syncStatus.lastSync;
              if (lastSync != null &&
                  DateTime.now().difference(lastSync) < const Duration(minutes: 1)) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("settings.advanced.options.sync.rateLimited".t),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                return;
              }
              ref.read(syncStatusProvider.notifier).sync();
            }
          : null,
    );
  }
}

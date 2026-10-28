part of 'settings.dart';

class AdvancedSettingsView extends ConsumerWidget {
  const AdvancedSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(onlineProvider).value;
    final controller = ref.read(settingsControllerProvider);

    return Scaffold(
      body: DetailsView(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(context.t.settings.advanced.title),
              leading: MDVConfiguration.backButtonOf(context),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  title: Text(context.t.settings.options.import.label),
                  leading: const Icon(GTIcons.import),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.importSettings(context);
                  },
                ),
                Builder(
                  builder: (context) {
                    return ListTile(
                      title: Text(context.t.settings.options.export.label),
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
                        title: Text(context.t.settings.options.exportSQL.label),
                        subtitle: Text(
                          context.t.settings.options.exportSQL.text,
                        ),
                        leading: const Icon(GTIcons.export),
                        trailing: const Icon(GTIcons.lt_chevron),
                        onTap: () async {
                          await controller.exportRawDatabase(context);
                        },
                      );
                    },
                  ),
                if (account != null) ...[
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(context.t.social.reports),
                    onTap: () =>
                        Go.to(() => const SocialSettingsPage(reports: true)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: Text(context.t.social.blockedUsers),
                    onTap: () => Go.to(() => const SocialSettingsPage()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(context.t.social.push),
                    subtitle: Text(context.t.social.pushDescription),
                    onTap: () => socialAction(context, () async {
                      final enabled = await ref
                          .read(pushServiceProvider)
                          .enable();
                      if (!enabled && context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.t.social.pushDisabled),
                          ),
                        );
                    }),
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title: Text(context.t.food.catalog.submissions),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () => Go.to(() => const CatalogSubmissionsView()),
                ),
                const SyncRecoveryActions(),
                const Divider(),
                ListTile(
                  title: Text(context.t.settings.advanced.options.logs.title),
                  leading: const Icon(GTIcons.logs),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: () async {
                    await controller.showLogs();
                  },
                ),
                ListTile(
                  title: Text(
                    context.t.settings.advanced.options.migrations.title,
                  ),
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
                          text:
                              context.t.settings.advanced.options.backups.title,
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
                const LegacyWorkoutRecoveryTile(),
                const SyncStatusListTile(),
                if (account != null) ...[
                  Divider(),
                  ListTile(
                    title: Text(
                      context.t.settings.advanced.deleteAccount.title,
                    ),
                    subtitle: Text("@${account.name}"),
                    leading: const Icon(GTIcons.delete_forever),
                    trailing: const Icon(GTIcons.lt_chevron),
                    onTap: () async {
                      final exit = await Go.confirm(
                        context.t.settings.advanced.deleteAccount.warning.title,
                        context
                            .t
                            .settings
                            .advanced
                            .deleteAccount
                            .warning
                            .content,
                      );
                      if (!exit || !context.mounted) return;
                      final controller = TextEditingController();
                      final username = await Go.textPrompt(
                        context
                            .t
                            .settings
                            .advanced
                            .deleteAccount
                            .confirmation
                            .title,
                        context.t.settings.advanced.deleteAccount.confirmation
                            .content(username: account.name),
                        controller: controller,
                        hintText: context
                            .t
                            .settings
                            .advanced
                            .deleteAccount
                            .confirmation
                            .hint,
                        validator: (text) {
                          if (text != null &&
                              text.trim().isNotEmpty &&
                              text != account.name) {
                            return context
                                .t
                                .settings
                                .advanced
                                .deleteAccount
                                .confirmation
                                .error
                                .mismatch;
                          }
                          return null;
                        },
                      );
                      if (account.name != username || !context.mounted) return;
                      final online = ref.read(onlineProvider.notifier);
                      await Go.futureDialog(
                        future: online.deleteAccount,
                        title:
                            context.t.settings.advanced.deleteAccount.deleting,
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

class BackupListView extends ConsumerStatefulWidget {
  const BackupListView({super.key});

  @override
  ConsumerState<BackupListView> createState() => _BackupListViewState();
}

class _BackupListViewState extends ConsumerState<BackupListView> {
  DatabaseService get controller => ref.read(databaseServiceProvider);
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
                  title: Text(
                    context.t.settings.advanced.options.backups.title,
                  ),
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
                            context
                                .t
                                .settings
                                .advanced
                                .options
                                .backups
                                .delete
                                .title,
                            context
                                .t
                                .settings
                                .advanced
                                .options
                                .backups
                                .delete
                                .confirm,
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
                        final mode = await previewBackupRestore(
                          context,
                          controller,
                          backup,
                        );

                        if (mode != null) {
                          await Go.futureDialog(
                            future: () async {
                              await controller.restoreBackup(
                                backup,
                                mode: mode,
                              );
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
                      title: Text(
                        context.t.settings.advanced.options.backups.create,
                      ),
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
      leading = Icon(GTIcons.sync_problem, color: context.colorScheme.error);
    } else {
      leading = const Icon(GTIcons.sync);
    }

    final String subtitleText;
    if (syncStatus.isSyncing) {
      subtitleText = context.t.settings.advanced.options.sync.status.syncing;
    } else {
      final statusPrefix = syncStatus.hasError
          ? context.t.settings.advanced.options.sync.status.failed
          : context.t.settings.advanced.options.sync.status.notSyncing;
      if (account == null) {
        subtitleText =
            "$statusPrefix • ${context.t.settings.advanced.options.sync.notLoggedIn}";
      } else if (syncStatus.lastSync != null) {
        final formattedDate = DateFormat.yMd(
          context.locale.languageCode,
        ).add_Hms().format(syncStatus.lastSync!);
        subtitleText =
            "$statusPrefix • ${context.t.settings.advanced.options.sync.lastSync(date: formattedDate)}";
      } else {
        subtitleText =
            "$statusPrefix • ${context.t.settings.advanced.options.sync.never}";
      }
    }

    final canSync = !syncStatus.isSyncing && account != null;

    return ListTile(
      title: Text(context.t.settings.advanced.options.sync.title),
      subtitle: Text(subtitleText),
      leading: leading,
      onTap: canSync
          ? () {
              final lastSync = syncStatus.lastSync;
              if (lastSync != null &&
                  DateTime.now().difference(lastSync) <
                      const Duration(minutes: 1)) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        context.t.settings.advanced.options.sync.rateLimited,
                      ),
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

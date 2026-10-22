import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:intl/intl.dart';

class AchievementsView extends ConsumerStatefulWidget {
  const AchievementsView({super.key});

  @override
  ConsumerState<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends ConsumerState<AchievementsView> {
  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(achievementCatalogProvider);
    final achievementKeys = achievements.keys.toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(context.t.achievements.title),
            actions: [
              IconButton(
                icon: const Icon(GTIcons.history),
                onPressed: () => Go.to(() => const AchievementHistoryScreen()),
                tooltip: context.t.achievements.history,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              delegate: SliverChildListDelegate([
                for (final key in achievementKeys) ...[
                  for (final level in achievements[key]!.levels)
                    AchievementGridTile(
                      achievement: achievements[key]!,
                      level: level,
                      onTap: (achievement, level) {
                        Go.toDialog(
                          () => AchievementGetDialog(
                            achievement: achievement,
                            level: level,
                          ),
                        );
                      },
                    ),
                ],
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

class AchievementGridTile extends ConsumerWidget {
  final Achievement achievement;
  final AchievementLevel level;
  final void Function(Achievement, AchievementLevel) onTap;

  const AchievementGridTile({
    required this.achievement,
    required this.level,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(achievementCompletionsProvider);
    final controller = ref.watch(achievementsControllerProvider);
    final enabled = controller.isUnlocked(achievement, level);
    return LayoutBuilder(
      builder: (context, cardSize) {
        var child = InkWell(
          onTap: () => onTap(achievement, level),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // const Spacer(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, size) {
                      return Center(
                        child: AchievementIcon(
                          achievement: achievement,
                          enabled: enabled,
                          size: min(
                            size.maxHeight,
                            switch (Breakpoints.currentBreakpoint) {
                              Breakpoints.xxs => 48,
                              _ => cardSize.maxHeight / 3,
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // const Spacer(),
                Text(
                  level.getLocalizedName(context.t),
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  achievement.shouldShowDescriptionFor(level.level, controller)
                      ? level.getLocalizedDescription(context.t)
                      : "???",
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );

        return Card.outlined(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: child,
        );
      },
    );
  }
}

class AchievementGetDialog extends ConsumerWidget {
  final Achievement achievement;
  final AchievementLevel level;

  const AchievementGetDialog({
    required this.achievement,
    required this.level,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(achievementCompletionsProvider);
    final controller = ref.watch(achievementsControllerProvider);
    final completion = controller.getCompletion(achievement, level);
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            AchievementIcon(
              achievement: achievement,
              enabled: completion != null,
              size: min(MediaQuery.sizeOf(context).width, 96),
            ),
            const SizedBox(height: 16),
            Text(
              level.getLocalizedName(context.t),
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodyLarge,
            ),
            Text(
              achievement.shouldShowDescriptionFor(level.level, controller)
                  ? level.getLocalizedDescription(context.t)
                  : "???",
              textAlign: TextAlign.center,
            ),
            if (completion == null &&
                level.canShowProgress &&
                achievement.shouldShowDescriptionFor(
                  level.level,
                  controller,
                )) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(
                  value: level.progress!() / level.progressMax!(),
                ),
              ),
              Text(_getProgressText(context), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            if (completion != null || !level.canShowProgress) ...[
              Text(
                completion == null
                    ? context.t.achievements.locked
                    : context.t.achievements.unlockedOn(
                        date: DateFormat.yMMMMEEEEd(
                          context.locale.languageCode,
                        ).add_Hms().format(completion.completedAt),
                      ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  String _getProgressText(BuildContext context) {
    assert(level.canShowProgress);
    final progress = level.progress!();
    final progressMax = level.progressMax!();

    if (level.progressText != null) {
      return "${level.progressText!(context.t, progress)} / ${level.progressText!(context.t, progressMax)}";
    } else {
      return "$progress / $progressMax";
    }
  }
}

class AchievementHistoryScreen extends ConsumerWidget {
  const AchievementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(achievementsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.achievements.history)),
      body: CustomScrollView(
        slivers: [
          StreamBuilder<List<AchievementCompletion>>(
            stream: controller.completionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: GBLoadingIndicator()),
                );
              }
              return SliverList.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final completion = snapshot.data![index];
                  final achievement = controller.getAchievement(
                    completion.achievementID,
                  );
                  final level = controller.getLevel(
                    achievement,
                    completion.level,
                  )!;
                  return ListTile(
                    leading: AchievementIcon(
                      achievement: achievement,
                      enabled: true,
                      size: 48,
                    ),
                    title: Text(level.getLocalizedName(context.t)),
                    subtitle: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: level.getLocalizedDescription(context.t),
                          ),
                          const TextSpan(text: "\n"),
                          TextSpan(
                            text: context.t.achievements.unlockedOn(
                              date: DateFormat.yMMMMEEEEd(
                                context.locale.languageCode,
                              ).add_Hms().format(completion.completedAt),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

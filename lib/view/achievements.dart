import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:intl/intl.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState
    extends ControlledState<AchievementsView, AchievementsController> {
  @override
  Widget build(BuildContext context) {
    final achievementKeys = achievements.keys.toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("achievements.title".t),
            leading: const SkeletonDrawerButton(),
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
              delegate: SliverChildListDelegate(
                [
                  for (final key in achievementKeys) ...[
                    for (final level in achievements[key]!.levels)
                      AchievementGridTile(
                        achievement: achievements[key]!,
                        level: level,
                        onTap: (achievement, level) {
                          Go.toDialog(() => AchievementGetDialog(
                                achievement: achievement,
                                level: level,
                              ));
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

class AchievementGridTile extends ControlledWidget<AchievementsController> {
  final Achievement achievement;
  final AchievementLevel level;
  final void Function(Achievement, AchievementLevel) onTap;

  const AchievementGridTile({
    required this.achievement,
    required this.level,
    required this.onTap,
    super.key,
  });

  bool get enabled => controller.isUnlocked(achievement, level);

  @override
  Widget build(BuildContext context) {
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
                  child: LayoutBuilder(builder: (context, size) {
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
                  }),
                ),
                // const Spacer(),
                Text(
                  level.localizedName,
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  achievement.shouldShowDescriptionFor(level.level)
                      ? level.descriptionKey.t
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

class AchievementGetDialog extends ControlledWidget<AchievementsController> {
  final Achievement achievement;
  final AchievementLevel level;

  const AchievementGetDialog({
    required this.achievement,
    required this.level,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              size: min(context.width, 96),
            ),
            const SizedBox(height: 16),
            Text(
              level.localizedName,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodyLarge,
            ),
            Text(
              achievement.shouldShowDescriptionFor(level.level)
                  ? level.descriptionKey.t
                  : "???",
              textAlign: TextAlign.center,
            ),
            if (completion == null &&
                level.canShowProgress &&
                achievement.shouldShowDescriptionFor(level.level)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(
                  value: level.progress!() / level.progressMax!(),
                ),
              ),
              Text(
                _getProgressText(),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            if (completion != null || !level.canShowProgress) ...[
              Text(
                completion == null
                    ? "achievements.locked".t
                    : "achievements.unlockedOn".tParams({
                        "date":
                            DateFormat.yMMMMEEEEd(context.locale.languageCode)
                                .add_Hms()
                                .format(completion.completedAt),
                      }),
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
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  String _getProgressText() {
    assert(level.canShowProgress);
    final progress = level.progress!();
    final progressMax = level.progressMax!();

    if (level.progressText != null) {
      return "${level.progressText!(progress)} / ${level.progressText!(progressMax)}";
    } else {
      return "$progress / $progressMax";
    }
  }
}

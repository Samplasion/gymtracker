import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:intl/intl.dart';

class AchievementHistoryTile extends ConsumerWidget {
  const AchievementHistoryTile({super.key, required this.completion});
  final AchievementCompletion completion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievement = ref.watch(
      achievementMetadataProvider,
    )[completion.achievementID];
    final level =
        achievement != null &&
            completion.level > 0 &&
            completion.level <= achievement.levels.length
        ? achievement.getLevel(completion)
        : null;
    return ListTile(
      leading: achievement == null || level == null
          ? const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.emoji_events_outlined),
            )
          : AchievementIcon(achievement: achievement, enabled: true, size: 48),
      title: Text(
        level?.getLocalizedName(context.t) ??
            context.t.friendsList.unknownAchievement,
      ),
      subtitle: Text(
        [
          if (level != null) level.getLocalizedDescription(context.t),
          context.t.achievements.unlockedOn(
            date: DateFormat.yMMMMEEEEd(
              context.locale.languageCode,
            ).add_Hms().format(completion.completedAt),
          ),
        ].join('\n'),
      ),
    );
  }
}

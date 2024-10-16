import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';

class AchievementListTile extends StatelessWidget {
  final Achievement achievement;
  final AchievementCompletion completion;

  const AchievementListTile({
    required this.achievement,
    required this.completion,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AchievementIcon(achievement: achievement),
      title: Text(achievement.getLevel(completion)!.localizedName),
      subtitle: Text(achievement.getLevel(completion)!.descriptionKey.t),
    );
  }
}

class AchievementIcon extends StatelessWidget {
  final Achievement achievement;
  final Color? color;
  final double size;
  final bool enabled;

  const AchievementIcon({
    super.key,
    required this.achievement,
    this.color,
    this.size = 48,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final key = "assets/svg/trophies/${achievement.iconKey}.svg";
    return SvgPicture.asset(
      key,
      width: size,
      height: size,
      theme: SvgTheme(
        currentColor: enabled
            ? (color ?? context.harmonizeColor(Colors.amber))
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class AchievementSnackBar extends SnackBar {
  final Achievement achievement;
  final AchievementCompletion completion;

  AchievementSnackBar({
    required this.achievement,
    required this.completion,
    super.key,
  }) : super(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 15),
          content: Row(
            children: [
              AchievementIcon(achievement: achievement, size: 32),
              const SizedBox(width: 16),
              Builder(builder: (context) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.getLevel(completion)!.localizedName,
                        style: context.theme.textTheme.bodyLarge!.copyWith(
                          color: context.theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        achievement.getLevel(completion)!.descriptionKey.t,
                        style: context.theme.textTheme.bodySmall!.copyWith(
                          color: context.theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
}

extension AchievementLevelName on AchievementLevel {
  String get localizedName => "${nameKey.t} ${level.toRomanNumeral()}";
}

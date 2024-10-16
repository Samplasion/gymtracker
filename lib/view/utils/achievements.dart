import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymtracker/gen/assets.gen.dart';
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

class AchievementIcon extends StatefulWidget {
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
  State<AchievementIcon> createState() => _AchievementIconState();
}

class _AchievementIconState extends State<AchievementIcon> {
  late Future<String> _icon;

  @override
  void initState() {
    super.initState();
    _icon = rootBundle
        .loadString("assets/svg/trophies/${widget.achievement.iconKey}.svg")
        .catchError((e) {
      return rootBundle.loadString(GTAssets.svg.trophies.generic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _icon,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.square(
              dimension: widget.size,
              child: const CircularProgressIndicator(),
            );
          }
          return SvgPicture.string(
            snapshot.data!,
            width: widget.size,
            height: widget.size,
            theme: SvgTheme(
              currentColor: widget.enabled
                  ? (widget.color ??
                      context.harmonizeColor(widget.achievement.color))
                  : Theme.of(context).colorScheme.outline,
            ),
          );
        });
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

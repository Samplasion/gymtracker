import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/gen/assets.gen.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
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
      subtitle: Text(achievement.getLevel(completion)!.localizedDescription),
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
        var svgPicture = SvgPicture.string(
          snapshot.data!,
          width: widget.size,
          height: widget.size,
          theme: SvgTheme(
            currentColor: (widget.color ??
                context.harmonizeColor(widget.achievement.color)),
          ),
        );
        if (widget.enabled) return svgPicture;
        return Stack(
          children: [
            if (Platform.isIOS)
              SvgPicture.asset(
                GTAssets.svg.trophies.generic,
                width: widget.size,
                height: widget.size,
                theme: SvgTheme(
                  currentColor: context.theme.colorScheme.outline,
                ),
              )
            else
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.outline,
                  ],
                  begin: Alignment.center,
                  end: Alignment.center,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: svgPicture,
              ),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget.size / 4),
                  child: Icon(
                    GTIcons.achievement_locked,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
                        achievement.getLevel(completion)!.localizedDescription,
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

class AchievementBanner extends MaterialBanner {
  final Achievement achievement;
  final AchievementCompletion completion;

  AchievementBanner({
    required this.achievement,
    required this.completion,
    super.key,
  }) : super(
          content: AchievementListTile(
            achievement: achievement,
            completion: completion,
          ),
          actions: [
            Builder(builder: (context) {
              return TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              );
            }),
          ],
        );
}

extension AchievementLevelLocalized on AchievementLevel {
  String get localizedName {
    if (achievements[achievementID]!.levels.length == 1) return nameKey.t;
    return "${nameKey.t} ${level.toRomanNumeral()}";
  }

  String get localizedDescription =>
      descriptionKey.tParams(descriptionParameters());
}

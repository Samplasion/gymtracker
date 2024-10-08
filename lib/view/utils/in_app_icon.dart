import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';

class InAppIcon extends StatelessWidget {
  final double size;
  final double iconSize;

  const InAppIcon({
    this.size = 48,
    this.iconSize = 34,
    super.key,
  });

  const InAppIcon.proportional({
    this.size = 48,
    super.key,
  }) :
        // Looks about right
        iconSize = 0.70 * size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(13),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Icon(
          GTIcons.app_icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: iconSize,
        ),
      ],
    );
  }
}

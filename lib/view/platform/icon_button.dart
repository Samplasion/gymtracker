import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformIconButton extends PlatformStatelessWidget {
  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  const PlatformIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: icon,
    );
  }
}

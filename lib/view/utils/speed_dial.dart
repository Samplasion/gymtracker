import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/view/utils/action_icon.dart';

const kSpeedDialButtonHeight = 72.0;
const kSpeedDialButtonSpacing = 16.0;

class SpeedDial extends StatelessWidget {
  final int Function(Breakpoints) crossAxisCountBuilder;
  final List<Widget> buttons;
  final double buttonHeight;
  final double spacing;

  const SpeedDial({
    required this.crossAxisCountBuilder,
    required this.buttons,
    this.buttonHeight = kSpeedDialButtonHeight,
    this.spacing = kSpeedDialButtonSpacing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final crossAxis =
            crossAxisCountBuilder(Breakpoints.computeBreakpoint(size.maxWidth));
        return GridView.count(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: crossAxis,
          childAspectRatio: (size.maxWidth / crossAxis) / buttonHeight,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          children: buttons,
        );
      },
    );
  }
}

class SpeedDialButton extends StatelessWidget {
  final Widget icon;
  final Widget text;
  final VoidCallback onTap;
  final bool enabled;
  final bool showTrailing;

  const SpeedDialButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.enabled = true,
    this.showTrailing = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Center(
          child: ListTile(
            leading: icon,
            title: text,
            enabled: enabled,
            mouseCursor: MouseCursor.defer,
            trailing: showTrailing ? const ListTileActionIcon() : null,
          ),
        ),
      ),
    );
  }
}

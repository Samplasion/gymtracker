import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/view/utils/action_icon.dart';

const kSpeedDialButtonHeight = 72.0;
const kSpeedDialButtonSpacing = 16.0;

class SpeedDial extends StatelessWidget {
  final int Function(Breakpoints) crossAxisCountBuilder;
  final List<Widget> buttons;
  final double Function(Breakpoints) buttonHeight;
  final double spacing;

  const SpeedDial({
    required this.crossAxisCountBuilder,
    required this.buttons,
    this.buttonHeight = _defaultButtonHeight,
    this.spacing = kSpeedDialButtonSpacing,
    super.key,
  });

  static double _defaultButtonHeight(Breakpoints _) => kSpeedDialButtonHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final breakpoint = Breakpoints.computeBreakpoint(size.maxWidth);
        final crossAxis = crossAxisCountBuilder(breakpoint);
        return GridView.count(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          crossAxisCount: crossAxis,
          childAspectRatio:
              (size.maxWidth / crossAxis) / buttonHeight(breakpoint),
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
  final Widget? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showTrailing;
  final bool dense;

  const SpeedDialButton({
    required this.icon,
    required this.text,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.showTrailing = false,
    this.dense = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardTheme = CardTheme.of(context);
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: enabled ? null : 0,
      surfaceTintColor: Colors.transparent,
      color: ElevationOverlay.applySurfaceTint(
        cardTheme.color ?? colorScheme.background,
        cardTheme.surfaceTintColor ?? colorScheme.surfaceTint,
        1,
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListTile(
              leading: icon,
              title: text,
              subtitle: subtitle,
              enabled: enabled,
              mouseCursor: MouseCursor.defer,
              trailing: showTrailing ? const ListTileActionIcon() : null,
              dense: dense,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/view/utils/action_icon.dart';

const kSpeedDialButtonHeight = 72.0;
const kSpeedDialButtonSpacing = 16.0;

class SpeedDialConfiguration extends InheritedWidget {
  final int crossAxisCount;
  final Breakpoints builtBreakpoint;

  const SpeedDialConfiguration({
    required this.crossAxisCount,
    required this.builtBreakpoint,
    required super.child,
    super.key,
  });

  static SpeedDialConfiguration? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SpeedDialConfiguration>();

  static SpeedDialConfiguration of(BuildContext context) {
    final SpeedDialConfiguration? result = maybeOf(context);
    assert(result != null, 'No SpeedDialConfiguration found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SpeedDialConfiguration oldWidget) {
    return oldWidget.crossAxisCount != crossAxisCount ||
        oldWidget.builtBreakpoint != builtBreakpoint;
  }
}

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
        return SpeedDialConfiguration(
          crossAxisCount: crossAxis,
          builtBreakpoint: breakpoint,
          child: GridView.count(
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
          ),
        );
      },
    );
  }
}

class CustomSpeedDialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const CustomSpeedDialButton({
    required this.child,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: enabled ? null : 0.5,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Stack(
          alignment: Alignment.center,
          children: [child],
        ),
      ),
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
    return CustomSpeedDialButton(
      onTap: onTap,
      enabled: true,
      child: ListTile(
        leading: icon,
        title: text,
        subtitle: subtitle,
        enabled: enabled,
        mouseCursor: MouseCursor.defer,
        trailing: showTrailing ? const ListTileActionIcon() : null,
        dense: dense,
      ),
    );
  }
}

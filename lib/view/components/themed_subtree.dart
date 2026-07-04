import 'package:flutter/material.dart';
import 'package:gymtracker/utils/theme.dart';

class ThemedSubtree extends StatefulWidget {
  final Color color;
  final Widget? child;
  final Widget Function(BuildContext)? builder;
  final bool enabled;

  const ThemedSubtree({
    required this.color,
    required this.child,
    this.enabled = true,
    super.key,
  }) : builder = null;

  const ThemedSubtree.builder({
    required this.color,
    required this.builder,
    this.enabled = true,
    super.key,
  }) : child = null;

  @override
  State<ThemedSubtree> createState() => _ThemedSubtreeState();
}

class _ThemedSubtreeState extends State<ThemedSubtree>
    with SingleTickerProviderStateMixin {
  late final Animation<ThemeData> _animation =
      _tween.animate(_animationController)
        ..addListener(() {
          setState(() {});
        });
  late final ThemeTween _tween =
      ThemeTween(begin: getCurrentTheme(), end: getCurrentTheme());
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  );

  ThemeData getCurrentTheme() {
    return getGymTrackerThemeFor(
        context, widget.color, Theme.of(context).brightness);
  }

  Widget _childBuilder(BuildContext context) {
    if (widget.child != null) return widget.child!;

    return widget.builder!(context);
  }

  @override
  void didUpdateWidget(ThemedSubtree oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tween.begin = _animation.value;
    _tween.end = getCurrentTheme();
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tween.end = getCurrentTheme();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return _childBuilder(context);
    return Theme(
      data: _animation.value,
      child: Builder(builder: _childBuilder),
    );
  }
}

class ThemeTween extends Tween<ThemeData> {
  ThemeTween({required ThemeData begin, required ThemeData end})
      : super(begin: begin, end: end);

  @override
  ThemeData lerp(double t) =>
      ThemeData.lerp(begin!, end!, Curves.easeOut.transform(t));
}

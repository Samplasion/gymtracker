import 'package:flutter/material.dart';

class Crossfade extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final bool showSecond;
  final Clip clipBehavior;

  const Crossfade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.showSecond,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: clipBehavior,
      child: AnimatedCrossFade(
        firstChild: ClipRect(clipBehavior: clipBehavior, child: firstChild),
        secondChild: ClipRect(clipBehavior: clipBehavior, child: secondChild),
        crossFadeState:
            showSecond ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
        sizeCurve: Curves.easeInOutCirc,
      ),
    );
  }
}

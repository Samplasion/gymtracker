import 'package:flutter/material.dart';

class Crossfade extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final bool showSecond;

  const Crossfade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.showSecond,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: AnimatedCrossFade(
        firstChild: ClipRect(clipBehavior: Clip.hardEdge, child: firstChild),
        secondChild: ClipRect(clipBehavior: Clip.hardEdge, child: secondChild),
        crossFadeState:
            showSecond ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
        sizeCurve: Curves.easeInOutCirc,
      ),
    );
  }
}

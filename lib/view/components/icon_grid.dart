import 'dart:math';

import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    super.key,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.linear,
    required this.child,
  });

  final Duration duration;
  final double deltaX;
  final Widget child;
  final Curve curve;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..forward()
      ..addListener(() {
        if (controller.isCompleted) {
          controller.repeat();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: ValueKey(widget.duration),
      animation: controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(widget.deltaX * controller.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class IconGrid extends StatelessWidget {
  final Widget child;
  final double bigScale;
  final double littleScale;
  final num? boxWidth;
  final Alignment alignment;
  final double maxCrossAxisExtent;
  final bool animated;

  const IconGrid({
    required this.child,
    this.bigScale = 3,
    this.littleScale = 0.65,
    this.boxWidth,
    this.alignment = Alignment.centerLeft,
    this.maxCrossAxisExtent = 80,
    this.animated = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final boxWidth = this.boxWidth ?? MediaQuery.of(context).size.width;
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: Transform.scale(
        scale: bigScale,
        alignment: alignment,
        child: Transform.rotate(
          angle: 25 * 180 / pi,
          child: () {
            final grid = GridView.extent(
              physics: const NeverScrollableScrollPhysics(),
              maxCrossAxisExtent: maxCrossAxisExtent,
              children: [
                for (int i = 0; i < 1000; i++)
                  Center(
                    child: Opacity(
                      opacity: 0.5,
                      child: Transform.scale(
                        scale: littleScale,
                        child: child,
                      ),
                    ),
                  ),
              ],
            );
            if (!animated) {
              return grid;
            }
            return ShakeWidget(
              deltaX: -boxWidth /
                  _getItemCountPerRow(
                    context,
                    maxCrossAxisExtent,
                    boxWidth,
                  ),
              duration: const Duration(seconds: 15),
              child: grid,
            );
          }(),
        ),
      ),
    );
  }

  int _getItemCountPerRow(
      BuildContext context, double maxCrossAxisExtent, num boxWidth) {
    double availableWidth = boxWidth.toDouble();
    int crossAxisCount = (availableWidth / (maxCrossAxisExtent)).ceil();
    crossAxisCount = max(1, crossAxisCount);

    return crossAxisCount;
  }
}

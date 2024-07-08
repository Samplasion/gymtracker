import 'package:flutter/material.dart';

class GradientBottomBar extends StatelessWidget {
  const GradientBottomBar({
    super.key,
    required this.buttons,
    this.color,
    this.alignment = MainAxisAlignment.end,
    this.topButtonPadding = 12.0,
    this.center = false,
  });

  final List<Widget> buttons;
  final Color? color;
  final MainAxisAlignment alignment;
  final double topButtonPadding;
  final bool center;

  static (EdgeInsets, double, double) _getMetrics(
    BuildContext context, {
    topButtonPadding = 0.0,
  }) {
    final safeArea = MediaQuery.of(context).padding;
    const kBottomCalBarHeight = 48.0;
    final bottomNavigationBarHeight =
        kBottomCalBarHeight + safeArea.bottom + 16 + topButtonPadding;
    return (
      safeArea,
      kBottomCalBarHeight,
      bottomNavigationBarHeight,
    );
  }

  /// Wraps the child with a MediaQuery that includes the bottomNavigationBarHeight
  /// in the padding.
  static wrap({required BuildContext context, required Widget child}) {
    final (safeArea, _, bottomNavigationBarHeight) = _getMetrics(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: safeArea.copyWith(
          bottom: safeArea.bottom + bottomNavigationBarHeight,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradientColor = color ?? colorScheme.surface;
    final (
      safeArea,
      kBottomCalBarHeight,
      bottomNavigationBarHeight,
    ) = _getMetrics(context, topButtonPadding: topButtonPadding);
    var overflowBar = OverflowBar(
      alignment: alignment,
      spacing: 8,
      overflowSpacing: 16,
      // mainAxisAlignment: alignment,
      children: buttons,
    );
    return Container(
      alignment: Alignment.topCenter,
      height: bottomNavigationBarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColor.withAlpha(0),
            gradientColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0,
            16 / (16 + kBottomCalBarHeight + safeArea.bottom),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: topButtonPadding,
          ),
          child: center
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: safeArea.bottom),
                    child: overflowBar,
                  ),
                )
              : overflowBar,
        ),
      ),
    );
  }
}

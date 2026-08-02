import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final Gradient? pulseGradient;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.gradient,
    this.pulseGradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1160),
    );
    _pulseAnimation = Tween<double>(
      begin: -5,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getColorAt(double position) {
    if (widget.gradient is LinearGradient) {
      final linearGradient = widget.gradient as LinearGradient;
      final colors = linearGradient.colors;
      final stops =
          linearGradient.stops ??
          List.generate(colors.length, (index) => index / (colors.length - 1));
      for (int i = 0; i < stops.length - 1; i++) {
        if (position >= stops[i] && position <= stops[i + 1]) {
          final t = (position - stops[i]) / (stops[i + 1] - stops[i]);
          return Color.lerp(colors[i], colors[i + 1], t)!;
        }
      }
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final centerColor = getColorAt(0.5);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = _pulseAnimation.value;

            return Positioned(
              top: -offset,
              bottom: -offset,
              left: -offset,
              right: -offset,
              child: Padding(
                // Buttons add an implicit padding of 4 in the Y axis (probably due to the shadow)
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.pulseGradient ?? widget.gradient,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        GradientElevatedButton(
          onPressed: widget.onPressed,
          style: GradientElevatedButton.styleFrom(
            backgroundGradient: widget.gradient,
          ),
          child: DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: centerColor.onColor),
            child: widget.child,
          ),
        ),
      ],
    );

    // return Stack(
    //   children: [
    //     Positioned.fill(
    //       child: LayoutBuilder(
    //         builder: (context, constraints) {
    //           return AnimatedBuilder(
    //             animation: _controller,
    //             builder: (context, child) {
    //               final buttonSize = Size(
    //                 constraints.minWidth,
    //                 constraints.minHeight,
    //               );
    //               final delta =
    //                   (const Size(100, 100) - _sizeAnimation.value) as Offset;
    //               final effectiveSize = (buttonSize - delta) as Size;
    //               final scaleX = effectiveSize.width / buttonSize.width;
    //               final scaleY = effectiveSize.height / buttonSize.height;

    //               // print(
    //               //   "scaleX: $scaleX, scaleY: $scaleY, effectiveSize: $effectiveSize, buttonSize: $buttonSize, delta: $delta",
    //               // );
    //               return Opacity(
    //                 opacity: _opacityAnimation.value,
    //                 child: Container(
    //                   width: effectiveSize.width,
    //                   height: effectiveSize.height,
    //                   decoration: BoxDecoration(
    //                     gradient: widget.gradient,
    //                     borderRadius: BorderRadius.circular(8.0),
    //                   ),
    //                 ),
    //               );
    //               return Transform.scale(
    //                 scaleX: scaleX,
    //                 scaleY: scaleY,
    //                 child: Opacity(
    //                   opacity: _opacityAnimation.value,
    //                   child: Container(
    //                     decoration: BoxDecoration(
    //                       gradient: widget.gradient,
    //                       borderRadius: BorderRadius.circular(8.0),
    //                     ),
    //                   ),
    //                 ),
    //               );
    //             },
    //           );
    //         },
    //       ),
    //     ),
    //     // Ink(
    //     //   decoration: BoxDecoration(
    //     //     gradient: widget.gradient,
    //     //     borderRadius: BorderRadius.circular(8.0),
    //     //   ),
    //     //   child: InkWell(
    //     //     onTap: widget.onPressed,
    //     //     child: Container(
    //     //       alignment: Alignment.center,
    //     //       padding: const EdgeInsets.symmetric(
    //     //         vertical: 12.0,
    //     //         horizontal: 16.0,
    //     //       ),
    //     //       child: DefaultTextStyle(
    //     //         style: Theme.of(
    //     //           context,
    //     //         ).textTheme.labelLarge!.copyWith(color: centerColor.onColor),
    //     //         child: widget.child,
    //     //       ),
    //     //     ),
    //     //   ),
    //     // ),
    //     GradientElevatedButton(
    //       onPressed: widget.onPressed,
    //       style: GradientElevatedButton.styleFrom(
    //         backgroundGradient: widget.gradient,
    //       ),
    //       child: DefaultTextStyle(
    //         style: Theme.of(
    //           context,
    //         ).textTheme.labelLarge!.copyWith(color: centerColor.onColor),
    //         child: widget.child,
    //       ),
    //     ),
    //   ],
    // );
  }
}

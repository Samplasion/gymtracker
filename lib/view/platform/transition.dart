import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformTransition extends PlatformStatelessWidget {
  final SharedAxisTransitionType materialTransitionType;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const PlatformTransition({
    super.key,
    required this.materialTransitionType,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: child,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return SharedAxisTransition(
      transitionType: SharedAxisTransitionType.horizontal,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

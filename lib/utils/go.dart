import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class Go {
  static Future<T?> to<T>(Widget Function() page) async {
    return Navigator.of(Get.context!).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => page(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            transitionType: SharedAxisTransitionType.horizontal,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    );
  }

  static Future<T?> off<T>(Widget Function() page) async {
    Navigator.of(Get.context!).pop();
    return to<T>(page);
  }

  static Future snack(String text) async {
    final snackBar = SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }
}

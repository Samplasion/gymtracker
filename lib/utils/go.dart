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

  static void dialog(
    String title,
    String body, {
    Widget? icon,
  }) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          icon: icon ?? const Icon(Icons.info),
          title: Text(title.tr),
          content: Text(body.tr),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
  }
}

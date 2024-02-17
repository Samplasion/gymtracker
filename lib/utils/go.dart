import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/platform/dialogs_modals.dart';
import 'package:gymtracker/view/platform/transition.dart';

class Go {
  static Future<T?> to<T>(Widget Function() page) async {
    final platformController = Get.find<PlatformController>();
    if (platformController.platform.value == UIPlatform.cupertino) {
      return Navigator.of(Get.context!).push<T>(
        CupertinoPageRoute(
          builder: (context) => page(),
        ),
      );
    }
    return Navigator.of(Get.context!).push<T>(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => page(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return PlatformTransition(
            materialTransitionType: SharedAxisTransitionType.horizontal,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    );
  }

  static Future<T?> toDialog<T>(Widget Function() page) async {
    showDialog(context: Get.context!, builder: (_) => page());
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
    List<Widget> actions = const <Widget>[],
  }) {
    showPlatformDialog(
      context: Get.context!,
      builder: (context) {
        return PlatformAlertDialog(
          icon: icon ?? const Icon(Icons.info),
          title: Text(title.t),
          content: Text(body.t),
          actions: [
            ...actions,
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

  static Future<bool> confirm(
    String title,
    String body, {
    Widget? icon,
  }) {
    return showPlatformDialog<bool>(
      context: Get.context!,
      builder: (context) {
        return PlatformAlertDialog(
          icon: icon ?? const Icon(Icons.info),
          title: Text(title.t),
          content: Text(body.t),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(result: false);
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                Get.back(result: true);
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}

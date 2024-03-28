import 'package:flutter/material.dart' hide Material;
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Go {
  static Navigator get navigator => Get.find<Navigator>();

  static Future<T?> to<T>(Widget Function() page) async {
    return Navigator.of(Get.context!).push<T>(
      MaterialWithModalsPageRoute(
        builder: (context) => page(),
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

  static Future<T?> replace<T>(Widget Function() page) async {
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    return off<T>(page);
  }

  static Future snack(String text, {SnackBarAction? action}) async {
    final snackBar = SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      action: action,
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }

  static void dialog(
    String title,
    String body, {
    Widget? icon,
    List<Widget> actions = const <Widget>[],
  }) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
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
    String Function(String) transformText = _defaultT,
  }) {
    return showDialog<bool>(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
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

  static Future<T?> showBottomModalScreen<T>(
      Widget Function(BuildContext, ScrollController?) page) async {
    final context = Get.context!;
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => page(context, ModalScrollController.of(context)),
      duration: const Duration(milliseconds: 250),
    );
  }
}

String _defaultT(String s) => s.t;

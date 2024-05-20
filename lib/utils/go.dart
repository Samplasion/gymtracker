import 'package:flutter/material.dart' hide Material;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Go {
  static Navigator get navigator => Get.find<Navigator>();

  /// Returns the name of the topmost route in the navigator stack.
  ///
  /// This is a workaround for the fact that [Navigator] does not have a method
  /// to get the topmost route name. Please use this method with caution.
  static String? getTopmostRouteName() {
    String? top;
    Navigator.popUntil(Get.context!, (route) {
      top = route.settings.name;
      return true;
    });
    return top;
  }

  static Route<T> materialRoute<T>(Widget Function() page) {
    return MaterialWithModalsPageRoute(
      builder: (context) => page(),
    );
  }

  static Future<T?> to<T>(Widget Function() page) async {
    return Navigator.of(Get.context!).push<T>(materialRoute(page));
  }

  static Future<T?> toNamed<T>(String route, {Object? arguments}) async {
    return Navigator.of(Get.context!).pushNamed<T>(route, arguments: arguments);
  }

  static Future<T?> toDialog<T>(Widget Function() page) async {
    return showDialog(context: Get.context!, builder: (_) => page());
  }

  static Future<T?> off<T>(Widget Function() page) async {
    Navigator.of(Get.context!).pop();
    return to<T>(page);
  }

  static Future<T?> replaceStack<T>(Widget Function() page) async {
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    return off<T>(page);
  }

  static Future snack(
    String text, {
    SnackBarAction? action,
    bool assertive = false,
  }) async {
    final snackBar = SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      action: action,
    );
    var messenger = ScaffoldMessenger.of(Get.context!);
    if (assertive) messenger.clearSnackBars();
    messenger.showSnackBar(snackBar);
  }

  static void dialog(
    String title,
    String body, {
    Widget? icon,
    List<Widget> actions = const <Widget>[],
    bool scrollable = true,
    TextStyle? bodyStyle,
  }) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          icon: icon ?? const Icon(GymTrackerIcons.info),
          title: Text(title.t),
          content: Text(body.t, style: bodyStyle),
          scrollable: scrollable,
          clipBehavior: Clip.hardEdge,
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
          icon: icon ?? const Icon(GymTrackerIcons.info),
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

  static Future<void> showRadioModal<T>({
    required T? selectedValue,
    required Map<T, String> values,
    required Widget title,
    required void Function(T?)? onChange,
  }) async {
    final T? oldValue = selectedValue;
    T? _value = selectedValue;
    final revert = await showModalBottomSheet<bool>(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: title,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in values.entries)
                          RadioListTile<T>(
                            title: Text(entry.value),
                            value: entry.key,
                            groupValue: _value,
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  _value = value;
                                  onChange?.call(value);
                                }
                              });
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                setState(() {});
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton(
                            child: Text(MaterialLocalizations.of(context)
                                .cancelButtonLabel),
                            onPressed: () {
                              onChange?.call(oldValue);
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text(MaterialLocalizations.of(context)
                                .okButtonLabel),
                            onPressed: () {
                              if (onChange != null) {
                                onChange(_value);
                              }
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (revert != true) {
      globalLogger.i("[Go.showRadioModal]\nReverting");
      onChange?.call(oldValue);
    }
  }
}

String _defaultT(String s) => s.t;

import 'dart:async';

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

  static Route<T> materialRoute<T>(
    Widget Function() page, {
    RouteSettings? settings,
    bool animation = true,
  }) {
    if (!animation) {
      return _NoAnimMaterialWithModalsPageRoute(
        builder: (context) => page(),
        settings: settings,
      );
    }
    return MaterialWithModalsPageRoute(
      builder: (context) => page(),
      settings: settings,
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

  static Future<T?> offWithoutAnimation<T>(Widget Function() page) async {
    Navigator.of(Get.context!).pushReplacement(
      materialRoute(page, animation: false),
    );
  }

  static Future<T?> replaceStack<T>(Widget Function() page) async {
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    return off<T>(page);
  }

  static Future snack(
    Object text, {
    SnackBarAction? action,
    bool assertive = false,
    Duration duration = const Duration(milliseconds: 4000),
    Color? backgroundColor,
  }) async {
    assert(text is String || text is Widget, "Text must be a String or Widget");
    return customSnack(
      SnackBar(
        content: text is String ? Text(text) : text as Widget,
        behavior: SnackBarBehavior.floating,
        action: action,
        duration: duration,
        backgroundColor: backgroundColor,
      ),
      assertive: assertive,
    );
  }

  static Future customSnack(
    SnackBar snackBar, {
    bool assertive = false,
  }) async {
    var messenger = ScaffoldMessenger.of(Get.context!);
    if (assertive) messenger.clearSnackBars();
    messenger.showSnackBar(snackBar);
  }

  static Future banner(
    String text, {
    List<Widget>? actions,
    Color? color,
    Color? textColor,
    bool assertive = false,
  }) async {
    return customBanner(
      MaterialBanner(
        content: Text(text),
        actions: actions ??
            [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(Get.context!)
                      .hideCurrentMaterialBanner();
                },
                child:
                    Text(MaterialLocalizations.of(Get.context!).okButtonLabel),
              ),
            ],
        backgroundColor: color,
        contentTextStyle: TextStyle(color: textColor),
      ),
      assertive: assertive,
    );
  }

  static Future customBanner(
    MaterialBanner banner, {
    bool assertive = false,
  }) async {
    var messenger = ScaffoldMessenger.of(Get.context!);
    if (assertive) messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(banner);
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
          icon: icon ?? const Icon(GTIcons.info),
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
          icon: icon ?? const Icon(GTIcons.info),
          title: Text(title.t),
          content: Text(body.t),
          actions: [
            TextButton(
              onPressed: () {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Get.back(result: false);
                });
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Get.back(result: true);
                });
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  static Future<T?> showBottomSheet<T>(
      Widget Function(BuildContext) builder) async {
    return await showModalBottomSheet<T>(
      context: Get.context!,
      builder: builder,
    );
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
    bool fullScreen = false,
  }) async {
    final T? oldValue = selectedValue;
    T? _value = selectedValue;

    Widget builder(context) {
      return StatefulBuilder(
        builder: (context, setState) {
          if (fullScreen) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: title,
                  leading: IconButton(
                    icon: const Icon(GTIcons.close),
                    onPressed: () {
                      onChange?.call(oldValue);
                      Navigator.of(context).pop(false);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(GTIcons.save),
                      onPressed: () {
                        if (onChange != null) {
                          onChange(_value);
                        }
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
                body: ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    final entry = values.entries.elementAt(
                      index,
                    );

                    return RadioListTile<T>(
                      title: Text(entry.value),
                      value: entry.key,
                      groupValue: _value,
                      activeColor: Theme.of(context).colorScheme.secondary,
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
                    );
                  },
                ),
              ),
            );
          }
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
                          activeColor: Theme.of(context).colorScheme.secondary,
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
                          child: Text(
                              MaterialLocalizations.of(context).okButtonLabel),
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
    }

    final revert = fullScreen
        ? await showDialog<bool>(
            context: Get.context!,
            builder: builder,
          )
        : await showModalBottomSheet<bool>(
            context: Get.context!,
            builder: builder,
          );

    if (revert != true) {
      globalLogger.i("[Go.showRadioModal]\nReverting");
      onChange?.call(oldValue);
    }
  }

  static Future<void> futureDialog<T>({
    required Future<T> Function() future,
    required String title,
    String? body,
  }) async {
    final context = Get.context!;
    final computation = future();

    computation.then((_) => SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        }));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: FutureBuilder<T>(
            future: computation,
            builder: (context, snapshot) {
              return AlertDialog(
                title: Text(title.t),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (body != null) Text(body.t),
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
                actions: [
                  if (snapshot.connectionState == ConnectionState.done)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child:
                          Text(MaterialLocalizations.of(context).okButtonLabel),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static void popUntil(bool Function(Route route) predicate) {
    Navigator.of(Get.context!).popUntil(predicate);
  }

  static Future<T?> pick<T>({
    required Map<T, String> values,
    required String title,
  }) async {
    Widget builder(context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Text(title),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in values.entries)
                          ListTile(
                            title: Text(entry.value),
                            onTap: () {
                              Navigator.of(context).pop(entry.key);
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
                                .closeButtonLabel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return await showModalBottomSheet<T>(
      context: Get.context!,
      builder: builder,
    );
  }

  static Future<void> awaitInitialization() {
    final completer = Completer<void>();
    final sub =
        Stream.periodic(const Duration(milliseconds: 100)).listen((event) {
      if (Get.context != null) {
        completer.complete();
      }
    });
    return completer.future.whenComplete(() => sub.cancel());
  }
}

String _defaultT(String s) => s.t;

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class _NoAnimMaterialWithModalsPageRoute<T>
    extends MaterialWithModalsPageRoute<T> {
  _NoAnimMaterialWithModalsPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is MaterialWithModalsPageRoute &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is _NoAnimMaterialWithModalsPageRoute &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is ModalSheetRoute);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      child: super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        Theme(
          data: Theme.of(context),
          child: child,
        ),
      ),
    );
  }
}

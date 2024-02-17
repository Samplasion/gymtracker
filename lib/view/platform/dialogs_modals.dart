import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

PlatformController get controller => Get.find<PlatformController>();

Future<T?> showPlatformDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  if (controller.platform.value == UIPlatform.cupertino) {
    return cupertino.showCupertinoDialog(
      context: context,
      builder: builder,
    );
  } else {
    return material.showDialog(
      context: context,
      builder: builder,
    );
  }
}

Future<T?> showPlatformModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  if (controller.platform.value == UIPlatform.cupertino) {
    return cupertino.showCupertinoModalPopup(
      context: context,
      builder: builder,
    );
  } else {
    return material.showModalBottomSheet(
      context: context,
      builder: builder,
    );
  }
}

class PlatformAlertDialog extends PlatformStatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<Widget> actions;
  final bool scrollable;

  const PlatformAlertDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions = const <Widget>[],
    this.scrollable = false,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return material.AlertDialog(
      title: title,
      content: content,
      actions: actions,
      scrollable: scrollable,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    printInfo(info: 'buildCupertino');
    return cupertino.CupertinoAlertDialog(
      title: title,
      content: content,
      actions: actions,
    );
  }
}

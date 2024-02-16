import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';

PlatformController get controller => Get.find<PlatformController>();

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

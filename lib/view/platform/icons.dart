import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';

class PlatformIcons {
  PlatformIcons._() {
    throw UnsupportedError('PlatformIcons cannot be instantiated');
  }

  static PlatformController get controller => Get.find<PlatformController>();

  static _icon(IconData material, IconData cupertino) {
    return controller.platform.value == UIPlatform.material
        ? material
        : cupertino;
  }

  static IconData get add => _icon(Icons.add, CupertinoIcons.add);

  static IconData get library =>
      _icon(Icons.local_library_rounded, CupertinoIcons.book);
  static IconData get history =>
      _icon(Icons.history_rounded, CupertinoIcons.time);
  static IconData get settings =>
      _icon(Icons.settings_rounded, CupertinoIcons.settings);
  static IconData get debug =>
      _icon(Icons.bug_report_rounded, CupertinoIcons.ant_fill);
  static IconData get stopwatch =>
      _icon(Icons.timer_rounded, CupertinoIcons.stopwatch);
  static IconData get calculator =>
      _icon(Icons.calculate_rounded, CupertinoIcons.number_circle_fill);
  static IconData get delete_forever =>
      _icon(Icons.delete_forever_rounded, CupertinoIcons.delete_solid);
}

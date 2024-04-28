import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:universal_platform/universal_platform.dart';

class DragHandle extends StatelessWidget {
  final int index;

  const DragHandle({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      return ReorderableDelayedDragStartListener(
        index: index,
        child: const Icon(GymTrackerIcons.drag_handle),
      );
    } else {
      return ReorderableDragStartListener(
        index: index,
        child: const Icon(GymTrackerIcons.drag_handle),
      );
    }
  }
}

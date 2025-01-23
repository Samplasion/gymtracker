import 'package:flutter/material.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:universal_platform/universal_platform.dart';

class DragHandle extends StatelessWidget {
  final int index;

  const DragHandle({required this.index, super.key});

  @override
  Widget build(BuildContext context) => DraggableChild(
        index: index,
        child: const Icon(GTIcons.drag_handle),
      );
}

class DraggableChild extends StatelessWidget {
  final int index;
  final Widget child;

  const DraggableChild({
    required this.index,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      return ReorderableDelayedDragStartListener(
        index: index,
        child: child,
      );
    } else {
      return ReorderableDragStartListener(
        index: index,
        child: child,
      );
    }
  }
}

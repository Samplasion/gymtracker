import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';
import 'package:universal_platform/universal_platform.dart';

class DragHandle extends StatelessWidget {
  final int index;

  const DragHandle({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = PlatformBuilder(
      buildMaterial: (BuildContext context, _) => const Icon(Icons.drag_handle),
      buildCupertino: (BuildContext context, _) => const Icon(
        CupertinoIcons.bars,
        color: CupertinoColors.systemGrey,
      ),
    );

    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      return ReorderableDelayedDragStartListener(
        index: index,
        child: icon,
      );
    } else {
      return ReorderableDragStartListener(
        index: index,
        child: icon,
      );
    }
  }
}

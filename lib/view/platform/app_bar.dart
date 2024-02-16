import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformSliverAppBar extends PlatformStatelessWidget {
  final Widget title;

  const PlatformSliverAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return SliverAppBar.large(
      title: title,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: title,
    );
  }
}

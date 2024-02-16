import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformScaffold extends StatefulWidget {
  final PreferredSizeWidget? materialAppBar;
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.materialAppBar,
    this.cupertinoNavigationBar,
    this.extendBody = false,
  });

  @override
  State<PlatformScaffold> createState() => _PlatformScaffoldState();
}

class _PlatformScaffoldState extends PlatformState<PlatformScaffold> {
  final bottomNavBarKey = GlobalKey();

  @override
  Widget buildMaterial(BuildContext context) {
    return Scaffold(
      appBar: widget.materialAppBar,
      body: widget.body,
      bottomNavigationBar: widget.bottomNavigationBar,
      extendBody: widget.extendBody,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    double bottomNavBarHeight = 0;

    if (!widget.extendBody && widget.bottomNavigationBar != null) {
      final bottomNavBarContext = bottomNavBarKey.currentContext;
      if (bottomNavBarContext != null) {
        final bottomNavBarBox =
            bottomNavBarContext.findRenderObject() as RenderBox;
        bottomNavBarHeight = bottomNavBarBox.size.height;
      }
    }

    return CupertinoPageScaffold(
      navigationBar: widget.cupertinoNavigationBar,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: bottomNavBarHeight..printInfo(info: "bottomNavBarHeight"),
            child: widget.body,
          ),
          if (widget.bottomNavigationBar != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: KeyedSubtree(
                key: bottomNavBarKey,
                child: widget.bottomNavigationBar!,
              ),
            ),
        ],
      ),
    );
  }
}

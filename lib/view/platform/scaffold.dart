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
  final bool? resizeToAvoidBottomInset;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.materialAppBar,
    this.cupertinoNavigationBar,
    this.extendBody = false,
    this.resizeToAvoidBottomInset,
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
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
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

    final MediaQueryData existingMediaQuery = MediaQuery.of(context);
    MediaQueryData newMediaQuery = MediaQuery.of(context);

    Widget content = widget.body;
    EdgeInsets contentPadding = EdgeInsets.zero;

    if (!widget.extendBody) {
      // Remove the view inset and add it back as a padding in the inner content.
      newMediaQuery = newMediaQuery.removeViewInsets(removeBottom: true);
      contentPadding =
          EdgeInsets.only(bottom: existingMediaQuery.viewInsets.bottom);
    }

    // Only pad the content with the height of the tab bar if the tab
    // isn't already entirely obstructed by a keyboard or other view insets.
    // Don't double pad.
    if (widget.extendBody ||
        bottomNavBarHeight > existingMediaQuery.viewInsets.bottom) {
      // https://github.com/flutter/flutter/issues/12912
      final double bottomPadding =
          bottomNavBarHeight + existingMediaQuery.padding.bottom;

      // If tab bar opaque, directly stop the main content higher. If
      // translucent, let main content draw behind the tab bar but hint the
      // obstructed area.
      newMediaQuery = newMediaQuery.copyWith(
        padding: newMediaQuery.padding.copyWith(
          bottom: bottomPadding,
        ),
      );
    }

    content = MediaQuery(
      data: newMediaQuery,
      child: Padding(
        padding: contentPadding,
        child: content,
      ),
    );

    return CupertinoPageScaffold(
      navigationBar: widget.cupertinoNavigationBar,
      child: Stack(
        children: <Widget>[
          // The main content being at the bottom is added to the stack first.
          content,
          if (widget.bottomNavigationBar != null)
            MediaQuery(
              data: existingMediaQuery.copyWith(textScaleFactor: 1),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: KeyedSubtree(
                  key: bottomNavBarKey,
                  child: widget.bottomNavigationBar!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

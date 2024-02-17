import 'package:flutter/cupertino.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformPadded extends PlatformStatelessWidget {
  final Widget sliver;

  const PlatformPadded({
    super.key,
    required this.sliver,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return sliver;
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return SliverPadding(
      padding: MediaQuery.of(context).removePadding(removeTop: true).padding,
      sliver: sliver,
    );
  }
}

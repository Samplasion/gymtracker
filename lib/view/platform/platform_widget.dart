import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/platform_controller.dart';

abstract class PlatformStatelessWidget extends StatelessWidget {
  const PlatformStatelessWidget({super.key});

  PlatformController get controller => Get.find<PlatformController>();

  @override
  Widget build(BuildContext context) {
    return controller.platform.value == UIPlatform.material
        ? buildMaterial(context)
        : buildCupertino(context);
  }

  /// Describes the part of the user interface represented by this widget in
  /// the Material design language.
  ///
  /// {@template gymtracker_platform_widget_info}
  /// The framework calls this method when this widget is inserted into the tree
  /// in a given [BuildContext] and when the dependencies of this widget change
  /// (e.g., an [InheritedWidget] referenced by this widget changes). This
  /// method can potentially be called in every frame and should not have any side
  /// effects beyond building a widget.
  ///
  /// The framework replaces the subtree below this widget with the widget
  /// returned by this method, either by updating the existing subtree or by
  /// removing the subtree and inflating a new subtree, depending on whether the
  /// widget returned by this method can update the root of the existing
  /// subtree, as determined by calling [Widget.canUpdate].
  ///
  /// Typically implementations return a newly created constellation of widgets
  /// that are configured with information from this widget's constructor and
  /// from the given [BuildContext].
  ///
  /// The given [BuildContext] contains information about the location in the
  /// tree at which this widget is being built. For example, the context
  /// provides the set of inherited widgets for this location in the tree. A
  /// given widget might be built with multiple different [BuildContext]
  /// arguments over time if the widget is moved around the tree or if the
  /// widget is inserted into the tree in multiple places at once.
  ///
  /// The implementation of this method must only depend on:
  ///
  /// * the fields of the widget, which themselves must not change over time,
  ///   and
  /// * any ambient state obtained from the `context` using
  ///   [BuildContext.dependOnInheritedWidgetOfExactType].
  ///
  /// If a widget's [build] method is to depend on anything else, use a
  /// [StatefulWidget] instead.
  ///
  /// See also:
  ///
  ///  * [StatelessWidget], which contains the discussion on performance considerations.
  /// {@endtemplate}
  ///  * [buildCupertino], which does the same thing but for the Cupertino library.
  Widget buildMaterial(BuildContext context);

  /// Describes the part of the user interface represented by this widget in
  /// the Cupertino design language.
  ///
  /// {@macro gymtracker_platform_widget_info}
  ///  * [buildMaterial], which does the same thing but for the Material library.
  Widget buildCupertino(BuildContext context);
}

abstract class PlatformState<T extends StatefulWidget> extends State<T> {
  PlatformController get controller => Get.find<PlatformController>();

  @override
  void initState() {
    super.initState();
    controller.addListener(_update);
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return controller.platform.value == UIPlatform.material
        ? buildMaterial(context)
        : buildCupertino(context);
  }

  /// Describes the part of the user interface represented by this widget in
  /// the Material design language.
  ///
  /// {@macro gymtracker_platform_widget_info}
  ///  * [buildCupertino], which does the same thing but for the Cupertino library.
  Widget buildMaterial(BuildContext context);

  /// Describes the part of the user interface represented by this widget in
  /// the Cupertino design language.
  ///
  /// {@macro gymtracker_platform_widget_info}
  ///  * [buildMaterial], which does the same thing but for the Material library.
  Widget buildCupertino(BuildContext context);
}

class PlatformBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) buildMaterial;
  final Widget Function(BuildContext context) buildCupertino;

  const PlatformBuilder({
    super.key,
    required this.buildMaterial,
    required this.buildCupertino,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlatformController>();
    return controller.platform.value == UIPlatform.material
        ? buildMaterial(context)
        : buildCupertino(context);
  }
}

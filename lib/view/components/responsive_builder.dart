import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext, Breakpoints);

class ResponsiveBuilder extends StatefulWidget {
  final ResponsiveWidgetBuilder builder;

  const ResponsiveBuilder({required this.builder, super.key});

  @override
  State<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends State<ResponsiveBuilder> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return widget.builder(context, Breakpoints.currentBreakpoint);
    });
  }
}

class InfinityCompatibleResponsiveBuilder extends StatefulWidget {
  final ResponsiveWidgetBuilder builder;

  const InfinityCompatibleResponsiveBuilder({required this.builder, super.key});

  @override
  State<InfinityCompatibleResponsiveBuilder> createState() =>
      _InfinityCompatibleResponsiveBuilderState();
}

class _InfinityCompatibleResponsiveBuilderState
    extends State<InfinityCompatibleResponsiveBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, Breakpoints.currentBreakpoint);
  }
}

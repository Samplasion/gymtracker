import 'package:flutter/material.dart';

typedef TweenedWidgetBuilder<T> = Widget Function(BuildContext, T);

class TweenedBuilder<T> extends StatelessWidget {
  final T value;
  final TweenedWidgetBuilder<T> builder;
  final Tween<T> Function(T) tweenBuilder;

  const TweenedBuilder({
    super.key,
    required this.value,
    required this.builder,
    required this.tweenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: tweenBuilder(value),
      builder: (context, value, _) => builder(context, value),
      duration: const Duration(milliseconds: 500),
    );
  }
}

class TweenedIntBuilder extends TweenedBuilder<int> {
  const TweenedIntBuilder({
    required super.value,
    required super.builder,
    super.tweenBuilder = _tweenBuilder,
    super.key,
  });

  static Tween<int> _tweenBuilder(int value) {
    return IntTween(begin: 0, end: value);
  }
}

class TweenedDoubleBuilder extends TweenedBuilder<double> {
  const TweenedDoubleBuilder({
    required super.value,
    required super.builder,
    super.tweenBuilder = _tweenBuilder,
    super.key,
  });

  static Tween<double> _tweenBuilder(double value) {
    return Tween(begin: 0, end: value);
  }
}

import 'package:flutter/material.dart';

typedef TweenedWidgetBuilder<T> = Widget Function(BuildContext, T);

class TweenedBuilder<T> extends StatelessWidget {
  final T value;
  final TweenedWidgetBuilder<T> builder;
  final Tween<T> Function(T) tweenBuilder;
  final Duration duration;
  final Curve curve;

  const TweenedBuilder({
    super.key,
    required this.value,
    required this.builder,
    required this.tweenBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: tweenBuilder(value),
      builder: (context, value, _) => builder(context, value),
      duration: duration,
      curve: curve,
    );
  }
}

class TweenedIntBuilder extends TweenedBuilder<int> {
  const TweenedIntBuilder({
    required super.value,
    required super.builder,
    super.tweenBuilder = _tweenBuilder,
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.linear,
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
    super.duration = const Duration(milliseconds: 500),
    super.curve = Curves.linear,
    super.key,
  });

  static Tween<double> _tweenBuilder(double value) {
    return Tween(begin: 0, end: value);
  }
}

class TweenedColorBuilder extends StatelessWidget {
  final Color value;
  final TweenedWidgetBuilder<Color> builder;
  final Duration duration;
  final Curve curve;

  const TweenedColorBuilder({
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: _tweenBuilder(value),
      builder: (context, value, _) => builder(context, value ?? this.value),
      duration: duration,
      curve: curve,
    );
  }

  static ColorTween _tweenBuilder(Color value) {
    return ColorTween(begin: Colors.transparent, end: value);
  }
}

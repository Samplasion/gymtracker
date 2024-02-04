import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../service/localizations.dart';

typedef TimerStringBuilder<T> = T Function(TextSpan time);

class TimerView extends StatefulWidget {
  final DateTime startingTime;
  final Widget Function(BuildContext context, Widget text) builder;

  const TimerView({
    required this.builder,
    required this.startingTime,
    super.key,
  });

  @override
  State<TimerView> createState() => _TimerViewState();

  static T buildTimeString<T>(
    BuildContext context,
    Duration time, {
    TimerStringBuilder<T>? builder,
    TextStyle? style,
  }) {
    builder ??= _defaultTimerStringBuilder as TimerStringBuilder<T>;
    final hours = time.inHours;
    final minutes = (time.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');

    String built = "time.hours".plural(hours, args: {
      "hours": "$hours",
      "minutes": minutes,
      "seconds": seconds,
    });

    final text = TextSpan(
      text: built,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );

    return builder(text);
  }

  static Widget _defaultTimerStringBuilder(TextSpan time) => RichText(
        text: time,
      );
}

class _TimerViewState extends State<TimerView> {
  Stream stream = Stream.periodic(
    const Duration(milliseconds: 200),
  );
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = stream.listen(
      (_) {
        if (!mounted) subscription.cancel();
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = DateTime.now().difference(widget.startingTime);

    return widget.builder(context, TimerView.buildTimeString(context, time));
  }
}

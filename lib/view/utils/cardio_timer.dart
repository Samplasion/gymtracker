import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/tweened_builder.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/time.dart';

class CardioSection {
  final Duration active;
  final Duration rest;

  const CardioSection({
    required this.active,
    required this.rest,
  });

  @override
  String toString() {
    return "CardioSection(active: $active, rest: $rest)";
  }
}

class CardioTimerSetupScreen extends StatefulWidget {
  const CardioTimerSetupScreen({super.key});

  @override
  State<CardioTimerSetupScreen> createState() => _CardioTimerSetupScreenState();
}

typedef _CardioTimerSetupControllerPair = ({
  TextEditingController active,
  TextEditingController rest,
});

typedef _CardioTimerSetupSection = ({
  CardioSection section,
  _CardioTimerSetupControllerPair controllers,
});

class _CardioTimerSetupScreenState extends State<CardioTimerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_CardioTimerSetupSection> sections = [
    (
      section: const CardioSection(
        active: Duration(minutes: 1),
        rest: Duration(seconds: 30),
      ),
      controllers: (
        active: TextEditingController(
          text: TimeInputField.encodeDuration(const Duration(minutes: 1)),
        ),
        rest: TextEditingController(
          text: TimeInputField.encodeDuration(const Duration(seconds: 30)),
        ),
      )
    ),
  ];

  _addSection() {
    setState(() {
      sections.add(
        (
          section: const CardioSection(
            active: Duration(minutes: 1),
            rest: Duration(seconds: 30),
          ),
          controllers: (
            active: TextEditingController(
              text: TimeInputField.encodeDuration(const Duration(minutes: 1)),
            ),
            rest: TextEditingController(
              text: TimeInputField.encodeDuration(const Duration(seconds: 30)),
            ),
          ),
        ),
      );
    });
  }

  _submit() {
    if (!_formKey.currentState!.validate() ||
        sections.any((section) => !_isValid(section.section))) {
      return Go.snack("cardioTimer.setUp.errors.generic".t, assertive: true);
    }
    final cardioSections = sections.map((section) => section.section).toList();
    Go.off(() => CardioTimerScreen(sections: cardioSections));
  }

  bool _isValid(CardioSection section) {
    return !(section.active + section.rest == Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("cardioTimer.setUp.title".t),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              ListTile(
                title: Text("cardioTimer.setUp.section".tParams({
                  "section": "${i + 1}",
                })),
                trailing: (i > 0)
                    ? IconButton(
                        icon: const Icon(GymTrackerIcons.delete),
                        tooltip: "actions.remove".t,
                        onPressed: () {
                          setState(() {
                            sections.removeAt(i);
                          });
                        },
                      )
                    : null,
                subtitle: () {
                  final section = sections[i].section;
                  return Crossfade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Text("cardioTimer.setUp.errors.bothZeros".t),
                    showSecond: !_isValid(section),
                  );
                }(),
                textColor: () {
                  final section = sections[i].section;
                  if (!_isValid(section)) {
                    return context.colorScheme.error;
                  }
                  return null;
                }(),
              ),
              Crossfade(
                firstChild: const SizedBox.shrink(),
                secondChild: const SizedBox(height: 16),
                showSecond: !_isValid(sections[i].section),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TimeInputField(
                  decoration: GymTrackerInputDecoration(
                    labelText: "cardioTimer.setUp.active".t,
                  ),
                  controller: sections[i].controllers.active,
                  validator: (duration) {
                    if (duration == null) {
                      return "cardioTimer.setUp.errors.duration".t;
                    }
                    return null;
                  },
                  onChangedTime: (value) {
                    if (value == null) return;
                    setState(() {
                      sections[i] = (
                        section: CardioSection(
                          active: value,
                          rest: sections[i].section.rest,
                        ),
                        controllers: sections[i].controllers,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TimeInputField(
                  decoration: GymTrackerInputDecoration(
                    labelText: "cardioTimer.setUp.rest".t,
                  ),
                  controller: sections[i].controllers.rest,
                  validator: (duration) {
                    if (duration == null) {
                      return "cardioTimer.setUp.errors.duration".t;
                    }
                    return null;
                  },
                  onChangedTime: (value) {
                    if (value == null) return;
                    setState(() {
                      sections[i] = (
                        section: CardioSection(
                          active: sections[i].section.active,
                          rest: value,
                        ),
                        controllers: sections[i].controllers,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: _addSection,
                child: Text("cardioTimer.setUp.addSection".t),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        child: const Icon(GymTrackerIcons.done),
      ),
    );
  }
}

class CardioTimerScreen extends StatefulWidget {
  final List<CardioSection> sections;

  const CardioTimerScreen({
    required this.sections,
    super.key,
  });

  factory CardioTimerScreen.fromExercise(Exercise exercise) {
    assert(exercise.sets.isNotEmpty, "Exercise has no sets");
    assert(supportsTimer(exercise), "Exercise does not support timer");

    final sections = [
      for (var set in exercise.sets) ...[
        CardioSection(
          active: set.time ?? Duration.zero,
          rest: exercise.restTime,
        ),
      ],
    ];
    return CardioTimerScreen(sections: sections);
  }

  @override
  State<CardioTimerScreen> createState() => _CardioTimerScreenState();

  static bool supportsTimer(Exercise exercise) {
    return exercise.parameters.hasTime &&
        exercise.sets.isNotEmpty &&
        exercise.sets.any((set) => set.time!.inSeconds > 0);
  }
}

class _CardioTimerScreenState extends State<CardioTimerScreen> {
  late final List<(Duration, bool)> _times = [
    for (var section in widget.sections) ...[
      if (section.active != Duration.zero) (section.active, true),
      if (section.rest != Duration.zero) (section.rest, false),
    ],
  ];

  int _currentTime = 0;
  late int _time = _times[_currentTime].$1.inSeconds;
  bool get _isWorkout => _times[_currentTime].$2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_time > 0) {
          _time--;
        } else {
          _currentTime++;
          _currentTime %= _times.length;
          _time = _times[_currentTime].$1.inSeconds;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get backgroundColor =>
      _isWorkout ? Colors.black : context.colorScheme.primaryContainer;
  Color get textColor =>
      _isWorkout ? Colors.white : context.colorScheme.onPrimaryContainer;

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width / 4;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await Go.confirm(
            "cardioTimer.confirmExit.title".t,
            "cardioTimer.confirmExit.message".t,
          );
          if (shouldPop) {
            Get.back();
          }
        }
      },
      child: TweenedColorBuilder(
        value: backgroundColor,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 125),
        builder: (context, backgroundColor) {
          return Scaffold(
            appBar: AppBar(
              title: Text("cardioTimer.name".t),
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              surfaceTintColor: Colors.transparent,
            ),
            body: Container(
              color: backgroundColor,
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              TimeInputField.encodeDuration(
                                  Duration(seconds: _time)),
                              style: TextStyle(
                                fontSize: fontSize,
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                fontVariations: const [FontVariation.width(35)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: kToolbarHeight),
                    TweenedDoubleBuilder(
                      value: _time / _times[_currentTime].$1.inSeconds,
                      curve: Curves.linear,
                      duration: const Duration(seconds: 1),
                      builder: (context, value) => LinearProgressIndicator(
                        minHeight:
                            max(4, MediaQuery.of(context).viewPadding.bottom),
                        value: value,
                        backgroundColor: textColor.withOpacity(0.5),
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

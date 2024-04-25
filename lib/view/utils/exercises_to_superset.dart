import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/exercise.dart';

class ExercisesToSupersetDialog extends StatefulWidget {
  final List<WorkoutExercisable> exercises;
  final int startingIndex;

  const ExercisesToSupersetDialog({
    required this.exercises,
    required this.startingIndex,
    super.key,
  })  : assert(startingIndex >= 0),
        assert(startingIndex < exercises.length);

  @override
  State<ExercisesToSupersetDialog> createState() =>
      _ExercisesToSupersetDialogState();
}

enum _ETSStatus {
  valid,
  tooFewExercises;

  bool get isValid => this == _ETSStatus.valid;
}

class _ExercisesToSupersetDialogState extends State<ExercisesToSupersetDialog> {
  late final selected = SplayTreeSet<int>.from({widget.startingIndex});
  List<Exercise> get exercises =>
      [for (final i in selected) widget.exercises[i] as Exercise];

  _ETSStatus get status {
    if (selected.length < 2) {
      return _ETSStatus.tooFewExercises;
    }

    return _ETSStatus.valid;
  }

  Widget get statusWidget {
    return switch (status) {
      _ETSStatus.tooFewExercises => AlertBanner(
          color: AlertColor.error(context),
          title: "ongoingWorkout.exercisesToSuperset.errorBannerTitle".t,
          text: RichText(
            text: TextSpan(
              text: "ongoingWorkout.exercisesToSuperset.errors.tooFew".t,
            ),
          ),
        ),
      _ => const SizedBox(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ongoingWorkout.exercisesToSuperset.title".t),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: status.isValid
                  ? () => Navigator.of(context).pop(selected.toList())
                  : null,
            ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Crossfade(
                firstChild: statusWidget,
                secondChild: const SizedBox(),
                showSecond: status.isValid,
              ),
            ),
            for (int i = 0; i < widget.exercises.length; i++)
              ExerciseListTile(
                exercise: widget.exercises[i],
                selected: selected.contains(i),
                isConcrete: false,
                onTap: () {
                  if (widget.exercises[i] is! Exercise) {
                    Go.snack(
                      "ongoingWorkout.exercisesToSuperset.errors.notExercise".t,
                      assertive: true,
                    );
                    return;
                  }

                  setState(() {
                    if (selected.contains(i)) {
                      if (i == selected.first || i == selected.last) {
                        selected.remove(i);
                      } else {
                        Go.snack(
                          "ongoingWorkout.exercisesToSuperset.errors.removingMiddle"
                              .t,
                          assertive: true,
                        );
                      }
                    } else {
                      if (selected.isEmpty ||
                          i == selected.first - 1 ||
                          i == selected.last + 1) {
                        selected.add(i);
                      } else {
                        Go.snack(
                          "ongoingWorkout.exercisesToSuperset.errors.addingNonContiguous"
                              .t,
                          assertive: true,
                        );
                      }
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

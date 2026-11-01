import 'package:gymtracker/db/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/workout_editor.dart';

extension HistoryPresentation on HistoryController {
  void deleteWorkoutWithDialog(
    BuildContext context, {
    required Workout workout,
    required void Function() onCanceled,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text(context.t.workouts.actions.delete.title),
          content: Text(context.t.workouts.actions.delete.text),
          actions: [
            TextButton(
              onPressed: () {
                Go.back(closeOverlays: true);
              },
              child: Text(context.t.workouts.actions.delete.actions.no),
            ),
            FilledButton.tonal(
              onPressed: () {
                deleteWorkout(workout);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.back(closeOverlays: true);
                });

                onCanceled();
              },
              child: Text(context.t.workouts.actions.delete.actions.yes),
            ),
          ],
        );
      },
    );
  }

  void deleteWorkoutsWithDialog(
    BuildContext context, {
    required Set<String> workoutIDs,
    required void Function() onDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text(
            context.t.history.actions.deleteMultiple.title(
              n: workoutIDs.length,
            ),
          ),
          content: Text(
            context.t.history.actions.deleteMultiple.text(n: workoutIDs.length),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Go.back(closeOverlays: true);
              },
              child: Text(context.t.history.actions.deleteMultiple.actions.no),
            ),
            FilledButton.tonal(
              onPressed: () {
                final deletedWorkouts = service.workoutHistory
                    .where((element) => workoutIDs.contains(element.id))
                    .toList();
                for (final workout in deletedWorkouts) {
                  deleteWorkout(workout);
                }

                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.back(closeOverlays: true);
                });

                onDeleted();
              },
              child: Text(context.t.history.actions.deleteMultiple.actions.yes),
            ),
          ],
        );
      },
    );
  }

  void finishEditingWorkoutWithDialog(BuildContext context, Workout workout) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.showBottomModalScreen(
        (context, _) => WorkoutFinishEditingPage(workout: workout),
      );
    });
  }

  Future<void> combineWorkoutsFlow(Workout workout) async {
    if (!hasContinuation(incompleteWorkout: workout)) {
      throw ArgumentError.value(
        workout,
        'workout',
        "Workout must have a continuation.",
      );
    }

    // Rationale: The old algorithm used a filter on the base workout to filter
    // done exercises so that they don't show up twice. To the new algorithm
    // that's counter-productive so we don't do that.
    // That is counter-productive because the new algorithm uses the
    // [supersedesID] field on exercises to know what exercise goes where,
    // so filtering exercises means that the combined workout has some
    // exercises missing.
    final w1 =
        linearExercisesUseNewAlgorithm(
          workout,
          getContinuation(incompleteWorkout: workout)!,
        )
        ? workout
        : workout.withFilters(
            exerciseFilter: (e) => e.sets.any((element) => element.done),
            setFilter: (e, s) => s.done,
          );
    // Rationale: the continuation's infobox is pre-populated with the base
    // workout's notes. Since the continuation algorithm appends the second
    // workout's notes to the first, we want to avoid showing them twice
    // if the user hasn't touched them.
    final w2 = getContinuation(incompleteWorkout: workout)!.copyWith.infobox(
      getContinuation(incompleteWorkout: workout)!.infobox == w1.infobox
          ? null
          : getContinuation(incompleteWorkout: workout)!.infobox,
    );

    if ((await service.db.isTrainerRoutine(w1.parentID) ||
            await service.db.isTrainerRoutine(w2.parentID)) &&
        w1.parentID != w2.parentID)
      return;
    final shouldCombine = await Go.confirm(
      "exercise.continuation.combine.confirm.title",
      "exercise.continuation.combine.confirm.body",
      icon: const Icon(GTIcons.combine),
    );

    logger.t("Should combine: $shouldCombine");

    if (!ref.mounted || !shouldCombine) {
      return;
    }

    final combined = Workout.combine(w1, w2);

    logger.d(combined.toJson().toPrettyString());

    replaceWorkoutsWithCombined(workouts: [w1, w2], combined: combined);

    Go.off(() => ExercisesView(workout: combined));
  }
}

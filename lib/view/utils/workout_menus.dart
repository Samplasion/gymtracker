import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/exercise_set_view.dart';
import 'package:gymtracker/view/utils/cardio_timer.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:gymtracker/view/utils/workout_done.dart';

List<PopupMenuEntry<dynamic>> buildWorkoutControlMenuEntries(
  BuildContext context,
  WorkoutController controller,
) {
  return <PopupMenuEntry<dynamic>>[
    PopupMenuItem(
      onTap: controller.changeWeightUnitDialog,
      child: Text("ongoingWorkout.actions.changeWeightUnit".t),
    ),
    PopupMenuItem(
      onTap: controller.changeDistanceUnitDialog,
      child: Text("ongoingWorkout.actions.changeDistanceUnit".t),
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      child: Text("ongoingWorkout.actions.finish".t),
      onTap: () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          controller.finishWorkoutWithDialog(context);
        });
      },
    ),
    PopupMenuItem(
      child: Text(
        "ongoingWorkout.actions.cancel".t,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      onTap: () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          controller.cancelWorkoutWithDialog(context, onCanceled: () {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Get.back(closeOverlays: true);
              Get.delete<WorkoutController>();
            });
          });
        });
      },
    ),
    if (kDebugMode)
      PopupMenuItem(
        child: const Text("Show Good Job dialog"),
        onTap: () {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Go.showBottomModalScreen((context, modalController) {
              return WorkoutDoneSheet(
                workout: controller.synthesizeTemporaryWorkout(),
                controller: modalController,
              );
            });
          });
        },
      ),
  ];
}

List<PopupMenuEntry<dynamic>> buildToolboxMenuEntries(
  BuildContext context,
  WorkoutController? controller,
) {
  return <PopupMenuEntry<dynamic>>[
    PopupMenuItem(
      enabled: controller != null,
      child: ListTile(
        leading: const Icon(GTIcons.stopwatch),
        title: Text("ongoingWorkout.stopwatch.label".t),
        mouseCursor: SystemMouseCursors.click,
        enabled: controller != null,
      ),
      onTap: () {
        if (controller == null) return;
        final stopwatchController = Get.find<StopwatchController>();
        GlobalStopwatch getStopwatch() => stopwatchController.globalStopwatch;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("ongoingWorkout.stopwatch.label".t),
              content: TimerView(
                startingTime: DateTime.now(),
                builder: (context, _) {
                  return Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TimerView.buildTimeString(
                          context,
                          getStopwatch().currentDuration,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 16),
                        OverflowBar(
                          alignment: MainAxisAlignment.end,
                          overflowAlignment: OverflowBarAlignment.end,
                          children: [
                            if (getStopwatch().isStopped())
                              TextButton.icon(
                                key: const Key("start"),
                                icon: const Icon(GTIcons.resume),
                                label: Text("ongoingWorkout.stopwatch.start".t),
                                onPressed: () {
                                  getStopwatch().start();
                                },
                              )
                            else
                              TextButton.icon(
                                key: const Key("pause"),
                                icon: const Icon(GTIcons.pause),
                                label: Text("ongoingWorkout.stopwatch.pause".t),
                                onPressed: () {
                                  getStopwatch().pause();
                                },
                              ),
                            if (getStopwatch().isStopped() &&
                                getStopwatch().currentDuration.inSeconds > 0)
                              TextButton.icon(
                                key: const Key("reset"),
                                icon: const Icon(GTIcons.reset),
                                label: Text("ongoingWorkout.stopwatch.reset".t),
                                onPressed: () {
                                  getStopwatch().reset();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    ),
    PopupMenuItem(
      child: ListTile(
        leading: const Icon(GTIcons.weight_calculator),
        title: Text("ongoingWorkout.weightCalculator".t),
        mouseCursor: SystemMouseCursors.click,
        enabled: controller != null,
      ),
      onTap: () {
        if (controller == null) return;
        final weightUnit = controller.weightUnit.value;
        showDialog(
          context: context,
          builder: (context) => WeightCalculator(
            weightUnit: weightUnit,
          ),
        );
      },
    ),
    PopupMenuItem(
      child: ListTile(
        leading: const Icon(GTIcons.cardio_timer),
        title: Text("cardioTimer.name".t),
        mouseCursor: SystemMouseCursors.click,
        enabled: controller != null,
      ),
      onTap: () {
        if (controller == null) return;
        Go.to(() => const CardioTimerSetupScreen());
      },
    ),
  ];
}

List<PopupMenuEntry<dynamic>> buildSetKindMenuEntries({
  required BuildContext context,
  required Exercise exercise,
  required GTSet set,
  required void Function(GTSetKind) onSetSelectKind,
}) {
  return <PopupMenuEntry<dynamic>>[
    for (final kind in GTSetKind.values)
      PopupMenuItem(
        onTap: () => onSetSelectKind(kind),
        child: ListTile(
          leading: buildSetType(
            context,
            kind,
            set: set,
            allSets: exercise.sets,
          ),
          title: Text('set.kindLong.${kind.name}'.t),
        ),
      ),
    const PopupMenuDivider(),
    PopupMenuItem(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('set.kinds.help.title'.t),
              scrollable: true,
              content: Column(
                children: [
                  for (final kind in GTSetKind.values)
                    ListTile(
                      leading: buildSetType(
                        context,
                        kind,
                        set: set,
                        allSets: exercise.sets,
                        fontSize: 16,
                      ),
                      title: Text('set.kindLong.${kind.name}'.t),
                      subtitle: Text('set.kinds.help.${kind.name}'.t),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        leading: Text(
          "?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: Text('set.kinds.help.title'.t),
      ),
    ),
  ];
}

List<PopupMenuEntry<dynamic>> buildExerciseControlMenuEntries({
  required BuildContext context,
  required ExerciseIndex index,
  required Exercise exercise,
  required bool isCreating,
  required EditorCallbacks callbacks,
  required Weights weightUnit,
  required Distance distanceUnit,
}) {
  final items = <PopupMenuEntry<dynamic>>[];

  if (!isCreating) {
    items.add(
      PopupMenuItem(
        onTap: () {
          callbacks.onExerciseReorder(index.supersetIndex);
        },
        child: ListTile(
          leading: const Icon(GTIcons.reorder),
          title: Text('ongoingWorkout.exercises.reorder'.t),
          mouseCursor: SystemMouseCursors.click,
        ),
      ),
    );
  }

  items.addAll([
    PopupMenuItem(
      onTap: () {
        callbacks.onExerciseReplace(index);
      },
      child: ListTile(
        leading: const Icon(GTIcons.replace),
        title: Text('ongoingWorkout.exercises.replace'.t),
        mouseCursor: SystemMouseCursors.click,
      ),
    ),
    if (index.supersetIndex == null)
      PopupMenuItem(
        onTap: () {
          callbacks.onGroupExercisesIntoSuperset(index.exerciseIndex);
        },
        child: ListTile(
          leading: const Icon(GTIcons.add_to_superset),
          title: Text('ongoingWorkout.exercises.addToSuperset'.t),
          mouseCursor: SystemMouseCursors.click,
        ),
      ),
  ]);

  if (!exercise.parameters.isSetless || !isCreating) {
    items.add(const PopupMenuDivider());
  }

  if (!exercise.parameters.isSetless) {
    items.add(
      PopupMenuItem(
        enabled: exercise.sets.isNotEmpty,
        onTap: exercise.sets.isEmpty
            ? null
            : () async {
                final newIndices = await Go.toDialog<List<int>>(
                  () => WorkoutReorderSetsDialog(
                    exercise: exercise,
                    sets: exercise.sets,
                    weightUnit: weightUnit,
                    distanceUnit: distanceUnit,
                    isConcrete: !isCreating,
                  ),
                );
                if (newIndices != null) {
                  callbacks.onExerciseSetReorder(index, newIndices);
                }
              },
        child: ListTile(
          leading: const Icon(GTIcons.reorder),
          title: Text('ongoingWorkout.exercises.reorderSets'.t),
          enabled: exercise.sets.isNotEmpty,
          mouseCursor: SystemMouseCursors.click,
        ),
      ),
    );
  }

  if (!isCreating) {
    items.addAll([
      PopupMenuItem(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return _SetRpeDialog(currentRPE: exercise.rpe);
            },
          ).then((value) {
            if (value != null) {
              callbacks.onExerciseChangeRPE(index, value.safeUnwrap());
            }
          });
        },
        child: ListTile(
          leading: const Icon(GTIcons.rpe),
          title: Text('ongoingWorkout.exercises.setRPE'.t),
          mouseCursor: SystemMouseCursors.click,
        ),
      ),
      if (CardioTimerScreen.supportsTimer(exercise))
        PopupMenuItem(
          onTap: () {
            Go.to(() => CardioTimerScreen.fromExercise(exercise));
          },
          child: ListTile(
            leading: const Icon(GTIcons.cardio_timer),
            title: Text('ongoingWorkout.exercises.startCardioTimer'.t),
            mouseCursor: SystemMouseCursors.click,
          ),
        ),
    ]);
  }

  items.add(const PopupMenuDivider());
  items.add(
    PopupMenuItem(
      onTap: () {
        callbacks.onExerciseRemove(index);
      },
      child: ListTile(
        textColor: Theme.of(context).colorScheme.error,
        iconColor: Theme.of(context).colorScheme.error,
        leading: const Icon(GTIcons.delete),
        title: Text('ongoingWorkout.exercises.remove'.t),
        mouseCursor: SystemMouseCursors.click,
      ),
    ),
  );

  return items;
}

class WorkoutReorderSetsDialog extends StatefulWidget {
  const WorkoutReorderSetsDialog({
    required this.exercise,
    required this.sets,
    required this.weightUnit,
    required this.distanceUnit,
    required this.isConcrete,
    super.key,
  });

  final Exercise exercise;
  final List<GTSet> sets;
  final Weights weightUnit;
  final Distance distanceUnit;
  final bool isConcrete;

  @override
  State<WorkoutReorderSetsDialog> createState() =>
      _WorkoutReorderSetsDialogState();
}

class _WorkoutReorderSetsDialogState extends State<WorkoutReorderSetsDialog> {
  late var indices = List.generate(widget.sets.length, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('exercise.editor.fields.reorderSets.title'.t),
          leading: IconButton(
            icon: const Icon(GTIcons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(GTIcons.save),
              onPressed: () {
                Navigator.pop(context, indices);
              },
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AlertBanner(
                  title: 'exercise.editor.fields.reorderSets.title'.t,
                  text: Text('exercise.editor.fields.reorderSets.text'.t),
                  color: AlertColor.secondary(context),
                ),
              ),
            ),
            SliverReorderableList(
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  indices.insert(newIndex, indices.removeAt(oldIndex));
                });
              },
              itemBuilder: (context, j) {
                final index = indices[j];
                return ExerciseSetView(
                  key: ValueKey(widget.sets[index]),
                  set: widget.sets[index],
                  exercise: widget.exercise,
                  isConcrete: widget.isConcrete,
                  alt: j % 2 == 0,
                  weightUnit: widget.weightUnit,
                  distanceUnit: widget.distanceUnit,
                  draggable: true,
                  index: j,
                );
              },
              itemCount: widget.sets.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRpeDialog extends StatefulWidget {
  final int? currentRPE;

  const _SetRpeDialog({this.currentRPE});

  @override
  State<_SetRpeDialog> createState() => _SetRpeDialogState();
}

class _SetRpeDialogState extends State<_SetRpeDialog> {
  late int currentRPE = widget.currentRPE ?? 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('exercise.editor.fields.rpe.label'.t),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(GTIcons.help),
            title: Text('exercise.editor.fields.rpe.description.title'.t),
            subtitle: Text('exercise.editor.fields.rpe.description.text'.t),
          ),
          ListTile(
            leading: const Icon(GTIcons.rpe),
            title: Text('exercise.editor.fields.rpe.level$currentRPE.title'.t),
            subtitle:
                Text('exercise.editor.fields.rpe.level$currentRPE.text'.t),
          ),
          Slider(
            value: currentRPE.toDouble(),
            secondaryTrackValue: widget.currentRPE?.toDouble(),
            onChanged: (value) {
              setState(() {
                currentRPE = value.toInt();
              });
            },
            min: 1,
            max: 10,
            divisions: 9,
            label: currentRPE.toString(),
            activeColor: rpeColor(context, currentRPE),
            secondaryActiveColor: rpeColor(context, widget.currentRPE ?? 5)
                .withAlpha((0.54 * 255).round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<Optional<int?>>(context, const None());
          },
          child: Text('exercise.editor.fields.rpe.removeRPE'.t),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<Optional<int?>>(context, Some(currentRPE));
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

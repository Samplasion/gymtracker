import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/parent_viewer.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/components/themed_subtree.dart';
import 'package:gymtracker/view/utils/cardio_timer.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_menus.dart';
import 'package:gymtracker/view/workout.dart';

class WorkoutSimpleView extends StatelessWidget {
  const WorkoutSimpleView({super.key});

  static const routeName = "/workout/simple";

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();
    final countdownController = Get.find<CountdownController>();
    final stopwatchController = Get.find<StopwatchController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final current = _currentSetData(controller);
      final isRestActive = countdownController.isActive;
      final isWorkoutComplete = _isWorkoutComplete(controller);
      final canShowAddExercise = current == null
          ? !isWorkoutComplete
          : _isLastSetInWorkout(controller, current.cursor);
      final canShowAddSet = current != null &&
          _isLastSetInExercise(current.cursor, current.exercise);
      final accentColor = settings.tintExercises.value && current != null
          ? current.exerciseColor
          : settings.color.value;

      final body = Column(
        children: [
          Expanded(
            child: current == null
                ? _EmptyCurrentSetView(
                    isRestActive: isRestActive,
                    isWorkoutComplete: isWorkoutComplete,
                    onFinishWorkout: () {
                      controller.finishWorkoutWithDialog(context);
                    },
                    onAddExercise: () async {
                      await _addExerciseAndAdvanceCursor(
                        controller,
                        current,
                      );
                    },
                    showAddExercise: canShowAddExercise,
                  )
                : _CurrentSetView(
                    data: current,
                    isRestActive: isRestActive,
                    nextUp: _nextUpData(controller, current),
                    showAddExercise: canShowAddExercise,
                    showAddSet: canShowAddSet,
                    onAddExercise: () async {
                      await _addExerciseAndAdvanceCursor(
                        controller,
                        current,
                      );
                    },
                    onAddSet: () {
                      controller.callbacks.onSetCreate(current.index);
                      controller.selectSetCursorByIndex(
                        current.index,
                        current.cursor.setIndex + 1,
                      );
                    },
                    onEditSet: () {
                      Go.to<void>(() => _SimpleSetEditDialog(data: current));
                    },
                  ),
          ),
          _BottomPanel(
            current: current,
            isRestActive: isRestActive,
            accentColor: accentColor,
            canGoPrevious: current == null
                ? false
                : _hasPreviousSet(controller, current.cursor),
            canGoNext: current == null
                ? false
                : _hasNextSet(controller, current.cursor),
            onGoToFirstSet: () {
              if (current != null) {
                controller.moveSetCursorToFirstUndone();
              }
            },
            onPrevious: controller.moveSetCursorToPrevious,
            onCalculator: () {
              showDialog(
                context: context,
                builder: (context) => WeightCalculator(
                  weightUnit: controller.weightUnit.value,
                ),
              );
            },
            onDone: controller.autoMarkNextSetDone,
            onInterval: () => Go.to(() => const CardioTimerSetupScreen()),
            onNext: controller.moveSetCursorToNext,
            onGoToLastSet: () {
              if (current != null) {
                controller.moveSetCursorToLastUndone();
              }
            },
            workoutStart: controller.time.value,
          ),
        ],
      );

      Widget page = Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Obx(() {
            if (stopwatchController.globalStopwatch.isStopped.isFalse ||
                stopwatchController.globalStopwatch.currentDuration.inSeconds >
                    0) {
              return TimerView(
                builder: (ctx, _) {
                  return Text.rich(
                    TimerView.buildTimeString(
                      context,
                      stopwatchController.globalStopwatch.currentDuration,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      builder: (time) => TextSpan(
                        children: [
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  GTIcons.stopwatch,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              const TextSpan(text: ' '),
                              time,
                            ],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                startingTime: DateTime.now(),
              );
            }
            return Text('ongoingWorkout.title'.t);
          }),
          actions: [
            IconButton(
              tooltip: 'ongoingWorkout.simple.restTimer'.t,
              onPressed: _canTriggerRestTimer(current)
                  ? () => controller.markSetAsDone(current!.index, -1, true)
                  : null,
              icon: const Icon(GTIcons.rest_timer),
            ),
            PopupMenuButton(
              itemBuilder: (context) => buildToolboxMenuEntries(
                context,
                controller,
              ),
              tooltip: "ongoingWorkout.toolbox.title".t,
              icon: const Icon(GTIcons.tools),
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                final items = <PopupMenuEntry<dynamic>>[
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(GTIcons.workout),
                      title: Text('ongoingWorkout.simple.switchToFull'.t),
                      mouseCursor: SystemMouseCursors.click,
                    ),
                    onTap: () {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context)
                            .popAndPushNamed(WorkoutView.routeName);
                      });
                    },
                  ),
                  const PopupMenuDivider(),
                  ...buildWorkoutControlMenuEntries(context, controller),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    enabled: current != null,
                    onTap: current == null
                        ? null
                        : () {
                            _insertSetAfterCurrent(
                              controller,
                              current,
                              GTSetKind.drop,
                            );
                          },
                    child: ListTile(
                      leading: const Icon(GTIcons.sets),
                      title: Text('set.kindLong.drop'.t),
                      mouseCursor: SystemMouseCursors.click,
                      enabled: current != null,
                    ),
                  )
                ];

                return items;
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 220),
              tween: Tween<double>(begin: 0, end: controller.progress),
              builder: (context, value, _) {
                return LinearProgressIndicator(value: value);
              },
            ),
          ),
        ),
        body: SafeArea(bottom: false, child: body),
      );

      if (settings.tintExercises.value) {
        return ThemedSubtree(
          key: const ValueKey<String>('tinted-exercise'),
          color:
              current?.exerciseColor ?? Theme.of(context).colorScheme.primary,
          child: page,
        );
      }

      return page;
    });
  }
}

class _CurrentSetView extends StatelessWidget {
  final _CurrentSetData data;
  final bool isRestActive;
  final _NextUpData? nextUp;
  final bool showAddExercise;
  final bool showAddSet;
  final VoidCallback onAddExercise;
  final VoidCallback onAddSet;
  final VoidCallback onEditSet;

  const _CurrentSetView({
    required this.data,
    required this.isRestActive,
    required this.nextUp,
    required this.showAddExercise,
    required this.showAddSet,
    required this.onAddExercise,
    required this.onAddSet,
    required this.onEditSet,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();

    if (isRestActive) {
      return _NextSetRestView(data: data);
    }

    return PageTransitionSwitcher(
      reverse: !_isSetIndexAfter(data.cursor, controller.previousSetCursor)
          ? true
          : false,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Theme.of(context).colorScheme.surface,
          child: child,
        );
      },
      child: Center(
        key: ValueKey<String>(
            'current-set-${data.index}-${data.cursor.setIndex}'),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExerciseParentViewGesture(
                exercise: data.exercise,
                child: ExerciseIcon(
                  radius: 32,
                  exercise: data.exercise,
                ),
              ),
              const SizedBox(height: 20),
              if (data.isInSuperset)
                Text.rich(
                  TextSpan(
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(GTIcons.superset, size: 18),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'superset'.plural(data.supersetExerciseCount),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: data.exercise.displayName,
                  ),
                  const TextSpan(text: ' '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: PopupMenuButton(
                      itemBuilder: (context) => buildExerciseControlMenuEntries(
                        context: context,
                        index: data.index,
                        exercise: data.exercise,
                        isCreating: false,
                        callbacks: controller.callbacks,
                        weightUnit: controller.weightUnit.value,
                        distanceUnit: controller.distanceUnit.value,
                      ),
                    ),
                  ),
                ]),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _SetTypeBadge(
                    set: data.set,
                    exercise: data.exercise,
                    index: data.index,
                    setIndex: data.cursor.setIndex,
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    icon: const Icon(GTIcons.edit),
                    onPressed: onEditSet,
                    label: Text(
                      data.parametersLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => _showRestTimeEditor(context, data),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(
                  GTIcons.edit,
                  size: 16,
                ),
                label: Text(
                  '${'exercise.fields.restTime'.t}: ${TimeInputField.encodeDuration(data.restTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              _NotesBox(
                title: 'exercise.editor.fields.notes.label'.t,
                text: data.exercise.notes,
                onTap: () => _showNotesEditor(
                  context,
                  initialText: data.exercise.notes,
                  onSave: (text) {
                    Get.find<WorkoutController>()
                        .callbacks
                        .onExerciseNotesChange(
                          data.index,
                          text,
                        );
                  },
                ),
              ),
              if (data.supersetNotes != null) ...[
                const SizedBox(height: 8),
                _NotesBox(
                  title: 'ongoingWorkout.simple.supersetNotes'.t,
                  text: data.supersetNotes!,
                  onTap: () => _showNotesEditor(
                    context,
                    initialText: data.supersetNotes!,
                    onSave: (text) {
                      Get.find<WorkoutController>()
                          .callbacks
                          .onExerciseNotesChange(
                        (
                          exerciseIndex: data.cursor.supersetIndex!,
                          supersetIndex: null,
                        ),
                        text,
                      );
                    },
                  ),
                ),
              ],
              if (showAddExercise || showAddSet) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (showAddExercise)
                      FilledButton.tonal(
                        onPressed: onAddExercise,
                        child: Text('ongoingWorkout.exercises.add'.t),
                      ),
                    if (showAddSet)
                      FilledButton.tonal(
                        onPressed: onAddSet,
                        child: Text('exercise.actions.addSet'.t),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NextSetRestView extends StatelessWidget {
  const _NextSetRestView({
    // ignore: unused_element
    super.key,
    required this.data,
  });

  final _CurrentSetData data;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.75);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'exercise.fields.restTime'.t,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              'ongoingWorkout.simple.nextUp'
                  .tParams({'exercise': data.exercise.displayName}),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExerciseIcon(exercise: data.exercise),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data.isInSuperset) ...[
                            Row(
                              children: [
                                const Icon(GTIcons.superset, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'superset'.plural(data.supersetExerciseCount),
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            data.exercise.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: data.setTypeLabel,
                                  style: TextStyle(
                                    color: _setTypeColor(
                                      context,
                                      data.set.kind,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ': '),
                                TextSpan(text: data.parametersLabel),
                              ],
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final _CurrentSetData? current;
  final bool isRestActive;
  final bool canGoPrevious;
  final bool canGoNext;
  final Color accentColor;
  final VoidCallback onGoToFirstSet;
  final VoidCallback onPrevious;
  final VoidCallback onCalculator;
  final VoidCallback onDone;
  final VoidCallback onInterval;
  final VoidCallback onNext;
  final VoidCallback onGoToLastSet;
  final DateTime workoutStart;

  const _BottomPanel({
    required this.current,
    required this.isRestActive,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.accentColor,
    required this.onGoToFirstSet,
    required this.onPrevious,
    required this.onCalculator,
    required this.onDone,
    required this.onInterval,
    required this.onNext,
    required this.onGoToLastSet,
    required this.workoutStart,
  });

  @override
  Widget build(BuildContext context) {
    final controlsDisabled = current == null;
    final countdownController = Get.find<CountdownController>();

    return SafeArea(
      top: false,
      child: Card(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () {
                  final showRestControls =
                      countdownController.targetTime.value != null;
                  return Crossfade(
                    showSecond: showRestControls,
                    firstChild: const SizedBox.shrink(
                      key: ValueKey<String>('rest-controls-hidden'),
                    ),
                    secondChild: Padding(
                      key: const ValueKey<String>('rest-controls-visible'),
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                GTIcons.cardio_timer,
                                size: 18,
                                color: accentColor,
                              ),
                              const SizedBox(width: 6),
                              TimerView(
                                startingTime:
                                    countdownController.startingTime.value ??
                                        DateTime.now(),
                                builder: (context, _) {
                                  return TimerView.buildTimeString(
                                    context,
                                    countdownController.remaining,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: accentColor,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TimerView(
                            startingTime: () {
                              try {
                                return Get.find<WorkoutController>().time.value;
                              } catch (_) {
                                return DateTime.now();
                              }
                            }(),
                            builder: (context, _) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 1,
                                  end: countdownController.progress,
                                ),
                                duration: const Duration(milliseconds: 220),
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accentColor,
                                    ),
                                    backgroundColor:
                                        accentColor.withOpacity(0.18),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed:
                                    countdownController.subtract15Seconds,
                                child: Text(
                                  'timer.subtract15s'.t,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: countdownController.add15Seconds,
                                child: Text(
                                  'timer.add15s'.t,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: countdownController.removeCountdown,
                                icon: const Icon(GTIcons.skip),
                                label: Text('timer.skip'.t),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimerView(
                    startingTime: workoutStart,
                    builder: (context, _) {
                      return TimerView.buildTimeString(
                        context,
                        DateTime.now().difference(workoutStart),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundControlButton(
                        icon: GTIcons.previousDay,
                        tooltip: 'ongoingWorkout.simple.previousSet'.t,
                        onPressed: (!controlsDisabled && canGoPrevious)
                            ? onPrevious
                            : null,
                        onLongPress: (!controlsDisabled && canGoPrevious)
                            ? onGoToFirstSet
                            : null,
                      ),
                      _RoundControlButton(
                        icon: GTIcons.weight_calculator,
                        tooltip: 'ongoingWorkout.weightCalculator'.t,
                        onPressed: controlsDisabled ? null : onCalculator,
                      ),
                      _RoundControlButton(
                        icon: GTIcons.done,
                        tooltip: 'ongoingWorkout.simple.markAsDone'.t,
                        highlighted: true,
                        onPressed: controlsDisabled ? null : onDone,
                      ),
                      _RoundControlButton(
                        icon: GTIcons.cardio_timer,
                        tooltip: 'cardioTimer.name'.t,
                        onPressed: controlsDisabled ? null : onInterval,
                      ),
                      _RoundControlButton(
                        icon: GTIcons.nextDay,
                        tooltip: 'ongoingWorkout.simple.nextSet'.t,
                        onPressed:
                            (!controlsDisabled && canGoNext) ? onNext : null,
                        onLongPress: (!controlsDisabled && canGoNext)
                            ? onGoToLastSet
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool highlighted;

  const _RoundControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onLongPress,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = highlighted ? 66.0 : 50.0;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          onPressed: onPressed,
          onLongPress: onLongPress,
          child: Icon(icon, size: highlighted ? 30 : 24),
        ),
      ),
    );
  }
}

class _EmptyCurrentSetView extends StatelessWidget {
  final bool isRestActive;
  final bool isWorkoutComplete;
  final VoidCallback onFinishWorkout;
  final bool showAddExercise;
  final VoidCallback onAddExercise;

  const _EmptyCurrentSetView({
    required this.isRestActive,
    required this.isWorkoutComplete,
    required this.onFinishWorkout,
    required this.showAddExercise,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context) {
    if (isWorkoutComplete) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: onFinishWorkout,
              icon: const Icon(GTIcons.done),
              label: Text('ongoingWorkout.actions.finish'.t),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: onAddExercise,
                  child: Text('ongoingWorkout.exercises.add'.t),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isRestActive
                ? 'ongoingWorkout.restOver'.t
                : 'general.exercises'.plural(0),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (showAddExercise) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onAddExercise,
              child: Text('ongoingWorkout.exercises.add'.t),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimpleSetEditDialog extends StatefulWidget {
  final _CurrentSetData data;

  const _SimpleSetEditDialog({required this.data});

  @override
  State<_SimpleSetEditDialog> createState() => _SimpleSetEditDialogState();
}

class _SimpleSetEditDialogState extends State<_SimpleSetEditDialog> {
  late GTSet _set = widget.data.set.copyWith();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('ongoingWorkout.simple.editSet'.t),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            WorkoutExerciseSetEditor(
              exercise: widget.data.exercise,
              set: _set,
              index: widget.data.index,
              setIndex: widget.data.cursor.setIndex,
              alt: true,
              isCreating: false,
              showDoneCheckbox: false,
              onDelete: () {
                controller.callbacks.onSetRemove(
                  widget.data.index,
                  widget.data.cursor.setIndex,
                );
                Navigator.of(context).pop();
              },
              onSetSelectKind: (kind) => controller.callbacks.onSetSelectKind(
                widget.data.index,
                widget.data.cursor.setIndex,
                kind,
              ),
              onSetSetDone: (done) => controller.callbacks.onSetSetDone(
                widget.data.index,
                widget.data.cursor.setIndex,
                done,
              ),
              onSetValueChange: (set) {
                setState(() {
                  _set = set;
                  controller.callbacks.onSetValueChange(
                    widget.data.index,
                    widget.data.cursor.setIndex,
                    set,
                  );
                });
              },
              weightUnit: controller.weightUnit.value,
              distanceUnit: controller.distanceUnit.value,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentSetData {
  final WorkoutSetCursor cursor;
  final WorkoutExerciseIndex index;
  final Exercise exercise;
  final GTSet set;
  final Duration restTime;
  final String setTypeLabel;
  final String? supersetNotes;
  final bool isInSuperset;
  final int supersetExerciseCount;
  final Color exerciseColor;
  final String parametersLabel;

  const _CurrentSetData({
    required this.cursor,
    required this.index,
    required this.exercise,
    required this.set,
    required this.restTime,
    required this.setTypeLabel,
    required this.supersetNotes,
    required this.isInSuperset,
    required this.supersetExerciseCount,
    required this.exerciseColor,
    required this.parametersLabel,
  });
}

class _SetRef {
  final WorkoutSetCursor cursor;
  final Exercise exercise;
  final GTSet set;
  final bool isInSuperset;

  const _SetRef({
    required this.cursor,
    required this.exercise,
    required this.set,
    required this.isInSuperset,
  });
}

class _NextUpData {
  final Exercise exercise;
  final GTSet set;
  final bool isInSuperset;
  final String parametersLabel;

  const _NextUpData({
    required this.exercise,
    required this.set,
    required this.isInSuperset,
    required this.parametersLabel,
  });
}

_CurrentSetData? _currentSetData(WorkoutController controller) {
  final cursor = controller.currentSetCursor;
  if (cursor == null) return null;

  final exercise = _exerciseAtCursor(controller, cursor);
  if (exercise == null) return null;

  final set = exercise.sets[cursor.setIndex];
  final supersetNotes = cursor.supersetIndex == null
      ? null
      : (controller.exercises[cursor.supersetIndex!] as Superset).notes;
  final restTime = cursor.supersetIndex == null
      ? exercise.restTime
      : (controller.exercises[cursor.supersetIndex!] as Superset).restTime;
  final supersetExerciseCount = cursor.supersetIndex == null
      ? 1
      : ((controller.exercises[cursor.supersetIndex!] as Superset)
          .exercises
          .length);
  final context = Get.context;
  final fallbackColor = context?.theme.colorScheme.primary ?? Colors.grey;
  final exerciseColor = exercise.standard && exercise.category != null
      ? exerciseStandardLibrary[exercise.category]?.color ?? fallbackColor
      : fallbackColor;

  return _CurrentSetData(
    cursor: cursor,
    index: (
      exerciseIndex: cursor.exerciseIndex,
      supersetIndex: cursor.supersetIndex,
    ),
    exercise: exercise,
    set: set,
    restTime: restTime,
    setTypeLabel: _nextUpSetShortLabel(exercise, set),
    supersetNotes: supersetNotes,
    isInSuperset: cursor.supersetIndex != null,
    supersetExerciseCount: supersetExerciseCount,
    exerciseColor: exerciseColor,
    parametersLabel: set.getHumanReadableDescription(
      weightUnit: controller.weightUnit.value,
      distanceUnit: controller.distanceUnit.value,
    ),
  );
}

Future<void> _showRestTimeEditor(
  BuildContext context,
  _CurrentSetData data,
) async {
  final controller = Get.find<WorkoutController>();
  final textController = TextEditingController(
    text: TimeInputField.encodeDuration(data.restTime),
  );
  final focusNode = FocusNode();
  Duration restTime = data.restTime;

  SchedulerBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('exercise.fields.restTime'.t),
      content: TimeInputField(
        controller: textController,
        focusNode: focusNode,
        decoration: GymTrackerInputDecoration(
          labelText: 'exercise.fields.restTime'.t,
        ),
        onChangedTime: (value) {
          restTime = value ?? Duration.zero;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            final index = data.cursor.supersetIndex == null
                ? data.index
                : (
                    exerciseIndex: data.cursor.supersetIndex!,
                    supersetIndex: null,
                  );
            controller.callbacks.onExerciseChangeRestTime(index, restTime);
            Navigator.of(ctx).pop();
          },
          child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
        ),
      ],
    ),
  );

  textController.dispose();
  focusNode.dispose();
}

Exercise? _exerciseAtCursor(
    WorkoutController controller, WorkoutSetCursor cursor) {
  if (cursor.supersetIndex == null) {
    final ex = controller.exercises[cursor.exerciseIndex];
    return ex is Exercise ? ex : null;
  }

  final superset = controller.exercises[cursor.supersetIndex!];
  if (superset is! Superset) return null;
  if (cursor.exerciseIndex < 0 ||
      cursor.exerciseIndex >= superset.exercises.length) {
    return null;
  }
  return superset.exercises[cursor.exerciseIndex];
}

List<_SetRef> _orderedSetRefs(WorkoutController controller) {
  final refs = <_SetRef>[];

  for (int i = 0; i < controller.exercises.length; i++) {
    final candidate = controller.exercises[i];
    if (candidate is Exercise) {
      for (int setIndex = 0; setIndex < candidate.sets.length; setIndex++) {
        refs.add(_SetRef(
          cursor: (
            exerciseIndex: i,
            supersetIndex: null,
            setIndex: setIndex,
          ),
          exercise: candidate,
          set: candidate.sets[setIndex],
          isInSuperset: false,
        ));
      }
      continue;
    }

    if (candidate is! Superset) continue;

    final maxSets = candidate.exercises.fold<int>(
      0,
      (value, exercise) =>
          value > exercise.sets.length ? value : exercise.sets.length,
    );

    for (int setIndex = 0; setIndex < maxSets; setIndex++) {
      for (int exerciseIndex = 0;
          exerciseIndex < candidate.exercises.length;
          exerciseIndex++) {
        final exercise = candidate.exercises[exerciseIndex];
        if (setIndex >= exercise.sets.length) continue;
        refs.add(_SetRef(
          cursor: (
            exerciseIndex: exerciseIndex,
            supersetIndex: i,
            setIndex: setIndex,
          ),
          exercise: exercise,
          set: exercise.sets[setIndex],
          isInSuperset: true,
        ));
      }
    }
  }

  return refs;
}

bool _sameCursor(WorkoutSetCursor a, WorkoutSetCursor b) {
  return a.exerciseIndex == b.exerciseIndex &&
      a.supersetIndex == b.supersetIndex &&
      a.setIndex == b.setIndex;
}

bool _hasPreviousSet(WorkoutController controller, WorkoutSetCursor? cursor) {
  if (cursor == null) return false;
  final ordered = _orderedSetRefs(controller);
  final current = ordered.indexWhere((ref) => _sameCursor(ref.cursor, cursor));
  if (current <= 0) return false;

  for (int i = current - 1; i >= 0; i--) {
    if (!ordered[i].set.done) return true;
  }

  return false;
}

bool _hasNextSet(WorkoutController controller, WorkoutSetCursor? cursor) {
  if (cursor == null) return false;
  final ordered = _orderedSetRefs(controller);
  final current = ordered.indexWhere((ref) => _sameCursor(ref.cursor, cursor));
  if (current < 0 || current >= ordered.length - 1) return false;

  for (int i = current + 1; i < ordered.length; i++) {
    if (!ordered[i].set.done) return true;
  }

  return false;
}

_NextUpData? _nextUpData(
    WorkoutController controller, _CurrentSetData current) {
  final ordered = _orderedSetRefs(controller);
  final currentIndex =
      ordered.indexWhere((ref) => _sameCursor(ref.cursor, current.cursor));
  if (currentIndex == -1) return null;

  for (int i = currentIndex + 1; i < ordered.length; i++) {
    if (!ordered[i].set.done) {
      final next = ordered[i];
      return _NextUpData(
        exercise: next.exercise,
        set: next.set,
        isInSuperset: next.isInSuperset,
        parametersLabel: next.set.getHumanReadableDescription(
          weightUnit: controller.weightUnit.value,
          distanceUnit: controller.distanceUnit.value,
        ),
      );
    }
  }

  for (int i = 0; i < ordered.length; i++) {
    if (!ordered[i].set.done) {
      final next = ordered[i];
      return _NextUpData(
        exercise: next.exercise,
        set: next.set,
        isInSuperset: next.isInSuperset,
        parametersLabel: next.set.getHumanReadableDescription(
          weightUnit: controller.weightUnit.value,
          distanceUnit: controller.distanceUnit.value,
        ),
      );
    }
  }

  return null;
}

String _nextUpSetShortLabel(Exercise exercise, GTSet set) {
  switch (set.kind) {
    case GTSetKind.warmUp:
      return 'set.kindShort.warmUp'.t;
    case GTSetKind.normal:
      final normalSets = exercise.sets
          .where((element) => element.kind == GTSetKind.normal)
          .toList();
      final setIndex = normalSets.indexWhere((element) => element.id == set.id);
      final index = setIndex < 0 ? 1 : setIndex + 1;
      return index.toString();
    case GTSetKind.drop:
      return 'set.kindShort.drop'.t;
    case GTSetKind.failure:
      return 'set.kindShort.failure'.t;
    case GTSetKind.failureStripping:
      return 'set.kindShort.failureStripping'.t;
  }
}

Color _setTypeColor(BuildContext context, GTSetKind kind) {
  final scheme = Theme.of(context).colorScheme;
  final moreColors = Theme.of(context).extension<MoreColors>();
  switch (kind) {
    case GTSetKind.warmUp:
      return scheme.tertiary;
    case GTSetKind.normal:
      return scheme.primary;
    case GTSetKind.drop:
      return scheme.error;
    case GTSetKind.failure:
      return moreColors?.quinary ?? scheme.secondary;
    case GTSetKind.failureStripping:
      return moreColors?.quaternary ?? scheme.primary;
  }
}

bool _canTriggerRestTimer(_CurrentSetData? current) {
  if (current == null) return false;
  if (!Get.isRegistered<WorkoutController>()) return false;

  final controller = Get.find<WorkoutController>();
  if (current.cursor.supersetIndex == null) {
    return current.exercise.restTime.inSeconds > 0;
  }

  final superset = controller.exercises[current.cursor.supersetIndex!];
  if (superset is! Superset) return false;
  return superset.restTime.inSeconds > 0;
}

bool _isWorkoutComplete(WorkoutController controller) {
  final ordered = _orderedSetRefs(controller);
  if (ordered.isEmpty) return false;
  return ordered.every((entry) => entry.set.done);
}

bool _isLastSetInWorkout(
  WorkoutController controller,
  WorkoutSetCursor cursor,
) {
  final ordered = _orderedSetRefs(controller);
  final currentIndex =
      ordered.indexWhere((entry) => _sameCursor(entry.cursor, cursor));
  return currentIndex == ordered.length - 1;
}

bool _isLastSetInExercise(WorkoutSetCursor cursor, Exercise exercise) {
  return exercise.sets.isNotEmpty &&
      cursor.setIndex == exercise.sets.length - 1;
}

void _insertSetAfterCurrent(
  WorkoutController controller,
  _CurrentSetData current,
  GTSetKind kind,
) {
  final cursor = current.cursor;
  final insertionIndex = cursor.setIndex + 1;
  final newSet = GTSet.empty(
    kind: kind,
    parameters: current.exercise.parameters,
  );

  if (cursor.supersetIndex == null) {
    final exercise = controller.exercises[cursor.exerciseIndex] as Exercise;
    controller.exercises[cursor.exerciseIndex] = exercise.copyWith(
      sets: [
        ...exercise.sets.take(insertionIndex),
        newSet,
        ...exercise.sets.skip(insertionIndex),
      ],
    );
  } else {
    final superset = controller.exercises[cursor.supersetIndex!] as Superset;
    controller.exercises[cursor.supersetIndex!] = superset.copyWith(
      exercises: [
        for (int i = 0; i < superset.exercises.length; i++)
          if (i == cursor.exerciseIndex)
            superset.exercises[i].copyWith(
              sets: [
                ...superset.exercises[i].sets.take(insertionIndex),
                newSet,
                ...superset.exercises[i].sets.skip(insertionIndex),
              ],
            )
          else
            superset.exercises[i],
      ],
    );
  }

  controller.exercises.refresh();
  controller.save();
  controller.selectSetCursorByIndex(current.index, insertionIndex);
}

Future<void> _addExerciseAndAdvanceCursor(
  WorkoutController controller,
  _CurrentSetData? current,
) async {
  final previousLength = controller.exercises.length;
  await controller.pickExercises();

  if (controller.exercises.length <= previousLength) {
    return;
  }

  final firstNewExerciseIndex = previousLength;
  final firstNewExercise = controller.exercises[firstNewExerciseIndex];
  if (firstNewExercise is Exercise && firstNewExercise.sets.isNotEmpty) {
    controller.selectSetCursorByIndex(
      (
        exerciseIndex: firstNewExerciseIndex,
        supersetIndex: null,
      ),
      0,
    );
    return;
  }

  if (current != null) {
    controller.selectSetCursorByIndex(current.index, current.cursor.setIndex);
  }
}

class _SetTypeBadge extends StatelessWidget {
  final GTSet set;
  final Exercise exercise;
  final WorkoutExerciseIndex index;
  final int setIndex;

  const _SetTypeBadge({
    required this.set,
    required this.exercise,
    required this.index,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: 'set.kind'.t,
      icon: buildSetType(
        context,
        set.kind,
        set: set,
        allSets: exercise.sets,
      ),
      itemBuilder: (context) => buildSetKindMenuEntries(
        context: context,
        exercise: exercise,
        set: set,
        onSetSelectKind: (kind) {
          Get.find<WorkoutController>().callbacks.onSetSelectKind(
                index,
                setIndex,
                kind,
              );
        },
      ),
    );
  }
}

class _NotesBox extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback? onTap;

  const _NotesBox({
    required this.title,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final notesTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: text.isEmpty ? 15 : null,
          color: text.isEmpty
              ? Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((0.75 * 255).round())
              : null,
        );

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        GTIcons.notes,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(text: title),
                  ],
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              text.asQuillDocument().isEmpty()
                  ? Text(
                      'exercise.editor.fields.notes.tapToEdit'.t,
                      style: notesTextStyle,
                    )
                  : MaybeRichText(
                      text: text,
                      style: notesTextStyle,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showNotesEditor(
  BuildContext context, {
  required String initialText,
  required ValueChanged<String> onSave,
}) async {
  final controller = quillControllerFromText(initialText);
  await showDialog<void>(
    context: context,
    builder: (context) => GTRichTextEditDialog(
      controller: controller,
      onNotesChange: (text) {
        onSave(text);
        Navigator.of(context).pop();
      },
    ),
  );
}

bool _isSetIndexAfter(WorkoutSetCursor a, WorkoutSetCursor? b) {
  if (b == null) return true;

  // Exercise index is the number of the exercise relative to the root
  // Superset index is the number of the exercise relative to its superset
  // Set index is the number of the set in the exercise

  if (a.supersetIndex == null && b.supersetIndex == null) {
    // Both are in the root
    if (a.exerciseIndex != b.exerciseIndex) {
      return a.exerciseIndex > b.exerciseIndex;
    }
    return a.setIndex > b.setIndex;
  }

  if (a.supersetIndex != null && b.supersetIndex != null) {
    // Both are in a superset
    if (a.supersetIndex != b.supersetIndex) {
      return a.supersetIndex! > b.supersetIndex!;
    }
    if (a.exerciseIndex != b.exerciseIndex) {
      return a.exerciseIndex > b.exerciseIndex;
    }
    return a.setIndex > b.setIndex;
  }

  // One is in a superset and the other is not
  if (a.supersetIndex == null) {
    // a is in the root, b is in a superset
    return a.exerciseIndex > b.supersetIndex!;
  } else {
    // a is in a superset, b is in the root
    return a.supersetIndex! > b.exerciseIndex;
  }
}

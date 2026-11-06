import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/exercise_progression.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/parent_viewer.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/components/themed_subtree.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_menus.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:intl/intl.dart' show NumberFormat;

part 'workout_simple/animations.dart';
part 'workout_simple/data.dart';
part 'workout_simple/editors.dart';
part 'workout_simple/details.dart';
part 'workout_simple/empty.dart';
part 'workout_simple/header.dart';
part 'workout_simple/set_card.dart';
part 'workout_simple/controls.dart';
part 'workout_simple/rest_panel.dart';

class WorkoutSimpleView extends ConsumerWidget {
  const WorkoutSimpleView({super.key});
  static const routeName = '/workout/simple';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutControllerProvider);
    if (workout == null) return const Center(child: GBLoadingIndicator());
    final controller = ref.read(workoutControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);
    final current = _currentSetData(controller, context);
    final complete = _isWorkoutComplete(controller);
    final color = settings.tintExercises && current != null
        ? current.exerciseColor
        : settings.color;

    final page = Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const _StopwatchTitle(),
        actions: [
          IconButton(
            tooltip: context.t.ongoingWorkout.simple.restTimer,
            onPressed: _canTriggerRestTimer(current)
                ? () => controller.markSetAsDone(current!.index, -1, true)
                : null,
            icon: const Icon(GTIcons.rest_timer),
          ),
          PopupMenuButton(
            itemBuilder: (context) =>
                buildToolboxMenuEntries(context, controller),
            tooltip: context.t.ongoingWorkout.toolbox.title,
            icon: const Icon(GTIcons.tools),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              final items = <PopupMenuEntry<dynamic>>[
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(GTIcons.workout),
                    title: Text(context.t.ongoingWorkout.simple.switchToFull),
                    mouseCursor: SystemMouseCursors.click,
                  ),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      context.pushReplacement(WorkoutView.routeName);
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
                    title: Text(context.t.set.kindLong["drop"]!),
                    mouseCursor: SystemMouseCursors.click,
                    enabled: current != null,
                  ),
                ),
              ];

              return items;
            },
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _AnimatedWorkoutProgress(
            key: const ValueKey('simple-workout-progress'),
            value: controller.progress,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              // The sliver viewport preserves the elastic offset when a timer
              // triggers layout; SingleChildScrollView clamps it mid-bounce.
              child: CustomScrollView(
                key: const ValueKey('simple-workout-scroll'),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ContentInset(
                            child: _WorkoutHeader(
                              controller: controller,
                              current: current,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _WorkoutChangeTransition(
                            key: const ValueKey('simple-set-transition'),
                            identity:
                                current?.set.id ??
                                (complete ? 'complete' : 'empty'),
                            reverse: _movesToPreviousSet(
                              controller.exercises,
                              current?.cursor,
                              controller.previousSetCursor,
                            ),
                            child: current == null
                                ? _ContentInset(
                                    child: _EmptyCurrentSetView(
                                      isWorkoutComplete: complete,
                                      onFinishWorkout: () => controller
                                          .finishWorkoutWithDialog(context),
                                      onAddExercise: () =>
                                          _addExerciseAndAdvanceCursor(
                                            controller,
                                            null,
                                          ),
                                    ),
                                  )
                                : _CurrentSetView(
                                    data: current,
                                    controller: controller,
                                    nextUp: _nextUpData(
                                      context,
                                      controller,
                                      current,
                                    ),
                                    onEditSet: () => Go.to<void>(
                                      () => _SimpleSetEditDialog(data: current),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _RestPanel(accentColor: color),
          ],
        ),
      ),
    );
    final content = settings.tintExercises
        ? ThemedSubtree(
            color: color,
            child: _SimpleViewTheme(child: page),
          )
        : _SimpleViewTheme(child: page);
    // Stretching transforms deform the cards on Android. Disabling the effect
    // preserves the platform scroll physics, including iOS's elastic scrolling.
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: content,
    );
  }
}

/// Align content with the cards while allowing the set strip to reach the edges.
class _ContentInset extends StatelessWidget {
  const _ContentInset({required this.child});
  final Widget child;

  static double horizontal(double width) =>
      (width > 700 ? (width - 700) / 2 : 0) + 16;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal(constraints.maxWidth),
      ),
      child: child,
    ),
  );
}

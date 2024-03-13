import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:universal_platform/universal_platform.dart';

Workout get emptyWorkout => Workout(name: "", exercises: []);

class RoutinesView extends StatefulWidget {
  const RoutinesView({super.key});

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  RoutinesController get controller => Get.put(RoutinesController());
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.onServiceChange();
  }

  List<(Workout, int)> get _suggestedRoutines {
    final today = DateTime.now().weekday;
    final candidates = <Workout, int>{};
    final controller = Get.find<HistoryController>();
    final history = controller.history;
    for (final routine in this.controller.workouts) {
      final occurrences = history.where((wo) => wo.parentID == routine.id);
      candidates[routine] =
          occurrences.where((wo) => wo.startingDate?.weekday == today).length;
    }
    candidates.removeWhere((k, v) => v == 0);

    final listCandidates = [...candidates.entries];
    listCandidates.sort((a, b) => b.value - a.value);
    return [...listCandidates.map((a) => (a.key, a.value)).take(5)];
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _suggestedRoutines;
    return Scaffold(
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("routines.title".t),
            ),
            SliverToBoxAdapter(
              child: ListTile(
                title: Text("routines.quickWorkout.title".t),
                subtitle: Text("routines.quickWorkout.subtitle".t),
                leading: const CircleAvatar(child: Icon(Icons.timer_rounded)),
                onTap: () {
                  controller.startRoutine(context, emptyWorkout, isEmpty: true);
                },
              ),
            ),
            if (suggested.isNotEmpty) ...[
              const SliverToBoxAdapter(child: Divider()),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final (workout, frequency) = suggested[index];
                    return Material(
                      type: MaterialType.transparency,
                      key: ValueKey(workout.id),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          child:
                              Text(workout.name.characters.first.toUpperCase()),
                        ),
                        title: Text.rich(TextSpan(
                          children: [
                            TextSpan(
                              text: workout.name,
                            ),
                            const TextSpan(text: " "),
                            WidgetSpan(
                              child: GTBadge(content: frequency.toString()),
                              alignment: PlaceholderAlignment.middle,
                            ),
                          ],
                        )),
                        subtitle: Text("general.exercises"
                            .plural(workout.displayExerciseCount)),
                        onTap: () {
                          Go.to(() => ExercisesView(workout: workout));
                        },
                      ),
                    );
                  },
                  childCount: suggested.length,
                ),
              ),
              const SliverToBoxAdapter(child: Divider()),
            ],
            SliverReorderableList(
              itemBuilder: (context, index) {
                final workout = controller.workouts[index];
                return Material(
                  type: MaterialType.transparency,
                  key: ValueKey(workout.id),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      child: Text(workout.name.characters.first.toUpperCase()),
                    ),
                    trailing: () {
                      if (UniversalPlatform.isAndroid ||
                          UniversalPlatform.isIOS) {
                        return ReorderableDelayedDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        );
                      } else {
                        return ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        );
                      }
                    }(),
                    title: Text(workout.name),
                    subtitle: Text("general.exercises"
                        .plural(workout.displayExerciseCount)),
                    onTap: () {
                      Go.to(() => ExercisesView(workout: workout));
                    },
                  ),
                );
              },
              itemCount: controller.workouts.length,
              onReorder: (oldIndex, newIndex) {
                controller.reorder(oldIndex, newIndex);
              },
            ),
            const SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: ListTile(
                title: Text("routines.newRoutine".t),
                leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
                onTap: () {
                  Go.to(() => const RoutineCreator());
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/platform/app_bar.dart';
import 'package:gymtracker/view/platform/list_tile.dart';
import 'package:gymtracker/view/platform/scaffold.dart';
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

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            PlatformSliverAppBar(
              title: Text("routines.title".t),
            ),
            SliverToBoxAdapter(
              child: PlatformListTile(
                title: Text("routines.quickWorkout.title".t),
                subtitle: Text("routines.quickWorkout.subtitle".t),
                leading:
                    const PlatformLeadingIcon(child: Icon(Icons.timer_rounded)),
                onTap: () {
                  controller.startRoutine(context, emptyWorkout, isEmpty: true);
                },
              ),
            ),
            SliverReorderableList(
              itemBuilder: (context, index) {
                final workout = controller.workouts[index];
                return Material(
                  type: MaterialType.transparency,
                  key: ValueKey(workout.id),
                  child: PlatformListTile(
                    leading: PlatformLeadingIcon(
                      materialBackgroundColor:
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
              child: PlatformListTile(
                title: Text("routines.newRoutine".t),
                leading:
                    const PlatformLeadingIcon(child: Icon(Icons.add_rounded)),
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

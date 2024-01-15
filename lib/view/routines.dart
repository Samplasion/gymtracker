

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_platform/universal_platform.dart';

import '../controller/workouts_controller.dart';
import '../model/workout.dart';
import '../service/localizations.dart';
import '../utils/go.dart';
import '../view/exercises.dart';
import 'routine_creator.dart';

Workout get emptyWorkout => Workout(name: "", exercises: []);

class RoutinesView extends StatefulWidget {
  const RoutinesView({super.key});

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  WorkoutsController get controller => Get.put(WorkoutsController());
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.onServiceChange();
  }

  @override
  Widget build(BuildContext context) {
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
                      if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
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
                    subtitle: Text(
                        "general.exercises".plural(workout.exercises.length)),
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
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () {
          Go.to(() => const RoutineCreator());
        },
      ),
    );
  }
}

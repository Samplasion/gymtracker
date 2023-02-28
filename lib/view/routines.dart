import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      appBar: AppBar(
        title: Text("routines.title".tr),
      ),
      body: Obx(() {
        return ListView(
          children: [
            ListTile(
              title: Text("routines.quickWorkout.title".tr),
              subtitle: Text("routines.quickWorkout.subtitle".tr),
              leading: const CircleAvatar(child: Icon(Icons.timer_rounded)),
              onTap: () {
                controller.startRoutine(context, emptyWorkout);
              },
            ),
            for (final workout in controller.workouts) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  child: Text(workout.name.characters.first.toUpperCase()),
                ),
                title: Text(workout.name),
                subtitle:
                    Text("general.exercises".plural(workout.exercises.length)),
                onTap: () {
                  Go.to(() => ExercisesView(workout: workout));
                },
              ),
            ],
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

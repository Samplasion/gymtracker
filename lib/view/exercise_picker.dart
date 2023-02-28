import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/exercises_controller.dart';
import '../model/exercise.dart';
import 'utils/exercise.dart';
import 'exercise_creator.dart';

class ExercisePicker extends StatefulWidget {
  final bool singlePick;

  const ExercisePicker({required this.singlePick, super.key});

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  ExercisesController get controller => Get.put(ExercisesController());

  Set<Exercise> selectedExercises = {};

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("exercise.picker.title".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          )
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.exercises.length,
          itemBuilder: (BuildContext context, int index) {
            final exercise = controller.exercises[index];
            final isSelected = selectedExercises.contains(exercise);
            return Dismissible(
              key: ValueKey(exercise.id),
              onDismissed: (_) {
                selectedExercises.remove(exercise);
                controller.deleteExercise(exercise);
                controller.exercises.refresh();
              },
              direction: DismissDirection.endToStart,
              background: Container(
                color: scheme.error,
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "actions.remove".tr,
                    style: TextStyle(color: scheme.onError),
                  ),
                ),
              ),
              child: ExerciseListTile(
                exercise: exercise,
                selected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedExercises.remove(exercise);
                    } else {
                      if (widget.singlePick) {
                        selectedExercises = {exercise};
                      } else {
                        selectedExercises.add(exercise);
                      }
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ExerciseCreator(base: null),
          );
        },
        label: Text("actions.create".tr),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _submit() {
    if (widget.singlePick && selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("exercise.picker.errors.empty".tr),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    final List<Exercise> exercises =
        selectedExercises.map((e) => e.clone()..regenerateID()).toList();
    Get.back(result: exercises);
  }
}

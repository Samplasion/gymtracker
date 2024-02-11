import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';

import '../controller/exercises_controller.dart';
import '../data/exercises.dart';
import '../model/exercise.dart';
import '../utils/go.dart';
import '../utils/utils.dart';
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

  Map<String, ExerciseCategory> get exercises {
    final sortedKeys = [...exerciseStandardLibrary.keys]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      "library.custom".t: ExerciseCategory(
        exercises: controller.exercises,
        icon: const Icon(Icons.star_rounded),
        color: Colors.yellow,
      ),
      for (final key in sortedKeys) key: exerciseStandardLibrary[key]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("exercise.picker.title".t),
        actions: [
          if (!widget.singlePick)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _submit,
            )
        ],
      ),
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  for (final category in exercises.entries)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            getContainerColor(context, category.value.color),
                        foregroundColor:
                            getOnContainerColor(context, category.value.color),
                        child: category.value.icon,
                      ),
                      title: Text(category.key),
                      subtitle: Text(
                        "general.exercises"
                            .plural(category.value.exercises.length),
                      ),
                      onTap: () {
                        Go.to(
                          () => StatefulBuilder(builder: (context, setState) {
                            return LibraryPickerExercisesView(
                              name: category.key,
                              category: category.value,
                              singleSelection: widget.singlePick,
                              onSelected: (exercise) {
                                final isSelected =
                                    selectedExercises.contains(exercise);
                                isSelected.printInfo(info: "outer picker");
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
                              onSubmit: () {
                                Get.back();
                                _submit();
                              },
                              selectedExercises: selectedExercises,
                            );
                          }),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ExerciseCreator(base: null),
          );
        },
        label: Text("actions.create".t),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _submit() {
    if (widget.singlePick && selectedExercises.isEmpty) {
      Go.snack("exercise.picker.errors.empty".t);
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    final List<Exercise> exercises = selectedExercises
        .map((e) => e.clone()
          ..parentID = e.parentID ?? e.id
          ..regenerateID())
        .toList();
    Get.back(result: exercises, closeOverlays: true);
  }
}

class LibraryPickerExercisesView extends StatefulWidget {
  const LibraryPickerExercisesView({
    required this.name,
    required this.category,
    required this.onSelected,
    required this.singleSelection,
    required this.onSubmit,
    required this.selectedExercises,
    super.key,
  });

  final String name;
  final ExerciseCategory category;
  final ValueChanged<Exercise> onSelected;
  final bool singleSelection;
  final VoidCallback onSubmit;
  final Set<Exercise> selectedExercises;

  @override
  State<LibraryPickerExercisesView> createState() =>
      _LibraryPickerExercisesViewState();
}

class _LibraryPickerExercisesViewState
    extends State<LibraryPickerExercisesView> {
  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.category.exercises]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: widget.onSubmit,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.category.exercises.length,
        itemBuilder: (context, index) {
          return ExerciseListTile(
            exercise: sorted[index],
            selected: widget.selectedExercises.contains(sorted[index]),
            isConcrete: false,
            onTap: () {
              setState(() {
                widget.onSelected(sorted[index]);
              });
            },
          );
        },
      ),
    );
  }
}

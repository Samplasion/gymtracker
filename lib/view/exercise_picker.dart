import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/exercise_creator.dart';
import 'package:gymtracker/view/utils/exercise.dart';

enum ExercisePickerFilter {
  all,
  custom,
  library;

  bool get hasCustom =>
      this == ExercisePickerFilter.all || this == ExercisePickerFilter.custom;
  bool get hasLibrary =>
      this == ExercisePickerFilter.all || this == ExercisePickerFilter.library;
}

typedef ExerciseFilter = bool Function(Exercise);

class ExercisePicker extends StatefulWidget {
  final bool singlePick;
  final bool allowNone;
  final ExercisePickerFilter filter;
  final ExerciseFilter? individualFilter;

  const ExercisePicker({
    required this.singlePick,
    this.allowNone = false,
    this.filter = ExercisePickerFilter.all,
    this.individualFilter,
    super.key,
  }) : assert(
            allowNone ? singlePick : true, "Cannot allow none and multi pick");

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  ExercisesController get controller => Get.put(ExercisesController());

  Set<Exercise> selectedExercises = {};

  bool _filter(Exercise exercise) {
    if (widget.individualFilter != null) {
      return widget.individualFilter!(exercise);
    }
    return true;
  }

  Map<String, ExerciseCategory> get exercises {
    final sortedKeys = [...exerciseStandardLibrary.keys]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      if (widget.filter.hasCustom)
        "library.custom".t: ExerciseCategory(
          exercises: controller.exercises.where(_filter).toList(),
          icon: const Icon(GymTrackerIcons.custom_exercises),
          color: Colors.yellow,
        ),
      if (widget.filter.hasLibrary)
        for (final key in sortedKeys)
          if (exerciseStandardLibrary[key]!
              .filtered(_filter)
              .exercises
              .isNotEmpty)
            key: exerciseStandardLibrary[key]!.filtered(_filter),
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
              key: const Key('pick'),
              icon: const Icon(GymTrackerIcons.done),
              onPressed: _submit,
            )
        ],
      ),
      body: widget.filter.hasCustom
          ? Obx(() => _innerScrollView(context))
          : _innerScrollView(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Go.showBottomModalScreen(
            (context, scrollController) => ExerciseCreator(
              base: null,
              scrollController: scrollController,
            ),
          );
        },
        label: Text("actions.create".t),
        icon: const Icon(GymTrackerIcons.create_exercise),
      ),
    );
  }

  CustomScrollView _innerScrollView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            if (widget.allowNone) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colorScheme.tertiaryContainer,
                  foregroundColor: context.colorScheme.onTertiaryContainer,
                  child: const Icon(GymTrackerIcons.no_routine),
                ),
                title: Text("exercises.none.title".t),
                subtitle: Text("exercises.none.subtitle".t),
                onTap: () {
                  Get.back(result: <Exercise>[]);
                },
              ),
              const Divider(),
            ],
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
                  "general.exercises".plural(category.value.exercises.length),
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
                          isSelected.logger.d("outer picker");
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
          ]),
        ),
      ],
    );
  }

  void _submit() {
    if (widget.singlePick && selectedExercises.isEmpty) {
      Go.snack("exercise.picker.errors.empty".t);
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    final List<Exercise> exercises = selectedExercises.map((e) => e).toList();
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
            key: const Key('pick'),
            icon: const Icon(GymTrackerIcons.done),
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

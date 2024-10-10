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
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';

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

  Set<GTGymEquipment> equipmentFilter = GTGymEquipment.values.toSet();
  bool _showFilterRow = false;

  bool _filter(Exercise exercise) {
    bool show = true;
    show &= equipmentFilter.contains(exercise.gymEquipment);
    if (widget.individualFilter != null) {
      show &= widget.individualFilter!(exercise);
    }
    return show;
  }

  bool get _hasCustomFilters {
    return equipmentFilter.length != GTGymEquipment.values.length;
  }

  Map<GTExerciseMuscleCategory, ExerciseCategory> get exercises {
    return {
      if (widget.filter.hasCustom)
        GTExerciseMuscleCategory.custom: ExerciseCategory(
          exercises: controller.exercises.where(_filter).toList(),
          iconGetter: () => const Icon(GTIcons.custom_exercises),
          color: Colors.yellow,
        ),
      if (widget.filter.hasLibrary)
        for (final key in sortedCategories)
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
          IconButton(
            icon: Badge(
              isLabelVisible: _hasCustomFilters,
              child: const Icon(GTIcons.filter_list),
            ),
            onPressed: () {
              setState(() {
                _showFilterRow = !_showFilterRow;
              });
            },
          ),
          if (!widget.singlePick)
            IconButton(
              key: const Key('pick'),
              icon: const Icon(GTIcons.done),
              onPressed: _submit,
            ),
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
        icon: const Icon(GTIcons.create_exercise),
      ),
    );
  }

  CustomScrollView _innerScrollView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _filterSection(context),
        SliverList(
          delegate: SliverChildListDelegate([
            if (widget.allowNone) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colorScheme.tertiaryContainer,
                  foregroundColor: context.colorScheme.onTertiaryContainer,
                  child: const Icon(GTIcons.no_routine),
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
                title: Text(category.key.localizedName),
                subtitle: Text(
                  "general.exercises".plural(category.value.exercises.length),
                ),
                onTap: () {
                  Go.to(
                    () => StatefulBuilder(builder: (context, setState) {
                      return LibraryPickerExercisesView(
                        name: category.key.localizedName,
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
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        const SliverBottomSafeArea(),
      ],
    );
  }

  SliverToBoxAdapter _filterSection(BuildContext context) {
    final part = partition(
        GTGymEquipment.values.toList(), (el) => equipmentFilter.contains(el));
    final equipments = part.$1 + part.$2;
    return SliverToBoxAdapter(
      child: Crossfade(
        firstChild: Container(
          color: context.colorScheme.surfaceContainerLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text(
                    "exercise.picker.filter.equipment".t,
                    style: context.textTheme.labelMedium,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        for (final equipment in equipments)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(equipment.localizedName),
                              selected: equipmentFilter.contains(equipment),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    equipmentFilter.add(equipment);
                                  } else {
                                    equipmentFilter.remove(equipment);
                                  }
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        secondChild: const SizedBox.shrink(),
        showSecond: !_showFilterRow,
      ),
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
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            key: const Key('pick'),
            icon: const Icon(GTIcons.done),
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

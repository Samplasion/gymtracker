import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/equipment_icon.dart';
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

class ExercisePicker extends ConsumerStatefulWidget {
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
         allowNone ? singlePick : true,
         "Cannot allow none and multi pick",
       );

  @override
  ConsumerState<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<ExercisePicker> {
  ExercisesController get controller => ref.read(exercisesControllerProvider);

  Map<String, Exercise> selectedExercises = {};

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
          iconGetter: (t) => const Icon(GTIcons.custom_exercises),
          color: context.harmonizeColor(Colors.yellow),
        ),
      if (widget.filter.hasLibrary)
        for (final key in getSortedCategories(context.t))
          if (exerciseStandardLibrary[key]!
              .filtered(_filter)
              .exercises
              .isNotEmpty)
            key: exerciseStandardLibrary[key]!.filtered(_filter),
    };
  }

  late var badges = computeBadges();

  @override
  Widget build(BuildContext context) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.exercise.picker.title),
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
          _search(),
          if (!widget.singlePick)
            IconButton(
              key: const Key('pick'),
              icon: const Icon(GTIcons.done),
              onPressed: _submit,
            ),
        ],
      ),
      body: widget.filter.hasCustom
          ? Builder(builder: (context) => _innerScrollView(context))
          : _innerScrollView(context),
      floatingActionButton: const _CreateExerciseFab(),
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
                title: Text(context.t.exercises.none.title),
                subtitle: Text(context.t.exercises.none.subtitle),
                onTap: () {
                  Go.back(result: <Exercise>[]);
                },
              ),
              const Divider(),
            ],
            for (final category in exercises.entries)
              ListTile(
                leading: Badge(
                  isLabelVisible: badges[category.key]!.isLabelVisible,
                  label: badges[category.key]!.label,
                  child: CircleAvatar(
                    backgroundColor: getContainerColor(
                      context,
                      category.value.color,
                    ),
                    foregroundColor: getOnContainerColor(
                      context,
                      category.value.color,
                    ),
                    child: category.value.iconGetter(context.t),
                  ),
                ),
                title: Text(category.key.getLocalizedName(context.t)),
                subtitle: Text(
                  context.t.general.exercises(
                    n: category.value.exercises.length,
                  ),
                ),
                onTap: () {
                  Go.to(
                    () => StatefulBuilder(
                      builder: (context, setState) {
                        return LibraryPickerExercisesView(
                          name: category.key.getLocalizedName(context.t),
                          category: category.value,
                          singleSelection: widget.singlePick,
                          selectedExercises: selectedExercises,
                          onSelected: (exercise) {
                            final isSelected = selectedExercises.containsKey(
                              exercise.id,
                            );
                            isSelected.logger.d("outer picker");
                            setState(() {
                              if (isSelected) {
                                selectedExercises.remove(exercise.id);
                              } else {
                                if (widget.singlePick) {
                                  selectedExercises = {exercise.id: exercise};
                                } else {
                                  selectedExercises[exercise.id] = exercise;
                                }
                              }
                              badges = computeBadges();
                            });
                          },
                          onSubmit: () {
                            Go.back();
                            _submit();
                          },
                        );
                      },
                    ),
                  ).then((_) => setState(() {}));
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
    final equipments = GTGymEquipment.values.toList();
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
                    context.t.exercise.picker.filter.equipment,
                    style: Theme.of(context).textTheme.labelMedium,
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
                              showCheckmark: false,
                              avatar: ClipOval(
                                clipBehavior: Clip.hardEdge,
                                child: CircleAvatar(
                                  child: EquipmentIcon(equipment: equipment),
                                ),
                              ),
                              label: Text(
                                equipment.getLocalizedName(context.t),
                              ),
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
      Go.snack(context.t.exercise.picker.errors.empty);
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    final List<Exercise> exercises = selectedExercises.entries
        .map((e) => e.value)
        .toList();
    Go.back(result: exercises, closeOverlays: true);
  }

  Map<GTExerciseMuscleCategory, ({bool isLabelVisible, Widget? label})>
  computeBadges() {
    return {
      for (final category in exercises.entries)
        category.key: (
          isLabelVisible: category.value.exercises.any(
            (e) => selectedExercises.containsKey(e.id),
          ),
          label: widget.singlePick
              ? null
              : Text(
                  category.value.exercises
                      .where((e) => selectedExercises.containsKey(e.id))
                      .length
                      .toString(),
                ),
        ),
    };
  }

  SearchAnchor _search() {
    return SearchAnchor(
      builder: (context, sController) => IconButton(
        onPressed: () => sController.openView(),
        icon: const Icon(GTIcons.search),
      ),
      viewBuilder: (suggestions) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(padding: MediaQuery.of(context).padding.copyWith(top: 0)),
          child: suggestions.toList().getAt(0) ?? const SizedBox.shrink(),
        );
      },
      suggestionsBuilder: (context, sController) {
        final results = controller.search(sController.text, t: context.t);
        return [
          StatefulBuilder(
            builder: (context, ss) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final ex = results[index];
                  return ExerciseListTile(
                    exercise: ex,
                    selected: selectedExercises.containsKey(ex.id),
                    isConcrete: false,
                    onTap: () {
                      setState(() {
                        if (selectedExercises.containsKey(ex.id)) {
                          selectedExercises.remove(ex.id);
                        } else if (widget.singlePick) {
                          selectedExercises = {ex.id: ex};
                        } else {
                          selectedExercises[ex.id] = ex;
                        }
                        badges = computeBadges();
                      });
                      ss(() {});
                    },
                  );
                },
              );
            },
          ),
        ];
      },
    );
  }
}

class _CreateExerciseFab extends ConsumerWidget {
  const _CreateExerciseFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    return FloatingActionButton.extended(
      onPressed: () {
        Go.showBottomModalScreen(
          (context, scrollController) =>
              ExerciseCreator(base: null, scrollController: scrollController),
        );
      },
      label: Text(context.t.actions.create),
      icon: const Icon(GTIcons.create_exercise),
    );
  }
}

class LibraryPickerExercisesView extends ConsumerStatefulWidget {
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
  final Map<String, Exercise> selectedExercises;

  @override
  ConsumerState<LibraryPickerExercisesView> createState() =>
      _LibraryPickerExercisesViewState();
}

class _LibraryPickerExercisesViewState
    extends ConsumerState<LibraryPickerExercisesView> {
  @override
  Widget build(BuildContext context) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final sorted = [...widget.category.exercises]
      ..sort(
        (a, b) =>
            a.getDisplayName(context.t).compareTo(b.getDisplayName(context.t)),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            key: const Key('pick'),
            icon: const Icon(GTIcons.done),
            onPressed: widget.onSubmit,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.category.exercises.length,
        itemBuilder: (context, index) {
          return ExerciseListTile(
            exercise: sorted[index],
            selected: widget.selectedExercises.containsKey(sorted[index].id),
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

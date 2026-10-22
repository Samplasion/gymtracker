import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/equipment_icon.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class ExerciseCreator extends ConsumerStatefulWidget {
  final Exercise? base;
  final ScrollController? scrollController;
  final bool shouldChangeParameters;

  const ExerciseCreator({
    required this.base,
    this.scrollController,
    this.shouldChangeParameters = true,
    super.key,
  });

  @override
  ConsumerState<ExerciseCreator> createState() => _ExerciseCreatorState();
}

class _ExerciseCreatorState extends ConsumerState<ExerciseCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);

  late GTSetParameters params = (widget.base?.parameters.isSetless ?? false)
      ? GTSetParameters.repsWeight
      : widget.base?.parameters ?? GTSetParameters.repsWeight;
  late GTMuscleGroup? primaryGroup = widget.base?.primaryMuscleGroup;
  late Set<GTMuscleGroup> otherGroups =
      widget.base?.secondaryMuscleGroups ?? {};
  late GTGymEquipment equipment =
      widget.base?.gymEquipment ?? GTGymEquipment.none;
  late bool isSetless = widget.base?.parameters.isSetless ?? false;

  ExercisesController get controller => ref.read(exercisesControllerProvider);

  @override
  Widget build(BuildContext context) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final muscleGroups = GTMuscleGroup.values.toList();
    muscleGroups.sort(
      (a, b) =>
          context.t.muscleGroups[a.name]?.compareTo(
            context.t.muscleGroups[b.name] ?? "UNKNOWN",
          ) ??
          0,
    );
    final equipments = GTGymEquipment.values.toList();

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(() {
            if (widget.base == null) {
              return context.t.exercise.editor.create.title;
            } else {
              return context.t.exercise.editor.edit.title;
            }
          }()),
          leading: const CloseButton(),
          bottom: const PreferredSize(
            preferredSize: Size(0, 1),
            child: Divider(height: 1),
          ),
          actions: [
            IconButton(
              key: const Key("done"),
              icon: const Icon(GTIcons.done),
              onPressed: _submit,
            ),
          ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
            controller: widget.scrollController,
            children: [
              ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  decoration: _decoration(
                    context.t.exercise.editor.fields.title.label,
                  ),
                  validator: (string) {
                    if (string == null || string.isEmpty) {
                      return context
                          .t
                          .exercise
                          .editor
                          .fields
                          .title
                          .errors
                          .empty;
                    }
                    if (widget.base == null &&
                        !controller.isNameValid(string)) {
                      return context
                          .t
                          .exercise
                          .editor
                          .fields
                          .title
                          .errors
                          .invalid;
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: widget.shouldChangeParameters && !isSetless
                      ? null
                      : () {
                          final key = isSetless
                              ? "setless"
                              : "cannotChangeParameters";
                          Go.dialog(
                            "exercise.editor.$key.title",
                            "exercise.editor.$key.text",
                          );
                        },
                  child: DropdownButtonFormField(
                    decoration: _decoration(
                      context.t.exercise.editor.fields.parameters.label,
                    ),
                    items: [
                      for (final param in GTSetParameters.values)
                        if (!param.hidden)
                          DropdownMenuItem(
                            value: param,
                            child: Text(
                              context
                                      .t
                                      .exercise
                                      .editor
                                      .fields
                                      .parameters
                                      .values[param.name] ??
                                  "UNKNOWN",
                            ),
                          ),
                    ],
                    onChanged: widget.shouldChangeParameters && !isSetless
                        ? (GTSetParameters? v) => setState(() => params = v!)
                        : null,
                    validator: (value) {
                      if (value == null) {
                        return context
                            .t
                            .exercise
                            .editor
                            .fields
                            .parameters
                            .errors
                            .empty;
                      }
                      return null;
                    },
                    value: params,
                  ),
                ),
                DropdownButtonFormField<GTGymEquipment>(
                  decoration: _decoration(
                    context.t.exercise.editor.fields.gymEquipment.label,
                  ),
                  items: [
                    for (final equipment in equipments)
                      DropdownMenuItem(
                        value: equipment,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: EquipmentIcon(
                                  equipment: equipment,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              const TextSpan(text: " "),
                              TextSpan(
                                text: equipment.getLocalizedName(context.t),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => equipment = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      // Theoretically unreachable
                      return context
                          .t
                          .exercise
                          .editor
                          .fields
                          .gymEquipment
                          .errors
                          .empty;
                    }
                    return null;
                  },
                  value: equipment,
                ),
                DropdownButtonFormField<GTMuscleGroup>(
                  decoration: _decoration(
                    context.t.exercise.editor.fields.primaryMuscleGroup.label,
                  ),
                  items: [
                    for (final muscle in muscleGroups)
                      DropdownMenuItem(
                        value: muscle,
                        child: Text(
                          context.t.muscleGroups[muscle.name] ?? "UNKNOWN",
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (otherGroups.contains(value)) {
                      otherGroups.remove(value);
                    }

                    setState(() => primaryGroup = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return context
                          .t
                          .exercise
                          .editor
                          .fields
                          .primaryMuscleGroup
                          .errors
                          .empty;
                    }
                    return null;
                  },
                  value: primaryGroup,
                ),
                Text(
                  context.t.exercise.editor.fields.secondaryMuscleGroups.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final muscle in muscleGroups)
                      ChoiceChip(
                        label: Text(
                          context.t.muscleGroups[muscle.name] ?? "UNKNOWN",
                        ),
                        avatar: CircleAvatar(
                          child: Text(
                            otherGroups.contains(muscle)
                                ? ""
                                : (context
                                              .t
                                              .muscleGroups[muscle.name]
                                              ?.characters
                                              .first ??
                                          "UNKNOWN")
                                      .toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        selected: otherGroups.contains(muscle),
                        onSelected: primaryGroup == muscle
                            ? null
                            : (notSelected) {
                                setState(() {
                                  if (notSelected) {
                                    otherGroups.add(muscle);
                                  } else {
                                    otherGroups.remove(muscle);
                                  }
                                });
                              },
                      ),
                  ],
                ),
                // Advanced
                Card.outlined(
                  margin: EdgeInsets.zero,
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(context.t.exercise.editor.advanced.title),
                    children: [
                      GestureDetector(
                        onTap: widget.shouldChangeParameters
                            ? null
                            : () {
                                Go.dialog(
                                  context
                                      .t
                                      .exercise
                                      .editor
                                      .cannotChangeParameters
                                      .title,
                                  context
                                      .t
                                      .exercise
                                      .editor
                                      .cannotChangeParameters
                                      .text,
                                );
                              },
                        child: CheckboxListTile(
                          title: Text(
                            context.t.exercise.editor.advanced.setless.title,
                          ),
                          subtitle: Text(
                            context.t.exercise.editor.advanced.setless.text,
                          ),
                          value: isSetless,
                          onChanged: widget.shouldChangeParameters
                              ? (value) {
                                  setState(() {
                                    isSetless = value!;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ].map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ).copyWith(top: 0),
                  child: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return GymTrackerInputDecoration(labelText: label);
  }

  void _submit() async {
    final isValid = formKey.currentState!.validate();
    final params = isSetless ? GTSetParameters.setless : this.params;

    if (isValid) {
      if (widget.base == null) {
        controller.submit(
          name: titleController.text,
          parameters: params,
          primaryMuscleGroup: primaryGroup!,
          otherMuscleGroups: otherGroups,
          restTime: Duration.zero,
        );
        Go.back();
      } else {
        Go.back(
          result: Exercise.replaced(
            from: widget.base!,
            to: Exercise.custom(
              id: widget.base!.id,
              parentID: widget.base!.parentID,
              name: titleController.text,
              parameters: params,
              primaryMuscleGroup: primaryGroup!,
              secondaryMuscleGroups: otherGroups,
              restTime: Duration.zero,
              notes: widget.base!.notes,
              sets: [],
              workoutID: widget.base!.workoutID,
              supersetID: null,
              equipment: equipment,
            ),
          ),
        );
      }
    }
  }
}

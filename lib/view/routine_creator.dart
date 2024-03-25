import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/workout.dart';

class _DateWrapped<T> {
  T data;
  final DateTime date;

  _DateWrapped(this.data) : date = DateTime.now();
}

extension _Wrap<T> on List<T> {
  List<_DateWrapped<T>> wrap() => [for (final data in this) _DateWrapped(data)];
}

extension _Unwrap<T> on RxList<_DateWrapped<T>> {
  List<T> unwrap() => [for (final box in this) box.data];
}

class _RoutineCreatorController extends GetxController {
  final exercises = <_DateWrapped<WorkoutExercisable>>[].obs;
}

// ignore: library_private_types_in_public_api
_RoutineCreatorController get controller =>
    Get.put(_RoutineCreatorController());

class RoutineCreator extends StatefulWidget {
  final Workout? base;

  const RoutineCreator({this.base, super.key});

  @override
  State<RoutineCreator> createState() => _RoutineCreatorState();
}

class _RoutineCreatorState extends State<RoutineCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);
  late final infoboxController = QuillController(
    document: (widget.base?.infobox ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  RoutinesController get workoutsController => Get.find<RoutinesController>();

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      controller.exercises(widget.base!.exercises.wrap());
    }
  }

  @override
  void dispose() {
    Get.delete<_RoutineCreatorController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(() {
          if (widget.base == null) {
            return "routines.actions.create".t;
          } else {
            return "routines.actions.edit".t;
          }
        }()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "routines.editor.fields.name.label".t,
                ),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "routines.editor.fields.name.errors.empty".t;
                  }
                  return null;
                },
              ),
              GTRichTextEditor(
                infoboxController: infoboxController,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "routines.editor.fields.infobox.label".t,
                  alignLabelWithHint: true,
                ),
                onTapOutside: () {},
              ),
              Text("routines.editor.exercises.title".t,
                  style: Theme.of(context).textTheme.titleMedium),
            ]
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ).copyWith(top: 0),
                      child: c,
                    ))
                .toList(),
            ListTile(
              title: Text("routines.editor.exercises.add".t),
              leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
              onTap: () {
                Go.to<List<Exercise>>(() => const ExercisePicker(
                      singlePick: false,
                    )).then((result) {
                  result ??= [];
                  setState(() {
                    controller.exercises.addAll(result!
                        .map((ex) {
                          return ex.makeChild().copyWith.sets([
                            ExSet.empty(
                              kind: SetKind.normal,
                              parameters: ex.parameters,
                            ),
                          ]);
                        })
                        .toList()
                        .wrap());
                  });
                });
              },
            ),
            ListTile(
              title: Text("routines.editor.superset.add".t),
              leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
              onTap: () {
                Go.to<List<Exercise>>(() => const ExercisePicker(
                      singlePick: false,
                    )).then((result) {
                  result ??= [];
                  setState(() {
                    // controller.exercises.addAll(result!.wrap());
                    controller.exercises.add(_DateWrapped(
                      Superset(
                        restTime: Duration.zero,
                        exercises: [for (final ex in result!) ex.makeChild()],
                      ),
                    ));
                  });
                });
              },
            ),
            Obx(
              () => ReorderableListView(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < controller.exercises.length; i++) ...[
                    exerciseEntry(i),
                  ],
                ],
                onReorder: (oldIndex, newIndex) {
                  _reorder(controller.exercises, oldIndex, newIndex);
                  controller.exercises.refresh();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exerciseEntry(int i) {
    if (controller.exercises[i].data is Exercise) {
      return WorkoutExerciseEditor(
        key: ValueKey(
            "${(controller.exercises[i].data as Exercise).name}${controller.exercises[i].date}"),
        exercise: (controller.exercises[i].data as Exercise),
        index: i,
        isCreating: true,
        weightUnit:
            Get.find<SettingsController>().weightUnit.value ?? Weights.kg,
        onReorder: () {},
        onReplace: () {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            controller.exercises[i].data = ex.first.makeChild().copyWith.sets([
              ExSet.empty(
                kind: SetKind.normal,
                parameters: ex.first.parameters,
              ),
            ]);
            controller.exercises.refresh();
          });
        },
        onRemove: () {
          controller.exercises.removeAt(i);
          controller.exercises.refresh();
        },
        onChangeRestTime: (value) {
          (controller.exercises[i].data as Exercise).restTime = value;
          controller.exercises.refresh();
        },
        onSetCreate: () {
          final ex = controller.exercises[i];
          controller.exercises[i].data.sets.add(
            ExSet.empty(
              kind: SetKind.normal,
              parameters: (ex.data as Exercise).parameters,
            ),
          );
          controller.exercises.refresh();
        },
        onSetRemove: (int index) {
          setState(() {
            controller.exercises[i].data.sets.removeAt(index);
            controller.exercises.refresh();
          });
        },
        onSetSelectKind: (set, kind) {
          set.kind = kind;
          controller.exercises.refresh();
        },
        onSetSetDone: (ex, set, done) {},
        onSetValueChange: () {},
        onNotesChange: (ex, notes) {
          ex.notes = notes;
          controller.exercises.refresh();
        },
      );
    } else {
      return SupersetEditor(
        key: ValueKey(
            "superset-${(controller.exercises[i].data as Superset).id}${controller.exercises[i].date}"),
        superset: controller.exercises[i].data as Superset,
        index: i,
        isCreating: true,
        weightUnit:
            Get.find<SettingsController>().weightUnit.value ?? Weights.kg,
        onSupersetReorder: () {},
        onSupersetReplace: () {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            controller.exercises[i].data = ex.first.makeChild().copyWith.sets([
              ExSet.empty(
                kind: SetKind.normal,
                parameters: ex.first.parameters,
              ),
            ]);
            controller.exercises.refresh();
          });
        },
        onSupersetRemove: () {
          controller.exercises.removeAt(i);
          controller.exercises.refresh();
        },
        onSupersetChangeRestTime: (value) {
          (controller.exercises[i].data as Superset).restTime = value;
          controller.exercises.refresh();
        },
        onNotesChange: (superset, notes) {
          superset.notes = notes;
          controller.exercises.refresh();
        },
        onExerciseRemove: (int index) {
          setState(() {
            (controller.exercises[i].data as Superset)
                .exercises
                .removeAt(index);
            controller.exercises.refresh();
          });
        },
        onExerciseAdd: () async {
          final exercises = await Go.to<List<Exercise>>(
              () => const ExercisePicker(singlePick: false));
          if (exercises == null) return;
          (controller.exercises[i].data as Superset).exercises.addAll(
                exercises.map(
                  (ex) => ex.makeChild().copyWith.sets([
                    ExSet.empty(
                      kind: SetKind.normal,
                      parameters: ex.parameters,
                    ),
                  ]),
                ),
              );
          controller.exercises.refresh();
        },
        onExerciseReorder: (_) {},
        onExerciseReorderIndexed: (a, b) {
          _reorder(
            (controller.exercises[i].data as Superset).exercises,
            a,
            b,
          );
          controller.exercises.refresh();
        },
        onExerciseReplace: (j) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            (controller.exercises[i].data as Superset).exercises[j] =
                ex.first.copyWith.sets([
              ExSet.empty(
                kind: SetKind.normal,
                parameters: ex.first.parameters,
              ),
            ]);
            controller.exercises.refresh();
          });
        },
        onExerciseChangeRestTime: (int index, Duration value) {
          (controller.exercises[i].data as Superset).exercises[index].restTime =
              value;
          controller.exercises.refresh();
        },
        onExerciseSetCreate: (int index) {
          final ex =
              (controller.exercises[i].data as Superset).exercises[index];
          (controller.exercises[i].data as Superset).exercises[index].sets.add(
                ExSet.empty(
                  kind: SetKind.normal,
                  parameters: ex.parameters,
                ),
              );
          controller.exercises.refresh();
        },
        onExerciseSetRemove: (int index, int setIndex) {
          setState(() {
            (controller.exercises[i].data as Superset)
                .exercises[index]
                .sets
                .removeAt(setIndex);
            controller.exercises.refresh();
          });
        },
        onExerciseSetSelectKind: (int index, set, kind) {
          set.kind = kind;
          controller.exercises.refresh();
        },
        onExerciseSetSetDone: (ex, set, done) {},
        onExerciseSetValueChange: () {},
        onExerciseNotesChange: (ex, notes) {
          ex.notes = notes;
          controller.exercises.refresh();
        },
      );
    }
  }

  void _reorder<T>(List<T> list, int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) newIndex -= 1;
        list.insert(newIndex, list.removeAt(oldIndex));
      },
    );
  }

  void _submit() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      if (widget.base == null) {
        workoutsController.submitRoutine(
          name: titleController.text,
          exercises: controller.exercises.unwrap(),
          infobox: infoboxController.document.toPlainText().trim().isEmpty
              ? null
              : infoboxController.toEncoded(),
        );
      } else {
        Get.back(
          result: workoutsController.generate(
            name: titleController.text,
            exercises: controller.exercises.unwrap(),
            id: widget.base!.id,
            infobox: infoboxController.document.toPlainText().trim().isEmpty
                ? null
                : infoboxController.toEncoded(),
          ),
        );
      }
    }
  }
}

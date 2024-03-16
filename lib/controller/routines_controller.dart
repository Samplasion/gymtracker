import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' as utils;
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:protocol_handler/protocol_handler.dart';

class RoutinesController extends GetxController
    with ServiceableController, ProtocolListener {
  RxList<Workout> workouts = <Workout>[].obs;
  RxBool hasOngoingWorkout = false.obs;

  @override
  onInit() {
    super.onInit();
    protocolHandler.addListener(this);

    Get.put(HistoryController());

    if (service.hasOngoing) {
      Get.put(WorkoutController.fromSavedData(service.getOngoingData()!));
    }
  }

  @override
  onClose() {
    protocolHandler.removeListener(this);
    super.onClose();
  }

  @override
  onServiceChange() {
    workouts(service.routines);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    printInfo(info: "Change lifecycle state callback received (state: $state)");
    if (hasOngoingWorkout()) {
      switch (state) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
        case AppLifecycleState.resumed:
          Get.find<WorkoutController>().save();
          break;
        default:
          break;
      }
    }
  }

  void submitRoutine({
    required String name,
    required List<WorkoutExercisable> exercises,
    required String? infobox,
  }) {
    final routine = Workout(
      name: name,
      exercises: exercises,
      infobox: infobox,
      weightUnit: settingsController.weightUnit.value!,
    );
    service.setRoutine(routine);

    Get.back();
  }

  Future<void> startRoutine(
    BuildContext context,
    Workout workout, {
    bool isEmpty = false,
  }) async {
    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;
    }

    removeCountdown();

    String? workoutID = workout.isConcrete ? workout.parentID : workout.id;
    if (isEmpty) {
      workoutID = null;
    }

    Get.put(WorkoutController("workouts.untitled".t, workoutID, null));
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.to(() => const WorkoutView());
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: workoutID,
        exerciseFilter: (ex) => true,
      );
    });
  }

  bool isWorkoutContinuable(Workout workout) {
    return workout.isContinuable;
  }

  Future<void> continueWorkout(
    BuildContext context,
    Workout workout,
  ) async {
    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;
    }

    removeCountdown();

    String? parentID = workout.parentID;

    Get.put(WorkoutController(workout.name, parentID, workout.infobox));
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.to(() => const WorkoutView());
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: parentID,
        exerciseFilter: (ex) => ex.sets.any((set) => !set.done),
        setFilter: (set) => !set.done,
        continuation: true,
      );
    });
  }

  _clone(
    Workout workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool Function(ExSet set)? setFilter,
    bool continuation = false,
  }) {
    final clone = workout.clone();
    Get.find<WorkoutController>()
      ..name(clone.name)
      ..exercises([
        for (final ex in clone.exercises)
          if (exerciseFilter(ex))
            if (ex is Exercise)
              ex.instantiate(
                workout: workout,
                setFilter: setFilter,
              )
            else if (ex is Superset)
              ex.copyWith(
                exercises: ex.exercises
                    .map((e) => e.instantiate(
                          workout: workout,
                          setFilter: setFilter,
                        ))
                    .toList(),
              ),
      ])
      ..time(DateTime.now())
      ..parentID(parentID)
      ..infobox(workout.infobox)
      ..isContinuation(continuation)
      ..continuesID(continuation ? workout.id : null)
      ..weightUnit(clone.weightUnit)
      ..save();
  }

  void deleteWorkout(Workout workout) {
    service.removeRoutine(workout);
    Get.find<HistoryController>().unbindAllFromParent(workout.id);
  }

  generate({
    required String name,
    required List<WorkoutExercisable> exercises,
    required String id,
    required String? infobox,
  }) {
    return Workout(
        name: name,
        exercises: exercises,
        id: id,
        infobox: infobox,
        weightUnit: settingsController.weightUnit.value!);
  }

  void editRoutine(Workout newRoutine) {
    if (service.hasRoutine(newRoutine.id)) {
      service.setRoutine(newRoutine);
    }
  }

  void removeCountdown() {
    Get.find<CountdownController>().removeCountdown();
  }

  void reorder(int oldIndex, int newIndex) {
    final list = service.routines;
    utils.reorder(list, oldIndex, newIndex);
    service.setAllRoutines(list);
  }

  List<Workout> getChildren(Workout routine) {
    final historyCont = Get.find<HistoryController>();
    return [
      for (final workout in historyCont.history)
        if (workout.parentID == routine.id) workout
    ];
  }

  String importWorkout(Workout workout) {
    final routine = workout.toRoutine();
    service.setRoutine(routine);
    return routine.id;
  }

  void deleteRoutineWithDialog(
    BuildContext context, {
    required Workout workout,
    required void Function() onCanceled,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          title: Text("routines.actions.delete.title".t),
          content: Text(
            "routines.actions.delete.text".t,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(closeOverlays: true);
              },
              child: Text("routines.actions.delete.actions.no".t),
            ),
            FilledButton.tonal(
              onPressed: () {
                deleteWorkout(workout);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Get.back(closeOverlays: true);
                });

                onCanceled();
              },
              child: Text("routines.actions.delete.actions.yes".t),
            ),
          ],
        );
      },
    );
  }

  bool hasRoutine(String s) {
    return service.hasRoutine(s);
  }

  Workout? getRoutine(String s) {
    return service.routines.firstWhereOrNull((r) => r.id == s);
  }

  void updateRoutineFromWorkout(String s, Workout workout) {
    final oldRoutine = getRoutine(s);
    if (oldRoutine == null) return;
    final newRoutine = workout.toRoutine().copyWith(
          name: oldRoutine.name,
          id: oldRoutine.id,
          parentID: null,
          completedBy: null,
          completes: null,
        );
    service.setRoutine(newRoutine);
  }

  @override
  onProtocolUrlReceived(String url) {
    final Uri parsed = Uri.parse(url);
    debugPrint('Url received: $parsed');

    switch (parsed.host) {
      case "routine":
        return onRoutineUrlReceived(parsed);
      default:
        return onUnknownUrlReceived(parsed);
    }
  }

  void onRoutineUrlReceived(Uri parsed) {
    if (!parsed.queryParameters.containsKey("json")) {
      Go.dialog(
        "importRoutine.errors.noJson.title".t,
        "importRoutine.errors.noJson.body".t,
      );
      return;
    }

    late dynamic json;
    try {
      json = jsonDecode("${parsed.queryParameters['json']}".uncompressed);
    } catch (e) {
      printError(info: "$e");
      Go.dialog(
        "importRoutine.errors.badJson.title".t,
        "importRoutine.errors.badJson.body".t,
      );
      return;
    }

    late Workout workout;
    try {
      workout = Workout.fromJson(json);
    } catch (e) {
      printError(info: "$e");
      Go.dialog(
        "importRoutine.errors.badWorkout.title".t,
        "importRoutine.errors.badWorkout.body".t,
      );
      return;
    }

    Go.showBottomModalScreen(
      (context, _) => ImportRoutineModal(workout: workout),
    );
  }

  void onUnknownUrlReceived(Uri parsed) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text("unknownUrl.title".t),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "unknownUrl.text".t),
              const TextSpan(text: "\n\n"),
              TextSpan(
                text: parsed.toString(),
                style: const TextStyle(
                  fontFamily: "monospace",
                  fontFamilyFallback: <String>["Menlo", "Courier"],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  void shareRoutine(Uri uri) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text("workouts.actions.share.alert.title".t),
        scrollable: true,
        content: RichText(
          text: TextSpan(
            children: [
              // TODO: QR code.
              TextSpan(text: "workouts.actions.share.alert.body".t),
              const TextSpan(text: "\n\n"),
              TextSpan(
                text: uri.toString(),
                style: const TextStyle(
                  fontFamily: "monospace",
                  fontFamilyFallback: <String>["Menlo", "Courier"],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Clipboard.setData(ClipboardData(text: uri.toString()));
              Go.snack("workouts.actions.share.alert.actions.shared".t);
            },
            child: Text("workouts.actions.share.alert.actions.share".t),
          ),
        ],
      ),
    );
  }
}

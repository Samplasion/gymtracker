import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/share.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' as utils;
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

typedef RoutineSuggestion = ({
  Workout routine,
  int occurrences,
});

class RoutinesController extends GetxController
    with ServiceableController, ProtocolListener {
  RxList<Workout> workouts = <Workout>[].obs;
  RxBool hasOngoingWorkout = false.obs;
  RxMap<GTRoutineFolder, List<Workout>> folders =
      <GTRoutineFolder, List<Workout>>{}.obs;

  RxList<RoutineSuggestion> get suggestions => coordinator.suggestions;

  List<Workout> get rootRoutines =>
      workouts.where((r) => r.folder == null).toList();

  bool _init = false;
  @override
  onInit() {
    super.onInit();
    protocolHandler.addListener(this);

    service.routines$.listen((event) {
      logger.i("Updated with ${event.length} routines");
      workouts(event);
      coordinator.computeSuggestions();
      _recomputeFolders(service.folders$.valueOrNull ?? []);

      if (_init) {
        Get.find<Coordinator>()
            .maybeUnlockAchievements(AchievementTrigger.routines);
      }

      _init = true;
    });
    service.folders$.listen((fld) {
      _recomputeFolders(fld);
    });
  }

  @override
  onClose() {
    protocolHandler.removeListener(this);
    super.onClose();
  }

  @override
  onServiceChange() {}

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // logger.t("Change lifecycle state callback received (state: ${state.name})");
    if (hasOngoingWorkout()) {
      switch (state) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
        case AppLifecycleState.resumed:
          if (Get.isRegistered<WorkoutController>()) {
            Get.find<WorkoutController>().save();
          }
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
      weightUnit: settingsController.weightUnit.value,
    );
    service.setRoutine(routine);
    coordinator.scheduleBackup();

    Get.back();
  }

  Future<void> startRoutine(BuildContext context, [Workout? workout]) async {
    final isEmpty = workout == null;

    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;

      Get.delete<WorkoutController>();
    }

    removeCountdown();

    String? workoutID;
    if (!isEmpty) {
      workoutID = workout.isConcrete ? workout.parentID : workout.id;
    }

    // We aren't naming the workout here because the _clone()
    // method will take care of that.
    // Specifically, if [workout] is null, it will autogenerate a title
    // once the user goes to finish the workout.
    Get.put(WorkoutController("", workoutID, null));

    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.toNamed(WorkoutView.routeName);
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: workoutID,
        exerciseFilter: (ex) => true,
        shouldKeepRPEs: workout?.isConcrete ?? false,
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
    Go.toNamed(WorkoutView.routeName);
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: parentID,
        exerciseFilter: (ex) => ex.sets.any((set) => !set.done),
        // setFilter: (set) => !set.done,
        continuation: true,
        shouldKeepRPEs: true,
      );
    });
  }

  _clone(
    Workout? workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool continuation = false,
    required bool shouldKeepRPEs,
  }) {
    if (workout != null) {
      final clone = workout.withRegeneratedExerciseIDs(superseding: true);
      Get.find<WorkoutController>().applyExistingWorkout(
        clone,
        parentID: parentID,
        exerciseFilter: exerciseFilter,
        continuation: continuation,
        shouldKeepRPEs: shouldKeepRPEs,
      );
    }
  }

  void deleteWorkout(Workout workout) {
    service.removeRoutine(workout);
    coordinator.scheduleBackup();
    Get.find<HistoryController>().unbindAllFromParent(workout.id);
  }

  generate({
    required String name,
    required List<WorkoutExercisable> exercises,
    required String id,
    required String? infobox,
    GTRoutineFolder? folder,
  }) {
    return Workout(
      name: name,
      exercises: exercises,
      id: id,
      infobox: infobox,
      weightUnit: settingsController.weightUnit.value,
      folder: folder,
    );
  }

  void editRoutine(Workout newRoutine) {
    if (service.hasRoutine(newRoutine.id)) {
      service.setRoutine(newRoutine);
      coordinator.scheduleBackup();
    }
  }

  void removeCountdown() {
    Get.find<CountdownController>().removeCountdown();
  }

  void reorderRoot(int oldIndex, int newIndex) {
    final list = rootRoutines;
    utils.reorder(list, oldIndex, newIndex);

    final old = service.routines.toList();
    old.removeWhere((r) => r.folder == null);
    service.setAllRoutines([...list, ...old]);
    coordinator.scheduleBackup();

    // Optimistically reorder the list
    workouts([...list, ...old]);
  }

  void reorderFolder(GTRoutineFolder folder, int oldIndex, int newIndex) {
    final list = folders[folder]!;
    utils.reorder(list, oldIndex, newIndex);

    final old = service.routines.toList();
    old.removeWhere((r) => r.folder?.id == folder.id);
    service.setAllRoutines([...list, ...old]);
    coordinator.scheduleBackup();

    // Optimistically reorder the list
    workouts([...list, ...old]);
  }

  List<Workout> getChildren(
    Workout routine, {
    bool allowSynthesized = false,
  }) {
    final historyCont = Get.find<HistoryController>();
    return [
      for (final workout in historyCont.history)
        if (workout.parentID == routine.id && !workout.isContinuation)
          if (allowSynthesized)
            workout.synthesizeContinuations(
              previous: false,
              next: true,
            )
          else
            workout,
    ];
  }

  String importWorkout(Workout workout) {
    final routine = workout.toRoutine();
    logger.d((routine, routine.exercises));
    service.setRoutine(routine);
    coordinator.scheduleBackup();
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
          icon: const Icon(GTIcons.info),
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
    final newRoutine = workout
        .copyWith(
          name: oldRoutine.name,
          parentID: null,
          completedBy: null,
          completes: null,
        )
        .toRoutine(routineID: oldRoutine.id)
        // Why the second copyWith call?
        // That's because a concrete workout can't be in a folder,
        // and at the time of the first copyWith call, this object
        // is still a concrete workout.
        .copyWith
        .folder(oldRoutine.folder);
    service.setRoutine(newRoutine);
    coordinator.scheduleBackup();
  }

  @override
  onProtocolUrlReceived(String url) {
    final Uri parsed = Uri.parse(url);
    logger.i('Url received: $parsed');

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
    } catch (e, s) {
      logger.e("$e", error: e, stackTrace: s);
      Go.dialog(
        "importRoutine.errors.badJson.title".t,
        "importRoutine.errors.badJson.body".t,
      );
      return;
    }

    late Workout workout;
    try {
      workout = Workout.fromJson(json);
    } catch (e, s) {
      logger.e("$e", error: e, stackTrace: s);
      Go.dialog(
        "importRoutine.errors.badWorkout.title".t,
        "importRoutine.errors.badWorkout.body".t,
      );
      return;
    }

    // Scheduling this allows us to show the modal if the app was
    // invoked from a cold start.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.showBottomModalScreen(
        (context, _) => ImportRoutineModal(workout: workout),
      );
    });
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

  void shareRoutine(Workout routine) {
    final uri = Uri(
      scheme: "gymtracker",
      host: "routine",
      queryParameters: {
        "json": jsonEncode(routine.shareWorkout()).compressed,
      },
    );
    showDialog(
      context: Get.context!,
      builder: (context) => ShareRoutineAlertDialog(uri: uri),
    );
  }

  bool hasExercise(Exercise exercise) {
    return workouts.any(
      (routine) => routine.exercises.any((element) {
        return element.map(
            exercise: (ex) => exercise.isParentOf(ex),
            superset: (ss) =>
                ss.exercises.any((element) => exercise.isParentOf(element)));
      }),
    );
  }

  Future<void> applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);

    return service.applyExerciseModificationToRoutines(exercise);
  }

  void viewHistory({required Workout routine}) {
    final history = coordinator.getRoutineHistory(routine: routine);
    Go.to(
      () => Scaffold(
        appBar: AppBar(title: Text("routines.actions.viewHistory".t)),
        body: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8) +
                MediaQuery.of(Get.context!).padding.copyWith(top: 0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final workout = history[index];
              return HistoryWorkout(
                workout: workout,
                showExercises: workout.exercises.length,
                onTap: () {
                  Go.to(() => ExercisesView(workout: workout));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void createFolder() {
    final folder = GTRoutineFolder.generate(
      name: "routines.newFolder".t,
    );
    service.addFolder(folder);
    coordinator.scheduleBackup();
  }

  void moveToFolder(Workout data, GTRoutineFolder folder) {
    final routine = data.copyWith(folder: folder);
    service.setRoutine(routine);
    coordinator.scheduleBackup();
  }

  void moveToRoot(Workout data) {
    if (data.folder == null) return;

    final routine = data.copyWith(folder: null);
    service.setRoutine(routine);
    coordinator.scheduleBackup();
  }

  void _recomputeFolders(List<GTRoutineFolder> fld) {
    final res = <String, List<Workout>>{};
    for (final folder in fld) {
      res[folder.id] =
          service.routines.where((r) => r.folder?.id == folder.id).toList();
    }
    folders({
      for (final folder in fld) folder: res[folder.id] ?? [],
    });
  }

  Future<void> editFolderScreen(GTRoutineFolder folder) async {
    final newFolder = await Go.showBottomModalScreen(
      (context, _) => EditFolderModal(folder: folder),
    );
    if (newFolder != null) {
      service.updateFolder(newFolder);
      coordinator.scheduleBackup();
    }
  }

  Future<void> deleteFolder(GTRoutineFolder folder) async {
    final shouldDelete = await Go.confirm(
      "routines.actions.deleteFolder.title".t,
      "routines.actions.deleteFolder.text".t,
    );
    if (!shouldDelete) return;
    Get.back();
    service.removeFolder(folder);
    coordinator.scheduleBackup();
  }

  Future<Workout?> pickRoutine({
    required ValueChanged<Workout?> onPick,
    required bool allowNone,
  }) async {
    await Go.showBottomModalScreen(
      (context, _) => RoutinePicker(onPick: onPick, allowNone: allowNone),
    );
  }

  void replaceExercise(Exercise from, Exercise to) {
    service.setAllRoutines([
      for (final routine in service.routines)
        routine.copyWith(
          exercises: [
            for (final ex in routine.exercises)
              ex.map(
                exercise: (ex) {
                  if (from.isTheSameAs(ex)) {
                    return Exercise.replaced(
                      from: ex,
                      to: to.makeChild(),
                    );
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (from.isTheSameAs(ex))
                        Exercise.replaced(
                          from: ex,
                          to: to.makeChild(),
                        )
                      else
                        ex,
                  ],
                ),
              ),
          ],
        ),
    ]);
    coordinator.scheduleBackup();
  }

  void removeWeightFromExercise(Exercise exercise) {
    service.setAllRoutines([
      for (final routine in service.routines)
        routine.copyWith(
          exercises: [
            for (final ex in routine.exercises)
              ex.map(
                exercise: (ex) {
                  if (exercise.isTheSameAs(ex)) {
                    return ex.copyWith(
                      parameters: GTSetParameters.freeBodyReps,
                      sets: [
                        for (final set in ex.sets)
                          set.copyWith(
                            parameters: GTSetParameters.freeBodyReps,
                          ),
                      ],
                    );
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (exercise.isTheSameAs(ex))
                        ex.copyWith(
                          parameters: GTSetParameters.freeBodyReps,
                          sets: [
                            for (final set in ex.sets)
                              set.copyWith(
                                parameters: GTSetParameters.freeBodyReps,
                              ),
                          ],
                        )
                      else
                        ex,
                  ],
                ),
              ),
          ],
        ),
    ]);
    coordinator.scheduleBackup();
  }

  void installRoutines(List<Workout> routines) {
    for (final routine in routines) {
      service.setRoutine(routine);
    }
    coordinator.scheduleBackup();
  }

  void applyWeightMultiplier(Exercise exercise, double multiplier) {
    service.setAllRoutines([
      for (final routine in service.routines)
        routine.copyWith(
          exercises: [
            for (final ex in routine.exercises)
              ex.map(
                exercise: (ex) {
                  if (exercise.isTheSameAs(ex)) {
                    return ex.copyWith(
                      sets: [
                        for (final set in ex.sets)
                          set.copyWith(
                            weight: set.weight! * multiplier,
                          ),
                      ],
                    );
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (exercise.isTheSameAs(ex))
                        ex.copyWith(
                          sets: [
                            for (final set in ex.sets)
                              set.copyWith(
                                weight: set.weight! * multiplier,
                              ),
                          ],
                        )
                      else
                        ex,
                  ],
                ),
              ),
          ],
        ),
    ]);
    coordinator.scheduleBackup();
  }
}

class ShareRoutineAlertDialog extends StatefulWidget {
  final Uri uri;

  const ShareRoutineAlertDialog({required this.uri, super.key});

  @override
  State<ShareRoutineAlertDialog> createState() =>
      _ShareRoutineAlertDialogState();
}

class _ShareRoutineAlertDialogState extends State<ShareRoutineAlertDialog> {
  ScreenshotController screenshotController = ScreenshotController();

  bool get showQr => widget.uri.toString().length <= 2953;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("workouts.actions.share.alert.title".t),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("workouts.actions.share.alert.body".t),
          const SizedBox(height: 16),
          if (showQr)
            SizedBox(
              width: 480.0,
              height: 480.0,
              child: QrImageView(
                data: widget.uri.toString(),
                version: QrVersions.auto,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: context.theme.colorScheme.onSurface,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: context.theme.colorScheme.onSurface,
                ),
                padding: const EdgeInsets.all(16),
              ),
            )
          else
            Text("workouts.actions.share.alert.noQr".t),
          const SizedBox(height: 16),
          Text(
            widget.uri.toString(),
            style: TextStyle(
              fontFamily: "monospace",
              fontFamilyFallback: const <String>["Menlo", "Courier"],
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("workouts.actions.share.alert.actions.close".t),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            Clipboard.setData(ClipboardData(text: widget.uri.toString()));
            Go.snack("workouts.actions.share.alert.actions.shared".t);
          },
          child: Text("workouts.actions.share.alert.actions.share".t),
        ),
        if (showQr)
          FilledButton.tonal(
            onPressed: () {
              shareImage();
            },
            child: Text("workouts.actions.share.alert.actions.shareQR".t),
          ),
      ],
    );
  }

  Future<void> shareImage() async {
    const imageSize = 512.0;
    final capturedImage = await screenshotController.captureFromWidget(
      SizedBox(
        width: imageSize,
        height: imageSize,
        child: QrImageView(
          data: widget.uri.toString(),
          version: QrVersions.auto,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
          padding: const EdgeInsets.all(4),
        ),
      ),
      targetSize: const Size(imageSize, imageSize),
    );

    ShareService().shareImage(capturedImage);
  }
}

import 'package:gymtracker/db/database.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/intents_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/share.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/trainer.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/utils/workout_navigation.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

final routinesPresentationProvider = Provider<void>((ref) {
  final controller = ref.watch(routinesControllerProvider);
  final links = ref.watch(protocolServiceProvider);
  final listener = _RoutineLinkListener(controller);
  links.addListener(listener);
  ref.onDispose(() => links.removeListener(listener));
});

class _RoutineLinkListener with ProtocolListener {
  _RoutineLinkListener(this.controller);
  final RoutinesController controller;
  @override
  void onProtocolUrlReceived(String url) =>
      controller.onProtocolUrlReceived(url);
}

extension RoutinesPresentation on RoutinesController {
  Future<void> startRoutine(BuildContext context, [Workout? workout]) async {
    final isEmpty = workout == null;

    if (hasOngoingWorkout) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!ref.mounted || !context.mounted || !(result ?? false)) return;

      ref.read(workoutControllerProvider.notifier).cancel();
    }

    removeCountdown();

    String? workoutID;
    if (!isEmpty) {
      workoutID = workout.isConcrete ? workout.parentID : workout.id;

      IntentsController.donateRoutineStarted(
        routineId: workout.id,
        routineDisplayName: workout.name,
      );
    }

    // We aren't naming the workout here because the _clone()
    // method will take care of that.
    // Specifically, if [workout] is null, it will autogenerate a title
    // once the user goes to finish the workout.
    ref.read(workoutControllerProvider.notifier).start("", workoutID, null);

    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Go.back();
    }
    Go.toNamed(
      getPreferredWorkoutRouteName(
        simple: ref
            .read(settingsControllerInstanceProvider)
            .defaultToSimpleWorkoutView,
      ),
    );
    final generation = ref
        .read(workoutControllerProvider.notifier)
        .sessionGeneration;
    final owner = ref.read(workoutControllerProvider)?.ownerId;
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (!ref.mounted) return;
      final current = ref.read(workoutControllerProvider.notifier);
      if (!current.isActive ||
          current.sessionGeneration != generation ||
          ref.read(workoutControllerProvider)?.ownerId != owner) {
        return;
      }
      _clone(
        workout,
        parentID: workoutID,
        exerciseFilter: (ex) => true,
        shouldKeepRPEs: workout?.isConcrete ?? false,
      );
    });
  }

  Future<void> continueWorkout(BuildContext context, Workout workout) async {
    if (hasOngoingWorkout) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!ref.mounted || !context.mounted || !(result ?? false)) return;
    }

    removeCountdown();

    String? parentID = workout.parentID;

    ref
        .read(workoutControllerProvider.notifier)
        .start(workout.name, parentID, workout.infobox);
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Go.back();
    }
    Go.toNamed(
      getPreferredWorkoutRouteName(
        simple: ref
            .read(settingsControllerInstanceProvider)
            .defaultToSimpleWorkoutView,
      ),
    );
    final generation = ref
        .read(workoutControllerProvider.notifier)
        .sessionGeneration;
    final owner = ref.read(workoutControllerProvider)?.ownerId;
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      if (!ref.mounted) return;
      final current = ref.read(workoutControllerProvider.notifier);
      if (!current.isActive ||
          current.sessionGeneration != generation ||
          ref.read(workoutControllerProvider)?.ownerId != owner) {
        return;
      }
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

  void _clone(
    Workout? workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool continuation = false,
    required bool shouldKeepRPEs,
  }) {
    if (workout != null) {
      final clone = workout.withRegeneratedExerciseIDs(superseding: true);
      ref
          .read(workoutControllerProvider.notifier)
          .applyExistingWorkout(
            clone,
            parentID: parentID,
            exerciseFilter: exerciseFilter,
            continuation: continuation,
            shouldKeepRPEs: shouldKeepRPEs,
          );
    }
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
          title: Text(context.t.routines.actions.delete.title),
          content: Text(context.t.routines.actions.delete.text),
          actions: [
            TextButton(
              onPressed: () {
                Go.back(closeOverlays: true);
              },
              child: Text(context.t.routines.actions.delete.actions.no),
            ),
            FilledButton.tonal(
              onPressed: () {
                deleteWorkout(workout);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.back(closeOverlays: true);
                });

                onCanceled();
              },
              child: Text(context.t.routines.actions.delete.actions.yes),
            ),
          ],
        );
      },
    );
  }

  void onProtocolUrlReceived(String url) {
    final Uri parsed = Uri.parse(url);
    logger.i('URL received: ${parsed.scheme}://${parsed.host}');

    switch (parsed.host) {
      case "trainer":
        Go.to(() => TrainerView(token: parsed.queryParameters["token"]));
        return;
      case "routine":
        return onRoutineUrlReceived(parsed);
      default:
        return onUnknownUrlReceived(parsed);
    }
  }

  void onRoutineUrlReceived(Uri parsed) {
    final t = ref.read(translationsProvider);
    if (!parsed.queryParameters.containsKey("json")) {
      Go.dialog(
        t.importRoutine.errors.noJson.title,
        t.importRoutine.errors.noJson.body,
      );
      return;
    }

    late dynamic json;
    try {
      json = jsonDecode("${parsed.queryParameters['json']}".uncompressed);
    } catch (e, s) {
      logger.e("$e", error: e, stackTrace: s);
      Go.dialog(
        t.importRoutine.errors.badJson.title,
        t.importRoutine.errors.badJson.body,
      );
      return;
    }

    late Workout workout;
    try {
      workout = Workout.fromJson(json);
    } catch (e, s) {
      logger.e("$e", error: e, stackTrace: s);
      Go.dialog(
        t.importRoutine.errors.badWorkout.title,
        t.importRoutine.errors.badWorkout.body,
      );
      return;
    }

    // Scheduling this allows us to show the modal if the app was
    // invoked from a cold start.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted) return;
      Go.showBottomModalScreen(
        (context, _) => ImportRoutineModal(workout: workout),
      );
    });
  }

  void onUnknownUrlReceived(Uri parsed) {
    final t = ref.read(translationsProvider);
    showDialog(
      context: Go.context!,
      builder: (context) => AlertDialog(
        title: Text(t.unknownUrl.title),
        content: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: t.unknownUrl.text),
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
            onPressed: () => Go.back(),
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
      queryParameters: {"json": jsonEncode(routine.shareWorkout()).compressed},
    );
    showDialog(
      context: Go.context!,
      builder: (context) => ShareRoutineAlertDialog(uri: uri),
    );
  }

  void viewHistory({required Workout routine}) {
    final t = ref.read(translationsProvider);
    final history = ref
        .read(historyControllerProvider)
        .getRoutineHistory(routine);
    Go.to(
      () => Scaffold(
        appBar: AppBar(title: Text(t.routines.actions.viewHistory)),
        body: Scrollbar(
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(vertical: 8) +
                MediaQuery.of(Go.context!).padding.copyWith(top: 0),
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

  Future<void> deleteFolder(GTRoutineFolder folder) async {
    if (service.routines.any(
      (r) =>
          r.folder?.id == folder.id &&
          service.db.cachedTrainerState.controls.contains(r.id),
    ))
      return;
    final t = ref.read(translationsProvider);
    final shouldDelete = await Go.confirm(
      t.routines.actions.deleteFolder.title,
      t.routines.actions.deleteFolder.text,
    );
    if (!ref.mounted || !shouldDelete) return;
    Go.back();
    service.removeFolder(folder);
    scheduleBackup();
  }

  Future<Workout?> pickRoutine({
    required ValueChanged<Workout?> onPick,
    required bool allowNone,
  }) async {
    await Go.showBottomModalScreen(
      (context, _) => RoutinePicker(onPick: onPick, allowNone: allowNone),
    );
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
      title: Text(context.t.workouts.actions.share.alert.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t.workouts.actions.share.alert.body),
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
            Text(context.t.workouts.actions.share.alert.noQr),
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
            Go.back();
          },
          child: Text(context.t.workouts.actions.share.alert.actions.close),
        ),
        TextButton(
          onPressed: () {
            Go.back();
            Clipboard.setData(ClipboardData(text: widget.uri.toString()));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.t.workouts.actions.share.alert.actions.shared,
                ),
              ),
            );
          },
          child: Text(context.t.workouts.actions.share.alert.actions.share),
        ),
        if (showQr)
          FilledButton.tonal(
            onPressed: () {
              shareImage();
            },
            child: Text(context.t.workouts.actions.share.alert.actions.shareQR),
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

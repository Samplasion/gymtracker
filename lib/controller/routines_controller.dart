import 'package:gymtracker/db/database.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/utils/utils.dart' as utils;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routines_controller.g.dart';

typedef RoutineSuggestion = ({Workout routine, double score});

@Riverpod(keepAlive: true)
RoutinesController routinesController(Ref ref) {
  ref.listen(routinesStreamProvider, (_, next) {
    final routines = next.value;
    if (routines != null) {
      ref.read(nativeServiceProvider).updateShadowRoutines({
        for (final r in routines) r.id: r.name,
      });
    }
  });
  ref.listen(foldersStreamProvider, (_, _) {});
  final controller = RoutinesController(ref);
  return controller;
}

class RoutinesController {
  RoutinesController(this.ref);
  final Ref ref;
  DatabaseService get service => ref.read(databaseServiceProvider);
  void scheduleBackup() => ref.read(backupSchedulerProvider).schedule();
  List<Workout> get workouts =>
      ref.read(routinesStreamProvider).value ?? const [];
  bool get hasOngoingWorkout => ref.read(workoutControllerProvider) != null;
  Map<GTRoutineFolder, List<Workout>> get folders => {
    for (final folder
        in ref.read(foldersStreamProvider).value ?? <GTRoutineFolder>[])
      folder: workouts.where((r) => r.folder?.id == folder.id).toList(),
  };
  List<RoutineSuggestion> get suggestions =>
      ref.read(routineSuggestionsProvider);
  List<Workout> get rootRoutines =>
      workouts.where((r) => r.folder == null).toList();
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (hasOngoingWorkout &&
        {
          AppLifecycleState.inactive,
          AppLifecycleState.paused,
          AppLifecycleState.resumed,
        }.contains(state)) {
      ref.read(workoutControllerProvider.notifier).save();
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
      weightUnit: ref.read(settingsControllerInstanceProvider).weightUnit,
    );
    service.setRoutine(routine);
    scheduleBackup();
  }

  /// Starts a new workout from the given [workout] routine.
  /// If [workout] is null, it will start a new empty workout.
  ///
  /// If [IntentsController] is supported, this method will donate the intent
  /// to Siri.

  bool isWorkoutContinuable(Workout workout) {
    return workout.isContinuable;
  }

  void deleteWorkout(Workout workout) {
    if (service.db.cachedTrainerState.controls.contains(workout.id)) return;
    service.removeRoutine(workout);
    scheduleBackup();
    ref.read(historyControllerProvider).unbindAllFromParent(workout.id);
  }

  Workout generate({
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
      weightUnit: ref.read(settingsControllerInstanceProvider).weightUnit,
      folder: folder,
    );
  }

  void editRoutine(Workout newRoutine) {
    if (service.db.cachedTrainerState.controls.contains(newRoutine.id)) return;
    if (service.hasRoutine(newRoutine.id)) {
      service.setRoutine(newRoutine);
      scheduleBackup();
    }
  }

  void removeCountdown() {
    ref.read(countdownControllerProvider.notifier).removeCountdown();
  }

  void reorderRoot(int oldIndex, int newIndex) {
    final list = rootRoutines;
    utils.reorder(list, oldIndex, newIndex);

    final old = service.routines.toList();
    old.removeWhere((r) => r.folder == null);
    service.setAllRoutines([...list, ...old]);
    scheduleBackup();

    // Optimistically reorder the list
  }

  void reorderFolder(GTRoutineFolder folder, int oldIndex, int newIndex) {
    final list = folders[folder]!;
    utils.reorder(list, oldIndex, newIndex);

    final old = service.routines.toList();
    old.removeWhere((r) => r.folder?.id == folder.id);
    service.setAllRoutines([...list, ...old]);
    scheduleBackup();

    // Optimistically reorder the list
  }

  List<Workout> getChildren(Workout routine, {bool allowSynthesized = false}) {
    final historyCont = ref.read(historyControllerProvider);
    return [
      for (final workout in historyCont.history)
        if (workout.parentID == routine.id && !workout.isContinuation)
          if (allowSynthesized)
            workout.synthesizeContinuations(
              history: historyCont.history,
              previous: false,
              next: true,
            )
          else
            workout,
    ];
  }

  String importWorkout(Workout workout) {
    if (service.db.cachedTrainerState.controls.contains(
      workout.isConcrete ? workout.parentID : workout.id,
    ))
      return workout.id;
    final routine = workout.toRoutine();
    logger.d((routine, routine.exercises));
    service.setRoutine(routine);
    scheduleBackup();
    return routine.id;
  }

  bool hasRoutine(String s) {
    return service.hasRoutine(s);
  }

  Workout? getRoutine(String s) {
    return service.routines.firstWhereOrNull((r) => r.id == s);
  }

  Future<void> updateRoutineFromWorkout(String s, Workout workout) async {
    if (await service.db.isTrainerRoutine(s)) return;
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
    final previousById = <String, Exercise>{
      for (final entry in oldRoutine.exercises)
        if (entry is Exercise)
          entry.id: entry
        else if (entry is Superset)
          for (final exercise in entry.exercises) exercise.id: exercise,
    };
    Exercise reconcile(Exercise converted, Exercise performed) {
      final previous = previousById[performed.supersedesID];
      final progression = performed.progression;
      if (previous == null || progression == null) return converted;
      return converted.copyWith(
        progression: progression.forRoutineSets(previous.sets, performed.sets),
      );
    }

    final updated = newRoutine.copyWith(
      exercises: [
        for (var i = 0; i < newRoutine.exercises.length; i++)
          newRoutine.exercises[i].map(
            exercise: (converted) =>
                reconcile(converted, workout.exercises[i] as Exercise),
            superset: (converted) {
              final performed = workout.exercises[i] as Superset;
              return converted.copyWith(
                exercises: [
                  for (var j = 0; j < converted.exercises.length; j++)
                    reconcile(converted.exercises[j], performed.exercises[j]),
                ],
              );
            },
          ),
      ],
    );
    await service.setRoutine(updated);
    scheduleBackup();
  }

  /// Advances only goals belonging to the saved routine and completed workout.
  Future<void> advanceProgressionsFromWorkout(Workout workout) async {
    final routineID = workout.parentID;
    if (await service.db.isTrainerRoutine(routineID)) return;
    if (routineID == null) return;
    final db = service.db;
    final owner = db.currentUserId;
    // The routine stream may still contain the version from before the user
    // saved their workout changes. Advance from the committed version instead.
    final routines = await db.getAllRoutinesFuture();
    if (db.currentUserId != owner) return;
    final routine = routines.firstWhereOrNull((r) => r.id == routineID);
    if (routine == null) return;

    final performed = <Exercise>[
      for (final entry in workout.exercises)
        if (entry is Exercise)
          entry
        else if (entry is Superset)
          ...entry.exercises,
    ];
    final plannedExercises = <Exercise>[
      for (final entry in routine.exercises)
        if (entry is Exercise)
          entry
        else if (entry is Superset)
          ...entry.exercises,
    ];
    var advancedAny = false;
    Exercise advance(Exercise planned) {
      final current = planned.progression;
      if (current == null ||
          planned.parameters == GTSetParameters.repsNegWeight) {
        return planned;
      }
      var actual = performed
          .where(
            (ex) => ex.supersedesID == planned.id && ex.progression != null,
          )
          .firstOrNull;
      // Updating a routine from a workout regenerates exercise IDs. In that
      // case a library exercise can still be matched if it occurs only once.
      if (actual == null &&
          planned.parentID != null &&
          plannedExercises
                  .where((ex) => ex.parentID == planned.parentID)
                  .length ==
              1) {
        final candidates = performed
            .where(
              (ex) => ex.parentID == planned.parentID && ex.progression != null,
            )
            .toList();
        if (candidates.length == 1) actual = candidates.single;
      }
      if (actual == null || !actual.progression!.reached(actual)) {
        return planned;
      }
      // An edited goal must not be overwritten by a workout started earlier.
      if (!actual.progression!.sameAs(current)) {
        return planned;
      }
      final next = current.advance(
        current.setCount,
        hasWeight: planned.parameters.hasWeight,
      );
      if (next.sameAs(current)) return planned;
      advancedAny = true;
      return planned.copyWith(progression: next);
    }

    final updated = routine.copyWith(
      exercises: [
        for (final entry in routine.exercises)
          entry.map(
            exercise: advance,
            superset: (superset) => superset.copyWith(
              exercises: [for (final ex in superset.exercises) advance(ex)],
            ),
          ),
      ],
    );
    if (!advancedAny) return;
    await service.setRoutine(updated);
    scheduleBackup();
  }

  Future<void> setProgressionForOngoingExercise({
    required String? routineID,
    required Exercise exercise,
    required ExerciseProgression? progression,
  }) async {
    if (routineID == null || exercise.supersedesID == null) return;
    if (await service.db.isTrainerRoutine(routineID)) return;
    final routine = getRoutine(routineID);
    if (routine == null) return;
    Exercise update(Exercise planned) => planned.id == exercise.supersedesID
        ? planned.copyWith(progression: progression)
        : planned;
    await service.setRoutine(
      routine.copyWith(
        exercises: [
          for (final entry in routine.exercises)
            entry.map(
              exercise: update,
              superset: (superset) => superset.copyWith(
                exercises: [for (final ex in superset.exercises) update(ex)],
              ),
            ),
        ],
      ),
    );
    scheduleBackup();
  }

  bool hasExercise(Exercise exercise) {
    return workouts.any(
      (routine) => routine.exercises.any((element) {
        return element.map(
          exercise: (ex) => exercise.isParentOf(ex),
          superset: (ss) =>
              ss.exercises.any((element) => exercise.isParentOf(element)),
        );
      }),
    );
  }

  Future<void> applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);

    return service.applyExerciseModificationToRoutines(exercise);
  }

  void createFolder() {
    final t = ref.read(translationsProvider);
    final folder = GTRoutineFolder.generate(name: t.routines.newFolder);
    service.addFolder(folder);
    scheduleBackup();
  }

  void moveToFolder(Workout data, GTRoutineFolder folder) {
    if (service.db.cachedTrainerState.controls.contains(data.id)) return;
    final routine = data.copyWith(folder: folder);
    service.setRoutine(routine);
    scheduleBackup();
  }

  void moveToRoot(Workout data) {
    if (service.db.cachedTrainerState.controls.contains(data.id)) return;
    if (data.folder == null) return;

    final routine = data.copyWith(folder: null);
    service.setRoutine(routine);
    scheduleBackup();
  }

  void replaceExercise(Exercise from, Exercise to) {
    service.setAllRoutines([
      for (final routine in service.routines)
        if (service.db.cachedTrainerState.controls.contains(routine.id))
          routine
        else
          routine.copyWith(
            exercises: [
              for (final ex in routine.exercises)
                ex.map(
                  exercise: (ex) {
                    if (from.isTheSameAs(ex)) {
                      return Exercise.replaced(from: ex, to: to.makeChild());
                    } else {
                      return ex;
                    }
                  },
                  superset: (ss) => ss.copyWith(
                    exercises: [
                      for (final ex in ss.exercises)
                        if (from.isTheSameAs(ex))
                          Exercise.replaced(from: ex, to: to.makeChild())
                        else
                          ex,
                    ],
                  ),
                ),
            ],
          ),
    ]);
    scheduleBackup();
  }

  void removeWeightFromExercise(Exercise exercise) {
    service.setAllRoutines([
      for (final routine in service.routines)
        if (service.db.cachedTrainerState.controls.contains(routine.id))
          routine
        else
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
    scheduleBackup();
  }

  void installRoutines(List<Workout> routines) {
    for (final routine in routines) {
      service.setRoutine(routine);
    }
    scheduleBackup();
  }

  void applyWeightMultiplier(Exercise exercise, double multiplier) {
    service.setAllRoutines([
      for (final routine in service.routines)
        if (service.db.cachedTrainerState.controls.contains(routine.id))
          routine
        else
          routine.copyWith(
            exercises: [
              for (final ex in routine.exercises)
                ex.map(
                  exercise: (ex) {
                    if (exercise.isTheSameAs(ex)) {
                      return ex.copyWith(
                        sets: [
                          for (final set in ex.sets)
                            set.copyWith(weight: set.weight! * multiplier),
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
                                set.copyWith(weight: set.weight! * multiplier),
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
    scheduleBackup();
  }
}

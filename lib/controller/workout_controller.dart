import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// ignore_for_file: use_build_context_synchronously

part 'workout_controller.g.dart';

typedef WorkoutExerciseIndex = ExerciseIndex;
typedef WorkoutSetCursor = ({
  int exerciseIndex,
  int? supersetIndex,
  int setIndex,
});

class WorkoutState {
  WorkoutState({
    required this.workout,
    required this.ownerId,
    this.cursor,
    this.previousCursor,
  });
  final Workout workout;
  final String? ownerId;
  final WorkoutSetCursor? cursor;
  final WorkoutSetCursor? previousCursor;
}

@Riverpod(keepAlive: true)
class WorkoutController extends _$WorkoutController {
  Future<void> _progressionWrite = Future.value();
  Timer? _pendingInputSave;
  AppLifecycleListener? _inputSaveLifecycle;
  String? ownerId;
  int _sessionGeneration = 0;
  int get sessionGeneration => _sessionGeneration;
  bool isSessionActive(int generation) =>
      ref.mounted &&
      state != null &&
      generation == _sessionGeneration &&
      ownerId == service.db.currentUserId;
  bool get isClosed => !ref.mounted || state == null;
  bool get isActive => !isClosed;
  DatabaseService get service => ref.read(databaseServiceProvider);
  List<WorkoutExercisable> exercises = [];
  late String nativeWorkoutId;
  late String name;
  late DateTime time;
  late String? parentID;
  late String? infobox;
  late bool isContinuation;
  late String? continuesID;
  late Weights weightUnit;
  late Distance distanceUnit;
  late WorkoutSetCursor? _setCursor;
  late WorkoutSetCursor? _previousSetCursor;

  @override
  WorkoutState? build() {
    ref.listen(translationsProvider, (_, _) {});
    ref.onDispose(() {
      _pendingInputSave?.cancel();
      _inputSaveLifecycle?.dispose();
    });
    return null;
  }

  void start(
    String name,
    String? parentID,
    String? infobox, {
    bool saveInitial = true,
    String? restoredNativeId,
    DateTime? restoredStart,
  }) {
    _sessionGeneration++;
    _pendingInputSave?.cancel();
    _pendingInputSave = null;
    ownerId = service.db.currentUserId;
    this.name = name;
    this.parentID = parentID;
    this.infobox = infobox;
    nativeWorkoutId = restoredNativeId ?? const Uuid().v4();
    time = restoredStart ?? ref.read(workoutClockProvider).now();
    isContinuation = false;
    continuesID = null;
    _setCursor = null;
    _previousSetCursor = null;
    final settings = ref.read(settingsControllerProvider);
    weightUnit = settings.weightUnit;
    distanceUnit = settings.distanceUnit;
    exercises = [];
    publishExercises();
    _inputSaveLifecycle?.dispose();
    _inputSaveLifecycle = AppLifecycleListener(
      onStateChange: (lifecycle) {
        if (lifecycle != AppLifecycleState.resumed &&
            _pendingInputSave != null) {
          save();
        }
      },
    );
    ref
        .read(nativeServiceProvider)
        .setIsWorkoutRunning(true, workoutId: nativeWorkoutId, start: time);
    if (saveInitial) save();
  }

  void restore(Map<String, dynamic> data) {
    start(
      data['name'],
      data['parentID'],
      data['infobox'],
      saveInitial: false,
      restoredNativeId:
          data['nativeWorkoutId'] as String? ??
          (data['time'] == null
              ? null
              : const Uuid().v5(
                  Namespace.url.value,
                  'gymtracker:ongoing:${service.db.currentUserId ?? 'guest'}:${data['time']}',
                )),
      restoredStart: data['time'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(data['time'] as int),
    );
    exercises = (data['exercises'] as List)
        .map((el) => WorkoutExercisable.fromJson(el))
        .toList();
    time = DateTime.fromMillisecondsSinceEpoch(
      data['time'] ??
          ref.read(workoutClockProvider).now().millisecondsSinceEpoch,
    );
    continuesID = data['continuesID'];
    isContinuation = data['isContinuation'] ?? false;
    weightUnit = Weights.values.firstWhere(
      (v) => v.name == data['weightUnit'],
      orElse: () => Weights.kg,
    );
    distanceUnit = Distance.values.firstWhere(
      (v) => v.name == data['distanceUnit'],
      orElse: () => Distance.km,
    );
    if (data.containsKey("globalStopwatch")) {
      final controller = ref.read(stopwatchControllerProvider.notifier);

      // Separating the two cases this way avoids a couple of nasty bugs:
      //
      // * If the stopwatch is paused, saving the duration allows us to recover
      //   the stopwatch value without it ticking while the app is closed.
      // * If the stopwatch is running, we actually want to tick while the
      //   app is closed, so we save the starting time and the fact that it's
      //   running.
      // TODO: Test these cases.
      if (data['globalStopwatchPaused'] == false) {
        controller.globalStopwatch.stopwatch =
            ref.read(workoutStopwatchFactoryProvider)(
              ref.read(workoutClockProvider).now().millisecondsSinceEpoch -
                  (data['globalStopwatch'] as int),
            );
        controller.globalStopwatch.start();
      } else {
        controller.globalStopwatch.stopwatch = ref.read(
          workoutStopwatchFactoryProvider,
        )(data['globalStopwatchNominalDuration'] as int);
        controller.globalStopwatch.pause();
      }
    }

    publishExercises();
  }

  /// Publish a detached snapshot; editing buffers are never exposed as provider state.
  void publishExercises() {
    if (!ref.mounted) return;
    _syncSetCursorWithWorkout();
    state = WorkoutState(
      workout: synthesizeSnapshot(),
      ownerId: ownerId,
      cursor: _setCursor,
      previousCursor: _previousSetCursor,
    );
    final generation = sessionGeneration;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (isSessionActive(generation)) refreshWatchData();
    });
  }

  Workout synthesizeSnapshot() => Workout(
    name: name,
    exercises: List.unmodifiable(
      exercises.map(
        (e) => e.map(
          exercise: _snapshotExercise,
          superset: (ss) => ss.copyWith(
            exercises: List.unmodifiable(ss.exercises.map(_snapshotExercise)),
          ),
        ),
      ),
    ),
    duration: ref.read(workoutClockProvider).now().difference(time),
    startingDate: time,
    parentID: parentID,
    infobox: infobox,
    weightUnit: weightUnit,
    distanceUnit: distanceUnit,
    completes: continuesID,
  );

  Exercise _snapshotExercise(Exercise exercise) => Exercise.raw(
    id: exercise.id,
    name: exercise.name,
    parameters: exercise.parameters,
    sets: List.unmodifiable(exercise.sets),
    primaryMuscleGroup: exercise.primaryMuscleGroup,
    secondaryMuscleGroups: Set.unmodifiable(exercise.secondaryMuscleGroups),
    restTime: exercise.restTime,
    parentID: exercise.parentID,
    notes: exercise.notes,
    standard: exercise.standard,
    supersetID: exercise.supersetID,
    workoutID: exercise.workoutID,
    supersedesID: exercise.supersedesID,
    rpe: exercise.rpe,
    progression: exercise.progression?.copyWith(
      targetReps: List.unmodifiable(exercise.progression!.targetReps),
    ),
    category: exercise.category,
    skeleton: exercise.skeleton,
    equipment: exercise.gymEquipment,
    muscleHighlight: Map.unmodifiable(exercise.muscleHighlight),
  );

  Future<void> suspend() async {
    if (isClosed) return;
    final generation = sessionGeneration;
    await _progressionWrite;
    if (!isSessionActive(generation)) return;
    // A suspended native recording is discarded. Recovery starts a new recording
    // group so late callbacks/tombstones from the old account cannot affect it.
    await persist(force: true, recoveryNativeId: const Uuid().v4());
    if (isSessionActive(generation)) _clear();
  }

  Future<void> cancel({bool saveHealthWorkout = false}) async {
    if (isClosed) return;
    final owner = ownerId;
    _clear(saveHealthWorkout: saveHealthWorkout);
    await service.db.deleteOngoingForUser(owner);
  }

  void _clear({bool saveHealthWorkout = false}) {
    _sessionGeneration++;
    _pendingInputSave?.cancel();
    _inputSaveLifecycle?.dispose();
    _inputSaveLifecycle = null;
    removeCountdown();
    removeRelevantStopwatches();
    state = null;
    ref
        .read(nativeServiceProvider)
        .setIsWorkoutRunning(
          false,
          workoutId: nativeWorkoutId,
          start: time,
          save: saveHealthWorkout,
        );
  }

  void setName(String value) {
    name = value;
    publishExercises();
  }

  void setTime(DateTime value) {
    time = value;
    publishExercises();
  }

  void setParentID(String? value) {
    parentID = value;
    publishExercises();
  }

  void setInfobox(String? value) {
    infobox = value;
    publishExercises();
  }

  void setIsContinuation(bool value) {
    isContinuation = value;
    publishExercises();
  }

  void setContinuesID(String? value) {
    continuesID = value;
    publishExercises();
  }

  void setWeightUnit(Weights value) {
    weightUnit = value;
    publishExercises();
  }

  void setDistanceUnit(Distance value) {
    distanceUnit = value;
    publishExercises();
  }

  void setCursor(WorkoutSetCursor? value) {
    _setCursor = value;
    publishExercises();
  }

  void setPreviousCursor(WorkoutSetCursor? value) {
    _previousSetCursor = value;
    publishExercises();
  }

  void setExercises(List<WorkoutExercisable> value) {
    exercises = value;
    publishExercises();
  }

  void onExerciseProgressionChange(
    ExerciseIndex index,
    ExerciseProgression? progression,
  ) {
    final oldExercise = index.supersetIndex == null
        ? exercises[index.exerciseIndex] as Exercise
        : (exercises[index.supersetIndex!] as Superset).exercises[index
              .exerciseIndex];
    if (index.supersetIndex == null) {
      final ex = exercises[index.exerciseIndex] as Exercise;
      exercises[index.exerciseIndex] = ex.copyWith(progression: progression);
    } else {
      final superset = exercises[index.supersetIndex!] as Superset;
      exercises[index.supersetIndex!] = superset.copyWith(
        exercises: [
          for (var i = 0; i < superset.exercises.length; i++)
            i == index.exerciseIndex
                ? superset.exercises[i].copyWith(progression: progression)
                : superset.exercises[i],
        ],
      );
    }
    publishExercises();
    save();
    final generation = sessionGeneration;
    final routineID = parentID;
    final routines = ref.read(routinesControllerProvider);
    _progressionWrite = _progressionWrite.then((_) async {
      if (!isSessionActive(generation)) return;
      await routines.setProgressionForOngoingExercise(
        routineID: routineID,
        exercise: oldExercise,
        progression: progression,
      );
    });
  }

  void onExerciseRemove(ExerciseIndex index) {
    final previousCursor = _setCursor;
    _previousSetCursor = previousCursor;
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;
    if (supersetIndex == null) {
      exercises.removeAt(exerciseIndex);
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j != exerciseIndex) superset.exercises[j],
        ],
      );
    }

    _setCursor = _healCursorAfterExerciseDeletion(previousCursor, index);
    publishExercises();
    save();
  }

  void onExerciseChangeRestTime(ExerciseIndex index, Duration value) {
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      final ex = exercises[exerciseIndex];
      // Type safety
      exercises[exerciseIndex] = ex is Exercise
          ? ex.copyWith(restTime: value)
          : ex is Superset
          ? ex.copyWith(restTime: value)
          : throw AssertionError("Unreachable yet");
    } else {
      // We don't support changing rest time for individual exercises in a superset
      throw UnimplementedError();
    }

    publishExercises();
    save();
  }

  void onSetChangeRPE(ExerciseIndex index, int setIndex, double? value) {
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      final ex = exercises[exerciseIndex];
      // Type safety
      exercises[exerciseIndex] = ex is Exercise
          ? ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex)
                    ex.sets[j].copyWith(rpe: value)
                  else
                    ex.sets[j],
              ],
            )
          : ex is Superset
          ? ex.copyWith(
              exercises: [
                for (final e in ex.exercises)
                  e.copyWith(
                    sets: [
                      for (int j = 0; j < e.sets.length; j++)
                        if (j == setIndex)
                          e.sets[j].copyWith(rpe: value)
                        else
                          e.sets[j],
                    ],
                  ),
              ],
            )
          : throw AssertionError("Unreachable yet");
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == exerciseIndex)
              superset.exercises[j].copyWith(
                sets: [
                  for (int k = 0; k < superset.exercises[j].sets.length; k++)
                    if (k == setIndex)
                      superset.exercises[j].sets[k].copyWith(rpe: value)
                    else
                      superset.exercises[j].sets[k],
                ],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    publishExercises();
    save();
  }

  void onExerciseSetReorder(ExerciseIndex index, List<int> newIndices) {
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      final ex = exercises[exerciseIndex];
      // Type safety
      exercises[exerciseIndex] = ex is Exercise
          ? ex.copyWith(
              sets: [
                for (int i = 0; i < newIndices.length; i++)
                  ex.sets[newIndices[i]],
              ],
            )
          : ex is Superset
          ? ex.copyWith(
              exercises: [
                for (final e in ex.exercises)
                  e.copyWith(
                    sets: [
                      for (int i = 0; i < newIndices.length; i++)
                        e.sets[newIndices[i]],
                    ],
                  ),
              ],
            )
          : throw AssertionError("Unreachable yet");
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (final e in superset.exercises)
            e.copyWith(
              sets: [
                for (int i = 0; i < newIndices.length; i++)
                  e.sets[newIndices[i]],
              ],
            ),
        ],
      );
    }

    publishExercises();
    save();
  }

  void onSetCreate(ExerciseIndex index) {
    final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
    final set = GTSet.empty(
      kind: GTSetKind.normal,
      parameters: supersetIndex == null
          ? (exercises[i] as Exercise).parameters
          : (exercises[supersetIndex] as Superset).exercises[i].parameters,
    );

    if (supersetIndex == null) {
      exercises[i].sets.add(set);
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == i)
              superset.exercises[j].copyWith(
                sets: [...superset.exercises[j].sets, set],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    publishExercises();
    save();
  }

  void onSetRemove(ExerciseIndex index, int setIndex) {
    final previousCursor = _setCursor;
    _previousSetCursor = previousCursor;
    final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      exercises[i].sets.removeAt(setIndex);
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == i)
              superset.exercises[j].copyWith(
                sets: [
                  for (int k = 0; k < superset.exercises[j].sets.length; k++)
                    if (k != setIndex) superset.exercises[j].sets[k],
                ],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    _setCursor = _healCursorAfterSetDeletion(previousCursor, index, setIndex);

    publishExercises();
    save();
  }

  void onSetSelectKind(ExerciseIndex index, int setIndex, GTSetKind kind) {
    final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

    final exercise = supersetIndex == null
        ? (exercises[i] as Exercise)
        : (exercises[supersetIndex] as Superset).exercises[i];
    final set = exercise.sets[setIndex];

    final newSet = set.copyWith(kind: kind);

    if (supersetIndex == null) {
      final ex = exercises[i] as Exercise;
      exercises[i] = ex.copyWith(
        sets: [
          for (int j = 0; j < ex.sets.length; j++)
            if (j == setIndex) newSet else ex.sets[j],
        ],
      );
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == i)
              superset.exercises[j].copyWith(
                sets: [
                  for (int k = 0; k < superset.exercises[j].sets.length; k++)
                    if (k == setIndex)
                      newSet
                    else
                      superset.exercises[j].sets[k],
                ],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    publishExercises();
    save();
  }

  void onSetSetDone(ExerciseIndex index, int setIndex, bool done) {
    markSetAsDone(index, setIndex, done);
  }

  void onSetValueChange(ExerciseIndex index, int setIndex, GTSet set) {
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      final ex = exercises[exerciseIndex];
      // Type safety
      exercises[exerciseIndex] = ex is Exercise
          ? ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) set else ex.sets[j],
              ],
            )
          : ex is Superset
          ? ex.copyWith(
              exercises: [
                for (int j = 0; j < ex.exercises.length; j++)
                  if (j == setIndex)
                    ex.exercises[j].copyWith(
                      sets: [
                        for (int k = 0; k < ex.exercises[j].sets.length; k++)
                          if (k == setIndex) set else ex.exercises[j].sets[k],
                      ],
                    )
                  else
                    ex.exercises[j],
              ],
            )
          : throw AssertionError("Unreachable yet");
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == exerciseIndex)
              superset.exercises[j].copyWith(
                sets: [
                  for (int k = 0; k < superset.exercises[j].sets.length; k++)
                    if (k == setIndex) set else superset.exercises[j].sets[k],
                ],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    publishExercises();
    _pendingInputSave?.cancel();
    _pendingInputSave = ref.read(workoutClockProvider).once(
      const Duration(milliseconds: 250),
      () {
        _pendingInputSave = null;
        save();
      },
    );
  }

  void onExerciseNotesChange(ExerciseIndex index, String notes) {
    final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = index;

    if (supersetIndex == null) {
      final ex = exercises[exerciseIndex];
      // Type safety
      exercises[exerciseIndex] = ex is Exercise
          ? ex.copyWith(notes: notes)
          : ex is Superset
          ? ex.copyWith(notes: notes)
          : throw AssertionError("Unreachable yet");
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == exerciseIndex)
              superset.exercises[j].copyWith(notes: notes)
            else
              superset.exercises[j],
        ],
      );
    }

    publishExercises();
    save();
  }

  List<GTSet> get allSets => [for (final ex in exercises) ...ex.sets];
  List<GTSet> get doneSets => [
    for (final set in allSets)
      if (set.done) set,
  ];

  double get progress => allSets.isEmpty
      ? 0
      : allSets.where((set) => set.done).length / allSets.length;
  int get reps =>
      doneSets.fold(0, (value, element) => value + (element.reps ?? 0));
  double get liftedWeight => doneSets.fold(
    0.0,
    (value, element) => value + (element.weight ?? 0) * (element.reps ?? 1),
  );

  /// Writes the ongoing workout to the database so that we can restore it on app restart.
  void save() => unawaited(persist());

  Future<void> persist({bool force = false, String? recoveryNativeId}) async {
    _pendingInputSave?.cancel();
    _pendingInputSave = null;
    if (isClosed || ownerId != service.db.currentUserId) return;
    final stopwatchController = ref.read(stopwatchControllerProvider.notifier);

    await service.writeToOngoing({
      "nativeWorkoutId": recoveryNativeId ?? nativeWorkoutId,
      "name": name,
      "exercises": exercises.map((ex) => ex.toJson()).toList(),
      "parentID": parentID,
      "time": time.millisecondsSinceEpoch,
      "infobox": infobox,
      "isContinuation": isContinuation,
      "continuesID": continuesID,
      "weightUnit": weightUnit.name,
      "distanceUnit": distanceUnit.name,
      if (stopwatchController.globalStopwatch.currentDuration.inSeconds >
          0) ...{
        "globalStopwatch": stopwatchController
            .globalStopwatch
            .startingTime
            .millisecondsSinceEpoch,
        "globalStopwatchPaused": stopwatchController.globalStopwatch.isStopped,
        "globalStopwatchNominalDuration":
            stopwatchController.globalStopwatch.currentDuration.inMilliseconds,
      },
    });
  }

  void generateNameIfEmpty() {
    final t = ref.read(translationsProvider);

    if (name.trim().isEmpty) {
      final groups = <GTMuscleCategory>{};

      for (final ex in exercises) {
        ex.when(
          exercise: (e) {
            final cat = e.primaryMuscleGroup.category;
            if (cat != null) groups.add(cat);
          },
          superset: (s) => groups.addAll(
            s.exercises
                .map((e) => e.primaryMuscleGroup.category)
                .whereType<GTMuscleCategory>(),
          ),
        );
      }

      setName(generateWorkoutTitle(t, groups));
    }
  }

  Future<Workout> submit(String name, Duration duration) async {
    if (isClosed || ownerId != service.db.currentUserId) {
      throw StateError('Cannot submit a workout belonging to another account');
    }
    final generation = sessionGeneration;
    final historyController = ref.read(historyControllerProvider);
    await _progressionWrite;
    if (!isSessionActive(generation)) {
      throw StateError("Workout session changed during submission");
    }

    removeCountdown();
    removeRelevantStopwatches();

    final workout = Workout(
      name: name,
      exercises: exercises,
      duration: duration,
      startingDate: time,
      parentID: parentID,
      infobox: infobox,
      completes: continuesID,
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
    );

    if (isContinuation) {
      historyController.bindContinuation(continuation: workout);
    }

    workout.logger.i("Submitting workout");
    await historyController.addNewWorkout(workout);
    return workout;
  }

  void removeCountdown() {
    ref.read(countdownControllerProvider.notifier).removeCountdown();
  }

  void removeRelevantStopwatches() {
    final ids = allSets.map((e) => e.id);
    final controller = ref.read(stopwatchControllerProvider.notifier);

    for (final id in ids) {
      controller.updateBinding(id, (timer, duration, encoded) {
        // no-op
      });
    }

    controller.removeStopwatches(ids);

    // Stop the global stopwatch
    controller.globalStopwatch.reset();
  }

  bool hasExercise(Exercise exercise) {
    return exercises.any((element) {
      return element.map(
        exercise: (ex) => exercise.isParentOf(ex),
        superset: (ss) =>
            ss.exercises.any((element) => exercise.isParentOf(element)),
      );
    });
  }

  void applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);
    assert(hasExercise(exercise));

    final res = exercises.toList();
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].when(
        exercise: (e) {
          if (exercise.isParentOf(e)) {
            res[i] = Exercise.replaced(
              from: e,
              to: exercise,
            ).copyWith(id: e.id, parentID: e.parentID);
          }
        },
        superset: (superset) {
          for (int j = 0; j < superset.exercises.length; j++) {
            if (exercise.isParentOf(superset.exercises[j])) {
              (res[i] as Superset).exercises[j] =
                  Exercise.replaced(
                    from: superset.exercises[j],
                    to: exercise,
                  ).copyWith(
                    id: superset.exercises[j].id,
                    parentID: superset.exercises[j].parentID,
                  );
            }
          }
        },
      );
    }

    setExercises(res);
  }

  void applyExistingWorkout(
    Workout workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool Function(GTSet set)? setFilter,
    bool continuation = false,
    required bool shouldKeepRPEs,
  }) {
    this
      ..setName(workout.name)
      ..setExercises([
        for (final ex in workout.exercises)
          if (exerciseFilter(ex))
            if (ex is Exercise)
              ex.instantiate(
                workout: workout,
                setFilter: setFilter,
                isSupersedence: continuation && ex.isSupersedence,
                rpe: shouldKeepRPEs ? Some(ex.rpe) : const None(),
              )
            else if (ex is Superset)
              ex.copyWith(
                exercises: ex.exercises
                    .map(
                      (e) => e.instantiate(
                        workout: workout,
                        setFilter: setFilter,
                        isSupersedence: continuation && e.isSupersedence,
                        rpe: shouldKeepRPEs ? Some(e.rpe) : const None(),
                      ),
                    )
                    .toList(),
              ),
      ])
      ..setTime(ref.read(workoutClockProvider).now())
      ..setParentID(parentID)
      ..setInfobox(workout.infobox)
      ..setIsContinuation(continuation)
      ..setContinuesID(continuation ? workout.id : null)
      ..setWeightUnit(workout.weightUnit)
      ..setDistanceUnit(workout.distanceUnit)
      ..save();
  }

  /// Helper method used in debug mode to show "Good job" dialog while workout
  /// is running
  Workout synthesizeTemporaryWorkout() {
    return Workout(
      name: name,
      exercises: exercises,
      duration: ref.read(workoutClockProvider).now().difference(time),
      startingDate: time,
      parentID: parentID,
      infobox: infobox,
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
      completedBy: null,
      completes: continuesID,
      folder: null,
    );
  }

  List<WorkoutExercisable> generateWorkoutExercises({
    required Set<GTMuscleGroup> muscleGroups,
    required Set<GTGymEquipment> equipment,
  }) {
    final filteredLibrary = exerciseStandardLibraryAsList
        .where(
          (exercise) =>
              (muscleGroups.contains(exercise.primaryMuscleGroup) ||
                  muscleGroups
                      .intersection(exercise.secondaryMuscleGroups)
                      .isNotEmpty) &&
              equipment.contains(exercise.gymEquipment),
        )
        .toList();
    final exercises = <WorkoutExercisable>[];

    for (final group in muscleGroups) {
      final groupExercises = filteredLibrary
          .where(
            (exercise) =>
                exercise.primaryMuscleGroup == group ||
                muscleGroups
                    .intersection(exercise.secondaryMuscleGroups)
                    .isNotEmpty,
          )
          .toList();
      groupExercises.shuffle();

      final toAdd = switch (muscleGroups.length) {
        1 => 4,
        2 => 2,
        3 => muscleGroups.toList().indexOf(group) == 0 ? 2 : 1,
        _ => 1,
      };
      int i = 0;
      exercises.addAll(
        groupExercises.take(toAdd).map((e) {
          i++;
          return e.makeChild().copyWith(
            restTime: const Duration(minutes: 1),
            sets: [
              for (int j = 0; j < (i == toAdd - 1 && i > 3 ? 2 : 3); j++)
                GTSet(
                  weight: 0,
                  reps: 10,
                  time: const Duration(minutes: 1),
                  distance: 0,
                  kind: GTSetKind.normal,
                  parameters: e.parameters,
                ),
            ],
          );
        }),
      );
    }

    return exercises;
  }

  WorkoutSetCursor? get currentSetCursor {
    _syncSetCursorWithWorkout();
    return _setCursor;
  }

  WorkoutSetCursor? get previousSetCursor {
    final cursor = _previousSetCursor;
    if (cursor == null) return null;
    if (!_isCursorValid(cursor)) return null;
    return cursor;
  }

  WorkoutExerciseIndex? get currentExerciseIndex {
    final cursor = currentSetCursor;
    if (cursor == null) return null;
    return (
      exerciseIndex: cursor.exerciseIndex,
      supersetIndex: cursor.supersetIndex,
    );
  }

  bool moveSetCursorToNext() {
    final cursor = currentSetCursor;
    if (cursor == null) return false;

    final ordered = _orderedSetCursors;
    final position = ordered.indexWhere(
      (candidate) => _isSameSetCursor(candidate, cursor),
    );
    if (position == -1 || position >= ordered.length - 1) {
      return false;
    }

    for (int i = position + 1; i < ordered.length; i++) {
      final candidate = ordered[i];
      if (!_setForCursor(candidate).done) {
        _previousSetCursor = cursor;
        _setCursor = candidate;
        refreshWatchData();
        return true;
      }
    }

    return false;
  }

  bool moveSetCursorToPrevious() {
    final cursor = currentSetCursor;
    if (cursor == null) return false;

    final ordered = _orderedSetCursors;
    final position = ordered.indexWhere(
      (candidate) => _isSameSetCursor(candidate, cursor),
    );
    if (position <= 0) {
      return false;
    }

    for (int i = position - 1; i >= 0; i--) {
      final candidate = ordered[i];
      if (!_setForCursor(candidate).done) {
        _previousSetCursor = cursor;
        _setCursor = candidate;
        refreshWatchData();
        return true;
      }
    }

    return false;
  }

  bool moveSetCursorToFirstUndone() {
    final cursor = _firstUndoneCursor();
    if (cursor == null) return false;

    _previousSetCursor = _setCursor;
    _setCursor = cursor;
    refreshWatchData();
    return true;
  }

  bool moveSetCursorToLastUndone() {
    final ordered = _orderedSetCursors;
    for (int i = ordered.length - 1; i >= 0; i--) {
      final candidate = ordered[i];
      if (!_setForCursor(candidate).done) {
        _previousSetCursor = _setCursor;
        _setCursor = candidate;
        refreshWatchData();
        return true;
      }
    }

    return false;
  }

  bool selectSetCursor(WorkoutSetCursor cursor) {
    if (!_isCursorSelectable(cursor)) {
      return false;
    }

    _previousSetCursor = _setCursor;
    _setCursor = cursor;
    refreshWatchData();
    return true;
  }

  bool selectSetCursorByIndex(ExerciseIndex index, int setIndex) {
    return selectSetCursor((
      exerciseIndex: index.exerciseIndex,
      supersetIndex: index.supersetIndex,
      setIndex: setIndex,
    ));
  }

  List<WorkoutSetCursor> get _orderedSetCursors {
    final cursors = <WorkoutSetCursor>[];

    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      if (ex is Exercise) {
        for (int setIndex = 0; setIndex < ex.sets.length; setIndex++) {
          cursors.add((
            exerciseIndex: i,
            supersetIndex: null,
            setIndex: setIndex,
          ));
        }
      } else if (ex is Superset) {
        final maxSets = ex.exercises.fold<int>(
          0,
          (value, exercise) =>
              value > exercise.sets.length ? value : exercise.sets.length,
        );

        for (int setIndex = 0; setIndex < maxSets; setIndex++) {
          for (
            int exerciseIndex = 0;
            exerciseIndex < ex.exercises.length;
            exerciseIndex++
          ) {
            final exercise = ex.exercises[exerciseIndex];
            if (setIndex < exercise.sets.length) {
              cursors.add((
                exerciseIndex: exerciseIndex,
                supersetIndex: i,
                setIndex: setIndex,
              ));
            }
          }
        }
      }
    }

    return cursors;
  }

  void _syncSetCursorWithWorkout() {
    final current = _setCursor;
    final ordered = _orderedSetCursors;
    final hasUndone = ordered.any((cursor) => !_setForCursor(cursor).done);

    if (ordered.isEmpty || !hasUndone) {
      _previousSetCursor = _setCursor;
      _setCursor = null;
      return;
    }

    if (current != null && _isCursorSelectable(current)) {
      return;
    }

    _previousSetCursor = _setCursor;
    _setCursor = ordered.firstWhere((cursor) => !_setForCursor(cursor).done);
  }

  bool _isCursorSelectable(WorkoutSetCursor cursor) {
    if (!_isCursorValid(cursor)) {
      return false;
    }

    return !_setForCursor(cursor).done;
  }

  bool _isCursorValid(WorkoutSetCursor cursor) {
    if (cursor.supersetIndex == null) {
      final exerciseIndex = cursor.exerciseIndex;
      if (exerciseIndex < 0 || exerciseIndex >= exercises.length) {
        return false;
      }
      final exercise = exercises[exerciseIndex];
      if (exercise is! Exercise) return false;
      return cursor.setIndex >= 0 && cursor.setIndex < exercise.sets.length;
    }

    final supersetIndex = cursor.supersetIndex!;
    if (supersetIndex < 0 || supersetIndex >= exercises.length) {
      return false;
    }
    final superset = exercises[supersetIndex];
    if (superset is! Superset) return false;
    if (cursor.exerciseIndex < 0 ||
        cursor.exerciseIndex >= superset.exercises.length) {
      return false;
    }

    final exercise = superset.exercises[cursor.exerciseIndex];
    return cursor.setIndex >= 0 && cursor.setIndex < exercise.sets.length;
  }

  GTSet _setForCursor(WorkoutSetCursor cursor) {
    if (cursor.supersetIndex == null) {
      return (exercises[cursor.exerciseIndex] as Exercise).sets[cursor
          .setIndex];
    }

    return (exercises[cursor.supersetIndex!] as Superset)
        .exercises[cursor.exerciseIndex]
        .sets[cursor.setIndex];
  }

  bool _isSameSetCursor(WorkoutSetCursor a, WorkoutSetCursor b) {
    return a.exerciseIndex == b.exerciseIndex &&
        a.supersetIndex == b.supersetIndex &&
        a.setIndex == b.setIndex;
  }

  WorkoutSetCursor? _firstUndoneCursorAfter(WorkoutSetCursor cursor) {
    final ordered = _orderedSetCursors;
    final position = ordered.indexWhere(
      (candidate) => _isSameSetCursor(candidate, cursor),
    );
    if (position == -1) return null;

    for (int i = position + 1; i < ordered.length; i++) {
      final candidate = ordered[i];
      if (!_setForCursor(candidate).done) {
        return candidate;
      }
    }

    return null;
  }

  WorkoutSetCursor? _firstUndoneCursor() {
    for (final cursor in _orderedSetCursors) {
      if (!_setForCursor(cursor).done) {
        return cursor;
      }
    }
    return null;
  }

  WorkoutSetCursor? _healCursorAfterExerciseDeletion(
    WorkoutSetCursor? previousCursor,
    ExerciseIndex deletedIndex,
  ) {
    if (previousCursor == null) return null;

    final (
      exerciseIndex: deletedExerciseIndex,
      supersetIndex: deletedSupersetIndex,
    ) = deletedIndex;

    if (deletedSupersetIndex == null) {
      if (previousCursor.supersetIndex == null) {
        if (previousCursor.exerciseIndex == deletedExerciseIndex) {
          return _firstUndoneCursor();
        }

        if (previousCursor.exerciseIndex > deletedExerciseIndex) {
          return (
            exerciseIndex: previousCursor.exerciseIndex - 1,
            supersetIndex: null,
            setIndex: previousCursor.setIndex,
          );
        }

        return previousCursor;
      }

      if (previousCursor.supersetIndex == deletedExerciseIndex) {
        return _firstUndoneCursor();
      }

      if (previousCursor.supersetIndex! > deletedExerciseIndex) {
        return (
          exerciseIndex: previousCursor.exerciseIndex,
          supersetIndex: previousCursor.supersetIndex! - 1,
          setIndex: previousCursor.setIndex,
        );
      }

      return previousCursor;
    }

    if (previousCursor.supersetIndex != deletedSupersetIndex) {
      return previousCursor;
    }

    if (previousCursor.exerciseIndex == deletedExerciseIndex) {
      return _firstUndoneCursor();
    }

    if (previousCursor.exerciseIndex > deletedExerciseIndex) {
      return (
        exerciseIndex: previousCursor.exerciseIndex - 1,
        supersetIndex: previousCursor.supersetIndex,
        setIndex: previousCursor.setIndex,
      );
    }

    return previousCursor;
  }

  WorkoutSetCursor? _healCursorAfterSetDeletion(
    WorkoutSetCursor? previousCursor,
    ExerciseIndex deletedExercise,
    int deletedSetIndex,
  ) {
    if (previousCursor == null) return null;

    final isSameExercise =
        previousCursor.exerciseIndex == deletedExercise.exerciseIndex &&
        previousCursor.supersetIndex == deletedExercise.supersetIndex;
    if (!isSameExercise) {
      return previousCursor;
    }

    if (previousCursor.setIndex == deletedSetIndex) {
      return _firstUndoneCursor();
    }

    if (previousCursor.setIndex > deletedSetIndex) {
      return (
        exerciseIndex: previousCursor.exerciseIndex,
        supersetIndex: previousCursor.supersetIndex,
        setIndex: previousCursor.setIndex - 1,
      );
    }

    return previousCursor;
  }

  void markSetAsDone(ExerciseIndex index, int setIndex, bool done) {
    final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
    final targetCursor = (
      exerciseIndex: i,
      supersetIndex: supersetIndex,
      setIndex: setIndex,
    );
    final currentCursor = currentSetCursor;
    final exercise = supersetIndex == null
        ? (exercises[i] as Exercise)
        : (exercises[supersetIndex] as Superset).exercises[i];

    if (setIndex < 0) {
      // setIndex = -1 means "forcefully start the timer",
      // so just start the timer
      final superset = supersetIndex == null
          ? null
          : (exercises[supersetIndex] as Superset);
      ref
          .read(countdownControllerProvider.notifier)
          .setCountdown(
            supersetIndex == null ? exercise.restTime : superset!.restTime,
          );

      return;
    }
    final set = exercise.sets[setIndex];

    final newSet = set.copyWith(done: done);

    if (supersetIndex == null) {
      final ex = exercises[i] as Exercise;
      exercises[i] = ex.copyWith(
        sets: [
          for (int j = 0; j < ex.sets.length; j++)
            if (j == setIndex) newSet else ex.sets[j],
        ],
      );
    } else {
      final superset = exercises[supersetIndex] as Superset;
      exercises[supersetIndex] = superset.copyWith(
        exercises: [
          for (int j = 0; j < superset.exercises.length; j++)
            if (j == i)
              superset.exercises[j].copyWith(
                sets: [
                  for (int k = 0; k < superset.exercises[j].sets.length; k++)
                    if (k == setIndex)
                      newSet
                    else
                      superset.exercises[j].sets[k],
                ],
              )
            else
              superset.exercises[j],
        ],
      );
    }

    if (done) {
      final nextSet = exercise.sets.getAt(setIndex + 1);
      final superset = supersetIndex == null
          ? null
          : (exercises[supersetIndex] as Superset);

      bool shouldStart = false;
      shouldStart |= (supersetIndex == null && exercise.restTime.inSeconds > 0);
      shouldStart |=
          supersetIndex != null &&
          superset!.restTime.inSeconds > 0 &&
          i == superset.exercises.length - 1;

      if (nextSet != null && nextSet.kind == GTSetKind.failureStripping) {
        shouldStart = false;
      }

      // Start a countdown if:
      // either:
      //  - This is an exercise
      //  - This is the last exercise in a superset
      // and:
      //  - The rest time is greater than 0
      // and:
      //  - The next set is not a stripping set
      if (shouldStart) {
        ref
            .read(countdownControllerProvider.notifier)
            .setCountdown(
              supersetIndex == null ? exercise.restTime : superset!.restTime,
            );
      } else {
        logger.i(
          """
Not starting countdown because the following conditions are not met:
either:
 - This is an exercise (${supersetIndex == null})
 - This is the last exercise in a superset (${supersetIndex != null && i == (exercises[supersetIndex] as Superset).exercises.length - 1})
and:
 - The rest time is greater than 0 (${(supersetIndex == null && exercise.restTime.inSeconds > 0) || (supersetIndex != null && (exercises[supersetIndex] as Superset).restTime.inSeconds > 0)})
and:
 - The next set is not a stripping set (${!(nextSet != null && nextSet.kind == GTSetKind.failureStripping)})
"""
              .trim(),
        );
      }
    }

    _syncSetCursorWithWorkout();
    if (done &&
        currentCursor != null &&
        _isSameSetCursor(currentCursor, targetCursor)) {
      _previousSetCursor = currentCursor;
      _setCursor =
          _firstUndoneCursorAfter(currentCursor) ?? _firstUndoneCursor();
    }

    publishExercises();
    refreshWatchData();
    save();
  }

  void autoMarkNextSetDone() {
    final cursor = currentSetCursor;
    if (cursor == null) return;

    markSetAsDone(
      (
        exerciseIndex: cursor.exerciseIndex,
        supersetIndex: cursor.supersetIndex,
      ),
      cursor.setIndex,
      true,
    );
  }

  Color? nativePrimaryColor;

  void refreshWatchData({Color? primaryColor}) {
    nativePrimaryColor = primaryColor ?? nativePrimaryColor;
    if (isClosed || ownerId != service.db.currentUserId) return;
    if (state?.cursor != _setCursor ||
        state?.previousCursor != _previousSetCursor) {
      state = WorkoutState(
        workout: synthesizeSnapshot(),
        ownerId: ownerId,
        cursor: _setCursor,
        previousCursor: _previousSetCursor,
      );
    }
    final t = ref.read(translationsProvider);
    final ctdctrl = ref.read(countdownControllerProvider.notifier);
    final startingTime = ctdctrl.startingTime;
    final endingTime = ctdctrl.targetTime;

    final cursor = currentSetCursor;
    NativeWorkoutStateMessage message;

    final settingsController = ref.read(settingsControllerProvider);
    // This is going to be null if the user has enabled tinting,
    // so that we can use the null-aware operator to fall back to the exercise
    // color
    final theme = settingsController.tintExercises
        ? null
        : settingsController.color;

    if (cursor != null) {
      final (exerciseIndex: exerciseIndex, supersetIndex: supersetIndex) = (
        exerciseIndex: cursor.exerciseIndex,
        supersetIndex: cursor.supersetIndex,
      );
      final exercise = supersetIndex == null
          ? (exercises[exerciseIndex] as Exercise)
          : (exercises[supersetIndex] as Superset).exercises[exerciseIndex];
      final name = exercise.getDisplayName(t);
      final color =
          theme ??
          (exercise.standard && exercise.category != null
              ? exerciseStandardLibrary[exercise.category]?.color ??
                    nativePrimaryColor ??
                    Colors.red
              : nativePrimaryColor ?? Colors.red);
      final set = exercise.sets[cursor.setIndex];
      final setTypeLabel = _setTypeLabelForWatch(set, exercise.sets);

      message = NativeWorkoutStateMessage(
        hasExercise: true,
        exerciseName: name,
        exerciseColor: color,
        exerciseParameters: set.getHumanReadableDescription(
          t: t,
          weightUnit: weightUnit,
          distanceUnit: distanceUnit,
          targetWeightUnit: settingsController.weightUnit,
          targetDistanceUnit: settingsController.distanceUnit,
        ),
        setTypeLabel: setTypeLabel,
        startingTime: time,
        restTimeStart: startingTime,
        restTimeEnd: endingTime,
        percentageDone: progress,
        set: set,
      );
    } else {
      message = NativeWorkoutStateMessage(
        hasExercise: false,
        exerciseName: "",
        exerciseColor: Colors.transparent,
        exerciseParameters: "",
        setTypeLabel: "",
        startingTime: time,
        restTimeStart: startingTime,
        restTimeEnd: endingTime,
        percentageDone: progress,
        set: null,
      );
    }

    // TODO: Figure out why this was needed
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    // });
    ref.read(nativeServiceProvider).setExerciseParameters(message);
  }

  void addSuperset() {
    exercises.add(Superset.empty());
  }

  String _setTypeLabelForWatch(GTSet set, List<GTSet> allSets) {
    switch (set.kind) {
      case GTSetKind.warmUp:
        return t.set.kindShort.warmUp;
      case GTSetKind.normal:
        final normalSets = allSets.where(
          (element) => element.kind == GTSetKind.normal,
        );
        final normalSetIndex = normalSets.toList().indexWhere(
          (element) => element.id == set.id,
        );
        return (normalSetIndex >= 0 ? normalSetIndex + 1 : 1).toString();
      case GTSetKind.drop:
        return t.set.kindShort.drop;
      case GTSetKind.failure:
        return t.set.kindShort.failure;
      case GTSetKind.failureStripping:
        return t.set.kindShort.failureStripping;
    }
  }

  Exercise? getExercise(ExerciseIndex index) {
    return exercises.exerciseAt(index);
  }

  void updateSetParameters(
    double? weight,
    double? timeSeconds,
    int? reps,
    double? distance,
  ) {
    final cursor = currentSetCursor;
    if (cursor == null) return;

    if (cursor.supersetIndex != null) {
      final sup = exercises[cursor.supersetIndex!].asSuperset;
      final ex = sup.exercises[cursor.exerciseIndex];
      final setIndex = cursor.setIndex;
      ex.sets[setIndex] = ex.sets[setIndex].copyWith(
        weight: weight,
        time: timeSeconds == null
            ? null
            : Duration(seconds: timeSeconds.floor()),
        reps: reps,
        distance: distance,
      );
    } else {
      final ex = exercises[cursor.exerciseIndex].asExercise;
      final setIndex = cursor.setIndex;
      ex.sets[setIndex] = ex.sets[setIndex].copyWith(
        weight: weight,
        time: timeSeconds == null
            ? null
            : Duration(seconds: timeSeconds.floor()),
        reps: reps,
        distance: distance,
      );
    }

    publishExercises();
    refreshWatchData();
    save();
  }
}

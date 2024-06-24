import 'package:gymtracker/model/set.dart';

typedef ExerciseIndex = ({
  int exerciseIndex,
  int? supersetIndex,
});

enum EditorMode {
  creation,
  editingOrWorkout,
}

class EditorCallbacks {
  final EditorMode mode;
  final void Function(int? supersetIndex) onExerciseReorder;
  final void Function(ExerciseIndex exerciseIndex) onExerciseReplace;
  final void Function(ExerciseIndex exerciseIndex) onExerciseRemove;
  final void Function(ExerciseIndex exerciseIndex, Duration time)
      onExerciseChangeRestTime;
  final void Function(ExerciseIndex exerciseIndex, String notes)
      onExerciseNotesChange;
  final void Function(ExerciseIndex exerciseIndex, int? newRPE)
      onExerciseChangeRPE;
  final void Function(ExerciseIndex exerciseIndex) onSetCreate;
  final void Function(ExerciseIndex exerciseIndex, int setIndex) onSetRemove;
  final void Function(ExerciseIndex exerciseIndex, int setIndex, GTSetKind kind)
      onSetSelectKind;
  final void Function(ExerciseIndex exerciseIndex, int setIndex, bool isDone)
      onSetSetDone;
  final void Function(ExerciseIndex exerciseIndex, int setIndex, GTSet newSet)
      onSetValueChange;
  final void Function(int supersetIndex) onSupersetAddExercise;
  final void Function(int index, int oldExerciseIndex, int newExerciseIndex)
      onSupersetExercisesReorderPair;
  final void Function(int startingIndex) onGroupExercisesIntoSuperset;

  EditorCallbacks.creation({
    required this.onExerciseReplace,
    required this.onExerciseRemove,
    required this.onExerciseChangeRestTime,
    required this.onExerciseNotesChange,
    required this.onSetCreate,
    required this.onSetRemove,
    required this.onSetSelectKind,
    required this.onSetValueChange,
    required this.onSupersetAddExercise,
    required this.onSupersetExercisesReorderPair,
  })  : mode = EditorMode.creation,
        onExerciseReorder = ((index) {
          throw Exception(
              "onExerciseReorder is not available in creation mode.");
        }),
        onExerciseChangeRPE = ((index, newRPE) {
          throw Exception(
              "onExerciseChangeRPE is not available in creation mode.");
        }),
        onSetSetDone = ((ex, set, done) {
          throw Exception("onSetSetDone is not available in creation mode.");
        }),
        onGroupExercisesIntoSuperset = ((index) {
          throw Exception(
              "onGroupExercisesIntoSuperset is not available in creation mode.");
        });

  EditorCallbacks.editor({
    required this.onExerciseReorder,
    required this.onExerciseReplace,
    required this.onExerciseRemove,
    required this.onExerciseChangeRestTime,
    required this.onExerciseNotesChange,
    required this.onExerciseChangeRPE,
    required this.onSetCreate,
    required this.onSetRemove,
    required this.onSetSelectKind,
    required this.onSetSetDone,
    required this.onSetValueChange,
    required this.onSupersetAddExercise,
    required this.onGroupExercisesIntoSuperset,
  })  : mode = EditorMode.editingOrWorkout,
        onSupersetExercisesReorderPair = ((index, oldIndex, newIndex) {
          throw Exception(
              "onSupersetExercisesReorderPair is not available in editing mode.");
        });
}

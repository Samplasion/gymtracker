import 'package:gymtracker/model/set.dart';

typedef ExerciseIndex = ({
  int exerciseIndex,
  int? supersetIndex,
});

class EditorCallbacks {
  final void Function(int? supersetIndex) onExerciseReorder;
  final void Function(ExerciseIndex exerciseIndex) onExerciseReplace;
  final void Function(ExerciseIndex exerciseIndex) onExerciseRemove;
  final void Function(ExerciseIndex exerciseIndex, Duration time)
      onExerciseChangeRestTime;
  final void Function(ExerciseIndex exerciseIndex, String notes)
      onExerciseNotesChange;
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

  const EditorCallbacks({
    required this.onExerciseReorder,
    required this.onExerciseReplace,
    required this.onExerciseRemove,
    required this.onExerciseChangeRestTime,
    required this.onExerciseNotesChange,
    required this.onSetCreate,
    required this.onSetRemove,
    required this.onSetSelectKind,
    required this.onSetSetDone,
    required this.onSetValueChange,
    required this.onSupersetAddExercise,
    required this.onSupersetExercisesReorderPair,
  });
}

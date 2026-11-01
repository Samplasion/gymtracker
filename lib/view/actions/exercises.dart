import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercise_creator.dart';

extension ExercisesPresentation on ExercisesController {
  Future<Exercise?> editExercise(
    Exercise exercise,
    List<(Exercise, int, Workout)> history,
  ) async {
    if (service.db.cachedTrainerState.protectedExercises.contains(exercise.id))
      return null;
    if (ref.read(workoutControllerProvider) != null &&
        ref.read(workoutControllerProvider.notifier).hasExercise(exercise)) {
      final shouldOverwrite = await Go.confirm(
        "exercise.editor.overwriteInWorkout.title",
        "exercise.editor.overwriteInWorkout.body",
      );
      if (!ref.mounted || !shouldOverwrite) {
        return null;
      }
    }
    final ex = await Go.showBottomModalScreen<Exercise>(
      (context, controller) => ExerciseCreator(
        base: exercise,
        scrollController: controller,
        shouldChangeParameters: history.isEmpty,
      ),
    );
    if (!ref.mounted) return null;
    final isInUse = hasExerciseInUse(exercise);
    logger.d(("IS IN USE", isInUse));
    if (ex != null) {
      assert(ex.id == exercise.id);
      await saveEdit(ex);
      if (!ref.mounted) return null;
      if (isInUse) {
        await applyExerciseModification(ex);
      }
    }
    return ex;
  }
}

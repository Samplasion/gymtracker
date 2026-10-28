import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/model/model.dart';

import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  test('lats belong to back without changing other muscle categories', () {
    expect(GTMuscleGroup.lats.category, GTMuscleCategory.back);
    expect(GTMuscleGroup.quadriceps.category, GTMuscleCategory.legs);
    expect(GTMuscleGroup.hamstrings.category, GTMuscleCategory.legs);
    expect(GTMuscleGroup.upperBack.category, GTMuscleCategory.back);
    expect(GTMuscleGroup.chest.category, GTMuscleCategory.chest);
    expect(GTMuscleGroup.biceps.category, GTMuscleCategory.arms);
  });

  test('standard dumbbell pullover counts completed sets for back', () {
    final controller = dataController(HistoryController.new);
    final exercise =
        getStandardExerciseByID(
          GTStandardLibrary.back.dumbbellPullover,
        )!.makeChild().copyWith(
          sets: [
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsWeight,
              reps: 10,
              weight: 20,
              done: true,
            ),
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsWeight,
              reps: 10,
              weight: 20,
              done: false,
            ),
          ],
        );
    expect(exercise.primaryMuscleGroup, GTMuscleGroup.lats);
    final distribution = controller.calculateMuscleCategoryDistributionFor(
      workouts: [
        Workout(
          name: 'Back',
          exercises: [exercise],
          startingDate: DateTime(2026),
          duration: const Duration(minutes: 10),
        ),
      ],
    );
    expect(distribution[GTMuscleCategory.back], 1);
    expect(distribution[GTMuscleCategory.legs], 0);
  });
}

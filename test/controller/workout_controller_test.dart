import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockServices.setup();
    await initTestLocalizations();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('WorkoutController -', () {
    test('generateWorkoutTitle works correctly', () {
      final title1 =
          WorkoutController.generateWorkoutTitle({GTMuscleCategory.chest});
      expect(title1.contains('Chest'), true);

      final title2 = WorkoutController.generateWorkoutTitle({
        GTMuscleCategory.chest,
        GTMuscleCategory.shoulders,
      });
      expect(title2.contains('Chest'), true);
      expect(title2.contains('Shoulders'), true);
    });

    test('computed properties (progress, reps, liftedWeight) work correctly',
        () {
      final controller = WorkoutController("Test Workout", null, null);
      controller.exercises.addAll([
        exerciseHelper("ex1", "Bench Press", sets: [
          GTSet(
            reps: 10,
            weight: 100,
            time: Duration.zero,
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
            done: true,
          ),
          GTSet(
            reps: 8,
            weight: 110,
            time: Duration.zero,
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
            done: false, // undone set
          ),
        ]),
      ]);

      expect(controller.progress, 0.5); // 1 done, 1 undone
      expect(controller.reps, 10); // only done sets count
      expect(controller.liftedWeight, 1000.0); // 10 reps * 100 kg
    });

    test('hasExercise & applyExerciseModification work correctly', () {
      final controller = WorkoutController("Test Workout", null, null);
      final template = exerciseHelper("ex1", "Bench Press");
      final concrete = template.copyWith(id: "concrete1", parentID: "ex1");
      controller.exercises.add(concrete);

      expect(controller.hasExercise(template), true);

      // Modify the exercise name on the template
      final modifiedTemplate = template.copyWith(name: "New Name");
      controller.applyExerciseModification(modifiedTemplate);

      expect(controller.exercises.first.asExercise.name, "New Name");
    });

    test('generateNameIfEmpty works correctly', () {
      final controller = WorkoutController("", null, null);
      controller.exercises.add(exerciseHelper("ex1", "Bench Press"));
      controller.generateNameIfEmpty();

      expect(controller.name.value.isNotEmpty, true);
      expect(controller.name.value.contains('Chest'), true);
    });

    test('serialization & deserialization (save/fromSavedData) work correctly',
        () {
      final controller =
          WorkoutController("Saved Workout", "parent123", "Some info");
      controller.exercises.add(exerciseHelper("ex1", "Bench Press"));

      // Stub routinesController to return true for hasOngoingWorkout
      when(() => MockServices.routinesController.hasOngoingWorkout)
          .thenReturn(true.obs);

      controller.save();

      // Verify that databaseService.writeToOngoing was called
      verify(() => MockServices.databaseService.writeToOngoing(any()))
          .called(1);

      // Deserialization
      final data = {
        'name': 'Saved Workout',
        'parentID': 'parent123',
        'infobox': 'Some info',
        'time': DateTime.now().millisecondsSinceEpoch,
        'isContinuation': false,
        'weightUnit': 'kg',
        'distanceUnit': 'km',
        'exercises': controller.exercises.map((e) => e.toJson()).toList(),
      };

      final restored = WorkoutController.fromSavedData(data);
      expect(restored.name.value, 'Saved Workout');
      expect(restored.parentID.value, 'parent123');
      expect(restored.infobox.value, 'Some info');
      expect(restored.exercises.length, 1);
      expect(restored.exercises[0].id, 'ex1');
    });

    test('cursor navigation works correctly', () {
      final controller = WorkoutController("Cursor Test", null, null);
      controller.exercises.addAll([
        exerciseHelper("ex1", "Bench Press", sets: [
          GTSet(
            reps: 10,
            weight: 100,
            time: Duration.zero,
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
            done: false,
          ),
          GTSet(
            reps: 8,
            weight: 110,
            time: Duration.zero,
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
            done: false,
          ),
        ]),
      ]);

      // Initial cursor should be at first set
      expect(controller.currentSetCursor, isNotNull);
      expect(controller.currentSetCursor!.setIndex, 0);

      // Move to next set cursor
      final moved = controller.moveSetCursorToNext();
      expect(moved, true);
      expect(controller.currentSetCursor!.setIndex, 1);

      // Move previous
      final movedBack = controller.moveSetCursorToPrevious();
      expect(movedBack, true);
      expect(controller.currentSetCursor!.setIndex, 0);
    });
  });
}

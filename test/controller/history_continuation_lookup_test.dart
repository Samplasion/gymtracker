import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  for (final complete in [false, true]) {
    for (final hasChild in [false, true]) {
      for (final viaController in [false, true]) {
        test(
          '${viaController ? 'controller' : 'extension'} finds existing continuation: complete=$complete, child=$hasChild',
          () {
            final exercise = exerciseHelper('exercise', 'Bench');
            final original = Workout(
              id: 'original',
              name: 'Original',
              exercises: [exercise],
              startingDate: DateTime(2026),
              duration: const Duration(minutes: 10),
              completedBy: hasChild ? 'child' : null,
            );
            // Match editing the original after its continuation was saved.
            final edited = original.copyWith(
              exercises: [
                exercise.copyWith(
                  sets: [
                    for (final set in exercise.sets)
                      set.copyWith(done: complete),
                  ],
                ),
              ],
            );
            final child = Workout(
              id: 'child',
              name: 'Continuation',
              exercises: [],
              startingDate: DateTime(2026, 1, 2),
              duration: const Duration(minutes: 5),
              completes: original.id,
            );
            final history = [edited, if (hasChild) child];
            when(
              () => MockServices.databaseService.workoutHistory,
            ).thenReturn(history);
            final expected = hasChild ? same(child) : isNull;
            expect(edited.isComplete, complete);
            expect(edited.isContinuable, !complete && !hasChild);
            expect(child.isContinuable, isFalse);
            if (viaController) {
              final controller = dataController(HistoryController.new);
              expect(
                controller.getContinuation(incompleteWorkout: edited),
                expected,
              );
              expect(
                controller.hasContinuation(incompleteWorkout: edited),
                hasChild,
              );
            } else {
              expect(edited.continuationIn(history), expected);
              expect(edited.hasContinuationIn(history), hasChild);
              expect(
                edited.synthesizeContinuations(history: history).components,
                hasChild ? [edited, child] : [edited],
              );
            }
          },
        );
      }
    }
  }
}

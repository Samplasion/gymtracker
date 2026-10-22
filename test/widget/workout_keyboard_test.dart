import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/workout.dart' show WorkoutListView;

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  testWidgets('keyboard padding changes without rebuilding exercise children', (
    tester,
  ) async {
    var builds = 0;
    final textController = TextEditingController(text: '42');
    final child = WorkoutListView(
      children: [
        Builder(
          builder: (context) {
            builds++;
            return TextField(controller: textController);
          },
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(resizeToAvoidBottomInset: false, body: child)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final before = builds;
    final state = tester.state<EditableTextState>(find.byType(EditableText));
    textController.selection = const TextSelection.collapsed(offset: 1);
    for (final height in [100.0, 200.0, 300.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: height);
      await tester.pump();
      final list = tester.widget<ListView>(find.byType(ListView));
      final padding = list.padding! as EdgeInsets;
      expect(padding.bottom, 8 + height / tester.view.devicePixelRatio);
      expect(builds, before);
      expect(state.widget.focusNode.hasFocus, isTrue);
      expect(textController.selection.baseOffset, 1);
    }
    tester.view.resetViewInsets();
    await tester.pumpWidget(const SizedBox());
    textController.dispose();
  });

  testWidgets(
    'unrelated set changes preserve text selection; remote changes sync',
    (tester) async {
      MockServices.setup();
      await initTestLocalizations();
      final workout = MockServices.createWorkout('Workout', null, null);
      workout.exercises.addAll([
        exerciseHelper('ex1', 'Bench Press'),
        exerciseHelper('ex2', 'Squat'),
      ]);
      final exercise = workout.exercises.first.asExercise;
      await tester.pumpWidget(
        WidgetTestApp(
          wrapWithProviderScope: true,
          child: WorkoutExerciseSetEditor(
            exercise: exercise,
            set: exercise.sets.first,
            index: (exerciseIndex: 0, supersetIndex: null),
            setIndex: 0,
            alt: false,
            isCreating: false,
            onDelete: () {},
            onSetSelectKind: (_) {},
            onSetSetDone: (_) {},
            onSetChangeRPE: (_) {},
            onSetValueChange: (_) {},
            weightUnit: Weights.kg,
            distanceUnit: Distance.km,
          ),
        ),
      );
      final weight = tester
          .widgetList<TextField>(find.byType(TextField))
          .first
          .controller!;
      weight.selection = const TextSelection.collapsed(offset: 0);
      var updates = 0;
      weight.addListener(() => updates++);
      final other = workout.exercises[1].asExercise;
      workout.exercises[1] = other.copyWith(notes: 'Changed remotely');
      workout.publishExercises();
      await tester.pump();
      expect(updates, 0);
      expect(weight.selection.baseOffset, 0);

      workout.exercises[0] = exercise.copyWith(
        sets: [exercise.sets.first.copyWith(weight: 42)],
      );
      workout.publishExercises();
      await tester.pump();
      expect(weight.text, '42');
      expect(updates, 1);
      await tester.pumpWidget(const SizedBox());
      MockServices.tearDown();
    },
  );
}

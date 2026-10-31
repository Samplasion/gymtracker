import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/workout.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    final session = MockServices.createWorkout('Workout', null, null);
    session.time = DateTime.now().subtract(const Duration(minutes: 10));
  });
  tearDown(MockServices.tearDown);

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: Text('Home')),
    );
    unawaited(
      Go.navigator.push(
        MaterialPageRoute<void>(builder: (_) => const WorkoutFinishPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final modified in [false, true]) {
    testWidgets('Cupertino modal drag respects edits: $modified', (
      tester,
    ) async {
      await tester.pumpWidget(
        const WidgetTestApp(wrapWithProviderScope: true, child: Text('Home')),
      );
      unawaited(Go.showBottomModalScreen((_, _) => const WorkoutFinishPage()));
      await tester.pumpAndSettle();
      if (modified) {
        await tester.enterText(find.byType(TextFormField).first, 'Changed');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }
      // Start at the toolbar so the gesture belongs to the modal, not the list.
      await tester.dragFrom(
        tester.getCenter(find.text('Finish workout')),
        const Offset(0, 650),
      );
      await tester.pumpAndSettle();
      if (modified) {
        expect(find.text('Discard changes?'), findsOneWidget);
        await tester.tap(find.text('Keep editing'));
        await tester.pumpAndSettle();
        expect(find.byType(WorkoutFinishPage), findsOneWidget);
      } else {
        expect(find.byType(WorkoutFinishPage), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('unchanged form closes immediately', (tester) async {
    await open(tester);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('restoring the initial name avoids the discard warning', (
    tester,
  ) async {
    await open(tester);
    final name = find.byType(TextFormField).first;
    await tester.enterText(name, 'Changed');
    await tester.enterText(name, 'Workout');
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'close can keep edits or discard them without ending the session',
    (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Changed');
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Changed'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      final session = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      expect(session.name, 'Workout');
      expect(session.isActive, isTrue);
    },
  );

  testWidgets('back uses the same discard confirmation', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Changed');
    unawaited(Go.navigator.maybePop());
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutFinishPage), findsOneWidget);
  });

  testWidgets('date, routine, duration and notes stay in the form until save', (
    tester,
  ) async {
    await open(tester);
    final session = MockServices.container.read(
      workoutControllerProvider.notifier,
    );
    final originalDate = session.time;
    tester
        .widget<DateField>(find.byType(DateField))
        .onSelect(DateTime(2026, 1, 1));
    tester
        .widget<RoutineFormPicker>(find.byType(RoutineFormPicker))
        .onChanged(
          Workout(
            id: 'routine',
            name: 'Routine',
            exercises: [],
            duration: Duration.zero,
          ),
        );
    tester.widget<TimeInputField>(find.byType(TimeInputField)).controller.text =
        '00:20:00';
    await tester.ensureVisible(find.byType(GTRichTextEditor));
    final notes = tester
        .widget<GTRichTextEditor>(find.byType(GTRichTextEditor))
        .controller;
    notes.replaceText(
      0,
      0,
      'Unsaved notes',
      const TextSelection.collapsed(offset: 13),
    );
    await tester.pumpAndSettle();
    expect(session.time, originalDate);
    expect(session.parentID, isNull);
    expect(session.infobox, isNull);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
  });
}

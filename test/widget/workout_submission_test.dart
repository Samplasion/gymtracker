import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  testWidgets('concurrent presentation calls complete the flow once', (
    tester,
  ) async {
    MockServices.setup();
    await initTestLocalizations();
    final controller = MockServices.createWorkout('Workout', null, null);
    final pending = Completer<void>();
    when(
      () => MockServices.historyController.addNewWorkout(any()),
    ).thenAnswer((_) => pending.future);
    when(
      () => MockServices.routinesController.service,
    ).thenReturn(MockServices.databaseService);
    when(
      () =>
          MockServices.routinesController.advanceProgressionsFromWorkout(any()),
    ).thenAnswer((_) async {});
    await tester.pumpWidget(
      const WidgetTestApp(wrapWithProviderScope: true, child: Text('Home')),
    );
    unawaited(
      Go.navigator.push(
        MaterialPageRoute<void>(builder: (_) => const Text('Workout route')),
      ),
    );
    await tester.pumpAndSettle();
    final calls = <Future<void>>[];
    unawaited(
      Go.navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () {
                calls.add(
                  controller.submitWithPresentation(
                    'Workout',
                    Duration.zero,
                    ref: ref,
                  ),
                );
                calls.add(
                  controller.submitWithPresentation(
                    'Duplicate',
                    Duration.zero,
                    ref: ref,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    verify(() => MockServices.historyController.addNewWorkout(any())).called(1);
    pending.complete();
    await Future.wait(calls);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(controller.isClosed, isTrue);
    verify(
      () =>
          MockServices.routinesController.advanceProgressionsFromWorkout(any()),
    ).called(1);
    verify(() => MockServices.backupScheduler.schedule()).called(1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    MockServices.tearDown();
  });

  testWidgets('failed save keeps form open and allows retry', (tester) async {
    MockServices.setup();
    await initTestLocalizations();
    final controller = MockServices.createWorkout('Workout', null, null);
    controller.time = DateTime.now().subtract(const Duration(minutes: 10));
    var pending = Completer<void>();
    var writes = 0;
    when(() => MockServices.historyController.addNewWorkout(any())).thenAnswer((
      _,
    ) {
      writes++;
      return pending.future;
    });
    await tester.pumpWidget(
      const WidgetTestApp(
        wrapWithProviderScope: true,
        child: WorkoutFinishPage(),
      ),
    );
    await tester.pump();
    final save = find.widgetWithText(FilledButton, 'Save workout');
    await tester.tap(save);
    await tester.pump();
    pending.completeError(StateError('Write failed'));
    await tester.pump();
    expect(find.byType(WorkoutFinishPage), findsOneWidget);
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    expect(find.textContaining('Unable to save the workout'), findsOneWidget);
    expect(find.textContaining('Write failed'), findsNothing);
    expect(tester.takeException(), isNull);
    pending = Completer<void>();
    await tester.tap(save);
    await tester.pump();
    expect(writes, 2);
    controller.start('New', null, null, saveInitial: false);
    pending.complete();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    MockServices.tearDown();
  });

  testWidgets(
    'save reads every draft field including notes still being edited',
    (tester) async {
      MockServices.setup();
      await initTestLocalizations();
      final controller = MockServices.createWorkout('Workout', 'routine', null);
      controller.time = DateTime.now().subtract(const Duration(minutes: 10));
      final pending = Completer<void>();
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((_) => pending.future);
      await tester.pumpWidget(
        const WidgetTestApp(
          wrapWithProviderScope: true,
          child: WorkoutFinishPage(),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).first, 'Edited');
      tester
          .widget<DateField>(find.byType(DateField))
          .onSelect(DateTime(2026, 1, 1));
      tester
          .widget<RoutineFormPicker>(find.byType(RoutineFormPicker))
          .onChanged(null);
      await tester.ensureVisible(find.byType(GTRichTextEditor));
      tester
          .widget<GTRichTextEditor>(find.byType(GTRichTextEditor))
          .controller
          .replaceText(
            0,
            0,
            'Final notes',
            const TextSelection.collapsed(offset: 11),
          );
      await tester.tap(find.text('Save workout'));
      await tester.pump();
      final saved =
          verify(
                () =>
                    MockServices.historyController.addNewWorkout(captureAny()),
              ).captured.single
              as Workout;
      expect(saved.name, 'Edited');
      expect(saved.startingDate, DateTime(2026, 1, 1));
      expect(saved.parentID, isNull);
      expect(saved.infobox, contains('Final notes'));
      // Closing is blocked while persistence is pending.
      await tester.tap(find.byType(CloseButton));
      await tester.pump();
      expect(find.byType(WorkoutFinishPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      controller.start('New session', null, null, saveInitial: false);
      pending.complete();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      MockServices.tearDown();
    },
  );

  testWidgets('invalid form does not save or lock the button', (tester) async {
    MockServices.setup();
    await initTestLocalizations();
    MockServices.createWorkout('Workout', null, null);
    await tester.pumpWidget(
      const WidgetTestApp(
        wrapWithProviderScope: true,
        child: WorkoutFinishPage(),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, '');
    final save = find.widgetWithText(FilledButton, 'Save workout');
    await tester.tap(save);
    await tester.pump();
    verifyNever(() => MockServices.historyController.addNewWorkout(any()));
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.pumpWidget(const SizedBox());
    MockServices.tearDown();
  });

  testWidgets('rapid save taps submit once and disable save while pending', (
    tester,
  ) async {
    MockServices.setup();
    await initTestLocalizations();
    final controller = MockServices.createWorkout('Workout', null, null);
    controller.time = DateTime.now().subtract(const Duration(minutes: 10));
    final pending = Completer<void>();
    var writes = 0;
    when(() => MockServices.historyController.addNewWorkout(any())).thenAnswer((
      _,
    ) {
      writes++;
      return pending.future;
    });
    await tester.pumpWidget(
      const WidgetTestApp(
        wrapWithProviderScope: true,
        child: WorkoutFinishPage(),
      ),
    );
    await tester.pump();
    final save = find.widgetWithText(FilledButton, 'Save workout');
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();
    final count = writes;
    final callback = tester
        .widget<FilledButton>(find.byType(FilledButton))
        .onPressed;
    // Invalidate the session before resolving to avoid unrelated navigation.
    controller.start('Another workout', null, null, saveInitial: false);
    pending.complete();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    MockServices.tearDown();
    expect(count, 1);
    expect(callback, isNull);
  });
}

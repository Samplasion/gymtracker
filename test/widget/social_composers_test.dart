import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/view/social.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  for (final canOpenComments in [true, false]) {
    testWidgets('comment navigation enabled: $canOpenComments', (tester) async {
      const source = (owner: 'friend', source: 'workout', kind: 'workout');
      final container = ProviderContainer(
        overrides: [
          ...MockServices.defaultOverrides,
          currentUserIdProvider.overrideWithValue('viewer'),
          sourceSocialProvider(source).overrideWith(
            (ref) async => {
              'post': {'id': 'post', 'active': true},
              'likes': 4,
              'comments': 7,
            },
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: WidgetTestApp(
            child: PostActions(
              source: source,
              canOpenComments: canOpenComments,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<TextButton>(
        find.ancestor(
          of: find.byIcon(Icons.comment_outlined),
          matching: find.byType(TextButton),
        ),
      );
      expect(button.onPressed, canOpenComments ? isNotNull : isNull);
      expect(find.text('7'), findsOneWidget);
      // Disabling comments must leave likes usable.
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, '4'))
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('visibility is edited in a dialog opened from the popup menu', (
    tester,
  ) async {
    final workout = Workout(
      id: 'visibility',
      name: 'Workout',
      exercises: [],
      duration: const Duration(minutes: 30),
      startingDate: DateTime.utc(2026, 10, 23),
    );
    registerFallbackValue(workout);
    final saved = <Workout>[];
    when(
      () => MockServices.databaseService.getHistoryWorkout(workout.id),
    ).thenReturn(workout);
    when(
      () => MockServices.databaseService.setHistoryWorkout(any()),
    ).thenAnswer((invocation) async {
      saved.add(invocation.positionalArguments.single as Workout);
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: MockServices.container,
        child: WidgetTestApp(child: WorkoutVisibilityMenu(workout: workout)),
      ),
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visibility'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Only me'));
    await tester.pump();
    expect(saved, isEmpty);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved.single.visibility, 'private');
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visibility'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(saved, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'comment composer is a bottom sheet with validation and keyboard insets',
    (tester) async {
      String? submitted;
      await tester.pumpWidget(
        WidgetTestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                submitted = await showCommentComposer(context);
              },
              child: const Text('Open composer'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open composer'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      FilledButton send() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Send'),
      );
      expect(send().onPressed, isNull);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(send().onPressed, isNull);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(find.byType(TextField), '  A new comment  ');
      await tester.pumpAndSettle();
      expect(send().onPressed, isNotNull);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(submitted, 'A new comment');
      expect(find.byType(BottomSheet), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

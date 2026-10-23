import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

ProviderContainer? pageContainer;

Widget testPage(ExercisesView child, {String? signedInUserId}) {
  final created = pageContainer == null;
  final container = pageContainer ??= ProviderContainer(
    overrides: [
      ...MockServices.defaultOverrides,
      currentUserIdProvider.overrideWithValue(signedInUserId),
      userIdentityProvider('other').overrideWith(
        (ref) async => Friend(id: 'other', username: 'Other user'),
      ),
      userAvatarProvider('other').overrideWith((ref) async => null),
    ],
  );
  if (created) addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: WidgetTestApp(child: child),
  );
}

void main() {
  setUp(() async {
    MockServices.setup();
    pageContainer = null;
    await initTestLocalizations();

    // Register fallback value for Workout
    registerFallbackValue(Workout(name: '', exercises: []));

    // Stub hasContinuation
    when(
      () => MockServices.historyController.hasContinuation(
        incompleteWorkout: any(named: 'incompleteWorkout'),
      ),
    ).thenReturn(false);

    // Stub ExercisesController exercises
    when(
      () => MockServices.exercisesController.exercises,
    ).thenReturn(<Exercise>[]);
  });

  tearDown(() {
    MockServices.tearDown();
  });

  testWidgets('ExercisesView canStart disabling logic', (
    WidgetTester tester,
  ) async {
    final customEx = Exercise.custom(
      id: 'custom_1',
      name: 'Custom Pushup',
      parameters: GTSetParameters.repsWeight,
      primaryMuscleGroup: GTMuscleGroup.chest,
      secondaryMuscleGroups: {},
      sets: [],
      restTime: Duration.zero,
      notes: '',
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.none,
    );

    final workout = Workout(
      id: 'workout_1',
      name: 'Test Workout',
      exercises: [customEx],
      duration: const Duration(hours: 1),
      startingDate: DateTime.now(),
    );

    // 1. By default, with no matching local custom exercise, starting should be disabled.
    await tester.pumpWidget(
      testPage(ExercisesView(workout: workout, isOwned: false)),
    );
    await tester.pumpAndSettle();

    // Find the filled button (which contains text 'Redo this workout' or starting routines/workouts)
    final redoButtonFinder = find.byType(FilledButton);
    expect(redoButtonFinder, findsOneWidget);

    FilledButton redoButton = tester.widget<FilledButton>(redoButtonFinder);
    expect(
      redoButton.onPressed,
      isNull,
    ); // Disabled because customEx is unmatched!

    // 2. Now matching the custom exercise locally
    when(
      () => MockServices.exercisesController.exercises,
    ).thenReturn(<Exercise>[customEx]);

    await tester.pumpWidget(
      testPage(ExercisesView(workout: workout, isOwned: false)),
    );
    await tester.pumpAndSettle();

    redoButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(redoButton.onPressed, isNotNull); // Enabled now!

    // 3. Setting canStart = false explicitly should disable it even if exercises match
    await tester.pumpWidget(
      testPage(ExercisesView(workout: workout, canStart: false)),
    );
    await tester.pumpAndSettle();

    redoButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(redoButton.onPressed, isNull); // Disabled because canStart is false!
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  for (final signedIn in [false, true]) {
    testWidgets('workout visibility menu requires login ($signedIn)', (
      tester,
    ) async {
      final workout = Workout(
        name: 'Workout',
        exercises: [],
        duration: const Duration(minutes: 30),
        startingDate: DateTime.utc(2026, 10, 23),
      );
      await tester.pumpWidget(
        testPage(
          ExercisesView(workout: workout),
          signedInUserId: signedIn ? 'owner' : null,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('workout-visibility')),
        signedIn ? findsOneWidget : findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final scenario in [
    (
      name: 'remote other author',
      signedIn: 'owner',
      author: 'other',
      owned: false,
      visible: true,
    ),
    (
      name: 'remote current author',
      signedIn: 'owner',
      author: 'owner',
      owned: false,
      visible: false,
    ),
    (
      name: 'local workout',
      signedIn: 'owner',
      author: 'other',
      owned: true,
      visible: false,
    ),
    (
      name: 'unknown author',
      signedIn: 'owner',
      author: null,
      owned: false,
      visible: false,
    ),
    (
      name: 'signed out',
      signedIn: null,
      author: 'other',
      owned: false,
      visible: false,
    ),
  ]) {
    testWidgets('author card: ${scenario.name}', (tester) async {
      final workout = Workout(
        name: 'Workout',
        exercises: [],
        duration: const Duration(minutes: 30),
        startingDate: DateTime.utc(2026, 10, 23),
      );
      await tester.pumpWidget(
        testPage(
          ExercisesView(
            workout: workout,
            authorId: scenario.author,
            isOwned: scenario.owned,
          ),
          signedInUserId: scenario.signedIn,
        ),
      );
      await tester.pumpAndSettle();
      final card = find.byKey(const Key('workout-author-card'));
      expect(card, scenario.visible ? findsOneWidget : findsNothing);
      if (scenario.visible) {
        expect(
          find.descendant(of: card, matching: find.byType(UserAccountIcon)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: card, matching: find.text('Other user')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<ListTile>(
                find.descendant(of: card, matching: find.byType(ListTile)),
              )
              .onTap,
          isNotNull,
        );
        await tester.tap(find.byKey(const Key('menu')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('workout-visibility')), findsNothing);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

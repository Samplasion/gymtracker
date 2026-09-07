import 'package:easy_debounce/easy_debounce.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockHistoryController mockHistoryController;
  late MockRoutinesController mockRoutinesController;
  late Coordinator coordinator;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    mockDatabaseService = MockDatabaseService();
    mockHistoryController = MockHistoryController();
    mockRoutinesController = MockRoutinesController();

    when(() => mockDatabaseService.createBackup()).thenAnswer((_) async {});
    when(() => mockHistoryController.history).thenReturn(RxList<Workout>([]));
    when(() => mockRoutinesController.workouts).thenReturn(RxList<Workout>([]));

    Get.put<DatabaseService>(mockDatabaseService);
    Get.put<HistoryController>(mockHistoryController);
    Get.put<RoutinesController>(mockRoutinesController);

    coordinator = Coordinator();
  });

  tearDown(() {
    EasyDebounce.cancel('scheduleBackup');
    Get.reset();
  });

  group('Coordinator - scheduleBackup debounce', () {
    test('debounces multiple calls within one minute to a single backup', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 20));
        verifyNever(() => mockDatabaseService.createBackup());

        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 20));
        verifyNever(() => mockDatabaseService.createBackup());

        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 59));
        verifyNever(() => mockDatabaseService.createBackup());

        async.elapse(const Duration(seconds: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);
      });
    });

    test('creates at most one backup in a one-minute span', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        async.elapse(const Duration(minutes: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);

        coordinator.scheduleBackup();
        async.elapse(const Duration(minutes: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);
      });
    });

    test('cancels scheduled backup with EasyDebounce.cancel', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        EasyDebounce.cancel('scheduleBackup');
        async.elapse(const Duration(minutes: 2));
        verifyNever(() => mockDatabaseService.createBackup());
      });
    });
  });

  group('Coordinator.computeSuggestions - Half-life decay for suggested routines', () {
    final referenceDate = DateTime(2026, 9, 7, 12, 0);

    test(
      'workout at reference time has score exactly 1.0 (decay factor 2^0)',
      () {
        final routine = Workout(
          id: 'routine-1',
          name: 'Chest Day',
          exercises: [],
        );
        final workout = Workout(
          id: 'w-1',
          parentID: 'routine-1',
          name: 'Chest Session',
          exercises: [],
          startingDate: referenceDate,
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        expect(coordinator.suggestions.first.routine.id, 'routine-1');
        expect(coordinator.suggestions.first.score, closeTo(1.0, 1e-5));
      },
    );

    test(
      'workout exactly 1 half-life (28 days) ago on matching weekday has score 0.5 (2^-1)',
      () {
        final routine = Workout(
          id: 'routine-1',
          name: 'Back Day',
          exercises: [],
        );
        final workout = Workout(
          id: 'w-1',
          parentID: 'routine-1',
          name: 'Back Session',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 28)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        expect(coordinator.suggestions.first.score, closeTo(0.5, 1e-5));
      },
    );

    test(
      'workout exactly 2 half-lives (56 days) ago on matching weekday has score 0.25 (2^-2)',
      () {
        final routine = Workout(
          id: 'routine-1',
          name: 'Leg Day',
          exercises: [],
        );
        final workout = Workout(
          id: 'w-1',
          parentID: 'routine-1',
          name: 'Leg Session',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 56)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        expect(coordinator.suggestions.first.score, closeTo(0.25, 1e-5));
      },
    );

    test(
      'workout exactly 3 half-lives (84 days) ago on matching weekday has score 0.125 (2^-3)',
      () {
        final routine = Workout(
          id: 'routine-1',
          name: 'Arm Day',
          exercises: [],
        );
        final workout = Workout(
          id: 'w-1',
          parentID: 'routine-1',
          name: 'Arm Session',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 84)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        expect(coordinator.suggestions.first.score, closeTo(0.125, 1e-5));
      },
    );

    test(
      'fractional half-life (14 days = 0.5 half-lives) has score 2^-0.5 (~0.7071)',
      () {
        final routine = Workout(id: 'routine-1', name: 'Cardio', exercises: []);
        final workout = Workout(
          id: 'w-1',
          parentID: 'routine-1',
          name: 'Cardio Session',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 14)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        // 2^(-14/28) = 2^(-0.5) = 1/sqrt(2) ≈ 0.70710678
        expect(coordinator.suggestions.first.score, closeTo(0.707106, 1e-4));
      },
    );

    test('respects custom half-life parameter', () {
      final routine = Workout(
        id: 'routine-1',
        name: 'Shoulders',
        exercises: [],
      );
      final workout = Workout(
        id: 'w-1',
        parentID: 'routine-1',
        name: 'Shoulder Session',
        exercises: [],
        startingDate: referenceDate.subtract(const Duration(days: 14)),
      );

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([routine]));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>([workout]));

      // With halfLifeDays = 14, 14 days ago is exactly 1 half-life => 0.5
      coordinator.computeSuggestions(now: referenceDate, halfLifeDays: 14.0);

      expect(coordinator.suggestions.length, 1);
      expect(coordinator.suggestions.first.score, closeTo(0.5, 1e-5));
    });

    test(
      'workout on matching weekday receives 1.0 multiplier, non-matching weekday receives 0.2 multiplier',
      () {
        final routineMatch = Workout(
          id: 'routine-match',
          name: 'Monday Routine',
          exercises: [],
        );
        final routineOther = Workout(
          id: 'routine-other',
          name: 'Sunday Routine',
          exercises: [],
        );

        // referenceDate is Monday (Sep 7, 2026).
        // workoutMatch: 7 days ago, Sep 7 - 7 = Aug 31 (Monday, same weekday)
        final workoutMatch = Workout(
          id: 'w-match',
          parentID: 'routine-match',
          name: 'Monday Workout',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 7)),
        );

        // workoutOther: 8 days ago, Sep 7 - 8 = Aug 30 (Sunday, different weekday)
        final workoutOther = Workout(
          id: 'w-other',
          parentID: 'routine-other',
          name: 'Sunday Workout',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 8)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routineMatch, routineOther]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([workoutMatch, workoutOther]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 2);

        // Routine on matching weekday has weight 1.0 * 2^(-7/28) ≈ 0.840896
        final matchSuggestion = coordinator.suggestions.firstWhere(
          (s) => s.routine.id == 'routine-match',
        );
        expect(matchSuggestion.score, closeTo(1.0 * 0.840896, 1e-4));

        // Routine on other weekday has weight 0.2 * 2^(-8/28) ≈ 0.2 * 0.820335 = 0.164067
        final otherSuggestion = coordinator.suggestions.firstWhere(
          (s) => s.routine.id == 'routine-other',
        );
        expect(otherSuggestion.score, closeTo(0.2 * 0.820335, 1e-4));
      },
    );

    test(
      'multiple workouts for the same routine accumulate scores additively',
      () {
        final routine = Workout(id: 'routine-1', name: 'Push', exercises: []);
        // 3 workouts: today (score 1.0), 28 days ago (score 0.5), 56 days ago (score 0.25)
        final workouts = [
          Workout(
            id: 'w-0',
            parentID: 'routine-1',
            name: 'Push 0',
            exercises: [],
            startingDate: referenceDate,
          ),
          Workout(
            id: 'w-28',
            parentID: 'routine-1',
            name: 'Push 28',
            exercises: [],
            startingDate: referenceDate.subtract(const Duration(days: 28)),
          ),
          Workout(
            id: 'w-56',
            parentID: 'routine-1',
            name: 'Push 56',
            exercises: [],
            startingDate: referenceDate.subtract(const Duration(days: 56)),
          ),
        ];

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>(workouts));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        // Total score = 1.0 + 0.5 + 0.25 = 1.75
        expect(coordinator.suggestions.first.score, closeTo(1.75, 1e-5));
      },
    );

    test('recent routine is scored higher than old routine with many uses', () {
      final oldRoutine = Workout(
        id: 'routine-old',
        name: 'Old Program',
        exercises: [],
      );
      final activeRoutine = Workout(
        id: 'routine-active',
        name: 'Active Program',
        exercises: [],
      );

      // Old routine: 50 sessions performed 1 year ago (365 days ago on various days)
      // plus 1 session performed 7 days ago
      final oldWorkouts = <Workout>[
        for (int i = 0; i < 50; i++)
          Workout(
            id: 'old-$i',
            parentID: 'routine-old',
            name: 'Old Workout $i',
            exercises: [],
            startingDate: referenceDate.subtract(Duration(days: 365 + (i * 7))),
          ),
        Workout(
          id: 'old-recent',
          parentID: 'routine-old',
          name: 'Old Workout Recent',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 7)),
        ),
      ];

      // Active routine: 4 sessions in the past 4 weeks (7, 14, 21, 28 days ago)
      final activeWorkouts = <Workout>[
        Workout(
          id: 'act-7',
          parentID: 'routine-active',
          name: 'Active 7',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 7)),
        ),
        Workout(
          id: 'act-14',
          parentID: 'routine-active',
          name: 'Active 14',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 14)),
        ),
        Workout(
          id: 'act-21',
          parentID: 'routine-active',
          name: 'Active 21',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 21)),
        ),
        Workout(
          id: 'act-28',
          parentID: 'routine-active',
          name: 'Active 28',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 28)),
        ),
      ];

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([oldRoutine, activeRoutine]));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>([...oldWorkouts, ...activeWorkouts]));

      coordinator.computeSuggestions(now: referenceDate);

      expect(coordinator.suggestions.length, 2);

      // Active routine must be ranked #1
      expect(coordinator.suggestions[0].routine.id, 'routine-active');
      expect(coordinator.suggestions[1].routine.id, 'routine-old');

      // Active routine score (~2.64) is substantially higher than old routine (~0.85)
      expect(coordinator.suggestions[0].score, greaterThan(2.5));
      expect(coordinator.suggestions[1].score, lessThan(1.0));
    });

    test(
      'stale routine with 100 workouts years ago decays to near zero and ranks below single recent workout',
      () {
        final ancientRoutine = Workout(
          id: 'routine-ancient',
          name: 'Ancient Routine',
          exercises: [],
        );
        final freshRoutine = Workout(
          id: 'routine-fresh',
          name: 'Fresh Routine',
          exercises: [],
        );

        // 100 sessions 2 years (730 days) ago
        final ancientWorkouts = <Workout>[
          for (int i = 0; i < 100; i++)
            Workout(
              id: 'anc-$i',
              parentID: 'routine-ancient',
              name: 'Ancient $i',
              exercises: [],
              startingDate: referenceDate.subtract(Duration(days: 730 + i)),
            ),
        ];

        // Just 1 session 2 days ago
        final freshWorkouts = <Workout>[
          Workout(
            id: 'fresh-1',
            parentID: 'routine-fresh',
            name: 'Fresh 1',
            exercises: [],
            startingDate: referenceDate.subtract(const Duration(days: 2)),
          ),
        ];

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([ancientRoutine, freshRoutine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([...ancientWorkouts, ...freshWorkouts]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.first.routine.id, 'routine-fresh');
        expect(coordinator.suggestions.first.score, greaterThan(0.1));
      },
    );
  });

  group('Coordinator.computeSuggestions - (edge cases)', () {
    final referenceDate = DateTime(2026, 9, 7, 12, 0);

    test('returns empty suggestions when history or routines are empty', () {
      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([]));
      when(() => mockHistoryController.history).thenReturn(RxList<Workout>([]));

      coordinator.computeSuggestions(now: referenceDate);
      expect(coordinator.suggestions, isEmpty);
    });

    test('ignores routines with no matching history', () {
      final routine = Workout(
        id: 'unused-routine',
        name: 'Never Done',
        exercises: [],
      );
      final otherWorkout = Workout(
        id: 'w-other',
        parentID: 'different-routine',
        name: 'Other',
        exercises: [],
        startingDate: referenceDate,
      );

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([routine]));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>([otherWorkout]));

      coordinator.computeSuggestions(now: referenceDate);
      expect(coordinator.suggestions, isEmpty);
    });

    test('safely handles workouts with null startingDate', () {
      final routine = Workout(
        id: 'routine-1',
        name: 'Safe Routine',
        exercises: [],
      );
      final workoutNullDate = Workout(
        id: 'w-null',
        parentID: 'routine-1',
        name: 'Corrupt Date',
        exercises: [],
        startingDate: null,
      );
      final workoutValidDate = Workout(
        id: 'w-valid',
        parentID: 'routine-1',
        name: 'Valid Date',
        exercises: [],
        startingDate: referenceDate,
      );

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([routine]));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>([workoutNullDate, workoutValidDate]));

      expect(
        () => coordinator.computeSuggestions(now: referenceDate),
        returnsNormally,
      );
      expect(coordinator.suggestions.length, 1);
      expect(coordinator.suggestions.first.score, closeTo(1.0, 1e-5));
    });

    test(
      'clamps future workout dates to 0 days elapsed (decay factor 1.0)',
      () {
        final routine = Workout(
          id: 'routine-1',
          name: 'Clock Skew',
          exercises: [],
        );
        // Workout with startingDate in the future
        final futureWorkout = Workout(
          id: 'w-future',
          parentID: 'routine-1',
          name: 'Future',
          exercises: [],
          startingDate: referenceDate.add(const Duration(days: 5)),
        );

        when(
          () => mockRoutinesController.workouts,
        ).thenReturn(RxList<Workout>([routine]));
        when(
          () => mockHistoryController.history,
        ).thenReturn(RxList<Workout>([futureWorkout]));

        coordinator.computeSuggestions(now: referenceDate);

        expect(coordinator.suggestions.length, 1);
        // Clamped to daysAgo = 0 => decay = 1.0
        expect(coordinator.suggestions.first.score, greaterThan(0.0));
        expect(coordinator.suggestions.first.score, lessThanOrEqualTo(1.0));
      },
    );

    test('sorts suggestions strictly descending by score', () {
      final routines = [
        Workout(id: 'r-low', name: 'Low Score', exercises: []),
        Workout(id: 'r-mid', name: 'Mid Score', exercises: []),
        Workout(id: 'r-high', name: 'High Score', exercises: []),
      ];

      final workouts = [
        // Low: 84 days ago
        Workout(
          id: 'w-low',
          parentID: 'r-low',
          name: 'Low',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 84)),
        ),
        // Mid: 28 days ago
        Workout(
          id: 'w-mid',
          parentID: 'r-mid',
          name: 'Mid',
          exercises: [],
          startingDate: referenceDate.subtract(const Duration(days: 28)),
        ),
        // High: 0 days ago
        Workout(
          id: 'w-high',
          parentID: 'r-high',
          name: 'High',
          exercises: [],
          startingDate: referenceDate,
        ),
      ];

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>(routines));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>(workouts));

      coordinator.computeSuggestions(now: referenceDate);

      expect(coordinator.suggestions.length, 3);
      expect(coordinator.suggestions[0].routine.id, 'r-high');
      expect(coordinator.suggestions[1].routine.id, 'r-mid');
      expect(coordinator.suggestions[2].routine.id, 'r-low');

      expect(
        coordinator.suggestions[0].score,
        greaterThan(coordinator.suggestions[1].score),
      );
      expect(
        coordinator.suggestions[1].score,
        greaterThan(coordinator.suggestions[2].score),
      );
    });

    test('limits suggestions to top 5 even when more candidates exist', () {
      final routines = [
        for (int i = 0; i < 8; i++)
          Workout(id: 'r-$i', name: 'Routine $i', exercises: []),
      ];

      final workouts = [
        for (int i = 0; i < 8; i++)
          Workout(
            id: 'w-$i',
            parentID: 'r-$i',
            name: 'Workout $i',
            exercises: [],
            startingDate: referenceDate.subtract(Duration(days: i * 7)),
          ),
      ];

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>(routines));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>(workouts));

      coordinator.computeSuggestions(now: referenceDate);

      expect(coordinator.suggestions.length, 5);
      // Verify top 5 are in descending order
      for (int i = 0; i < coordinator.suggestions.length - 1; i++) {
        expect(
          coordinator.suggestions[i].score,
          greaterThanOrEqualTo(coordinator.suggestions[i + 1].score),
        );
      }
    });

    test('suggestion record contains score of type double', () {
      final routine = Workout(
        id: 'routine-1',
        name: 'Type Test',
        exercises: [],
      );
      final workout = Workout(
        id: 'w-1',
        parentID: 'routine-1',
        name: 'Type Session',
        exercises: [],
        startingDate: referenceDate,
      );

      when(
        () => mockRoutinesController.workouts,
      ).thenReturn(RxList<Workout>([routine]));
      when(
        () => mockHistoryController.history,
      ).thenReturn(RxList<Workout>([workout]));

      coordinator.computeSuggestions(now: referenceDate);

      final suggestion = coordinator.suggestions.first;
      expect(suggestion.score, isA<double>());
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/health_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/food.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/hydration.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/router.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/provider/trainer.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/achievements.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/me/statistics.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/trainer.dart';
import 'package:gymtracker/view/utils/feed_items.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:relative_time/relative_time.dart';

import '../test/test_helpers/mock_services.dart';
import 'screenshots/fixtures.dart';

class _Online extends Online {
  @override
  OnlineAccount? build() =>
      OnlineAccount(id: 'demo-user', name: 'Andrea', fullName: 'Andrea Rossi');
}

class _Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

class _OnlineService extends Mock implements OnlineService {}

class _FixedClock extends WorkoutClock {
  _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
  @override
  Timer once(Duration duration, void Function() callback) =>
      Timer(const Duration(days: 1), callback);
}

class _Trainer extends Mock implements TrainerService {}

class _Feed extends Feed {
  _Feed(this.items);
  final List<FeedItem> items;
  @override
  Future<List<FeedItem>> build() async => items;
  @override
  bool get hasMore => false;
  @override
  void setVisible(bool visible) {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> refreshIfStale() async {}
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  const companion = String.fromEnvironment(
    'SCREENSHOT_COMPANION',
    defaultValue: 'apple',
  );
  const watchSeries = bool.fromEnvironment('SCREENSHOT_WATCH_SERIES');
  const language = String.fromEnvironment(
    'SCREENSHOT_LOCALE',
    defaultValue: 'it',
  );
  const config = String.fromEnvironment('SCREENSHOT_MANIFEST');
  const only = String.fromEnvironment('SCREENSHOT_ONLY', defaultValue: 'all');
  const runID = String.fromEnvironment(
    'SCREENSHOT_RUN_ID',
    defaultValue: 'manual',
  );
  testWidgets(
    'App Store screenshots',
    (tester) => withClock(Clock.fixed(DateTime(2026, 11, 1, 9, 41)), () async {
      final manifest = jsonDecode(config) as Map<String, dynamic>;
      final fixtures = ScreenshotFixtures(
        language,
        DateTime.parse(manifest['reference_time']),
      );
      MockServices.setup();
      // The real adaptive drawer includes the version in its footer.
      await VersionService().init();
      registerFallbackValue(fixtures.exercises("fallback").first);
      final service = DatabaseService.withDatabase(MockServices.database);
      await service.ensureInitialized();
      final trainer = _Trainer();
      when(() => trainer.refreshAndSync(any())).thenAnswer((_) async {});
      await fixtures.seed(service);
      Intl.defaultLocale = language == 'it' ? 'it_IT' : 'en_US';
      await initializeDateFormatting(language == 'it' ? 'it_IT' : 'en_US');
      LocaleSettings.setLocaleSync(
        language == 'it' ? AppLocale.it : AppLocale.en,
      );
      when(
        () => MockServices.historyController.history,
      ).thenReturn(fixtures.history);
      when(
        () => MockServices.historyController.userVisibleWorkouts,
      ).thenReturn(fixtures.history);
      when(() => MockServices.historyController.getHistoryOf(any())).thenAnswer(
        (invocation) {
          final target = invocation.positionalArguments.single as Exercise;
          return [
            for (final workout in fixtures.history.reversed)
              for (final (index, exercise)
                  in workout.exercises.cast<Exercise>().indexed)
                if (exercise.parentID == target.parentID)
                  (exercise, index, workout),
          ];
        },
      );
      when(() => MockServices.exercisesController.exercises).thenReturn(
        fixtures.routines.expand((r) => r.exercises.cast<Exercise>()).toList(),
      );
      when(
        () => MockServices.routinesController.workouts,
      ).thenReturn(fixtures.routines);
      when(
        () => MockServices.routinesController.rootRoutines,
      ).thenReturn(fixtures.routines.where((r) => r.folder == null).toList());
      when(() => MockServices.routinesController.folders).thenReturn({
        for (final folder in fixtures.folders)
          folder: fixtures.routines.where((r) => r.folder == folder).toList(),
      });
      when(() => MockServices.routinesController.suggestions).thenReturn([]);
      final events = EventBus();
      final achievements = AchievementsController(
        _OnlineService(),
        service: service,
        events: events,
        isSyncing: () => false,
        unlocksEnabled: () => false,
      );
      final container = ProviderContainer(
        overrides: [
          showDeveloperNavigationProvider.overrideWithValue(false),
          healthEnergyProvider.overrideWith((ref) => Stream.value(164.0)),
          healthHeartRateProvider.overrideWith((ref) => Stream.value(132.0)),
          healthPermissionProvider.overrideWith((ref) => Stream.value(true)),
          hydrationPageVisitProvider.overrideWith((ref) async => false),
          waterEntriesProvider.overrideWith(
            (ref) => Stream.value([
              WaterEntry(
                id: 'demo-water-1',
                milliliters: 500,
                time: fixtures.now.subtract(const Duration(hours: 1)),
              ),
              WaterEntry(
                id: 'demo-water-2',
                milliliters: 750,
                time: fixtures.now.subtract(const Duration(minutes: 30)),
              ),
            ]),
          ),
          databaseServiceProvider.overrideWithValue(service),
          appDatabaseProvider.overrideWithValue(MockServices.database),
          platformLocaleProvider.overrideWithValue(Locale(language)),
          trainingClockProvider.overrideWithValue(() => fixtures.now),
          workoutClockProvider.overrideWithValue(_FixedClock(fixtures.now)),
          onlineProvider.overrideWith(_Online.new),
          networkConnectivityProvider.overrideWith(_Connectivity.new),
          backupSchedulerProvider.overrideWithValue(
            MockServices.backupScheduler,
          ),
          notificationControllerProvider.overrideWithValue(
            MockServices.notifications,
          ),
          historyControllerProvider.overrideWithValue(
            MockServices.historyController,
          ),
          routinesControllerProvider.overrideWithValue(
            MockServices.routinesController,
          ),
          exercisesControllerProvider.overrideWithValue(
            MockServices.exercisesController,
          ),
          purchasesControllerProvider.overrideWithValue(
            MockServices.purchasesController,
          ),
          subscriptionInfoProvider.overrideWith(
            (ref) => Stream.value(
              const SubscriptionInfo(
                isPro: true,
                isTrial: false,
                isForcedPro: false,
                isAboutToExpire: false,
                userID: 'demo-user',
              ),
            ),
          ),
          achievementsControllerProvider.overrideWithValue(achievements),
          achievementTriggerProvider.overrideWithValue((_) {}),
          trainerServiceProvider.overrideWithValue(trainer),
          trainerStateProvider.overrideWith(
            (ref) => Stream.value(fixtures.trainer),
          ),
          feedProvider.overrideWith(
            () => _Feed([
              FeedItemWorkout(
                workout: fixtures.history.last,
                authorship: FeedAuthorshipOwn(userID: 'demo-user'),
              ),
              for (var i = 0; i < 4; i++)
                FeedItemWorkout(
                  workout: fixtures.history[34 - i].copyWith(
                    id: 'demo-friend-workout-$i',
                    startingDate: fixtures.now.subtract(Duration(hours: 2 + i)),
                  ),
                  authorship: FeedAuthorshipFriend(userID: 'demo-friend-$i'),
                ),
            ]),
          ),
          notificationSummaryProvider.overrideWith(
            (ref) async => {'unread': 0, 'through_id': 0},
          ),
          socialNotificationsProvider.overrideWith((ref) => Stream.value([])),
          sourceSocialProvider.overrideWith(
            (ref, source) async => {
              'post': {'id': 'demo-post', 'active': true},
              'likes': 12,
              'comments': 3,
              'liked': true,
            },
          ),
          userIdentityProvider.overrideWith(
            (ref, id) async => Friend(
              id: id,
              username: id == 'demo-user'
                  ? 'andrea'
                  : ['sofia', 'luca', 'emma', 'marco'][int.parse(
                      id.split('-').last,
                    )],
              fullName: id == 'demo-user'
                  ? 'Andrea Rossi'
                  : [
                      'Sofia Bianchi',
                      'Luca Moretti',
                      'Emma Ricci',
                      'Marco Conti',
                    ][int.parse(id.split('-').last)],
            ),
          ),
          userAvatarProvider.overrideWith((ref, id) async => null),
          foodRelativeDayTextProvider.overrideWith(
            (ref, context) => language == 'it' ? 'Oggi' : 'Today',
          ),
        ],
      );
      final keep = [
        container.listen(foodSelectedDateProvider, (_, _) {}),
        container.listen(routinesStreamProvider, (_, _) {}),
        container.listen(foldersStreamProvider, (_, _) {}),
        container.listen(historyWorkoutsProvider, (_, _) {}),
        container.listen(appPreferencesProvider, (_, _) {}),
      ];
      await Future.wait([
        container.read(routinesStreamProvider.future),
        container.read(foldersStreamProvider.future),
        container.read(historyWorkoutsProvider.future),
        container.read(appPreferencesProvider.future),
      ]);
      final foods = await service.foods$.stream.firstWhere(
        (rows) => rows.length == 56,
      );
      final completions = fixtures.completions(foods);
      await service.setAchievementCompletions(completions);
      await service.db.watchAchievementCompletions().firstWhere(
        (rows) => rows.length == completions.length,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        for (final sub in keep) {
          sub.close();
        }
        container.dispose();
        achievements.dispose();
        events.dispose();
        service.dispose();
        MockServices.tearDown();
      });
      final shots = (manifest['screenshots'] as List)
          .cast<Map<String, dynamic>>()
          .where((s) => only == 'all' || only.split(',').contains(s['id']));
      for (final shot in shots) {
        final id = shot['id'] as String;
        final color = Color(
          int.parse(
            (shot['color'] as String).replaceFirst('#', 'FF'),
            radix: 16,
          ),
        );
        await service.writeSettings(
          Prefs.defaultValue.copyWith(
            color: color,
            locale: Locale(language),
            usesDynamicColor: false,
            themeMode: ThemeMode.dark,
            tintExercises: false,
            onboardingComplete: true,
            anonymizedLogging: false,
          ),
        );
        await service.db.watchPreferences().firstWhere((p) => p.color == color);
        // Each capture starts with its own workout state; otherwise the shell
        // would show an ongoing-workout bar left over from screenshot 01.
        if (container.read(workoutControllerProvider) != null) {
          await container
              .read(workoutControllerProvider.notifier)
              .cancel(publishWearableTerminal: false);
        }
        if (id == '01' || id == '09') {
          final controller = container.read(workoutControllerProvider.notifier);
          controller.start(
            fixtures.routines.first.name,
            fixtures.routines.first.id,
            null,
            saveInitial: false,
            notifyNative: false,
            restoredStart: fixtures.now.subtract(const Duration(minutes: 24)),
          );
          controller.exercises.addAll(fixtures.exercises('ongoing'));
          controller.publishExercises();
          container
              .read(countdownControllerProvider.notifier)
              .restoreCountdown(
                fixtures.now,
                // CountdownController includes the final displayed second.
                fixtures.now.add(
                  Duration(
                    seconds:
                        (manifest['workout_fixture']['rest_seconds'] as int) -
                        1,
                  ),
                ),
              );
          expect(
            container.read(countdownControllerProvider.notifier).remaining,
            Duration(
              seconds: manifest['workout_fixture']['rest_seconds'] as int,
            ),
          );
          container
              .read(stopwatchControllerProvider.notifier)
              .globalStopwatch
              .pause();
        }
        container.read(foodSelectedDateProvider.notifier).setDate(fixtures.now);
        final Widget page = switch (id) {
          '01' || '09' => const WorkoutView(),
          '02' => const RoutinesView(),
          '03' => const MeStatisticsPage(),
          '04' => const FoodView(),
          '05' => const WeightMeasurementDataPage(),
          '06' => const AchievementsView(),
          '07' => const FeedView(),
          '08' => const TrainerView(),
          _ => throw StateError('Unknown screenshot $id'),
        };
        final section = switch (id) {
          '02' || '01' || '09' => '/routines',
          '04' => '/food',
          '07' => '/feed',
          _ => '/profile',
        };
        // Reuse the production router and ShellRoute, including its adaptive
        // navigation. Bypass only startup, which must not contact real services.
        final router = container.read(appRouterProvider);
        router.go(section);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TranslationProvider(
              child: Builder(
                builder: (context) {
                  final settings = container.read(settingsControllerProvider);
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    key: ValueKey(id),
                    routerConfig: router,
                    locale: Locale(language),
                    supportedLocales: AppLocaleUtils.supportedLocales,
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      FlutterQuillLocalizations.delegate,
                      RelativeTimeLocalizations.delegate,
                    ],
                    theme: getGymTrackerThemeFor(
                      context,
                      settings.color,
                      Brightness.dark,
                    ),
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling),
                      child: GTExpressiveTheme(child: child!),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 25),
        );
        final isSection = {'02', '04', '07'}.contains(id);
        expect(find.byType(SkeletonView), findsOneWidget);
        expect(find.text('Debug').hitTestable(), findsNothing);
        expect(find.text('Logs').hitTestable(), findsNothing);
        if (isSection) {
          final context = tester.element(find.byType(SkeletonView));
          if (SkeletonView.isTwoPane(context)) {
            expect(find.byType(NavigationDrawer).hitTestable(), findsOneWidget);
          } else {
            expect(find.byType(NavigationBar).hitTestable(), findsOneWidget);
          }
        } else {
          // These views are full-screen routes in the real app. Keep their
          // back stack instead of artificially adding navigation around them.
          if (id == '01' || id == '09') {
            unawaited(Go.toNamed(WorkoutView.routeName));
          } else {
            unawaited(Go.to(() => page));
          }
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 25),
          );
        }
        if (id == '01' || id == '09') {
          expect(find.text(t.ongoingWorkout.title), findsOneWidget);
        }
        if (id == '04') {
          expect(container.read(foodsForSelectedDateProvider), hasLength(4));
          await tester.drag(
            find.byType(CustomScrollView).first,
            const Offset(0, -200),
          );
          await tester.pumpAndSettle();
        }
        if (id == '07') {
          await tester.scrollUntilVisible(
            find.byType(FeedItemWorkoutCard).first,
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(find.byType(FeedItemWorkoutCard).first);
          await tester.pumpAndSettle();
        }
        FocusManager.instance.primaryFocus?.unfocus();
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(page.runtimeType), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(find.byType(GBLoadingIndicator), findsNothing);
        if (id == '09' && companion == 'apple') {
          final host = GymBroNativeHostAPI();
          await host.startWorkout(
            'screenshot-$runID',
            fixtures.now
                .subtract(const Duration(minutes: 24))
                .millisecondsSinceEpoch,
          );
          final watchParameters = <String?, Object?>{
            'workoutId': 'screenshot-$runID',
            'hasExercise': true,
            'exerciseName': fixtures.exercises('watch').first.name,
            'exerciseColor': color.toARGB32(),
            'exerciseParameters': '8 × 72.5 kg',
            'setTypeLabel': '',
            'startingTime': fixtures.now
                .subtract(const Duration(minutes: 24))
                .millisecondsSinceEpoch,
            'percentageDone': 0.33,
            if (watchSeries) 'exerciseID': 'demo-watch-bench',
            if (watchSeries)
              'set': fixtures.exercises('watch').first.sets.first.toJson(),
            if (watchSeries)
              'exerciseNotes': fixtures.tr(
                'Discesa controllata.\nPausa di un secondo sul petto.',
                'Lower with control.\nPause for one second at the chest.',
              ),
          };
          final catalog = <String, dynamic>{
            'version': 1,
            'ownerScope': 'screenshot-$runID',
            'routines': [
              for (final routine in fixtures.routines) routine.toJson(),
            ],
            'folders': [for (final folder in fixtures.folders) folder.toJson()],
          };
          final dailyNutrition = foods
              .where(
                (row) =>
                    row.date.year == fixtures.now.year &&
                    row.date.month == fixtures.now.month &&
                    row.date.day == fixtures.now.day,
              )
              .map((row) => row.value.nutritionalValues)
              .reduce((a, b) => a + b);
          final foodParameters = <String?, Object?>{
            'referenceDay': DateFormat('yyyy-MM-dd').format(fixtures.now),
            'generatedAt': fixtures.now.millisecondsSinceEpoch,
            'calorieGoal': 2400.0,
            'calorieIntake': dailyNutrition.calories,
            'waterIntake': 1250.0,
            'waterGoal': 2500.0,
            'waterOwnerScope': 'screenshot-$runID',
            'waterEntryIds': <String>[],
            'categories': <Object>[],
            'totalNutritionSplit': {
              'protein': dailyNutrition.protein,
              'proteinGoal': 150.0,
              'carbs': dailyNutrition.carbs,
              'carbsGoal': 270.0,
              'fats': dailyNutrition.fat,
              'fatsGoal': 80.0,
            },
          };
          Future<void> publishWatchData() async {
            if (watchSeries) {
              await const MethodChannel(
                'gymbro/training',
              ).invokeMethod<Object?>('exchange', {
                'ownerScope': 'screenshot-$runID',
                'catalog': jsonDecode(jsonEncode(catalog)),
              });
              await host.updateFoodParameters(foodParameters);
            }
            await host.setExerciseParameters(watchParameters);
          }

          await publishWatchData();
          final dir = Directory(
            '${(await getApplicationDocumentsDirectory()).path}/screenshots-$runID',
          );
          await dir.create(recursive: true);
          await File('${dir.path}/ready').writeAsString('ready');
          final deadline = DateTime.now().add(
            Duration(seconds: watchSeries ? 360 : 120),
          );
          while (!await File('${dir.path}/watch-captured').exists()) {
            if (DateTime.now().isAfter(deadline)) {
              fail('Watch capture timed out');
            }
            // WCSession may still be discovering the freshly installed companion.
            // Republish the same state until the runner confirms this run's receipt.
            await publishWatchData();
            await Future<void>.delayed(const Duration(seconds: 1));
          }
        }
        if (Platform.isAndroid && id == shots.first['id']) {
          await binding.convertFlutterSurfaceToImage();
          await tester.pumpAndSettle();
        }
        // UIKit's capture waits for a native display update. Let that frame run
        // while keeping all visible clocks and fixture values fixed.
        binding.framePolicy =
            LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
        try {
          await binding.takeScreenshot('$id-${shot['name']}');
        } finally {
          binding.framePolicy =
              LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
        }
        debugPrint('SCREENSHOT_CAPTURED $language/$id');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    }),
    timeout: const Timeout(Duration(minutes: 12)),
    skip: Platform.isMacOS,
  );
}

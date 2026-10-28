import 'dart:async';

import 'package:collection/collection.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

part 'achievements_controller.g.dart';

class AchievementsController {
  final OnlineService _onlineService;
  final DatabaseService service;
  final EventBus events;
  final bool Function() isSyncing;
  bool _disposed = false;
  final List<Timer> _timers = [];
  final Map<String, AchievementCompletion> _pendingCompletions = {};
  final _unlocked =
      StreamController<
        Map<Achievement, List<AchievementCompletion>>
      >.broadcast();
  Stream<Map<Achievement, List<AchievementCompletion>>> get unlocked =>
      _unlocked.stream;

  bool get _disableUnlocks =>
      _disableUnlocksWillLogin || _disableUnlocksDidLogin;

  bool _disableUnlocksWillLogin = false;
  bool _disableUnlocksDidLogin = false;

  StreamSubscription<GBUserWillLoginEvent>? _eventSubscriptionWillLogin;
  StreamSubscription<GBUserDidLoginEvent>? _eventSubscriptionDidLogin;

  final Map<String, Achievement> Function() _catalogResolver;
  Map<String, Achievement> get _catalog => _catalogResolver();
  final bool Function() _unlocksEnabled;
  final void Function(Map<Achievement, List<AchievementCompletion>>)? _present;

  AchievementsController(
    this._onlineService, {
    required this.service,
    required this.events,
    required this.isSyncing,
    Map<String, Achievement>? catalog,
    Map<String, Achievement> Function()? catalogResolver,
    bool Function()? unlocksEnabled,
    void Function(Map<Achievement, List<AchievementCompletion>>)? present,
  }) : _catalogResolver = catalogResolver ?? (() => catalog ?? achievements),
       _unlocksEnabled = unlocksEnabled ?? (() => !TestService().isTest),
       _present = present;

  void init() {
    final eventBus = events;
    if (_eventSubscriptionWillLogin != null || _disposed) return;
    _eventSubscriptionWillLogin = eventBus.on<GBUserWillLoginEvent>().listen((
      event,
    ) {
      _disableUnlocksWillLogin = true;

      logger.i("Disabling achievement unlocks due to user login");
      _timers.add(
        Timer(const Duration(seconds: 30), () {
          _disableUnlocksWillLogin = false;
          logger.i("Re-enabling achievement unlocks 30s after user login");
        }),
      );
    });
    _eventSubscriptionDidLogin = eventBus.on<GBUserDidLoginEvent>().listen((
      event,
    ) {
      _disableUnlocksDidLogin = true;

      logger.i("Disabling achievement unlocks due to user login");
      _timers.add(
        Timer(const Duration(seconds: 30), () {
          _disableUnlocksDidLogin = false;
          logger.i("Re-enabling achievement unlocks 30s after user login");
        }),
      );
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    _unlocked.close();
    _eventSubscriptionWillLogin?.cancel();
    _eventSubscriptionDidLogin?.cancel();
  }

  BehaviorSubject<List<AchievementCompletion>> get _completions$ =>
      service.completions$;

  Stream<List<AchievementCompletion>> get completionStream =>
      _completions$.stream.map(
        (completions) => completions.toList()
          ..sort((a, b) {
            final date = b.completedAt.compareTo(a.completedAt);
            final level = b.level.compareTo(a.level);
            return date == 0 ? level : date;
          }),
      );

  Map<Achievement, List<AchievementCompletion>> maybeUnlockAchievements(
    AchievementTrigger trigger,
  ) {
    if (_disposed || _disableUnlocks) return {};

    // Achievements slow tests down too much
    if (!_unlocksEnabled()) return {};

    logger.i("Checking for achievements to unlock for trigger: $trigger");

    final unlocked = <Achievement, List<AchievementCompletion>>{};

    for (final MapEntry(key: id, value: achievement) in _catalog.entries) {
      var completion = _getHighestLevelCompletionFor(achievement.id);
      AchievementLevel? nextLevel;

      bool isFirstTime = true;

      innerLoop:
      do {
        nextLevel = completion == null
            ? achievement.levels.first
            : achievement.nextLevel(completion);

        if (nextLevel == null) {
          break innerLoop;
        }

        if (nextLevel.trigger != trigger && isFirstTime) {
          break innerLoop;
        }

        final hasJustUnlocked = nextLevel.checkCompletion(
          nextLevel.progress?.call(),
        );

        logger.d((id, nextLevel.level, hasJustUnlocked));

        if (hasJustUnlocked) {
          unlocked.putIfAbsent(achievement, () => []);
          final c = AchievementCompletion(
            id: Uuid().v4(),
            achievementID: id,
            level: nextLevel.level,
            completedAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
            deleted: false,
            userId: _onlineService.account?.id,
          );
          unlocked[achievement]!.add(c);
          completion = c;
        } else {
          break innerLoop;
        }

        isFirstTime = false;
      } while (true);
    }

    _markUnlockAchievements(unlocked);
    if (_present case final present?) {
      present(unlocked);
    } else {
      _showUnlockAchievements(unlocked);
    }

    return unlocked;
  }

  void _markUnlockAchievements(
    Map<Achievement, List<AchievementCompletion>> unlocked,
  ) {
    final completions = unlocked.values.expand((e) => e).toList();
    if (completions.isEmpty) return;
    for (final completion in completions) {
      _pendingCompletions[completion.id] = completion;
    }
    unawaited(
      service.insertAchievementCompletions(completions).catchError((
        Object error,
        StackTrace stack,
      ) {
        for (final completion in completions) {
          _pendingCompletions.remove(completion.id);
        }
        logger.e(
          'Could not persist achievement completions',
          error: error,
          stackTrace: stack,
        );
      }),
    );
  }

  void _showUnlockAchievements(
    Map<Achievement, List<AchievementCompletion>> unlocked,
  ) {
    if (!isSyncing() && unlocked.isNotEmpty && !_disposed) {
      _unlocked.add(unlocked);
    }
  }

  AchievementCompletion? _getHighestLevelCompletionFor(String achievementID) {
    _pendingCompletions.removeWhere(
      (id, _) => _completions$.value.any((completion) => completion.id == id),
    );
    final completions = [
      ..._completions$.value,
      ..._pendingCompletions.values.where(
        (completion) => completion.userId == _onlineService.account?.id,
      ),
    ].where((completion) => completion.achievementID == achievementID).toList();
    if (completions.isEmpty) return null;
    completions.sort((a, b) => a.level.compareTo(b.level));
    return completions.last;
  }

  AchievementCompletion? getCompletion(
    Achievement achievement,
    AchievementLevel level,
  ) => _getCompletionInternal(achievement.id, level.level);

  bool isUnlocked(Achievement achievement, AchievementLevel level) =>
      getCompletion(achievement, level) != null;

  AchievementCompletion? _getCompletionInternal(
    String achievementID,
    int level,
  ) => _completions$.value.firstWhereOrNull(
    (completion) =>
        completion.achievementID == achievementID && completion.level == level,
  );

  Achievement getAchievement(String achievementID) {
    return _catalog[achievementID]!;
  }

  AchievementLevel? getLevel(Achievement achievement, int level) {
    return achievement.levels.firstWhereOrNull((l) => l.level == level);
  }
}

extension AchievementLevelDescription on Achievement {
  bool shouldShowDescriptionFor(int level, AchievementsController controller) {
    if (level == 1) return true;

    final completion = controller._getHighestLevelCompletionFor(id);
    return completion != null && completion.level + 1 >= level;
  }
}

@Riverpod(keepAlive: true)
Map<String, Achievement> achievementCatalog(Ref ref) {
  ref.watch(appPreferencesProvider);
  final settings = ref.watch(settingsControllerProvider);
  return AchievementRules(
    history: () => ref.read(historyControllerProvider).history,
    routines: () => ref.read(routinesControllerProvider).workouts,
    hasFolders: () => ref.read(routinesControllerProvider).folders.isNotEmpty,
    weights: () => ref.read(meControllerProvider).weightMeasurements,
    foods: () => ref.read(databaseServiceProvider).foods$.value,
    customExercises: () => ref.read(exercisesControllerProvider).exercises,
    distanceUnit: settings.distanceUnit,
    weightUnit: settings.weightUnit,
  ).catalog;
}

@Riverpod(keepAlive: true)
AchievementsController achievementsController(Ref ref) {
  final controller = AchievementsController(
    ref.read(onlineProvider.notifier).onlineService,
    service: ref.watch(databaseServiceProvider),
    events: ref.watch(eventBusProvider),
    isSyncing: () => ref.read(onlineProvider.notifier).isSyncing,
    catalogResolver: () => ref.read(achievementCatalogProvider),
  );
  controller.init();
  // Evaluate committed snapshots, after Riverpod has received the new data.
  // Ignore each stream's initial load so startup does not unlock old data.
  ref.listen(historyWorkoutsProvider, (previous, next) {
    if (previous?.hasValue == true && next.hasValue) {
      controller.maybeUnlockAchievements(AchievementTrigger.workout);
    }
  });
  ref.listen(routinesStreamProvider, (previous, next) {
    if (previous?.hasValue == true && next.hasValue) {
      controller.maybeUnlockAchievements(AchievementTrigger.routines);
    }
  });
  ref.listen(foldersStreamProvider, (previous, next) {
    if (previous?.hasValue == true && next.hasValue) {
      controller.maybeUnlockAchievements(AchievementTrigger.routines);
    }
  });
  ref.onDispose(controller.dispose);
  return controller;
}

@Riverpod(keepAlive: true)
void Function(AchievementTrigger) achievementTrigger(Ref ref) => (trigger) {
  ref.read(achievementsControllerProvider).maybeUnlockAchievements(trigger);
};

@riverpod
Stream<List<AchievementCompletion>> achievementCompletions(Ref ref) =>
    ref.watch(achievementsControllerProvider).completionStream;

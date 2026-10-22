import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/online.dart';
import 'package:rxdart/rxdart.dart';

class _GuestOnline extends Online {
  _GuestOnline() : super(service: TestOnlineServiceImpl());
  @override
  OnlineAccount? build() => null;
}

void main() {
  test(
    'feed and profile achievement metadata follows viewer unit preferences',
    () async {
      final prefs = BehaviorSubject<Prefs>.seeded(
        Prefs.defaultValue.copyWith(
          weightUnit: Weights.kg,
          distanceUnit: Distance.km,
        ),
      );
      final container = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWith((ref) => prefs.stream)],
      );
      final subscription = container.listen(
        achievementMetadataProvider,
        (_, _) {},
      );
      await container.read(appPreferencesProvider.future);
      final metric = container.read(achievementMetadataProvider);
      expect(
        metric['trailblazer']!.levels.first.descriptionKey,
        endsWith('.km'),
      );
      expect(metric['sparta']!.levels.first.descriptionKey, endsWith('.kg'));
      prefs.add(
        Prefs.defaultValue.copyWith(
          weightUnit: Weights.lb,
          distanceUnit: Distance.mi,
        ),
      );
      await container.read(appPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);
      final imperial = container.read(achievementMetadataProvider);
      expect(
        imperial['trailblazer']!.levels.first.descriptionKey,
        endsWith('.mi'),
      );
      expect(imperial['sparta']!.levels.first.descriptionKey, endsWith('.lb'));
      subscription.close();
      container.dispose();
      await prefs.close();
    },
  );
  test(
    'preference updates keep the achievement owner and its UI event stream alive',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      final service = DatabaseService.withDatabase(db);
      final prefs = BehaviorSubject<Prefs>.seeded(Prefs.defaultValue);
      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(service),
          onlineProvider.overrideWith(_GuestOnline.new),
          appPreferencesProvider.overrideWith((ref) => prefs.stream),
        ],
      );
      final preferenceSubscription = container.listen(
        appPreferencesProvider,
        (_, _) {},
      );
      await container.read(appPreferencesProvider.future);
      final owner = container.read(achievementsControllerProvider);
      final completion = owner.getAchievement('sparta');
      expect(completion.levels.first.descriptionKey, endsWith('.kg'));
      var closed = false;
      final events = owner.unlocked.listen((_) {}, onDone: () => closed = true);
      prefs.add(Prefs.defaultValue.copyWith(weightUnit: Weights.lb));
      await container.read(appPreferencesProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(
        identical(owner, container.read(achievementsControllerProvider)),
        isTrue,
      );
      expect(
        owner.getAchievement('sparta').levels.first.descriptionKey,
        endsWith('.lb'),
      );
      expect(closed, isFalse);
      preferenceSubscription.close();
      await events.cancel();
      container.dispose();
      await prefs.close();
      service.dispose();
    },
  );
}

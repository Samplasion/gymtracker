import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/settings.dart';

/// Display metadata follows the viewer's units without depending on user data
/// or starting the online/account controller used by achievement evaluation.
final achievementMetadataProvider = Provider<Map<String, Achievement>>((ref) {
  final prefs = ref.watch(appPreferencesProvider).value ?? Prefs.defaultValue;
  return AchievementRules(
    weightUnit: prefs.weightUnit,
    distanceUnit: prefs.distanceUnit,
  ).catalog;
});

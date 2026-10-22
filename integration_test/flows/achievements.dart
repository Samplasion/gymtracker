import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/database.dart';

import '../utils.dart';

Future<void> testAchievementsFlow(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, databaseService);

  final achievementsController = integrationContainer.read(
    achievementsControllerProvider,
  );
  final firstSteps = achievements["firstSteps"]!;
  final firstLevel = firstSteps.levels[0]; // Level 1: Workout completion

  // 1. Navigate to Achievements tab
  await openAchievements(tester);
  await tester.pumpAndSettle();

  // 2. Verify achievement is initially locked
  expect(achievementsController.isUnlocked(firstSteps, firstLevel), false);

  // 3. Insert completion directly into database to bypass isTest trigger restrictions
  await databaseService.insertAchievementCompletion(
    AchievementCompletion(
      achievementID: "firstSteps",
      level: 1,
      completedAt: DateTime.now(),
    ),
  );
  await tester.pumpAndSettle();

  // 4. Verify achievement is now unlocked in controller and visible
  expect(achievementsController.isUnlocked(firstSteps, firstLevel), true);
  expect(find.textContaining(t.achievements.firstSteps.title), findsAtLeast(1));
}

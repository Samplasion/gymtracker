import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';

import '../utils.dart';

Future<void> testAchievementsFlow(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Load app widget.
  await awaitApp(tester, l, databaseService);

  final achievementsController = Get.find<AchievementsController>();
  final firstSteps = achievements["firstSteps"]!;
  final firstLevel = firstSteps.levels[0]; // Level 1: Workout completion

  // 1. Navigate to Achievements tab
  await tester.tap(
    find.descendant(
        of: find.byType(NavigationDrawerDestination),
        matching: find.byIcon(GTIcons.achievements)),
  );
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
  expect(find.textContaining("achievements.firstSteps.title".t), findsAtLeast(1));
}

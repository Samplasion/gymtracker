import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/skeleton.dart';

const key = Key("app");

Future<void> awaitApp(
  WidgetTester tester,
  GTLocalizations l,
  DatabaseService databaseService,
) async {
  // Set screen size to a desktop-like resolution to ensure Navigation Drawer/Sidebar is visible.
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Load app widget.
  await tester.pumpWidget(
    MainApp(
      localizations: l,
      databaseService: databaseService,
      key: key,
    ),
    duration: const Duration(seconds: 5),
  );

  // Wait for the app to finish loading (waiting for SkeletonView to be in the widget tree)
  // to avoid issues with active shimmer animations preventing pumpAndSettle from finishing.
  int count = 0;
  while (!tester.any(find.byType(SkeletonView)) && count < 80) {
    await tester.pump(const Duration(milliseconds: 250));
    count++;
  }

  // Verify that the app has started.
  if (!tester.any(find.text('library.title'.t))) {
    final drawerButton = find.byIcon(Icons.menu);
    if (tester.any(drawerButton)) {
      await tester.tap(drawerButton, warnIfMissed: false);
      await tester.pumpAndSettle();
    }
  }
  expect(find.text('library.title'.t), findsAny);
}

Finder findMainListView(WidgetTester tester) {
  final listViews = find.byType(ListView).evaluate();
  if (listViews.length <= 1) {
    return find.byType(ListView);
  }
  for (final element in listViews) {
    bool isDrawer = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is NavigationDrawer || ancestor.widget is Drawer) {
        isDrawer = true;
        return false;
      }
      return true;
    });
    if (!isDrawer) {
      return find.byWidget(element.widget);
    }
  }
  return find.byType(ListView).first;
}

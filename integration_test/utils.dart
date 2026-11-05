import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/skeleton.dart';

late ProviderContainer integrationContainer;

const key = Key("app");

/// Native keyboard and channel replies may arrive after pumpAndSettle returns.
Future<void> dismissKeyboard(WidgetTester tester) async {
  // Quill and native input connections can request focus in a later frame.
  // Close the currently active connection as those replies arrive rather than
  // sending one hide request before a pending keyboard-show has been handled.
  await tester.pump();
  var hiddenFrames = 0;
  for (var i = 0; i < 100; i++) {
    FocusManager.instance.applyFocusChangesIfNeeded();
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump(const Duration(milliseconds: 100));
    hiddenFrames = tester.view.viewInsets.bottom == 0 ? hiddenFrames + 1 : 0;
    if (hiddenFrames >= 5) {
      await tester.pumpAndSettle();
      if (tester.view.viewInsets.bottom == 0) return;
      hiddenFrames = 0;
    }
  }
  expect(
    tester.view.viewInsets.bottom,
    0,
    reason:
        'Native keyboard must be dismissed before interacting with the page',
  );
}

Future<void> enterTextAndDismissKeyboard(
  WidgetTester tester,
  Finder field,
  String text,
) async {
  await tester.enterText(field, text);
  await dismissKeyboard(tester);
}

Future<void> scrollToIfNeeded(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
}

Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  bool present = true,
}) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty == present) {
      await tester.pumpAndSettle();
      return;
    }
  }
  expect(finder, present ? findsWidgets : findsNothing);
}

Future<void> awaitApp(
  WidgetTester tester,
  DatabaseService databaseService,
) async {
  // Set screen size to a desktop-like resolution to ensure Navigation Drawer/Sidebar is visible.
  // Keep native insets in the same pixel scale as the synthetic viewport.
  // A 1x override on a 3x iPhone turns its keyboard into a nearly full-screen
  // inset and hides fields that are visible at the intended logical size.
  final pixelRatio = tester.view.devicePixelRatio;
  tester.view.physicalSize = Size(1280 * pixelRatio, 800 * pixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await tester.pump(const Duration(milliseconds: 100));
  });

  // Load app widget.
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: integrationContainer,
      child: TranslationProvider(child: MainApp(key: key)),
    ),
    duration: const Duration(seconds: 5),
  );

  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  // Wait for the app to finish loading (waiting for SkeletonView to be in the widget tree)
  // to avoid issues with active shimmer animations preventing pumpAndSettle from finishing.
  int count = 0;
  while (!tester.any(find.byType(SkeletonView)) && count < 80) {
    await tester.pump(const Duration(milliseconds: 250));
    count++;
  }

  expect(find.byType(SkeletonView), findsOneWidget);
  (tester.state(find.byType(SkeletonView)) as SkeletonViewState).goToRoutines();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text(t.routines.title), findsAny);
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

Future<void> openMainSection(WidgetTester tester, IconData icon) async {
  await dismissKeyboard(tester);
  // Complete dismissal of pushed routes before querying interactive shell icons.
  await tester.pump(const Duration(milliseconds: 600));
  final destination = icon == GTIcons.muscle
      ? find.text(t.workoutPage.title).hitTestable()
      : find.byIcon(icon).hitTestable();
  await tester.tap(destination.first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

Future<void> openHistory(WidgetTester tester) async {
  await openMainSection(tester, GTIcons.profile);
  final entry = find.widgetWithText(ListTile, t.history.title);
  // The profile uses lazy slivers; build the history card by scrolling.
  await tester.scrollUntilVisible(
    entry.hitTestable(),
    250,
    scrollable: find
        .descendant(of: find.byType(MeView), matching: find.byType(Scrollable))
        .first,
  );
  await tester.ensureVisible(entry);
  await tester.pumpAndSettle();
  expect(entry.hitTestable(), findsOneWidget);
  await tester.tap(entry.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> openAchievements(WidgetTester tester) async {
  await openMainSection(tester, GTIcons.profile);
  await tester.tap(find.byIcon(GTIcons.achievements).hitTestable().first);
  await tester.pumpAndSettle();
}

/// Wait for the persisted fixture through the same source observed by the UI.
Future<void> awaitCustomExercise(WidgetTester tester, String id) async {
  await tester.runAsync(() async {
    final ready = Completer<void>();
    final subscription = integrationContainer.listen(customExercisesProvider, (
      _,
      next,
    ) {
      if (next.hasError && !ready.isCompleted) {
        ready.completeError(next.error!, next.stackTrace);
      } else if ((next.value?.any((e) => e.id == id) ?? false) &&
          !ready.isCompleted) {
        ready.complete();
      }
    }, fireImmediately: true);
    try {
      await ready.future.timeout(const Duration(seconds: 10));
    } finally {
      subscription.close();
    }
  });
}

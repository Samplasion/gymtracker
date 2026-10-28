import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    VersionService().packageInfo = PackageInfo(
      appName: 'Gym Bro',
      packageName: 'test',
      version: '1.0',
      buildNumber: '1',
    );
  });
  tearDown(MockServices.tearDown);
  for (final pro in [false, true]) {
    for (final width in [390.0, 1400.0]) {
      testWidgets('diary navigation at width $width, Pro $pro', (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final router = GoRouter(
          initialLocation: '/food',
          routes: [
            for (final path in ['/feed', '/profile', '/food', '/routines'])
              GoRoute(path: path, builder: (_, _) => const SizedBox()),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...MockServices.defaultOverrides,
              subscriptionInfoProvider.overrideWith(
                (ref) => Stream.value(
                  SubscriptionInfo(
                    isPro: pro,
                    isTrial: false,
                    isForcedPro: false,
                    isAboutToExpire: false,
                  ),
                ),
              ),
            ],
            child: WidgetTestApp(
              child: InheritedGoRouter(
                goRouter: router,
                child: const SkeletonView(
                  sectionIndex: 2,
                  child: Text('Diary content'),
                ),
              ),
            ),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(SkeletonView)),
        );
        final info = await container.read(subscriptionInfoProvider.future);
        expect(info.isPro, pro);
        await container.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        if (width < 1000) {
          final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
          expect(bar.selectedIndex, 2);
          expect(bar.destinations.length, pro ? 4 : 5);
          final destinations = bar.destinations.cast<NavigationDestination>();
          expect(destinations.map((d) => d.label).toList().sublist(1, 4), [
            'Profile',
            'Food',
            'Train',
          ]);
          bar.onDestinationSelected!(3);
        } else {
          final drawer = tester.widget<NavigationDrawer>(
            find.byType(NavigationDrawer).first,
          );
          expect(drawer.selectedIndex, 2);
          drawer.onDestinationSelected!(3);
          // Collapsed desktop navigation uses the same destination ordering.
          final toggle = find.descendant(
            of: find.byWidgetPredicate(
              (w) => w is SkeletonDrawerButton && w.isInRail,
            ),
            matching: find.byType(IconButton),
          );
          tester.widget<IconButton>(toggle).onPressed!();
          await tester.pumpAndSettle();
          final rail = tester.widget<NavigationRail>(
            find.byType(NavigationRail),
          );
          expect(rail.selectedIndex, 2);
          expect(rail.destinations.length, greaterThanOrEqualTo(pro ? 5 : 6));
        }
        expect(router.routeInformationProvider.value.uri.path, '/routines');
        expect(tester.takeException(), isNull);
      });
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/view/social.dart';
import 'package:gymtracker/view/social_notifications.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Friends extends FriendNotifier {
  @override
  FutureOr<FriendState> build() =>
      FriendState(friends: [], pendingReceived: [], pendingSent: []);
  @override
  Future<void> refresh({bool force = false}) async {}
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);
  testWidgets(
    'marks the entry watermark and leaves later notifications unread',
    (tester) async {
      final changes = StreamController<List<Map<String, dynamic>>>.broadcast();
      addTearDown(changes.close);
      final watermarks = <int>[];
      final container = ProviderContainer(
        overrides: [
          ...MockServices.defaultOverrides,
          currentUserIdProvider.overrideWith((ref) => 'A'),
          friendProvider.overrideWith(_Friends.new),
          markNotificationsReadProvider.overrideWith(
            (ref) => (id) async {
              watermarks.add(id);
            },
          ),
          socialNotificationsProvider.overrideWith((ref) => changes.stream),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WidgetTestApp(child: SocialNotificationsPage()),
        ),
      );
      await tester.pump();
      await tester.pump();
      Map<String, dynamic> notification(int id) => {
        'id': id,
        'kind': 'report_status',
        'actor_id': null,
        'report_id': 'report',
        'params': {'status': 'received'},
        'read_at': null,
      };
      changes.add([notification(10)]);
      await tester.pumpAndSettle();
      expect(watermarks, [10]);
      changes.add([notification(11), notification(10)]);
      await tester.pumpAndSettle();
      expect(watermarks, [10]);
      expect(find.byIcon(Icons.circle), findsNWidgets(2));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('reports page requires an active account before reading data', (
    tester,
  ) async {
    var queried = false;
    final container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        currentUserIdProvider.overrideWith((ref) => null),
        reportsProvider.overrideWith((ref) async {
          queried = true;
          return [];
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WidgetTestApp(child: SocialSettingsPage(reports: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(queried, isFalse);
    expect(find.byType(ListTile), findsNothing);
  });
}

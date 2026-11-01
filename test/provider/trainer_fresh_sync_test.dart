import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';
import 'package:syncable/syncable.dart';

import '../test_helpers/mock_services.dart';

class _SyncManager extends Mock implements GBSyncManager {}

class _Online extends Online {
  _Online(this.manager);
  final GBSyncManager manager;
  int pulls = 0;
  @override
  FutureOr<OnlineAccount?> build() => OnlineAccount(id: 'owner', name: 'Owner');
  @override
  GBSyncManager get syncManager => manager;
  @override
  Future<SyncResult> synchronize() async {
    pulls++;
    return const SyncResult(
      SyncOutcome.completed,
      userId: 'owner',
      cycleId: 'new',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);
  for (final changeOwner in [false, true]) {
    test(
      'trainer import waits for an older sync horizon; owner changes=$changeOwner',
      () async {
        MockServices.database.setCurrentUserId('owner');
        final manager = _SyncManager();
        final finished = Completer<void>();
        when(
          () => manager.waitForAllTables(),
        ).thenAnswer((_) => finished.future);
        final online = _Online(manager);
        final container = ProviderContainer(
          overrides: [
            ...MockServices.defaultOverrides,
            onlineProvider.overrideWith(() => online),
          ],
        );
        addTearDown(container.dispose);
        await container.read(onlineProvider.future);
        final sync = online.synchronizeFresh();
        await pumpEventQueue();
        expect(online.pulls, 0);
        if (changeOwner) MockServices.database.setCurrentUserId('other');
        finished.complete();
        final result = await sync;
        expect(online.pulls, changeOwner ? 0 : 1);
        expect(result.completed, !changeOwner);
      },
    );
  }
}

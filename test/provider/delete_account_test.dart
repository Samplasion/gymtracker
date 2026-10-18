import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

class _Service extends Mock implements OnlineService {}

class _Manager extends Mock implements GBSyncManager {}

class _Online extends Online {
  _Online(OnlineService service, this.manager) : super(service: service);
  final GBSyncManager manager;
  @override
  GBSyncManager get syncManager => manager;
  @override
  FutureOr<OnlineAccount?> build() => onlineService.account;
}

void main() {
  late _Service service;
  late _Manager manager;
  late _Online online;
  final account = OnlineAccount(id: 'A', name: 'A');

  setUp(() async {
    MockServices.setup();
    service = _Service();
    manager = _Manager();
    when(() => service.account).thenReturn(account);
    when(() => manager.syncingEnabled).thenReturn(true);
    when(
      () => MockServices.databaseService.db,
    ).thenReturn(MockServices.database);
    when(
      () => MockServices.databaseService.setCurrentUserId(null),
    ).thenAnswer((_) async {});
    globalContainer = ProviderContainer(
      overrides: [
        onlineProvider.overrideWith(() => online = _Online(service, manager)),
      ],
    );
    await globalContainer.read(onlineProvider.future);
    MockServices.database.setCurrentUserId('A');
    await MockServices.database.insertRoutineFolder(
      const GTRoutineFolder(id: 'A', name: 'A', sortOrder: 0, notes: ''),
    );
    MockServices.database.setCurrentUserId('B');
    await MockServices.database.insertRoutineFolder(
      const GTRoutineFolder(id: 'B', name: 'B', sortOrder: 0, notes: ''),
    );
    MockServices.database.setCurrentUserId('A');
  });

  tearDown(() {
    globalContainer.dispose();
    MockServices.tearDown();
  });

  test(
    'remote failure preserves all local accounts and restores sync',
    () async {
      when(
        () => service.deleteAccount(),
      ).thenThrow(StateError('Remote failure'));
      await expectLater(online.deleteAccount(), throwsStateError);
      expect((await MockServices.database.getAllRoutinesFuture()), isEmpty);
      final rows = await MockServices.database
          .select((MockServices.database as GTDatabaseImpl).routineFolders)
          .get();
      expect(rows.map((r) => r.userId), containsAll(['A', 'B']));
      expect(globalContainer.read(onlineProvider).value?.id, 'A');
      verifyInOrder([
        () => manager.disableSync(),
        () => service.deleteAccount(),
        () => manager.enableSync(),
      ]);
    },
  );

  test(
    'local cleanup happens after remote success and only affects A',
    () async {
      final remote = Completer<void>();
      when(() => service.deleteAccount()).thenAnswer((_) => remote.future);
      final deletion = online.deleteAccount();
      expect(
        (await MockServices.database
                .select((MockServices.database as GTDatabaseImpl).routineFolders)
                .get())
            .length,
        2,
      );
      remote.complete();
      await deletion;
      final rows = await MockServices.database
          .select((MockServices.database as GTDatabaseImpl).routineFolders)
          .get();
      expect(rows.map((r) => r.userId), ['B']);
      expect(globalContainer.read(onlineProvider).value, isNull);
      verifyNever(() => manager.enableSync());
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/database.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

void main() {
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  test(
    'stale controller cannot save or submit after account changes',
    () async {
      MockServices.database.setCurrentUserId('A');
      final controller = MockServices.createWorkout('A workout', null, null);
      MockServices.database.setCurrentUserId('B');
      expect(controller.refreshWatchData, returnsNormally);
      await controller.persist(force: true);
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
      await expectLater(
        controller.submit('A workout', const Duration(minutes: 10)),
        throwsStateError,
      );
    },
  );

  test(
    'account transition saves before switching and restores afterwards',
    () async {
      MockServices.database.setCurrentUserId('A');
      final service = DatabaseService.withDatabase(MockServices.database);
      final order = <String?>[];
      service.beforeUserChange = () async {
        order.add(service.db.currentUserId);
      };
      service.afterUserChange = () async {
        order.add(service.db.currentUserId);
      };
      await service.setCurrentUserId('B');
      expect(order, ['A', 'B']);
      expect(service.db.currentUserId, 'B');
      expect(
        MockServices.container.read(databaseServiceProvider),
        same(MockServices.databaseService),
      );
    },
  );
}

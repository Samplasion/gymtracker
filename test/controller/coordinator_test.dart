import 'package:easy_debounce/easy_debounce.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/service/database.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late Coordinator coordinator;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    mockDatabaseService = MockDatabaseService();
    when(() => mockDatabaseService.createBackup())
        .thenAnswer((_) async {});
    Get.put<DatabaseService>(mockDatabaseService);

    coordinator = Coordinator();
  });

  tearDown(() {
    EasyDebounce.cancel('scheduleBackup');
    Get.reset();
  });

  group('Coordinator - scheduleBackup debounce', () {
    test('debounces multiple calls within one minute to a single backup', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 20));
        verifyNever(() => mockDatabaseService.createBackup());

        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 20));
        verifyNever(() => mockDatabaseService.createBackup());

        coordinator.scheduleBackup();
        async.elapse(const Duration(seconds: 59));
        verifyNever(() => mockDatabaseService.createBackup());

        async.elapse(const Duration(seconds: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);
      });
    });

    test('creates at most one backup in a one-minute span', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        async.elapse(const Duration(minutes: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);

        coordinator.scheduleBackup();
        async.elapse(const Duration(minutes: 1));
        verify(() => mockDatabaseService.createBackup()).called(1);
      });
    });

    test('cancels scheduled backup with EasyDebounce.cancel', () {
      fakeAsync((async) {
        coordinator.scheduleBackup();
        EasyDebounce.cancel('scheduleBackup');
        async.elapse(const Duration(minutes: 2));
        verifyNever(() => mockDatabaseService.createBackup());
      });
    });
  });
}

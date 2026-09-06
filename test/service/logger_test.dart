import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:logging/logging.dart';

class _TestClass {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Logger Service & Controller Tests', () {
    late LoggerController controller;

    setUp(() {
      Get.reset();
      controller = LoggerController();
      Get.put(controller);
      initLogger();
    });

    tearDown(() {
      Get.reset();
    });

    test('globalLogger is named Gym Bro', () {
      expect(globalLogger.name, equals('Gym Bro'));
    });

    test('ObjectLoggerExt returns logger with runtimeType as name', () {
      final obj = _TestClass();
      expect(obj.logger.name, equals('_TestClass'));
    });

    test('LoggerShorthands log at appropriate levels', () {
      final captured = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(captured.add);

      final testLogger = Logger('TestLogger');
      testLogger.t('trace message');
      testLogger.d('debug message');
      testLogger.i('info message');
      testLogger.w('warning message');
      testLogger.e('error message', error: 'sample error');
      testLogger.f('fatal message');

      sub.cancel();

      expect(captured.length, equals(6));
      expect(captured[0].level, equals(Level.FINEST));
      expect(captured[0].message, equals('trace message'));
      expect(captured[1].level, equals(Level.FINE));
      expect(captured[1].message, equals('debug message'));
      expect(captured[2].level, equals(Level.INFO));
      expect(captured[2].message, equals('info message'));
      expect(captured[3].level, equals(Level.WARNING));
      expect(captured[3].message, equals('warning message'));
      expect(captured[4].level, equals(Level.SEVERE));
      expect(captured[4].message, equals('error message'));
      expect(captured[4].error, equals('sample error'));
      expect(captured[5].level, equals(Level.SHOUT));
      expect(captured[5].message, equals('fatal message'));
    });

    test('LoggerController captures in-memory logs and filters by level', () {
      controller.clearLogs();
      expect(controller.logs, isEmpty);

      final testLogger = Logger('BufferTest');
      testLogger.t('trace msg');
      testLogger.d('debug msg');
      testLogger.i('info msg');
      testLogger.w('warning msg');
      testLogger.e('error msg');

      expect(controller.logs.length, equals(5));

      controller.level = Level.INFO;
      expect(controller.filteredLogs.length, equals(3));
      expect(
        controller.filteredLogs.map((l) => l.message),
        containsAllInOrder(['info msg', 'warning msg', 'error msg']),
      );

      controller.level = Level.SEVERE;
      expect(controller.filteredLogs.length, equals(1));
      expect(controller.filteredLogs.first.message, equals('error msg'));
    });

    test('LoggerController ring buffer trims old logs when exceeding capacity', () {
      controller.clearLogs();
      const maxLogs = LoggerController.keptLogs;

      for (int i = 0; i < maxLogs + 10; i++) {
        controller.addLog(
          Log(
            message: 'Msg $i',
            timestamp: DateTime.now(),
            level: Level.INFO,
            loggerName: 'RingBuffer',
          ),
        );
      }

      expect(controller.logs.length, equals(maxLogs));
      expect(controller.logs.first.message, equals('Msg 10'));
      expect(controller.logs.last.message, equals('Msg ${maxLogs + 9}'));
    });

    test('LevelExt provides correct display names and short names', () {
      expect(Level.FINEST.displayName, equals('Trace'));
      expect(Level.FINEST.shortName, equals('TRC'));
      expect(Level.FINEST.translationKey, equals('trace'));

      expect(Level.FINE.displayName, equals('Debug'));
      expect(Level.FINE.shortName, equals('DBG'));
      expect(Level.FINE.translationKey, equals('debug'));

      expect(Level.INFO.displayName, equals('Info'));
      expect(Level.INFO.shortName, equals('NFO'));
      expect(Level.INFO.translationKey, equals('info'));

      expect(Level.WARNING.displayName, equals('Warning'));
      expect(Level.WARNING.shortName, equals('WRN'));
      expect(Level.WARNING.translationKey, equals('warning'));

      expect(Level.SEVERE.displayName, equals('Error'));
      expect(Level.SEVERE.shortName, equals('ERR'));
      expect(Level.SEVERE.translationKey, equals('error'));

      expect(Level.SHOUT.displayName, equals('Fatal'));
      expect(Level.SHOUT.shortName, equals('FTL'));
      expect(Level.SHOUT.translationKey, equals('fatal'));
    });
  });
}

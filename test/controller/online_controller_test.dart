import 'package:gymtracker/controller/online_controller.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:test/test.dart';

typedef _SyncModeTestCase = ({
  DateTime lastSync,
  DateTime local,
  DateTime remote
});

void main() {
  if (!Configuration.isOnlineAccountEnabled) {
    return;
  }
  group('OnlineController', () {
    group("getSyncMode", () {
      final tests = <SyncMode, List<_SyncModeTestCase>>{
        SyncMode.download: [
          (
            local: DateTime(2024, 1, 1),
            remote: DateTime(2024, 1, 2),
            lastSync: DateTime(2024, 1, 1),
          ),
          (
            local: DateTime(2024, 1, 1),
            remote: DateTime(2024, 1, 2),
            lastSync: DateTime(2024, 1, 1, 12),
          ),
          (
            local: DateTime(2024, 1, 1),
            remote: DateTime(2024, 1, 2),
            lastSync: DateTime(2024, 1, 3),
          ),
        ],
        SyncMode.upload: [
          (
            local: DateTime(2024, 1, 2),
            remote: DateTime(2024, 1, 1),
            lastSync: DateTime(2024, 1, 1),
          ),
          (
            local: DateTime(2024, 1, 2),
            remote: DateTime(2024, 1, 1),
            lastSync: DateTime(2024, 1, 3),
          ),
        ],
        SyncMode.allSynced: [
          (
            local: DateTime(2024, 1, 1),
            remote: DateTime(2024, 1, 1),
            lastSync: DateTime(2024, 1, 1),
          ),
          (
            local: DateTime(2024, 1, 1),
            remote: DateTime(2024, 1, 1),
            lastSync: DateTime(2024, 1, 2),
          ),
          (
            local: DateTime(2024, 1, 2),
            remote: DateTime(2024, 1, 2),
            lastSync: DateTime(2024, 1, 3),
          ),
        ],
        SyncMode.conflict: [
          (
            local: DateTime(2024, 1, 2),
            remote: DateTime(2024, 1, 2),
            lastSync: DateTime(2024, 1, 1),
          ),
          (
            local: DateTime(2024, 1, 2, 1),
            remote: DateTime(2024, 1, 2, 2),
            lastSync: DateTime(2024, 1, 1),
          ),
        ],
      };

      for (final MapEntry(key: mode, value: tests) in tests.entries) {
        test("returns the correct sync mode (${mode.name})", () {
          for (final test in tests) {
            final result = OnlineController.getSyncMode(
              localLastModified: test.local,
              remoteLastModified: test.remote,
              lastSuccessfulSync: test.lastSync,
            );
            expect(result, mode);
          }
        });
      }
    });
  });
}

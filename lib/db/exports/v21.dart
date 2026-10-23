import 'package:gymtracker/db/exports/v20.dart';

/// Adds workout visibility through the existing Workout JSON serializer.
class VersionedJsonExportV21 extends VersionedJsonExportV20 {
  const VersionedJsonExportV21();
  @override
  int get version => 21;
}

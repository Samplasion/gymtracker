import 'package:gymtracker/db/imports/v2.dart';

class VersionedJsonImportV3 extends VersionedJsonImportV2 {
  @override
  int get version => 3;

  const VersionedJsonImportV3();
}

import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  late PackageInfo packageInfo;

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}

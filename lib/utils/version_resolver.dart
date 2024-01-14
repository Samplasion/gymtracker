import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<bool> versionMatches({
  VersionRequirement? android,
  VersionRequirement? ios,
  VersionRequirement? macos,
  // maybe?
  // VersionRequirement? web,
  // VersionRequirement? windows,
  // VersionRequirement? linux,
  // VersionRequirement? fuchsia,
}) async {
  if (kIsWeb) return false;
  final resolver = VersionResolver(DeviceInfoPlugin());
  if (Platform.isAndroid && android != null) {
    final sdkInt = await resolver.getAndroidVersion();
    return android.matches(sdkInt);
  } else if (Platform.isIOS && ios != null) {
    final version = await resolver.getiOSVersion();
    return ios.matches(version);
  } else if (Platform.isMacOS && macos != null) {
    final version = await resolver.getMacOSVersion();
    return macos.matches(version);
  }
  return false;
}

class VersionRequirement {
  double? min, max;

  VersionRequirement({this.min, this.max});

  bool matches(double version) {
    if (min != null && version < min!) return false;
    if (max != null && version > max!) return false;
    return true;
  }
}

class VersionResolver {
  VersionResolver(this._plugin);

  final DeviceInfoPlugin _plugin;

  Future<double> getAndroidVersion() async {
    final androidInfo = await _plugin.androidInfo;
    return androidInfo.version.sdkInt.toDouble();
  }

  Future<double> getiOSVersion() async {
    final iosInfo = await _plugin.iosInfo;
    return double.parse(iosInfo.systemVersion!.split(".").first);
  }

  Future<double> getMacOSVersion() async {
    final macInfo = await _plugin.macOsInfo;
    final major = macInfo.majorVersion;
    final minor = macInfo.minorVersion;
    return double.parse("$major.$minor");
  }
}

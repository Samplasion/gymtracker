import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/utils/version_resolver.dart';

class ColorService {
  static final ColorService _instance = ColorService._internal();
  factory ColorService() => _instance;
  ColorService._internal();

  late bool supportsDynamicColor;

  Future<void> init() async {
    supportsDynamicColor = await versionMatches(
      android: VersionRequirement(min: 31),
      macos: VersionRequirement(min: 10.14),
    );
  }
}

final colorServiceProvider = Provider<ColorService>((ref) => ColorService());

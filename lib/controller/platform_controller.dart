import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';

enum UIPlatform {
  material,
  cupertino,
}

class PlatformController extends GetxController with ServiceableController {
  bool get supportsCupertino => GetPlatform.isIOS || GetPlatform.isMacOS;
  late final Rx<UIPlatform> platform = () {
    if (supportsCupertino) {
      return UIPlatform.cupertino;
    }

    return UIPlatform.material;
  }()
      .obs;

  @override
  void onServiceChange() {
    // TODO: Change platform on DB platform change
  }

  void toggle() {
    platform.value = platform.value == UIPlatform.material
        ? UIPlatform.cupertino
        : UIPlatform.material;
  }
}

import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';

import 'package:gymtracker/service/database.dart';

mixin ServiceableController on GetxController {
  DatabaseService get service => Get.find<DatabaseService>();
  Coordinator get coordinator => Get.find<Coordinator>();

  @override
  onInit() {
    super.onInit();

    onServiceChange();
    service.addListener(onServiceChange);
  }

  @override
  onClose() {
    super.onClose();
    service.removeListener(onServiceChange);
  }

  void onServiceChange();
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/go.dart';
import 'serviceable_controller.dart';

class SettingsController extends GetxController with ServiceableController {
  RxBool usesDynamicColor = false.obs;
  Rx<Locale?> locale = Get.locale.obs;

  void setUsesDynamicColor(bool usesDC) =>
      service.writeSetting("usesDynamicColor", usesDC);
  void setLocale(Locale locale) {
    Get.updateLocale(locale);
    service.writeSetting("locale", locale.languageCode);
  }

  @override
  void onServiceChange() {
    final storage = service.settingsStorage;
    usesDynamicColor(storage.read<bool>("usesDynamicColor") ?? false);
    locale(Locale(storage.read<String>("locale") ?? "en"));
  }

  Future exportSettings(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    // printInfo(info: service.toJson());
    await Share.shareXFiles(
      [
        XFile.fromData(
          Uint8List.fromList(utf8.encode(json.encode(service.toJson()))),
          mimeType: "application/json",
          name: "${"settings.options.export.filename".tr}.json",
        )
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future importSettings() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result?.files.single.path != null) {
      try {
        File file = File(result!.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> map = json.decode(content);

        service.fromJson(map);
        Go.snack("settings.options.import.success".tr);
      } catch (e) {
        e.printError();
        Go.snack("settings.options.import.failed".tr);
      }
    } else {
      // User canceled the picker
      printInfo(info: "Picker canceled");
    }
  }
}

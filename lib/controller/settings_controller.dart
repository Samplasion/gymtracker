import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../data/weights.dart';
import '../utils/go.dart';
import 'serviceable_controller.dart';

Color defaultColor = Color(Colors.blue.value);

class SettingsController extends GetxController with ServiceableController {
  RxBool usesDynamicColor = false.obs;
  Rx<Color> color = defaultColor.obs;
  Rx<Locale?> locale = Get.locale.obs;
  Rx<Weights?> weightUnit = Weights.kg.obs;

  void setUsesDynamicColor(bool usesDC) =>
      service.writeSetting("usesDynamicColor", usesDC);

  void setColor(Color color) => service.writeSetting("color", color.value);

  void setLocale(Locale locale) {
    Get.updateLocale(locale);
    service.writeSetting("locale", locale.languageCode);
  }

  void setWeightUnit(Weights weightUnit) =>
      service.writeSetting("weightUnit", weightUnit.name);

  @override
  void onServiceChange() {
    final storage = service.settingsStorage;
    usesDynamicColor(storage.read<bool>("usesDynamicColor") ?? false);
    color(Color(storage.read<int>("color") ?? defaultColor.value));
    locale(Locale(storage.read<String>("locale") ?? "en"));
    weightUnit(Weights.values.firstWhere(
      (element) => element.name == storage.read<String>("weightUnit"),
      orElse: () => Weights.kg,
    ));
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

    if (kIsWeb && result?.files.single.bytes != null) {
      String content = String.fromCharCodes(result!.files.single.bytes!.toList());
      Map<String, dynamic> map = json.decode(content);

      service.fromJson(map);
      Go.snack("settings.options.import.success".tr);
    } else if (!kIsWeb && result?.files.single.path != null) {
      try {
        File file = File(result!.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> map = json.decode(content);

        service.fromJson(map);
        Go.snack("settings.options.import.success".tr);
      } catch (e) {
        e.printError();

        String errorString = e.toString();
        if (e is Error) {
          errorString = e.stackTrace.toString();
        }

        Go.dialog("settings.options.import.failed".tr, errorString);
      }
    } else {
      // User canceled the picker
      printInfo(info: "Picker canceled");
    }
  }
}

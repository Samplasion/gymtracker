import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:share_plus/share_plus.dart';

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
    usesDynamicColor(service.readSetting<bool>("usesDynamicColor") ?? false);
    color(Color(service.readSetting<int>("color") ?? defaultColor.value));
    locale(Locale(service.readSetting<String>("locale") ?? "en"));
    weightUnit(Weights.values.firstWhere(
      (element) => element.name == service.readSetting<String>("weightUnit"),
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
          name:
              "${"settings.options.export.filename".t}_${DateTime.now().toIso8601String()}.json",
        )
      ],
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future importSettings(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (kIsWeb && result?.files.single.bytes != null) {
      String content =
          String.fromCharCodes(result!.files.single.bytes!.toList());
      Map<String, dynamic> map = json.decode(content);

      service.fromJson(map);
      Go.snack("settings.options.import.success".t);
    } else if (!kIsWeb && result?.files.single.path != null) {
      try {
        File file = File(result!.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> map = json.decode(content);

        service.fromJson(map);
        Go.snack("settings.options.import.success".t);
      } catch (e) {
        e.printError();

        String errorString = e.toString();
        if (e is Error) {
          errorString = "$errorString\n${e.stackTrace}";
        }

        Go.dialog("settings.options.import.failed.title".t, errorString,
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: errorString));
                  Go.snack("settings.options.import.failed.copy".t);
                },
                child: Text(
                    // ignore: use_build_context_synchronously
                    MaterialLocalizations.of(context).copyButtonLabel),
              )
            ]);
      }
    } else {
      // User canceled the picker
      printInfo(info: "Picker canceled");
    }
  }
}

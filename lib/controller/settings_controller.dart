import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:share_plus/share_plus.dart';

Color defaultColor = Color(Colors.blue.value);

SettingsController get settingsController => Get.find<SettingsController>();

class SettingsController extends GetxController with ServiceableController {
  RxBool hasInitialized = false.obs;
  RxBool usesDynamicColor = false.obs;
  Rx<Color> color = defaultColor.obs;
  Rx<Locale?> locale = Get.locale.obs;
  Rx<Weights> weightUnit = Weights.kg.obs;
  Rx<Distance> distanceUnit = Distance.km.obs;
  RxBool showSuggestedRoutines = true.obs;

  void setUsesDynamicColor(bool usesDC) =>
      service.writeSettings(service.prefs$.value.copyWith(
        usesDynamicColor: usesDC,
      ));

  void setColor(Color color) =>
      service.writeSettings(service.prefs$.value.copyWith(color: color));

  void setLocale(Locale locale) {
    Get.updateLocale(locale);
    service.writeSettings(service.prefs$.value.copyWith(locale: locale));
  }

  void setWeightUnit(Weights weightUnit) =>
      service.writeSettings(service.prefs$.value.copyWith(
        weightUnit: weightUnit,
      ));

  void setDistanceUnit(Distance distanceUnit) =>
      service.writeSettings(service.prefs$.value.copyWith(
        distanceUnit: distanceUnit,
      ));

  void setShowSuggestedRoutines(bool show) =>
      service.writeSettings(service.prefs$.value.copyWith(
        showSuggestedRoutines: show,
      ));

  @override
  void onInit() {
    super.onInit();

    service.prefs$.listen((prefs) {
      hasInitialized(true);

      Get.updateLocale(prefs.locale);

      usesDynamicColor(prefs.usesDynamicColor);
      color(prefs.color);
      locale(prefs.locale);
      weightUnit(prefs.weightUnit);
      distanceUnit(prefs.distanceUnit);
      showSuggestedRoutines(prefs.showSuggestedRoutines);

      notifyChildrens();
    });
  }

  @override
  void onServiceChange() {
    final prefs = service.prefs$.value;

    usesDynamicColor(prefs.usesDynamicColor);
    color(prefs.color);
    locale(prefs.locale);
    weightUnit(prefs.weightUnit);
    distanceUnit(prefs.distanceUnit);
    showSuggestedRoutines(prefs.showSuggestedRoutines);

    notifyChildrens();
  }

  Future exportSettings(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
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

    try {
      if (kIsWeb && result?.files.single.bytes != null) {
        String content =
            String.fromCharCodes(result!.files.single.bytes!.toList());
        Map<String, dynamic> map = json.decode(content);

        await service.fromJson(map);
        Go.snack("settings.options.import.success".t);
      } else if (!kIsWeb && result?.files.single.path != null) {
        File file = File(result!.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> map = json.decode(content);

        await service.fromJson(map);
        Go.snack("settings.options.import.success".t);
      } else {
        // User canceled the picker
        logger.i("Picker canceled");
      }
    } catch (e, s) {
      logger.e("", error: e, stackTrace: s);

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
  }

  /// Waits for the database to fire the first "Preferences loaded" event.
  ///
  /// Guaranteed to always return if the first event has already been fired.
  /// Otherwise, it is guaranteed to return in 5 seconds if the database
  /// doesn't fire the event for some reason.
  Future<void> awaitInitialized() async {
    if (hasInitialized()) return;
    await Future.any([
      service.db.watchPreferences().first,
      Future.delayed(const Duration(seconds: 5)),
    ]);
  }
}

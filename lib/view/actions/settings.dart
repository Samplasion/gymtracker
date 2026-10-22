import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/logs.dart';
import 'package:gymtracker/view/migrations.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:share_plus/share_plus.dart';

extension SettingsPresentation on SettingsController {
  Future<void> exportSettings(BuildContext context) async {
    final labels = context.t;
    final copyLabel = MaterialLocalizations.of(context).copyButtonLabel;
    try {
      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin = box!.localToGlobal(Offset.zero) & box.size;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(
                utf8.encode(json.encode(await service.exportJson())),
              ),
              mimeType: "application/json",
              name:
                  "${labels.settings.options.export.filename}_${DateTime.now().toIso8601String()}.json",
            ),
          ],
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e, s) {
      logger.e(null, error: e, stackTrace: s);

      Go.dialog(
        labels.settings.options.export.failed.title,
        "$e\n$s".trim(),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "$e\n$s".trim()));
              Go.snack(labels.settings.options.export.failed.copy);
            },
            child: Text(copyLabel),
          ),
        ],
        bodyStyle: monospace,
      );
    }
  }

  Future<void> importSettings(BuildContext context) async {
    final labels = context.t;
    final copyLabel = MaterialLocalizations.of(context).copyButtonLabel;
    final choice = await Go.pick(
      title: labels.settings.options.import.label,
      values: {"hevy": labels.settings.options.import.types.hevy},
    );

    if (choice == null) return;

    PlatformFile? result = await FilePicker.pickFile();
    Uint8List? bytes = await result?.readAsBytes();
    String content;

    if (kIsWeb && bytes != null) {
      content = String.fromCharCodes(bytes.toList());
    } else if (!kIsWeb && result != null) {
      content = await result.xFile.readAsString();
    } else {
      // User canceled the picker
      logger.i("Picker canceled");
      return;
    }

    try {
      switch (choice) {
        case "hevy":
          await importHevy(content);
          break;
      }

      Go.snack(labels.settings.options.import.success);
    } catch (e, s) {
      logger.e("", error: e, stackTrace: s);

      String errorString = e.toString();
      if (e is Error) {
        errorString = "$errorString\n${e.stackTrace}";
      }

      Go.dialog(
        labels.settings.options.import.failed.title,
        errorString,
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorString));
              Go.snack(labels.settings.options.import.failed.copy);
            },
            child: Text(copyLabel),
          ),
        ],
      );
    }
  }

  Future<void> showLogs() async {
    unawaited(Go.to(() => const LogView()));
  }

  Future<void> showMigrations() async {
    unawaited(Go.to(() => const AllMigrationsView()));
  }

  Future<void> exportRawDatabase(BuildContext context) async {
    final labels = context.t;
    final copyLabel = MaterialLocalizations.of(context).copyButtonLabel;
    try {
      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin = box!.localToGlobal(Offset.zero) & box.size;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              (await service.exportRaw()).path,
              mimeType: "application/octet-stream",
              name:
                  "${labels.settings.options.export.filename}_${DateTime.now().toIso8601String()}.db",
            ),
          ],
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e, s) {
      logger.e(null, error: e, stackTrace: s);

      Go.dialog(
        labels.settings.options.export.failed.title,
        "$e\n$s".trim(),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "$e\n$s".trim()));
              Go.snack(labels.settings.options.export.failed.copy);
            },
            child: Text(copyLabel),
          ),
        ],
        bodyStyle: monospace,
      );
    }
  }

  Future<void> showBackups() async {
    unawaited(Go.to(() => const BackupListView()));
  }
}

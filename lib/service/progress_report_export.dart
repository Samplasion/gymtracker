import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

final progressReportExportProvider = Provider((ref) => ProgressReportExport());

class ProgressReportExport {
  Future<bool> save(Uint8List bytes, String filename) async =>
      await FilePicker.saveFile(
        fileName: filename,
        bytes: bytes,
        mimeType: 'application/pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      ) !=
      null;

  Future<void> share(Uint8List bytes, String filename, Rect origin) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/pdf', name: filename),
        ],
        fileNameOverrides: [filename],
        sharePositionOrigin: origin,
      ),
    );
  }
}

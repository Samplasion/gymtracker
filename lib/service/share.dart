import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  void shareImage(
    Uint8List data, {
    String name = "image.png",
  }) {
    Share.shareXFiles(
      [
        XFile.fromData(
          data,
          name: name,
          mimeType: "image/png",
        ),
      ],
    );
  }
}

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';

class CropImagePage extends StatefulWidget {
  final Uint8List imageBytes;

  const CropImagePage({super.key, required this.imageBytes});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  ui.Image? _decodedImage;
  double? _renderedWidth;
  double? _renderedHeight;
  Rect? _cropRect;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _decodeImage();
    _transformationController.addListener(_onTransformChanged);
  }

  Future<void> _decodeImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _decodedImage = frame.image;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _reset() {
    if (_renderedWidth == null || _renderedHeight == null || _cropRect == null)
      return;

    final double minScaleX = _cropRect!.width / _renderedWidth!;
    final double minScaleY = _cropRect!.height / _renderedHeight!;
    final double minScale = max(minScaleX, minScaleY);

    final double tx = _cropRect!.center.dx - (_renderedWidth! / 2) * minScale;
    final double ty = _cropRect!.center.dy - (_renderedHeight! / 2) * minScale;

    setState(() {
      _transformationController.value = Matrix4.identity()
        ..setEntry(0, 0, minScale)
        ..setEntry(1, 1, minScale)
        ..setEntry(0, 3, tx)
        ..setEntry(1, 3, ty);
    });
  }

  bool _isClamping = false;
  void _onTransformChanged() {
    if (_isClamping ||
        _renderedWidth == null ||
        _renderedHeight == null ||
        _cropRect == null)
      return;

    final matrix = _transformationController.value;
    final clamped = _clampTransform(
      matrix,
      _renderedWidth!,
      _renderedHeight!,
      _cropRect!,
    );

    if (matrix != clamped) {
      _isClamping = true;
      _transformationController.value = clamped;
      _isClamping = false;
    }
  }

  Matrix4 _clampTransform(
    Matrix4 matrix,
    double renderedWidth,
    double renderedHeight,
    Rect cropRect,
  ) {
    final double scale = matrix.entry(0, 0);

    final double minScaleX = cropRect.width / renderedWidth;
    final double minScaleY = cropRect.height / renderedHeight;
    final double minScale = max(minScaleX, minScaleY);

    double clampedScale = scale;
    if (clampedScale < minScale) {
      clampedScale = minScale;
    }

    double tx = matrix.entry(0, 3);
    double ty = matrix.entry(1, 3);

    final double minTx = cropRect.right - clampedScale * renderedWidth;
    final double maxTx = cropRect.left;
    tx = tx.clamp(minTx, maxTx);

    final double minTy = cropRect.bottom - clampedScale * renderedHeight;
    final double maxTy = cropRect.top;
    ty = ty.clamp(minTy, maxTy);

    return Matrix4.identity()
      ..setEntry(0, 0, clampedScale)
      ..setEntry(1, 1, clampedScale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  Future<void> _cropImage(Rect cropRect) async {
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Capture the InteractiveViewer contents at 2x resolution for better quality
      const double pixelRatio = 2.0;
      final ui.Image fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      final double cropSize = cropRect.width * pixelRatio;
      final Rect scaledCropRect = Rect.fromLTWH(
        cropRect.left * pixelRatio,
        cropRect.top * pixelRatio,
        cropRect.width * pixelRatio,
        cropRect.height * pixelRatio,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the cropped portion of the full image onto the crop canvas
      final destRect = Rect.fromLTWH(0, 0, cropSize, cropSize);
      canvas.drawImageRect(
        fullImage,
        scaledCropRect,
        destRect,
        Paint()..isAntiAlias = true,
      );

      final croppedImage = await recorder.endRecording().toImage(
        cropSize.toInt(),
        cropSize.toInt(),
      );
      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        final croppedBytes = byteData.buffer.asUint8List();
        if (mounted) {
          Navigator.of(context).pop(croppedBytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("userProfile.edit.error".t)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(GTIcons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("userProfile.edit.cropTitle".t),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _reset,
            ),
          ],
        ),
        body: _decodedImage == null
            ? const Center(child: GBLoadingIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  final double screenHeight = constraints.maxHeight;

                  // Crop size is 80% of the smaller dimension
                  final double cropSize = min(screenWidth, screenHeight) * 0.8;
                  final Rect cropRect = Rect.fromCenter(
                    center: Offset(screenWidth / 2, screenHeight / 2),
                    width: cropSize,
                    height: cropSize,
                  );

                  // Compute aspect ratio of image and fit dimensions
                  final double imageRatio =
                      _decodedImage!.width / _decodedImage!.height;
                  final double parentRatio = screenWidth / screenHeight;

                  double renderedWidth;
                  double renderedHeight;

                  if (imageRatio > parentRatio) {
                    renderedWidth = screenWidth;
                    renderedHeight = screenWidth / imageRatio;
                  } else {
                    renderedHeight = screenHeight;
                    renderedWidth = screenHeight * imageRatio;
                  }

                  _renderedWidth = renderedWidth;
                  _renderedHeight = renderedHeight;
                  _cropRect = cropRect;

                  final double minScaleX = cropRect.width / renderedWidth;
                  final double minScaleY = cropRect.height / renderedHeight;
                  final double minScale = max(minScaleX, minScaleY);

                  if (!_initialized) {
                    final double tx =
                        cropRect.center.dx - (renderedWidth / 2) * minScale;
                    final double ty =
                        cropRect.center.dy - (renderedHeight / 2) * minScale;

                    _transformationController.value = Matrix4.identity()
                      ..setEntry(0, 0, minScale)
                      ..setEntry(1, 1, minScale)
                      ..setEntry(0, 3, tx)
                      ..setEntry(1, 3, ty);

                    _initialized = true;
                  }

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: RepaintBoundary(
                          key: _repaintKey,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: minScale,
                            maxScale: 10.0,
                            boundaryMargin: const EdgeInsets.all(
                              double.infinity,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: renderedWidth,
                                height: renderedHeight,
                                child: Image.memory(
                                  widget.imageBytes,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _CropOverlayPainter(cropRect: cropRect),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 32,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "userProfile.edit.cropInstructions".t,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white30,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      "userProfile.crop.buttons.cancel".t,
                                    ),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () => _cropImage(cropRect),
                                    child: Text(
                                      "userProfile.crop.buttons.confirm".t,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  _CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Draw the dimmed background with a circular hole in the center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw the circular border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(cropRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}

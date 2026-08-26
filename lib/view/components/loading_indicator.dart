import 'package:flutter/material.dart';
import 'package:gymtracker/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

class GBLoadingIndicator extends StatelessWidget {
  const GBLoadingIndicator({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return GTAssets.anim.loading.lottie(
      frameRate: FrameRate(45),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

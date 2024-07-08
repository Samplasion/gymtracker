import 'package:device_sim/device_sim.dart';
import 'package:flutter/material.dart';

/// iPhone 15
const iphone15 = DeviceConfiguration(
    name: 'iPhone 15 - 6.1"',
    frameConfiguration: _iphone15Frame,
    screenConfiguration: _iphone15Screen);

const _iphone15Frame = FrameConfiguration(
  frameInsets: EdgeInsets.all(20.0),
  outerRadius: BorderRadius.all(Radius.circular(68)),
  innerRadius: BorderRadius.all(Radius.circular(48)),
  features: [
    StaticFeature(
      portraitAlignment: Alignment.topCenter,
      child: SizedBox(
        height: 59,
        child: Center(child: IPhone15DynamicIsland()),
      ),
    ),
  ],
);

const _iphone15Screen = ScreenConfiguration(
  standardRectangleDiagonalInInch: 6.06,
  size: Size(390.0, 844.0),
  portraitPadding: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 34.0),
  portraitViewPadding: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 34.0),
  portraitViewInsets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  portraitPaddingIfKeyboard: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 0.0),
  portraitViewPaddingIfKeyboard: EdgeInsets.fromLTRB(0.0, 59.0, 0.0, 34.0),
  portraitViewInsetsIfKeyboard: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 336.0),
  landscapePadding: EdgeInsets.fromLTRB(59.0, 0.0, 59.0, 21.0),
  landscapeViewPadding: EdgeInsets.fromLTRB(59.0, 0.0, 59.0, 21.0),
  landscapeViewInsets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  landscapePaddingIfKeyboard: EdgeInsets.fromLTRB(59.0, 0.0, 59.0, 0.0),
  landscapeViewPaddingIfKeyboard: EdgeInsets.fromLTRB(59.0, 0.0, 59.0, 21.0),
  landscapeViewInsetsIfKeyboard: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 219.0),
  textScaleFactor: 1.0,
  devicePixelRatio: 3.0,
  targetPlatform: TargetPlatform.iOS,
  features: [
    Align(
      alignment: Alignment.bottomCenter,
      child: HomeIndicator(
        widthInPortrait: 138.0,
        widthInLandscape: 220.0,
      ),
    ),
  ],
);

/// Notch of iPhone 15.
class IPhone15DynamicIsland extends StatelessWidget {
  /// Creates a new [IPhone15DynamicIsland].
  const IPhone15DynamicIsland(
      {super.key, this.width = 160.0, this.height = 34.0});

  /// Width of the notch.
  final double width;

  /// Height of the notch.
  final double height;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(22),
        ),
      );
    });
  }
}

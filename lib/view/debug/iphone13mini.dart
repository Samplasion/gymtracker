import 'package:device_sim/device_sim.dart';
import 'package:flutter/material.dart';

/// iPhone 13
const iphone13mini = DeviceConfiguration(
    name: 'iPhone 13 mini - 5.4"',
    frameConfiguration: _iphone13Frame,
    screenConfiguration: _iphone13Screen);

const _iphone13Frame = FrameConfiguration(
  frameInsets: EdgeInsets.all(20.0),
  outerRadius: BorderRadius.all(Radius.circular(68)),
  innerRadius: BorderRadius.all(Radius.circular(48)),
  features: [
    StaticFeature(
      portraitAlignment: Alignment.topCenter,
      child: IPhone13Notch(),
    ),
  ],
);

const _iphone13Screen = ScreenConfiguration(
  standardRectangleDiagonalInInch: 6.06,
  size: Size(375.0, 812.0),
  portraitPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 34.0),
  portraitViewPadding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 34.0),
  portraitViewInsets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  portraitPaddingIfKeyboard: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
  portraitViewPaddingIfKeyboard: EdgeInsets.fromLTRB(0.0, 47.0, 0.0, 34.0),
  portraitViewInsetsIfKeyboard: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 336.0),
  landscapePadding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 21.0),
  landscapeViewPadding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 21.0),
  landscapeViewInsets: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  landscapePaddingIfKeyboard: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
  landscapeViewPaddingIfKeyboard: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 21.0),
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

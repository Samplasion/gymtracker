import 'package:get/get.dart';

enum Breakpoints {
  xxs._(320),
  xs._(480),
  s._(600),
  m._(720),
  l._(1024),
  xl._(999999);

  const Breakpoints._(this.screenWidth);

  final int screenWidth;

  static Breakpoints get currentBreakpoint =>
      computeBreakpoint(Get.context!.width);

  static Breakpoints computeBreakpoint(double width) {
    final w = width;
    if (w < xxs.screenWidth) return xxs;
    if (w < xs.screenWidth) return xs;
    if (w < s.screenWidth) return s;
    if (w < m.screenWidth) return m;
    if (w < l.screenWidth) return l;
    return xl;
  }
}

class NotificationIDs {
  static const restTimer = 0;
}

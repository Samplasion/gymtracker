import 'package:flutter/widgets.dart';
import 'package:gymtracker/service/logger.dart';

class LoggerNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.t("didPush: ${route.settings.name}");
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.t("didPop: ${route.settings.name}");
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.t("didRemove: ${route.settings.name}");
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.t(
      "didReplace: ${oldRoute?.settings.name ?? 'null'} with ${newRoute?.settings.name ?? 'null'}",
    );
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    logger.t("didChangeTop: ${topRoute.settings.name}");
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    logger.t("didStartUserGesture: ${route.settings.name}");
  }

  @override
  void didStopUserGesture() {
    logger.t("didStopUserGesture");
  }
}

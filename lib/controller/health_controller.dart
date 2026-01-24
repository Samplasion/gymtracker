import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/native.dart';
import 'package:health/health.dart';
import 'package:rxdart/rxdart.dart';

class HealthController extends GetxController {
  final _health = Health();

  final typesToShare = [HealthDataType.WORKOUT];
  final typesToRead = [
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  Stream<double?> get energyStream => NativeService.instance().energyStream;
  Stream<double?> get heartRateStream =>
      NativeService.instance().heartRateStream;

  Future<void> init() async {
    await _health.configure();

    _health.hasPermissions(typesToRead).then((value) {
      hasPermissionStream.add(value ?? false);
    });
  }

  final hasPermissionStream = BehaviorSubject<bool>.seeded(true);
  Widget get settingsTile {
    return StreamBuilder(
      stream: hasPermissionStream,
      builder: (_, snap) {
        final hasPermission = snap.data ?? false;
        if (hasPermission) {
          return const SizedBox.shrink();
        } else {
          return ListTile(
            leading: const Icon(GTIcons.notification_dialog),
            title: Text("settings.options.health.label".t),
            subtitle: Text("settings.permissions.tapToRequest".t),
            onTap: () {
              requestPermission();
            },
          );
        }
      },
    );
  }

  requestPermission() async {
    if (await _health.hasPermissions(typesToRead) == true) return;
    _health.requestAuthorization(typesToRead).then((value) {
      hasPermissionStream.add(value);
    });
  }
}

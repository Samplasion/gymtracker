import 'dart:io';

import 'package:flutter/services.dart';

import 'package:gymtracker/service/native.dart';
import 'package:health/health.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'health_controller.g.dart';

/// Platform health operations. Widgets observe permission and metrics providers.
class HealthController {
  HealthController({Health? health, NativeService? native, bool? supported})
    : _supported =
          supported ?? (health != null || Platform.isIOS || Platform.isAndroid),
      _health = health ?? Health(),
      _native = native ?? NativeService.instance(),
      _ownsNative = native == null {
    if (_ownsNative) _native.attach();
  }
  final bool _supported;
  final Health _health;
  final NativeService _native;
  final bool _ownsNative;
  bool _disposed = false;

  final typesToShare = [HealthDataType.WORKOUT];
  final typesToRead = [
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];
  final hasPermissionStream = BehaviorSubject<bool>.seeded(true);
  Stream<double?> get energyStream => _native.energyStream;
  Stream<double?> get heartRateStream => _native.heartRateStream;

  Future<void> init() async {
    if (!_supported) return;
    await _health.configure();
    if (_disposed) return;
    final granted = Platform.isAndroid
        ? await const MethodChannel(
            'gymbro/wearableHealth',
          ).invokeMethod<bool>('permission')
        : await _health.hasPermissions(typesToRead);
    if (!_disposed) hasPermissionStream.add(granted ?? false);
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid && _supported && !_disposed) {
      final granted =
          await const MethodChannel(
            'gymbro/wearableHealth',
          ).invokeMethod<bool>('authorize') ??
          false;
      if (!_disposed) hasPermissionStream.add(granted);
      return;
    }
    if (!_supported ||
        _disposed ||
        await _health.hasPermissions(typesToRead) == true) {
      return;
    }
    if (_disposed) return;
    final granted = await _health.requestAuthorization(typesToRead);
    if (!_disposed) hasPermissionStream.add(granted);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_ownsNative) _native.dispose();
    await hasPermissionStream.close();
  }
}

@Riverpod(keepAlive: true)
Health healthPlugin(Ref ref) => Health();

@Riverpod(keepAlive: true)
HealthController healthController(Ref ref) {
  final service = HealthController(
    health: ref.watch(healthPluginProvider),
    native: ref.watch(nativeServiceProvider),
    supported: Platform.isIOS || Platform.isAndroid,
  );
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
Stream<bool> healthPermission(Ref ref) =>
    ref.watch(healthControllerProvider).hasPermissionStream;

@riverpod
Stream<double?> healthEnergy(Ref ref) =>
    ref.watch(healthControllerProvider).energyStream;

@riverpod
Stream<double?> healthHeartRate(Ref ref) =>
    ref.watch(healthControllerProvider).heartRateStream;

import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_controller.g.dart';

typedef DebugState = ({Set<String> missingKeys, bool showSimulator});

@Riverpod(keepAlive: true)
class DebugController extends _$DebugController {
  @override
  DebugState build() => (missingKeys: const {}, showSimulator: false);

  void addMissingKey(String key) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!ref.mounted) return;
      state = (
        missingKeys: Set.unmodifiable({...state.missingKeys, key}),
        showSimulator: state.showSimulator,
      );
    });
  }

  void toggleSimulator() => setShowSimulator(!state.showSimulator);

  void setShowSimulator(bool value) {
    state = (missingKeys: state.missingKeys, showSimulator: value);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_offline/online_offline.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'connectivity.g.dart';

@riverpod
class NetworkConnectivityNotifier extends StreamNotifier<bool> {
  @override
  Stream<bool> build() {
    final connectionService = ConnectionService(
      checkInterval: const Duration(seconds: 30),
    );
    final BehaviorSubject<bool> connectivitySubject = BehaviorSubject<bool>();

    // When the state is destroyed, we close the StreamController.
    ref.onDispose(connectivitySubject.close);
    ref.onDispose(connectionService.dispose);

    connectionService.isOnline.addListener(() {
      connectivitySubject.add(connectionService.isOnline.value);
    });
    connectivitySubject.add(connectionService.isOnline.value);

    return connectivitySubject.stream;
  }
}

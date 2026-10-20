import 'dart:async';
import 'package:flutter/material.dart';

/// Owns refresh scheduling only for the lifetime of the visible route.
class VisibleDataRefresh extends StatefulWidget {
  const VisibleDataRefresh({
    super.key,
    required this.refresh,
    required this.child,
    this.interval = const Duration(minutes: 5),
  });
  final Future<void> Function() refresh;
  final Widget child;
  final Duration interval;
  @override
  State<VisibleDataRefresh> createState() => _VisibleDataRefreshState();
}

class _VisibleDataRefreshState extends State<VisibleDataRefresh>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(widget.interval, (_) => _refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!mounted ||
        _busy ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused ||
        ModalRoute.of(context)?.isCurrent == false)
      return;
    _busy = true;
    try {
      await widget.refresh();
    } catch (_) {
      /* Keep the last successful data. */
    } finally {
      _busy = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

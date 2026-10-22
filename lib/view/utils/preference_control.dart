import 'package:flutter/widgets.dart';

/// Binds a preference control directly to the persisted reactive source.
class PreferenceControl<T> extends StatelessWidget {
  const PreferenceControl({
    required this.initialValue,
    required this.builder,
    required this.onUpdate,
    super.key,
  });
  final T initialValue;
  final Widget Function(T value, void Function(T value) update) builder;
  final void Function(T value) onUpdate;

  @override
  Widget build(BuildContext context) => builder(initialValue, onUpdate);
}

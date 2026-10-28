/// Claims the first usable code synchronously, before any camera/navigation await.
/// A fresh scanner route owns a fresh gate; frames and manual entry share it.
class BarcodeScanGate {
  bool get completed => _completed;
  bool _completed = false;

  String? take(Iterable<String?> codes) {
    if (_completed) return null;
    for (final raw in codes) {
      final code = raw?.trim();
      if (code != null && RegExp(r'^[0-9]{4,32}$').hasMatch(code)) {
        _completed = true;
        return code;
      }
    }
    return null;
  }
}

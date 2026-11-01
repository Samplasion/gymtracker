class TrainerControlledException implements Exception {
  const TrainerControlledException();
  @override
  String toString() => 'This routine is managed by your trainer.';
}

class TrainerState {
  final Map<String, dynamic>? link;
  final Set<String> controls;
  final Set<String> protectedExercises;
  final List<Map<String, dynamic>> shares;
  final List<Map<String, dynamic>> offers;
  const TrainerState({
    this.link,
    this.controls = const {},
    this.protectedExercises = const {},
    this.shares = const [],
    this.offers = const [],
  });
  static const empty = TrainerState();
  factory TrainerState.fromJson(Map<String, dynamic> json) => TrainerState(
    link: json['link'] as Map<String, dynamic>?,
    controls: {
      for (final c in json['controls'] as List? ?? [])
        (c as Map)['routine_id'] as String,
    },
    protectedExercises: {
      for (final e in json['protected_exercises'] as List? ?? [])
        if (e is String) e,
    },
    shares: [
      for (final s in json['shares'] as List? ?? [])
        Map<String, dynamic>.from(s as Map),
    ],
    offers: [
      for (final o in json['offers'] as List? ?? [])
        Map<String, dynamic>.from(o as Map),
    ],
  );
}

import 'dart:math';

import 'package:gymtracker/repository/food_catalog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Delivers immutable publication requests, independently of diary sync.
class CatalogDelivery {
  CatalogDelivery({
    required this.outbox,
    required this.activeOwner,
    required this.submit,
    this.submitCreateOnly,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;
  final CatalogOutbox outbox;
  final String? Function() activeOwner;
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>,
  )
  submit;
  final Future<Map<String, dynamic>> Function(
    String,
    String,
    Map<String, dynamic>,
  )?
  submitCreateOnly;
  final DateTime Function() now;
  bool _working = false;
  bool _recovered = false;
  bool _disposed = false;

  void dispose() => _disposed = true;

  Future<void> process() async {
    if (_working || _disposed) return;
    _working = true;
    try {
      if (!_recovered) {
        await outbox.recoverInterrupted();
        _recovered = true;
      }
      while (!_disposed) {
        final owner = activeOwner();
        if (owner == null) return;
        final request = await outbox.next(owner, now());
        if (request == null) return;
        if (_disposed || activeOwner() != owner) return;
        if (!await outbox.claim(request)) continue;
        if (_disposed || activeOwner() != owner) {
          await outbox.finish(request, 'pending', nextAttempt: now());
          return;
        }
        try {
          final sender = request.createOnly ? submitCreateOnly : submit;
          if (sender == null) {
            throw StateError("Create-only delivery unavailable");
          }
          final result = await sender(
            owner,
            request.operationId,
            request.definition,
          ).timeout(const Duration(seconds: 15));
          final outcome = result['outcome'] as String;
          if (!const {
            'published',
            'duplicate',
            'correction',
            'unavailable',
            'already_present',
            'uncertain',
          }.contains(outcome)) {
            throw StateError('Unexpected catalog response');
          }
          await outbox.finish(request, outcome, result: result);
        } catch (error) {
          final permanent =
              error is PostgrestException &&
              const {'22023', '23514', '42501'}.contains(error.code);
          final seconds = error is PostgrestException && error.code == 'P1005'
              ? 86400
              : min(300, 5 * (1 << min(request.attempts, 6)));
          await outbox.finish(
            request,
            permanent ? 'failed' : 'pending',
            error: error is PostgrestException
                ? error.message
                : 'delivery_unavailable',
            nextAttempt: now().add(Duration(seconds: seconds)),
          );
        }
      }
    } finally {
      _working = false;
    }
  }
}

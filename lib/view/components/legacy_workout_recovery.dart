import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:intl/intl.dart';

class LegacyWorkoutRecoveryTile extends ConsumerStatefulWidget {
  const LegacyWorkoutRecoveryTile({super.key});

  @override
  ConsumerState<LegacyWorkoutRecoveryTile> createState() => _RecoveryState();
}

class _RecoveryState extends ConsumerState<LegacyWorkoutRecoveryTile> {
  late final service = ref.read(databaseServiceProvider);
  late final stream = service.db.watchLegacyOngoing();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(onlineProvider).value;
    return StreamBuilder<Map<String, dynamic>?>(
      stream: stream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final name = data['name'] as String? ?? '';
        final timestamp = data['time'];
        final date = timestamp is int
            ? DateFormat.yMd().format(
                DateTime.fromMillisecondsSinceEpoch(timestamp),
              )
            : '';
        return ListTile(
          leading: const Icon(Icons.restore),
          title: Text(context.t.legacyWorkoutRecovery.title),
          subtitle: Text([name, date].where((s) => s.isNotEmpty).join(' • ')),
          trailing: const Icon(Icons.chevron_right),
          enabled: !busy,
          onTap: () async {
            final userId = service.db.currentUserId;
            if (account?.id != userId) return;
            final confirmed = await Go.confirm(
              context.t.legacyWorkoutRecovery.action,
              context.t.legacyWorkoutRecovery.confirm(
                account: account == null
                    ? context.t.legacyWorkoutRecovery.guest
                    : '@${account.name}',
              ),
            );
            if (!confirmed || !mounted) return;
            setState(() => busy = true);
            try {
              if (service.db.currentUserId != userId) {
                throw StateError('Account changed during confirmation');
              }
              await service.db.recoverLegacyOngoing();
              await service.afterUserChange?.call();
            } catch (_) {
              if (context.mounted) {
                Go.dialog(
                  context.t.error.title,
                  context.t.legacyWorkoutRecovery.failed,
                );
              }
            } finally {
              if (mounted) setState(() => busy = false);
            }
          },
        );
      },
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/db/sync_diagnostics.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/sync_status.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/sync_conflict_resolution.dart';
import 'package:share_plus/share_plus.dart';

bool _it(BuildContext c) => Localizations.localeOf(c).languageCode == 'it';
Future<bool> offerGuestImport(
  BuildContext context,
  DatabaseService service,
  String owner,
) async {
  final preview = await GuestImportPreview.load(service.db, owner);
  if (preview.count == 0 || !context.mounted) return false;
  final it = _it(context);
  final selected = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(
        it ? 'Importare i dati senza account?' : 'Import guest data?',
      ),
      content: Text(
        it
            ? '${preview.count} record sul dispositivo. ${preview.collisions} collisioni: queste versioni resteranno separate e recuperabili. Gli altri dati saranno associati al tuo account.'
            : '${preview.count} records on this device. ${preview.collisions} collisions will remain separate and recoverable. Other data will be assigned to your account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(it ? 'Tieni separati' : 'Keep separate'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(it ? 'Importa' : 'Import'),
        ),
      ],
    ),
  );
  if (selected != true) return false;
  await preview.apply(service.db, owner);
  return true;
}

class SyncConflictsPage extends ConsumerStatefulWidget {
  const SyncConflictsPage({super.key});
  @override
  ConsumerState<SyncConflictsPage> createState() => _ConflictsState();
}

class _ConflictsState extends ConsumerState<SyncConflictsPage> {
  bool _history = false;
  bool _busy = false;
  int _completed = 0;
  int _total = 0;
  late Future<List<Map<String, dynamic>>> _rows = _load();

  Future<void> _resolveAll(
    List<Map<String, dynamic>> rows, {
    required bool useLocal,
  }) async {
    if (_busy || _history) return;
    final owner = ref.read(currentUserIdProvider);
    if (owner == null) return;
    final it = _it(context);
    final ids = {for (final row in rows) row['operation_id'] as String};
    final count = {
      for (final row in rows) (row['entity'], row['record_id']),
    }.length;
    final title = useLocal
        ? (it ? 'Tieni tutto dal dispositivo' : 'Keep everything from device')
        : (it ? 'Tieni tutto dal server' : 'Keep everything from server');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: Icon(
          useLocal ? Icons.phone_android_rounded : Icons.cloud_outlined,
        ),
        title: Text(title),
        content: Text(
          it
              ? 'Verranno risolte $count modifiche in conflitto usando le versioni ${useLocal ? 'del dispositivo, che saranno inviate al server alla prossima sincronizzazione' : 'del server, che sostituiranno quelle sul dispositivo'}. Le versioni alternative resteranno nella cronologia dei conflitti risolti.'
              : '$count conflicting changes will be resolved using ${useLocal ? 'device versions, which will be sent to the server during the next sync' : 'server versions, which will replace those on this device'}. Alternative versions will remain in the resolved conflict history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(it ? 'Annulla' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(it ? 'Conferma scelta' : 'Confirm choice'),
          ),
        ],
      ),
    );
    if (confirmed != true ||
        !mounted ||
        ref.read(currentUserIdProvider) != owner) {
      return;
    }
    setState(() {
      _busy = true;
      _completed = 0;
      _total = count;
    });
    try {
      final resolved = await resolveSelectedSyncConflicts(
        db: ref.read(databaseServiceProvider).db,
        manager: ref.read(onlineProvider.notifier).syncManager,
        owner: owner,
        operationIds: ids,
        useLocal: useLocal,
        onProgress: (completed, total) {
          if (mounted) {
            setState(() {
              _completed = completed;
              _total = total;
            });
          }
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              it
                  ? '$resolved modifiche risolte. Le versioni alternative sono nella cronologia.'
                  : '$resolved changes resolved. Alternative versions are in history.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              it
                  ? 'Impossibile completare la scelta. Le versioni restano conservate: controlla le modifiche e riprova.'
                  : 'Unable to complete your choice. Your versions are preserved: review the changes and retry.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _rows = _load();
        });
      }
    }
  }

  Widget _bulkActions(List<Map<String, dynamic>> rows, bool it) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card.filled(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rule_folder_outlined, color: colors.primary, size: 28),
            const SizedBox(height: 12),
            Text(
              it ? 'Risolvi tutte le modifiche' : 'Resolve all changes',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              it
                  ? 'Scegli quale versione mantenere per tutte le modifiche in conflitto. Le alternative resteranno nella cronologia.'
                  : 'Choose which version to keep for all conflicting changes. Alternatives will remain in history.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                final width = wide
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _resolveAll(rows, useLocal: false),
                        icon: const Icon(Icons.cloud_outlined),
                        label: Text(
                          it
                              ? 'Tieni tutto dal server'
                              : 'Keep everything from server',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _resolveAll(rows, useLocal: true),
                        icon: const Icon(Icons.phone_android_rounded),
                        label: Text(
                          it
                              ? 'Tieni tutto dal dispositivo'
                              : 'Keep everything from device',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_busy) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _total == 0 ? null : _completed / _total,
              ),
              const SizedBox(height: 8),
              Text(
                it
                    ? 'Risoluzione in corso… $_completed / $_total'
                    : 'Resolving changes… $_completed / $_total',
                semanticsLabel: it
                    ? 'Risoluzione in corso'
                    : 'Resolving changes',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final owner = ref.read(currentUserIdProvider);
    if (owner == null) return [];
    final db = ref.read(databaseServiceProvider).db;
    final rows = await db
        .customSelect(
          'SELECT c.*,(SELECT payload FROM sync_outbox o WHERE c.resolved=0 AND o.owner=c.owner AND o.entity=c.entity AND o.record_id=c.record_id ORDER BY sequence DESC LIMIT 1) AS pending_payload FROM sync_conflicts c WHERE owner=? AND resolved=?',
          variables: [Variable(owner), Variable(_history ? 1 : 0)],
        )
        .get();
    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      final value = Map<String, dynamic>.from(row.data);
      if (value['pending_payload'] != null) {
        // These are historical SQLite snapshots, not rows in today's schema.
        // Display their fields directly: newer required columns may be absent.
        value['local_payload'] = value['pending_payload'];
      }
      result.add(value);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final it = _it(context);
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _history
                ? (it ? 'Conflitti risolti' : 'Resolved conflicts')
                : (it ? 'Modifiche da confrontare' : 'Changes to compare'),
          ),
          actions: [
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _history = !_history;
                      _rows = _load();
                    }),
              child: Text(
                _history
                    ? (it ? 'Da risolvere' : 'Pending')
                    : (it ? 'Cronologia' : 'History'),
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _rows,
          builder: (c, s) {
            if (s.hasError) return Center(child: Text('${s.error}'));
            if (!s.hasData || s.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (s.data!.isEmpty)
              return Center(
                child: Text(
                  it
                      ? 'Nessun conflitto da risolvere'
                      : 'No conflicts to resolve',
                ),
              );
            return ListView.builder(
              itemCount: s.data!.length + (_history ? 0 : 1),
              itemBuilder: (context, index) {
                if (!_history && index == 0) return _bulkActions(s.data!, it);
                final row = s.data![index - (_history ? 0 : 1)];
                return ListTile(
                  title: Text(recoveryLabel(row['entity'] as String, it)),
                  subtitle: Text(
                    it
                        ? 'Entrambe le versioni sono conservate'
                        : 'Both versions are preserved',
                  ),
                  onTap: _busy
                      ? null
                      : () async {
                          final choice = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text(
                                it
                                    ? 'Confronta le versioni'
                                    : 'Compare versions',
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it ? 'Sul dispositivo' : 'On this device',
                                      style: Theme.of(c).textTheme.titleMedium,
                                    ),
                                    SelectableText(
                                      describeRecovery(
                                        row['local_payload'] as String,
                                        it,
                                      ),
                                    ),
                                    const Divider(),
                                    Text(
                                      it ? 'Sul server' : 'On the server',
                                      style: Theme.of(c).textTheme.titleMedium,
                                    ),
                                    SelectableText(
                                      describeRecovery(
                                        row['server_payload'] as String,
                                        it,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: Text(it ? 'Annulla' : 'Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: Text(
                                    _history
                                        ? (it
                                              ? 'Ripristina server'
                                              : 'Restore server version')
                                        : (it ? 'Usa server' : 'Use server'),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: Text(
                                    _history
                                        ? (it
                                              ? 'Ripristina dispositivo'
                                              : 'Restore device version')
                                        : (it
                                              ? 'Usa dispositivo'
                                              : 'Use device'),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (choice == null || !mounted) return;
                          try {
                            final manager = ref
                                .read(onlineProvider.notifier)
                                .syncManager;
                            if (_history) {
                              await manager.restoreConflictVersion(
                                row['operation_id'] as String,
                                useLocal: choice,
                              );
                            } else {
                              await manager.resolveConflict(
                                row['operation_id'] as String,
                                useLocal: choice,
                              );
                            }
                            if (mounted) setState(() => _rows = _load());
                          } catch (e) {
                            if (context.mounted)
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('$e')));
                          }
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

String recoveryLabel(String entity, bool it) => switch (entity) {
  'foods' => it ? 'Diario alimentare' : 'Food diary',
  'nutrition_goals' => it ? 'Obiettivi alimentari' : 'Nutrition goals',
  'nutrition_categories' => it ? 'Categorie alimentari' : 'Food categories',
  'custom_barcode_foods' => it ? 'Alimenti con barcode' : 'Barcode foods',
  'favorite_foods' => it ? 'Alimenti preferiti' : 'Favorite foods',
  'history_workouts' || 'history_workout_exercises' =>
    it ? 'Allenamenti completati' : 'Completed workouts',
  'routines' ||
  'routine_exercises' ||
  'routine_folders' => it ? 'Schede di allenamento' : 'Training plans',
  'custom_exercises' => it ? 'Esercizi personalizzati' : 'Custom exercises',
  'achievements_v2' => it ? 'Obiettivi raggiunti' : 'Achievements',
  'weight_measurements' ||
  'body_measurements' => it ? 'Misurazioni' : 'Measurements',
  _ => it ? 'Dati recuperati' : 'Recovered data',
};

String describeRecovery(String encoded, bool it) {
  final map = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
  var body = map['json_data'];
  if (body is String) {
    try {
      body = jsonDecode(body);
    } catch (_) {}
  }
  final fields = <String, dynamic>{
    ...map,
    if (body is Map) ...Map<String, dynamic>.from(body),
  };
  if (fields['deleted'] == 0 || fields['deleted'] == false) {
    fields['deleted'] = 'No';
  } else if (fields['deleted'] == 1 || fields['deleted'] == true) {
    fields['deleted'] = it ? 'Sì' : 'Yes';
  }
  final labels = {
    'name': it ? 'Nome' : 'Name',
    'calories': it ? 'Calorie' : 'Calories',
    'protein': it ? 'Proteine' : 'Protein',
    'carbs': it ? 'Carboidrati' : 'Carbs',
    'fat': it ? 'Grassi' : 'Fat',
    'amount': it ? 'Quantità' : 'Amount',
    'reference_date': it ? 'Giorno' : 'Day',
    'starting_date': it ? 'Inizio' : 'Started',
    'weight': it ? 'Peso' : 'Weight',
    'value': it ? 'Valore' : 'Value',
    'deleted': it ? 'Eliminato' : 'Deleted',
    'notes': it ? 'Note' : 'Notes',
  };
  final text = [
    for (final e in labels.entries)
      if (fields[e.key] != null) '${e.value}: ${fields[e.key]}',
  ];
  return text.isEmpty
      ? (it
            ? 'Versione conservata per il recupero'
            : 'Version preserved for recovery')
      : text.join('\n');
}

class PreservedDataPage extends ConsumerStatefulWidget {
  const PreservedDataPage({super.key});
  @override
  ConsumerState<PreservedDataPage> createState() => _PreservedState();
}

class _PreservedState extends ConsumerState<PreservedDataPage> {
  late Future<List<Map<String, dynamic>>> _rows = _load();
  Future<List<Map<String, dynamic>>> _load() async {
    final owner = ref.read(currentUserIdProvider);
    return (await ref
            .read(databaseServiceProvider)
            .db
            .customSelect(
              'SELECT * FROM sync_quarantine WHERE owner IS ? ORDER BY id DESC',
              variables: [Variable(owner)],
            )
            .get())
        .map((r) => r.data)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final it = _it(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(it ? 'Versioni conservate' : 'Preserved versions'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rows,
        builder: (context, s) {
          if (s.hasError) return Center(child: Text('${s.error}'));
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          if (s.data!.isEmpty)
            return Center(
              child: Text(
                it ? 'Nessuna versione conservata' : 'No preserved versions',
              ),
            );
          return ListView(
            children: [
              for (final row in s.data!)
                ListTile(
                  title: Text(recoveryLabel(row['entity'] as String, it)),
                  subtitle: Text(
                    describeRecovery(row['payload'] as String, it),
                  ),
                  onTap: () async {
                    final choice = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text(
                          it
                              ? 'Recuperare questa versione?'
                              : 'Recover this version?',
                        ),
                        content: Text(
                          it
                              ? 'Il valore attuale sarà conservato prima della modifica. Se il server è cambiato, potrai confrontare le versioni.'
                              : 'The current value will be preserved first. If the server changed, you can compare the versions.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: Text(it ? 'Annulla' : 'Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: Text(it ? 'Recupera' : 'Recover'),
                          ),
                        ],
                      ),
                    );
                    if (choice != true || !mounted) return;
                    try {
                      final online = ref.read(onlineProvider.notifier);
                      await online.syncManager.runPaused(
                        () => SyncDiagnostics.recover(
                          ref.read(databaseServiceProvider).db,
                          row['id'] as int,
                        ),
                      );
                      if (mounted) setState(() => _rows = _load());
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class SyncRecoveryActions extends ConsumerWidget {
  const SyncRecoveryActions({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final it = _it(context);
    final owner = ref.watch(currentUserIdProvider);
    final delivery = ref.watch(deliveryStatusProvider).value;
    final deletions = ref.watch(deletionAlertProvider).value ?? 0;
    final online = ref.watch(networkConnectivityProvider).value ?? false;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.save_outlined),
          title: Text(it ? 'Salvato sul dispositivo' : 'Saved on this device'),
          subtitle: Text(
            owner == null
                ? (it ? 'Accedi per sincronizzare' : 'Sign in to synchronize')
                : '${online ? "" : (it ? "Offline · " : "Offline · ")}${delivery?.pending ?? 0} ${it ? "operazioni da inviare" : "pending operations"} · ${delivery?.conflicts ?? 0} ${it ? "conflitti" : "conflicts"}',
          ),
        ),
        if (deletions >= 20)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(
              it
                  ? '$deletions eliminazioni oggi'
                  : '$deletions deletions today',
            ),
            subtitle: Text(
              it
                  ? 'Le versioni precedenti sono conservate. Controllale se non ti aspettavi queste eliminazioni.'
                  : 'Previous versions are preserved. Review them if these deletions were unexpected.',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PreservedDataPage(),
              ),
            ),
          ),
        if ((delivery?.errors ?? 0) > 0)
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: Text(
              it
                  ? 'Alcune modifiche non sono state inviate'
                  : 'Some changes could not be sent',
            ),
            subtitle: Text(
              it
                  ? 'La copia sul dispositivo è salvata. Puoi riprovare o esportare la diagnostica.'
                  : 'Your device copy is saved. Retry or export diagnostics.',
            ),
            trailing: TextButton(
              onPressed: () async {
                await ref.read(onlineProvider.notifier).synchronize();
              },
              child: Text(it ? 'Riprova' : 'Retry'),
            ),
          ),
        if (owner != null) ...[
          ListTile(
            leading: const Icon(Icons.compare_arrows),
            title: Text(it ? 'Confronta modifiche' : 'Compare changes'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SyncConflictsPage(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.move_to_inbox_outlined),
            title: Text(
              it ? 'Importa dati senza account' : 'Import guest data',
            ),
            onTap: () async {
              try {
                await ref
                    .read(onlineProvider.notifier)
                    .syncManager
                    .runPaused(
                      () => offerGuestImport(
                        context,
                        ref.read(databaseServiceProvider),
                        owner,
                      ).then((_) {}),
                    );
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
          ),
        ],
        ListTile(
          leading: const Icon(Icons.restore),
          title: Text(it ? 'Versioni conservate' : 'Preserved versions'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PreservedDataPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: Text(
            it
                ? 'Esporta diagnostica e copia dei dati'
                : 'Export diagnostics and data copy',
          ),
          onTap: () async {
            try {
              final directory = await Directory.systemTemp.createTemp(
                'gymtracker-diagnostic-',
              );
              final file = await SyncDiagnostics.export(
                ref.read(databaseServiceProvider).db,
                directory,
              );
              if (context.mounted)
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path), XFile('${file.path}.json')],
                    sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                  ),
                );
            } catch (e) {
              if (context.mounted)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$e')));
            }
          },
        ),
      ],
    );
  }
}

Future<RestoreMode?> previewBackupRestore(
  BuildContext context,
  DatabaseService service,
  DatabaseBackup backup,
) async {
  final prepared = await PreparedDatabaseRestore.load(
    backup.file,
    service.db.currentUserId,
  );
  if (!context.mounted) return null;
  final it = _it(context);
  return showDialog<RestoreMode>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(it ? 'Anteprima ripristino' : 'Restore preview'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${prepared.count} ${it ? "record nel backup" : "records in this backup"}',
            ),
            for (final e in prepared.rows.entries)
              if (e.value.isNotEmpty)
                Text('${recoveryLabel(e.key, it)}: ${e.value.length}'),
            const SizedBox(height: 16),
            Text(
              it
                  ? 'Unisci conserva i dati attuali e archivia le versioni differenti. Sostituisci elimina anche dal cloud i record esclusi dal backup. Una copia di sicurezza viene creata prima del ripristino.'
                  : 'Merge preserves current data and archives differing versions. Replace also deletes cloud records absent from the backup. A safety copy is created before restoring.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(it ? 'Annulla' : 'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, RestoreMode.replace),
          child: Text(
            it ? 'Sostituisci anche nel cloud' : 'Replace including cloud',
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, RestoreMode.merge),
          child: Text(it ? 'Unisci' : 'Merge'),
        ),
      ],
    ),
  );
}

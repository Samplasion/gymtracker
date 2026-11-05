import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/shared_program.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/shared_program.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' show isNetworkError;
import 'package:gymtracker/view/actions/purchases.dart';
import 'package:gymtracker/view/actions/routines.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/components/routine_import_content.dart';
import 'package:gymtracker/view/components/section_card.dart';

String _tr(BuildContext context, String it, String en) =>
    Localizations.localeOf(context).languageCode == 'it' ? it : en;
String _failure(BuildContext context, Object error) {
  final code = error.toString();
  if (code.contains('sign_in_required')) {
    return _tr(
      context,
      'Accedi al tuo account Gym Bro per condividere.',
      'Sign in to your Gym Bro account to share.',
    );
  }
  if (code.contains('unsupported_version')) {
    return _tr(
      context,
      'Aggiorna Gym Bro per aprire questo programma.',
      'Update Gym Bro to open this program.',
    );
  }
  if (code.contains('not_found') || code.contains('404')) {
    return _tr(
      context,
      'Il link non esiste o è stato revocato.',
      'This link does not exist or has been revoked.',
    );
  }
  if (code.contains('invalid_program') || error is FormatException) {
    return _tr(
      context,
      'Il programma non è valido.',
      'This program is invalid.',
    );
  }
  return isNetworkError(error)
      ? context.t.routineImport.networkError
      : context.t.routineImport.loadError;
}

Future<void> shareProgram(
  BuildContext context,
  WidgetRef ref,
  SharedProgramV1 program,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(_tr(c, 'Condividi programma', 'Share program')),
      content: Text(
        '${program.title}\n\n${_tr(c, 'Chiunque abbia il link potrà leggere esercizi, giornate e note. Verrà creata una copia fissa, revocabile dai link condivisi. È necessaria una connessione.', 'Anyone with the link can read exercises, days and notes. This creates a fixed copy you can revoke from shared links. A connection is required.')}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(MaterialLocalizations.of(c).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(_tr(c, 'Crea link', 'Create link')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    final uri = await ref
        .read(sharedProgramServiceProvider)
        .create(program, Localizations.localeOf(context).languageCode);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ShareRoutineAlertDialog(uri: uri),
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_failure(context, error))));
    }
  }
}

class SharedProgramImportView extends ConsumerStatefulWidget {
  final String token;
  const SharedProgramImportView({required this.token, super.key});
  @override
  ConsumerState<SharedProgramImportView> createState() =>
      _SharedProgramImportState();
}

class _SharedProgramImportState extends ConsumerState<SharedProgramImportView> {
  late Future<SharedProgramV1> _program;
  bool _busy = false;
  int _day = 0;
  String? _error;
  @override
  void initState() {
    super.initState();
    _program = ref.read(sharedProgramServiceProvider).read(widget.token);
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sharedProgramServiceProvider)
          .import(widget.token, ref.read(databaseServiceProvider));
      ref.read(backupSchedulerProvider).schedule();
      if (mounted) {
        Go.back();
        Go.snack(context.t.importRoutine.import.done);
      }
    } catch (e) {
      if (mounted) setState(() => _error = _failure(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<SharedProgramV1>(
    future: _program,
    builder: (context, snapshot) {
      final program = snapshot.data;
      final routines = program?.materialize().routines;
      return PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              program?.title ??
                  _tr(context, 'Programma condiviso', 'Shared program'),
            ),
          ),
          body: program != null && routines != null
              ? RoutineImportContent(
                  routines: routines,
                  notes: program.notes,
                  selectedDay: _day,
                  onDayChanged: _busy
                      ? null
                      : (day) => setState(() => _day = day),
                )
              : _ImportLoadState(
                  error: snapshot.hasError
                      ? _failure(context, snapshot.error!)
                      : null,
                  onRetry: () {
                    final request = ref
                        .read(sharedProgramServiceProvider)
                        .read(widget.token);
                    setState(() {
                      _program = request;
                    });
                  },
                ),
          bottomNavigationBar: program == null
              ? null
              : ProBuilder(
                  builder: (context, subscription) => RoutineImportActionBar(
                    isPro: subscription?.hasProFeatures == true,
                    busy: _busy,
                    error: _error,
                    onPressed: () {
                      if (subscription?.hasProFeatures != true) {
                        ref.read(purchasesControllerProvider).presentPaywall();
                        return;
                      }
                      _import();
                    },
                  ),
                ),
        ),
      );
    },
  );
}

class _ImportLoadState extends StatelessWidget {
  const _ImportLoadState({required this.error, required this.onRetry});
  final String? error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Semantics(
            liveRegion: true,
            child: GTSectionCard(
              icon: error == null
                  ? Icons.downloading_rounded
                  : Icons.link_off_rounded,
              title: error == null
                  ? context.t.routineImport.loadingTitle
                  : context.t.routineImport.unavailableTitle,
              subtitle: error ?? context.t.routineImport.loadingDescription,
              child: error == null
                  ? const LinearProgressIndicator()
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(context.t.routineImport.retry),
                      ),
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SharedProgramLinksView extends ConsumerStatefulWidget {
  const SharedProgramLinksView({super.key});
  @override
  ConsumerState<SharedProgramLinksView> createState() =>
      _SharedProgramLinksState();
}

class _SharedProgramLinksState extends ConsumerState<SharedProgramLinksView> {
  late Future<List<Map<String, dynamic>>> links;
  final busy = <String>{};
  @override
  void initState() {
    super.initState();
    links = ref.read(sharedProgramServiceProvider).shares();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_tr(context, 'Link condivisi', 'Shared links'))),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: links,
      builder: (context, s) {
        if (s.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_failure(context, s.error!)),
                TextButton(
                  onPressed: () => setState(
                    () =>
                        links = ref.read(sharedProgramServiceProvider).shares(),
                  ),
                  child: Text(_tr(context, 'Riprova', 'Retry')),
                ),
              ],
            ),
          );
        }
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        if (s.data!.isEmpty) {
          return Center(
            child: Text(
              _tr(context, 'Nessun link condiviso.', 'No shared links.'),
            ),
          );
        }
        return ListView(
          children: [
            for (final link in s.data!)
              ListTile(
                title: Text(link['title'] as String),
                subtitle: Text(
                  link['revoked_at'] == null
                      ? _tr(context, 'Attivo', 'Active')
                      : _tr(context, 'Revocato', 'Revoked'),
                ),
                onTap: link['revoked_at'] != null
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text:
                                '${SharedProgramService.site}/${Localizations.localeOf(context).languageCode}/share/${link['token']}',
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _tr(context, 'Link copiato.', 'Link copied.'),
                              ),
                            ),
                          );
                        }
                      },
                trailing: link['revoked_at'] != null
                    ? null
                    : TextButton(
                        onPressed: busy.contains(link['id'])
                            ? null
                            : () async {
                                setState(() => busy.add(link['id'] as String));
                                try {
                                  await ref
                                      .read(sharedProgramServiceProvider)
                                      .revoke(link['id'] as String);
                                  if (mounted) {
                                    setState(
                                      () => links = ref
                                          .read(sharedProgramServiceProvider)
                                          .shares(),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_failure(context, e)),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => busy.remove(link['id']));
                                  }
                                }
                              },
                        child: Text(_tr(context, 'Revoca', 'Revoke')),
                      ),
              ),
          ],
        );
      },
    ),
  );
}

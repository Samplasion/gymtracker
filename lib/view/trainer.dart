import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/trainer.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/purchases.dart';
import 'package:gymtracker/view/components/section_card.dart';
import 'package:gymtracker/view/login.dart';
import 'package:m3e_core/m3e_core.dart';

String trainerText(BuildContext context, String it, String en) =>
    Localizations.localeOf(context).languageCode == 'it' ? it : en;

Workout trainerRoutine(Map<String, dynamic> r) =>
    workoutFromDatabase(Routine.fromJson({...r, 'sort_order': 0}), [
      for (final e in r['exercises'] as List? ?? [])
        RoutineExercise.fromJson({
          ...Map<String, dynamic>.from(e as Map),
          'routine_id': r['id'],
        }),
    ]);

class TrainerView extends ConsumerStatefulWidget {
  final String? token;
  const TrainerView({super.key, this.token});
  @override
  ConsumerState<TrainerView> createState() => _TrainerViewState();
}

class _TrainerViewState extends ConsumerState<TrainerView> {
  late final TextEditingController token = TextEditingController(
    text: widget.token,
  );
  bool busy = false;
  String? error;
  @override
  void dispose() {
    token.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(currentUserIdProvider) != null) _refresh();
    });
  }

  String tr(String it, String en) => trainerText(context, it, en);
  Future<void> _refresh() async {
    await _run(
      () => ref
          .read(trainerServiceProvider)
          .refreshAndSync(
            () => ref.read(onlineProvider.notifier).synchronizeFresh(),
          ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } on TrainerApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'relationship_ended') {
        await ref.read(trainerServiceProvider).refreshIfAvailable();
      }
      if (!mounted) return;
      if ([
        'routine_slots_exhausted',
        'exercise_slots_exhausted',
      ].contains(e.code)) {
        await ref.read(purchasesControllerProvider).presentPaywall();
      } else {
        setState(
          () => error = switch (e.code) {
            'already_linked' => tr(
              'Hai già un trainer collegato.',
              'You already have a trainer.',
            ),
            'self_link' => tr(
              'Non puoi collegare il tuo stesso account.',
              'You cannot connect to yourself.',
            ),
            'invite_unavailable' => tr(
              'Invito scaduto o non più disponibile.',
              'Invitation expired or unavailable.',
            ),
            'proposal_superseded' => tr(
              'La proposta è cambiata. Aggiorna prima di accettare.',
              'The proposal changed. Refresh before accepting.',
            ),
            'relationship_ended' => tr(
              'Il collegamento è terminato. Aggiorna per liberare le schede.',
              'The relationship ended. Refresh to release your routines.',
            ),
            'download_pending' => tr(
              'La scheda è stata accettata, ma il download non è completo. Premi Aggiorna per riprenderlo, senza accettarla di nuovo.',
              'Your plan was accepted, but the download is incomplete. Tap Refresh to resume it without accepting again.',
            ),
            'sync_pending' => tr(
              'L’operazione è stata completata. Restano modifiche da sincronizzare: controlla lo stato della sincronizzazione nel profilo. Eventuali conflitti sono consultabili in «Confronta modifiche».',
              'The action completed. Some changes still need to synchronize: check the sync status in your profile. Any conflicts are available under “Compare changes”.',
            ),
            'sync_required' => tr(
              'La sincronizzazione non è completa: l’operazione non è stata eseguita. Controlla lo stato della sincronizzazione e riprova.',
              'Synchronization is incomplete: the action has not been performed. Check your sync status and retry.',
            ),
            'sync_conflicts' => tr(
              'Prima di accettare la scheda, risolvi le modifiche in conflitto: dal profilo apri «Confronta modifiche». Le versioni sul dispositivo e sul server sono conservate.',
              'Before accepting the plan, resolve conflicting changes: open “Compare changes” from your profile. Both device and server versions are preserved.',
            ),
            'request_timeout' => tr(
              'Il server non ha risposto in tempo. Premi Aggiorna per verificare se la scheda è stata accettata e completarne il download.',
              'The server did not respond in time. Tap Refresh to check whether the plan was accepted and finish downloading it.',
            ),
            'network_unavailable' => tr(
              'Impossibile raggiungere il server. Controlla la connessione e premi Aggiorna per verificare lo stato della scheda.',
              'Unable to reach the server. Check your connection and tap Refresh to check the plan status.',
            ),
            'billing_unavailable' => tr(
              'Non è stato possibile verificare l’abbonamento. Riprova tra poco.',
              'Unable to verify your subscription right now. Please try again shortly.',
            ),
            'temporarily_unavailable' => tr(
              'Il servizio è temporaneamente non disponibile. Riprova tra poco.',
              'The service is temporarily unavailable. Please try again shortly.',
            ),
            'noncontiguous_superset' => tr(
              'La scheda contiene superserie non consecutive. Chiedi al trainer di correggerla e inviarla di nuovo.',
              'The plan contains non-consecutive supersets. Ask your trainer to correct and resend it.',
            ),
            'update_required' => tr(
              'Aggiorna Gym Bro per accettare le schede del trainer.',
              'Update Gym Bro to accept trainer plans.',
            ),
            'account_changed' => tr(
              'L’account è cambiato. Riapri la pagina del trainer.',
              'Your account changed. Reopen the trainer page.',
            ),
            'unauthorized' || 'sign_in_required' => tr(
              'Accedi al tuo account dal profilo per continuare.',
              'Sign in from your profile to continue.',
            ),
            _ => tr(
              'Operazione non riuscita. Premi Aggiorna e riprova.',
              'Unable to complete the action. Tap Refresh and retry.',
            ),
          },
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = tr(
            'Operazione non riuscita. Riprova.',
            'Unable to complete the action. Please retry.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> mutate(
    String operation,
    Map<String, dynamic> payload, {
    bool sync = false,
  }) => _run(
    () => ref
        .read(trainerServiceProvider)
        .performMutation(
          operation,
          payload,
          synchronize: sync
              ? () => ref.read(onlineProvider.notifier).synchronizeFresh()
              : null,
        ),
  );
  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(currentUserIdProvider);
    final colors = Theme.of(context).colorScheme;
    ref.listen(currentUserIdProvider, (previous, next) {
      if (next != null && previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refresh();
        });
      }
    });
    final state = owner == null
        ? const TrainerState()
        : ref.watch(trainerStateProvider).value ??
              ref.read(appDatabaseProvider).cachedTrainerState;
    final link = state.link;
    final routines = owner == null
        ? const <Workout>[]
        : ref.watch(routinesStreamProvider).value ?? const <Workout>[];
    final folders = owner == null
        ? const <GTRoutineFolder>[]
        : ref.watch(foldersStreamProvider).value ?? const <GTRoutineFolder>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Il mio trainer', 'My trainer')),
        actions: [
          if (owner != null)
            IconButton(
              onPressed: busy ? null : _refresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: tr('Aggiorna', 'Refresh'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 760,
            child: RefreshIndicator(
              onRefresh: owner == null ? () async {} : _refresh,
              notificationPredicate: (_) => owner != null,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (busy) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _TrainerSummary(
                    title: owner == null || link == null
                        ? tr(
                            'Schede e progressi con il tuo trainer',
                            'Training plans and progress with your trainer',
                          )
                        : link['trainer_name'] as String? ?? 'Trainer',
                    subtitle: owner == null || link == null
                        ? tr(
                            'Ricevi schede di allenamento e scegli quali routine condividere.',
                            'Receive training plans and choose which routines to share.',
                          )
                        : tr(
                            'Schede assegnate, revisioni e routine condivise.',
                            'Assigned plans, revisions and shared routines.',
                          ),
                    status: owner != null && link != null
                        ? tr('Collegamento attivo', 'Active relationship')
                        : null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: _TrainerPanel(
                        color: colors.errorContainer,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colors.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (owner == null)
                    _TrainerPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TrainerHeading(
                            title: tr(
                              'Il tuo prossimo passo',
                              'Your next step',
                            ),
                            subtitle: tr(
                              'Accedi al tuo account per collegarti a un trainer.',
                              'Sign in to your account to connect to a trainer.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => Go.to(() => const AuthScreen()),
                            icon: const Icon(Icons.login_rounded),
                            label: Text(tr('Accedi', 'Sign in')),
                          ),
                        ],
                      ),
                    )
                  else if (link == null)
                    _invitationPanel()
                  else ...[
                    GTSectionCard(
                      icon: Icons.inbox_outlined,
                      title: tr('Da accettare', 'Waiting for you'),
                      subtitle: tr(
                        'Controlla le nuove schede e le revisioni prima di aggiungerle.',
                        'Review new plans and revisions before adding them.',
                      ),
                      trailing: Chip(
                        label: Text('${state.offers.length}'),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.offers.isEmpty)
                            _TrainerEmptyState(
                              icon: Icons.task_alt_rounded,
                              title: tr('Sei in pari', 'You’re all caught up'),
                              message: tr(
                                'Le nuove proposte del trainer compariranno qui.',
                                'New proposals from your trainer will appear here.',
                              ),
                            ),
                          for (var i = 0; i < state.offers.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _offerPanel(state.offers[i], link),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GTSectionCard(
                      icon: Icons.fitness_center_rounded,
                      title: tr('Le tue routine', 'Your routines'),
                      subtitle: tr(
                        'Scegli quali routine personali condividere. Le schede assegnate restano condivise durante il collegamento.',
                        'Choose which personal routines to share. Assigned plans stay shared while connected.',
                      ),
                      trailing: Chip(
                        label: Text('${routines.length}'),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                      child: routines.isEmpty
                          ? _TrainerEmptyState(
                              icon: Icons.fitness_center_rounded,
                              title: tr(
                                'Il tuo percorso parte da qui',
                                'Your training starts here',
                              ),
                              message: tr(
                                'Qui troverai le schede accettate e le tue routine personali.',
                                'Your accepted plans and personal routines will appear here.',
                              ),
                            )
                          : _sharingRoutines(routines, folders, state, link),
                    ),
                    const SizedBox(height: 16),
                    _TrainerPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TrainerHeading(
                            icon: Icons.link_off_rounded,
                            title: tr(
                              'Il collegamento è una tua scelta',
                              'Your connection, your choice',
                            ),
                            subtitle: tr(
                              'Puoi interromperlo in qualsiasi momento. Le schede e gli allenamenti restano nel tuo account.',
                              'You can end it at any time. Your plans and workouts stay in your account.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.error,
                            ),
                            onPressed: busy ? null : () => _disconnect(link),
                            icon: const Icon(Icons.link_off_rounded),
                            label: Text(
                              tr('Interrompi collegamento', 'End relationship'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _invitationPanel() => _TrainerPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TrainerHeading(
          icon: Icons.person_add_alt_1_rounded,
          title: tr('Collegati al tuo trainer', 'Connect to your trainer'),
          subtitle: tr(
            'Incolla l’invito che hai ricevuto per iniziare. Puoi avere un solo trainer collegato.',
            'Paste the invitation you received to get started. You can have one connected trainer.',
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: token,
          enabled: !busy,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: tr('Invito del trainer', 'Trainer invitation'),
            hintText: tr('Incolla il link o il codice', 'Paste a link or code'),
            prefixIcon: const Icon(Icons.link_rounded),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr(
                  'Il trainer vedrà la data del tuo ultimo allenamento. I dettagli restano visibili solo per le sue schede e le routine che scegli di condividere.',
                  'Your trainer can see your latest workout date. Details are only visible for assigned plans and routines you choose to share.',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: token,
          builder: (context, value, _) => FilledButton.icon(
            onPressed: busy || value.text.trim().isEmpty
                ? null
                : () {
                    final raw = token.text.trim();
                    final value =
                        Uri.tryParse(raw)?.queryParameters['token'] ?? raw;
                    mutate('invite_accept', {'token': value});
                  },
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(tr('Accetta collegamento', 'Accept connection')),
          ),
        ),
      ],
    ),
  );

  Widget _offerPanel(Map<String, dynamic> offer, Map<String, dynamic> link) =>
      _TrainerPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              offer['active_revision'] == null
                  ? tr('NUOVA SCHEDA', 'NEW PLAN')
                  : tr('REVISIONE', 'REVISION'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer['name'] as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final routine
                in ((offer['revision'] as Map)['document'] as Map)['routines']
                    as List)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text(routine['name'] as String),
                subtitle: Text(
                  _differenceText(offer, Map<String, dynamic>.from(routine)),
                ),
                children: [
                  for (final e in routine['exercises'] as List)
                    if (e['is_superset'] != true)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        title: Text(e['name'] as String),
                        subtitle: Text(
                          _exercisePreview(
                            Map<String, dynamic>.from(e as Map),
                            Map<String, dynamic>.from(routine),
                          ),
                        ),
                      ),
                ],
              ),
            for (final removed in _removedRoutines(offer))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(removed['name'] as String),
                subtitle: Text(
                  tr(
                    'Rimossa dal piano: resterà come routine personale.',
                    'Removed from the plan: it stays as a personal routine.',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => mutate('accept', {
                          'link_id': link['id'],
                          'plan_id': offer['id'],
                          'revision_id': (offer['revision'] as Map)['id'],
                        }, sync: true),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(tr('Accetta', 'Accept')),
                ),
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => mutate('reject', {
                          'link_id': link['id'],
                          'plan_id': offer['id'],
                          'revision_id': (offer['revision'] as Map)['id'],
                        }),
                  child: Text(tr('Rifiuta', 'Reject')),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _sharingRoutines(
    List<Workout> routines,
    List<GTRoutineFolder> folders,
    TrainerState state,
    Map<String, dynamic> link,
  ) {
    // The routine stream already follows the user's sort order within each
    // folder. Grouping must preserve it rather than interleaving equal indices.
    final byId = <String, GTRoutineFolder>{
      for (final routine in routines)
        if (routine.folder != null) routine.folder!.id: routine.folder!,
      for (final folder in folders) folder.id: folder,
    };
    final ordered =
        byId.values
            .where((folder) => routines.any((r) => r.folder?.id == folder.id))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final unfiled = routines.where((r) => r.folder == null).toList();
    final owner = ref.read(currentUserIdProvider);
    if (owner == null) return const SizedBox.shrink();
    final linkId = link['id'] as String;
    final expanded =
        ref.read(trainerFolderExpansionProvider)[(owner, linkId)] ??
        const <String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ordered.isNotEmpty)
          M3EExpandableCardColumn.builder(
            // Expansion is indexed by the component. Recreate it when folder
            // order changes, restoring the user's open folders by ID.
            key: ValueKey((
              owner,
              linkId,
              Object.hashAll(ordered.map((folder) => folder.id)),
            )),
            allowMultipleExpanded: true,
            initiallyExpanded: {
              for (var i = 0; i < ordered.length; i++)
                if (expanded.contains(ordered[i].id)) i,
            },
            onExpansionChanged: (index, isExpanded) => ref
                .read(trainerFolderExpansionProvider.notifier)
                .setExpanded(owner, linkId, ordered[index].id, isExpanded),
            itemCount: ordered.length,
            style: M3EExpandableStyle(
              color: Theme.of(context).cardColor,
              border: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              outerRadius: 24,
              expandedRadius: 24,
              margin: EdgeInsets.zero,
              gap: 8,
              headerPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              bodyPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            ),
            headerBuilder: (context, index, progress) {
              final folder = ordered[index];
              final count = routines
                  .where((r) => r.folder?.id == folder.id)
                  .length;
              return Row(
                children: [
                  const Icon(Icons.folder_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          folder.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr(
                            '$count routine',
                            '$count ${count == 1 ? 'routine' : 'routines'}',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            bodyBuilder: (context, index, progress) {
              // The card animates the body height. Keep the header independent
              // and avoid a second height animation inside the clipped body.
              if (progress <= 0) return const SizedBox.shrink();
              final grouped = routines
                  .where((r) => r.folder?.id == ordered[index].id)
                  .toList();
              return Column(
                children: [
                  for (var i = 0; i < grouped.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _routinePanel(grouped[i], state, link),
                  ],
                ],
              );
            },
          ),
        for (var i = 0; i < unfiled.length; i++) ...[
          if (i > 0 || ordered.isNotEmpty) const SizedBox(height: 8),
          _routinePanel(unfiled[i], state, link),
        ],
      ],
    );
  }

  Widget _routinePanel(
    Workout routine,
    TrainerState state,
    Map<String, dynamic> link,
  ) {
    final controlled = state.controls.contains(routine.id);
    final shared = state.shares.any((s) => s['routine_id'] == routine.id);
    final colors = Theme.of(context).colorScheme;
    return _TrainerPanel(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: controlled || shared
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              controlled
                  ? Icons.assignment_outlined
                  : Icons.fitness_center_rounded,
              size: 22,
              color: controlled || shared
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  controlled
                      ? tr('Assegnata dal trainer', 'Assigned by trainer')
                      : shared
                      ? tr('Condivisa da te', 'Shared by you')
                      : tr('Solo tu puoi vederla', 'Only you can see this'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (controlled)
            Tooltip(
              message: tr(
                'Condivisa per la durata del collegamento',
                'Shared while connected',
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Semantics(
              label: '${tr('Condividi', 'Share')} ${routine.name}',
              child: Switch(
                value: shared,
                onChanged: busy
                    ? null
                    : (value) => _setSharing(routine, link, value),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _setSharing(
    Workout routine,
    Map<String, dynamic> link,
    bool value,
  ) async {
    if (!value) {
      await mutate('unshare', {
        'link_id': link['id'],
        'routine_id': routine.id,
      });
      return;
    }
    final previous = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr(
            'Quali allenamenti condividere?',
            'Which workouts should be shared?',
          ),
        ),
        content: Text(
          tr(
            'Puoi includere lo storico precedente oppure solo gli allenamenti da questo momento.',
            'Include previous workouts or share only workouts from now on.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('Annulla', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('Solo da oggi', 'From now on')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('Anche precedenti', 'Include previous')),
          ),
        ],
      ),
    );
    if (previous != null && mounted) {
      await mutate('share', {
        'link_id': link['id'],
        'routine_id': routine.id,
        'include_previous': previous,
      }, sync: true);
    }
  }

  Future<void> _disconnect(Map<String, dynamic> link) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          tr('Interrompere il collegamento?', 'End the relationship?'),
        ),
        content: Text(
          tr(
            'Il trainer perderà l’accesso ai tuoi dati. Schede, esercizi e allenamenti resteranno tuoi e diventeranno liberamente gestibili.',
            'Your trainer will lose access to your data. Plans, exercises and workouts stay in your account and become freely manageable.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('Annulla', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('Interrompi', 'Disconnect')),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      await mutate('disconnect', {'link_id': link['id']});
    }
  }

  List<Map<String, dynamic>> _removedRoutines(Map<String, dynamic> offer) {
    final active = offer['active_revision'] as Map?;
    final previous = active?['document']?['routines'] as List? ?? [];
    final next = (offer['revision'] as Map)['document']['routines'] as List;
    return [
      for (final r in previous)
        if (!next.any((n) => n['id'] == r['id']))
          Map<String, dynamic>.from(r as Map),
    ];
  }

  String _exercisePreview(
    Map<String, dynamic> exercise,
    Map<String, dynamic> routine,
  ) {
    final sets = exercise['sets'] as List? ?? [];
    final targets = sets
        .map(
          (s) => [
            if (s['reps'] != null) "${s['reps']} ${tr('rip.', 'reps')}",
            if (s['weight'] != null && s['weight'] != 0)
              "${s['weight']} ${routine['weight_unit']}",
            if (s['time'] != null && s['time'] != 0)
              "${(s['time'] as num) / 1000000}s",
            if (s['distance'] != null && s['distance'] != 0)
              "${s['distance']} ${routine['distance_unit']}",
            if (s['rpe'] != null) "RPE ${s['rpe']}",
          ].join(' · '),
        )
        .join(' / ');
    return [
      "${sets.length} ${tr('serie', 'sets')} · ${exercise['rest_time'] ?? 90}s ${tr('recupero', 'rest')}",
      targets,
      if ((exercise['notes'] as String? ?? '').isNotEmpty)
        exercise['notes'] as String,
    ].join('\n');
  }

  String _differenceText(
    Map<String, dynamic> offer,
    Map<String, dynamic> routine,
  ) {
    final active = offer['active_revision'] as Map?;
    final old = active?['document']?['routines'] as List?;
    Map<String, dynamic>? previous;
    for (final r in old ?? []) {
      if (r['id'] == routine['id']) {
        previous = Map<String, dynamic>.from(r as Map);
      }
    }
    if (previous == null) return tr('Nuova routine', 'New routine');
    final diff = WorkoutDifference.fromWorkouts(
      oldWorkout: trainerRoutine(previous),
      newWorkout: trainerRoutine(routine),
    );
    return '${tr('Aggiunti', 'Added')}: ${diff.addedExercises} · ${tr('Rimossi', 'Removed')}: ${diff.removedExercises} · ${tr('Modificati', 'Changed')}: ${diff.changedExercises} · ${tr('Riordinati', 'Reordered')}: ${diff.reorderedExercises}${diff.metadataChanged ? tr(' · Nome o note modificati', ' · Name or notes changed') : ''}';
  }
}

class _TrainerPanel extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _TrainerPanel({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return GTSectionCard(color: color, child: child);
  }
}

class _TrainerSummary extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? status;
  const _TrainerSummary({
    required this.title,
    required this.subtitle,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return _TrainerPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GTSectionIcon(Icons.sports_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    status!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerHeading extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String subtitle;
  const _TrainerHeading({
    this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              GTSectionIcon(icon!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TrainerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _TrainerEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Icon(icon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

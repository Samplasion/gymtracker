import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/view/legal.dart';
import 'package:purchases_ui_flutter/views/paywall_view.dart';

class PaywallScreen extends StatelessWidget {
  static const routeName = '/paywall';

  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return const _CustomPaywallView();
    }
    return PaywallView(
      displayCloseButton: true,
      onDismiss: () => Navigator.of(context).maybePop(),
      onPurchaseCompleted: (_, _) => Navigator.of(context).maybePop(),
      onRestoreCompleted: (_) => Navigator.of(context).maybePop(),
    );
  }
}

class _CustomPaywallView extends ConsumerStatefulWidget {
  const _CustomPaywallView();

  @override
  ConsumerState<_CustomPaywallView> createState() => _CustomPaywallViewState();
}

class _CustomPaywallViewState extends ConsumerState<_CustomPaywallView> {
  PurchasesController get _purchases => ref.read(purchasesControllerProvider);
  late Future<Offering?> _future;
  Subscription? _selectedSubscription;
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Offering?> _load() async {
    try {
      final offering = await _purchases.getPaywallData();
      if (mounted) {
        setState(() {
          _selectedSubscription = offering?.subscriptions.firstOrNull;
        });
      }
      return offering;
    } catch (error, stack) {
      logger.e('Error loading paywall', error: error, stackTrace: stack);
      rethrow;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy || _loading) return;
    setState(() {
      _selectedSubscription = null;
      _loading = true;
      _future = _load();
    });
    // FutureBuilder displays the failure; pull-to-refresh must also complete.
    try {
      await _future;
    } catch (_) {}
  }

  Future<void> _purchase() async {
    final subscription = _selectedSubscription;
    if (subscription == null || _busy || _loading) return;
    setState(() => _busy = true);
    var status = SubscriptionPurchaseStatus.error;
    try {
      status = await _purchases.purchaseSubscription(subscription);
    } catch (error, stack) {
      logger.e(
        'Error purchasing subscription',
        error: error,
        stackTrace: stack,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    switch (status) {
      case SubscriptionPurchaseStatus.success:
        await _close();
      case SubscriptionPurchaseStatus.cancelled:
        break;
      case SubscriptionPurchaseStatus.error:
        await _showError(
          context.t.paywall.purchaseError.title,
          context.t.paywall.purchaseError.subtitle,
        );
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    var failed = false;
    try {
      await _purchases.restorePurchases();
    } catch (error, stack) {
      failed = true;
      logger.e('Error restoring purchases', error: error, stackTrace: stack);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    if (failed) {
      await _showError(
        context.t.paywall.restoreError.title,
        context.t.paywall.restoreError.subtitle,
      );
    } else {
      await _close();
    }
  }

  Future<void> _close() async {
    // Let PopScope receive the cleared busy state before requesting navigation.
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _showError(String title, String message) => showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );

  String _trialText(SubscriptionTrial trial) {
    final t = context.t.paywall.trialPeriod;
    return switch (trial.periodType) {
      SubscriptionPeriod.day => t.day(n: trial.duration),
      SubscriptionPeriod.week => t.week(n: trial.duration),
      SubscriptionPeriod.month => t.month(n: trial.duration),
      SubscriptionPeriod.year => t.year(n: trial.duration),
    };
  }

  String _renewalText(Subscription subscription) {
    final t = context.t.paywall.autoRenewNotice;
    return switch (subscription.duration) {
      SubscriptionPeriod.day => t.day(price: subscription.price),
      SubscriptionPeriod.week => t.week(price: subscription.price),
      SubscriptionPeriod.month => t.month(price: subscription.price),
      SubscriptionPeriod.year => t.year(price: subscription.price),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.paywall;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(t.title), automaticallyImplyLeading: !_busy),
        body: FutureBuilder<Offering?>(
          future: _future,
          builder: (context, snapshot) {
            final subscriptions = snapshot.data?.subscriptions ?? [];
            return RefreshIndicator.adaptive(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    t.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Center(child: CircularProgressIndicator.adaptive())
                  else if (snapshot.hasError || subscriptions.isEmpty) ...[
                    Text(snapshot.hasError ? t.loadError : t.empty),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _busy ? null : _refresh,
                        child: Text(context.t.error.retry),
                      ),
                    ),
                  ] else
                    for (final subscription in subscriptions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          subscription == _selectedSubscription
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.circle,
                        ),
                        onTap: _busy
                            ? null
                            : () => setState(() {
                                _selectedSubscription = subscription;
                              }),
                        title: Text(subscription.displayName),
                        subtitle: subscription.trial == null
                            ? null
                            : Text(_trialText(subscription.trial!)),
                        trailing: Text(subscription.price),
                      ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed:
                        _selectedSubscription == null || _busy || _loading
                        ? null
                        : _purchase,
                    child: Text(t.actions.subscribe),
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ],
                  if (_selectedSubscription != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _renewalText(_selectedSubscription!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _busy ? null : _restore,
                        child: Text(t.actions.restorePurchase),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const TosViewerPage(),
                                ),
                              ),
                        child: Text(t.actions.termsOfService),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const PrivacyViewerPage(),
                                ),
                              ),
                        child: Text(t.actions.privacyPolicy),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

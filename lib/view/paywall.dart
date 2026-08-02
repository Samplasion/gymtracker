import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:purchases_ui_flutter/views/paywall_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PaywallScreen extends StatelessWidget {
  static const routeName = "/paywall";

  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) return const _CustomPaywallView();
    return PaywallView(
      displayCloseButton: true,
      onDismiss: () {
        Navigator.of(context).maybePop();
      },
      onPurchaseCompleted: (customerInfo, storeTransaction) {
        // Handle purchase completion
        // You can navigate to another screen or show a success message
        print("Purchase completed: $customerInfo, $storeTransaction");
        Navigator.of(context).maybePop();
      },
      onRestoreCompleted: (customerInfo) {
        // Handle restore completion
        // You can navigate to another screen or show a success message
        print("Restore completed: $customerInfo");
        Navigator.of(context).maybePop();
      },
    );
  }
}

class _CustomPaywallView extends StatefulWidget {
  const _CustomPaywallView();

  @override
  State<_CustomPaywallView> createState() => __CustomPaywallViewState();
}

class __CustomPaywallViewState extends State<_CustomPaywallView> {
  final _purchasesService = Get.find<PurchasesController>();
  late Future<Offering?> _future = Future.value(null);
  Subscription? _selectedSubscription;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  _refresh() async {
    if (_purchasing) return;
    _future = _purchasesService.getPaywallData().then((data) {
      if (data == null || data.subscriptions.isEmpty) {
        _selectedSubscription = null;
        return data;
      }
      _selectedSubscription = data.subscriptions.isNotEmpty
          ? data.subscriptions.first
          : null;
      if (mounted) setState(() {});

      return data;
    });
    return _future;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_purchasing,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: MediaQuery.of(context).platformBrightness,
          primaryColor: Theme.of(context).colorScheme.primary,
          scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: CupertinoPageScaffold(
          child: FutureBuilder(
            future: _future,
            builder: (context, asyncSnapshot) {
              final isLoading =
                  asyncSnapshot.connectionState == ConnectionState.waiting;
              final paywallData = asyncSnapshot.data ?? Offering.empty;
              return Skeletonizer(
                enabled: isLoading,
                child: RefreshIndicator.adaptive(
                  onRefresh: () => _refresh(),
                  child: CustomScrollView(
                    slivers: [
                      CupertinoSliverNavigationBar(
                        largeTitle: Text("paywall.title".t),
                        padding: const EdgeInsetsDirectional.only(
                          start: 0,
                          end: 16.0,
                        ),
                        leading: IconTheme.merge(
                          data: const IconThemeData(size: 32.0),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _purchasing
                                ? null
                                : () {
                                    if (context.mounted) {
                                      Navigator.of(context).maybePop();
                                    }
                                  },
                            child: const Icon(CupertinoIcons.back, size: 32.0),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "paywall.subtitle".t,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (asyncSnapshot.hasError)
                            Material(
                              type: MaterialType.transparency,
                              // child: ErrorDisplay(error: asyncSnapshot.error),
                              child: Center(
                                child: Text(
                                  asyncSnapshot.error.toString(), // FIXME
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          if (paywallData.subscriptions.isNotEmpty)
                            CupertinoListSection.insetGrouped(
                              backgroundColor: Colors.transparent,
                              children: [
                                for (final offering
                                    in paywallData.subscriptions)
                                  CupertinoListTile(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHigh,
                                    leading: offering == _selectedSubscription
                                        ? const Icon(
                                            CupertinoIcons
                                                .check_mark_circled_solid,
                                          )
                                        : const Icon(
                                            CupertinoIcons.circle,
                                            color: Colors.grey,
                                          ),
                                    onTap: () {
                                      setState(() {
                                        _selectedSubscription = offering;
                                      });
                                    },
                                    title: Text(offering.displayName),
                                    subtitle: () {
                                      var trial = offering.trial;
                                      if (trial == null) return null;
                                      return Text(
                                        // "paywall.trialPeriod".t.let((t) {
                                        trial.periodType.let((t) {
                                          return switch (t) {
                                            SubscriptionPeriod.week =>
                                              "paywall.trialPeriod.week".plural(
                                                trial.duration,
                                              ),
                                            SubscriptionPeriod.month =>
                                              "paywall.trialPeriod.month"
                                                  .plural(trial.duration),
                                            SubscriptionPeriod.year =>
                                              "paywall.trialPeriod.year".plural(
                                                trial.duration,
                                              ),
                                          };
                                        }),
                                      );
                                    }(),
                                    trailing: Text(
                                      offering.price,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          Center(
                            child: CupertinoButton(
                              onPressed:
                                  _selectedSubscription == null || _purchasing
                                  ? null
                                  : () async {
                                      setState(() {
                                        _purchasing = true;
                                      });
                                      final status = await _purchasesService
                                          .purchaseSubscription(
                                            _selectedSubscription!,
                                          );
                                      if (mounted) {
                                        setState(() {
                                          _purchasing = false;
                                        });
                                      }
                                      if (mounted) {
                                        if (status ==
                                            SubscriptionPurchaseStatus
                                                .success) {
                                          if (!context.mounted) return;
                                          Navigator.of(context).pop();
                                        } else {
                                          if (!context.mounted) return;
                                          showAdaptiveDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog.adaptive(
                                                title: Text(
                                                  "paywall.purchaseError.title"
                                                      .t,
                                                ),
                                                content: Text(
                                                  "paywall.purchaseError.subtitle"
                                                      .t,
                                                ),
                                                actions: [
                                                  CupertinoButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                    child: Text(
                                                      MaterialLocalizations.of(
                                                        context,
                                                      ).okButtonLabel,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                              child: Text("paywall.actions.subscribe".t),
                            ),
                          ),
                          if (_selectedSubscription != null)
                            Center(
                              child: Text(
                                // "paywall.autoRenewNotice".let((t) {
                                _selectedSubscription!.duration.let((t) {
                                  return switch (_selectedSubscription!
                                      .duration) {
                                    SubscriptionPeriod.week =>
                                      "paywall.autoRenewNotice.week".tParams({
                                        'price': _selectedSubscription!.price,
                                      }),
                                    SubscriptionPeriod.month =>
                                      "paywall.autoRenewNotice.month".tParams({
                                        'price': _selectedSubscription!.price,
                                      }),
                                    SubscriptionPeriod.year =>
                                      "paywall.autoRenewNotice.year".tParams({
                                        'price': _selectedSubscription!.price,
                                      }),
                                  };
                                }),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const SizedBox(height: 16.0),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                CupertinoButton(
                                  onPressed: _purchasing
                                      ? null
                                      : () async {
                                          setState(() {
                                            _purchasing = true;
                                          });
                                          try {
                                            await _purchasesService
                                                .restorePurchases();
                                            if (mounted) {
                                              setState(() {
                                                _purchasing = false;
                                              });
                                              if (!context.mounted) return;
                                              Navigator.of(context).maybePop();
                                            }
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            if (mounted) {
                                              setState(() {
                                                _purchasing = false;
                                              });
                                            }
                                            showAdaptiveDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog.adaptive(
                                                  title: Text(
                                                    "paywall.restoreError.title"
                                                        .t,
                                                  ),
                                                  content: Text(
                                                    "paywall.restoreError.subtitle"
                                                        .t,
                                                  ),
                                                  actions: [
                                                    CupertinoButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: Text(
                                                        MaterialLocalizations.of(
                                                          context,
                                                        ).okButtonLabel,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                  child: Text(
                                    "paywall.actions.restorePurchase".t,
                                  ),
                                ),
                                CupertinoButton(
                                  onPressed: _purchasing
                                      ? null
                                      : () {
                                          // context.router.push(
                                          //   const TosViewerRoute(),
                                          // );
                                        },
                                  child: Text(
                                    "paywall.actions.termsOfService".t,
                                  ),
                                ),
                                CupertinoButton(
                                  onPressed: _purchasing
                                      ? null
                                      : () {
                                          // context.router.push(
                                          //   const PrivacyViewerRoute(),
                                          // );
                                        },
                                  child: Text(
                                    "paywall.actions.privacyPolicy".t,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

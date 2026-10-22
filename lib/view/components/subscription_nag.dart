import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/actions/purchases.dart';
import 'package:gymtracker/view/components/gradient_button.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubscriptionNag extends ConsumerWidget {
  const SubscriptionNag({
    super.key,
    required this.shouldHide,
    required this.stringKey,
  }) : _builder = true,
       subscriptionInfo = null;

  const SubscriptionNag.unresponsive({
    super.key,
    required this.shouldHide,
    required this.stringKey,
    required this.subscriptionInfo,
  }) : _builder = false;

  final bool Function(SubscriptionInfo) shouldHide;
  final String stringKey;
  final SubscriptionInfo? subscriptionInfo;

  final bool _builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget card(BuildContext context, SubscriptionInfo? info) => _cardBuilder(
      context,
      info,
      () => ref.read(purchasesControllerProvider).presentPaywall(),
    );
    if (!_builder) return card(context, subscriptionInfo);

    return SafeArea(
      top: false,
      bottom: false,
      child: ProBuilder(builder: card),
    );
  }

  Widget _cardBuilder(
    BuildContext context,
    SubscriptionInfo? subscriptionInfo,
    VoidCallback onUpgrade,
  ) {
    if (subscriptionInfo != null && shouldHide(subscriptionInfo)) {
      return const SizedBox.shrink();
    } else {
      return Skeletonizer(
        enabled: subscriptionInfo == null,
        child: Card.outlined(
          clipBehavior: Clip.none,
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              ListTile(
                isThreeLine: true,
                leading: GTIcons.compound.pro.withColors(
                  accessoryColor: Theme.of(context).colorScheme.primary,
                ),
                title: Text(context.t.nags[stringKey].title),
                subtitle: Text(context.t.nags[stringKey].subtitle),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    GradientButton(
                      onPressed: () {
                        onUpgrade();
                      },
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).extension<MoreColors>()!.quaternary,
                        ],
                      ),
                      pulseGradient: LinearGradient(
                        colors: [
                          Theme.of(context).extension<MoreColors>()!.quaternary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      child: Text(context.t.nags["button"]!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/subscription.dart';

class ProBuilder extends ConsumerWidget {
  final Widget Function(BuildContext, SubscriptionInfo?) builder;

  const ProBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref.watch(subscriptionInfoProvider).value);
  }
}

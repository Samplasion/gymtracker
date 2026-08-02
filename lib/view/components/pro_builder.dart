import 'package:flutter/material.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/view/components/controlled.dart';

class ProBuilder extends ControlledWidgetAny<PurchasesController> {
  final Widget Function(BuildContext, SubscriptionInfo?) builder;

  const ProBuilder({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SubscriptionInfo>(
      stream: controller.subscriptionInfoStream,
      builder: (context, snapshot) {
        final subscriptionInfo = snapshot.data;

        return builder(context, subscriptionInfo);
      },
    );
  }
}

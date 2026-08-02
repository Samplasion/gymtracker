import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/period_unit.dart' show PeriodUnit;

import 'package:rxdart/subjects.dart';

class PurchasesController extends ChangeNotifier {
  final PurchasesService purchasesService;
  final Coordinator eventScheduler;

  final _subscriptionInfo$ = BehaviorSubject.seeded(SubscriptionInfo.empty);
  late final Stream<SubscriptionInfo> subscriptionInfoStream =
      _subscriptionInfo$.stream;
  SubscriptionInfo get subscriptionInfo => _subscriptionInfo$.value;

  PurchasesController(this.purchasesService, this.eventScheduler) {
    eventScheduler.addEventListener(
      ScheduledEvent.userDidLogin,
      _authChangeRoutine,
    );
    eventScheduler.addEventListener(
      ScheduledEvent.userDidLogout,
      _authChangeRoutine,
    );
    eventScheduler.addEventListener(
      ScheduledEvent.userDidUpdateSubscription,
      () {
        purchasesService.getCustomerInfo().then((entitlement) {
          final subscriptionInfo = _mapEntitlementToSubscriptionInfo(
            entitlement,
          );
          _subscriptionInfo$.add(subscriptionInfo);
          notifyListeners();
        });
      },
    );
    _subscriptionInfo$.add(SubscriptionInfo.empty);
    purchasesService.entitlementStream.listen((entitlement) async {
      // final user = authService.user.valueOrNull;
      // if (user == null) {
      //   _subscriptionInfo$.add(SubscriptionInfo.empty);
      //   notifyListeners();
      //   return;
      // }
      final subscriptionInfo = _mapEntitlementToSubscriptionInfo(entitlement);
      _subscriptionInfo$.add(subscriptionInfo);
      notifyListeners();
    });
  }

  Future<void> _authChangeRoutine() async {
    if (purchasesService.isPurchasingEnabled.isEmpty) {
      logger.d("Purchases are disabled");
      _subscriptionInfo$.add(
        const SubscriptionInfo(
          isPro: false,
          isTrial: false,
          isForcedPro: false,
          isAboutToExpire: false,
        ),
      );
      return;
    }

    final user = null;
    logger.d("Logging in with RevCat. ");
    if (user == null) {
      logger.d("Logging out from RevCat");
      await purchasesService.logout();
      _subscriptionInfo$.add(SubscriptionInfo.empty);
    } else {
      try {
        logger.d("Logging in to Purchases");
        await purchasesService.login(user.uid);
        if (user.isForcedPro) {
          logger.d(
            "User is forced pro, setting subscription info to forced pro",
          );
          _subscriptionInfo$.add(
            const SubscriptionInfo(
              isPro: false,
              isTrial: false,
              isForcedPro: true,
              isAboutToExpire: false,
            ),
          );
          return;
        }
        final entitlement = await purchasesService.getCustomerInfo();
        final subscriptionInfo = _mapEntitlementToSubscriptionInfo(entitlement);
        _subscriptionInfo$.add(subscriptionInfo);
      } catch (e, s) {
        // Handle error
        logger.e("Error logging in to Purchases: $e", error: e, stackTrace: s);
      }
    }
    notifyListeners();
  }

  bool canPresentNativePaywall() {
    return purchasesService.canPresentNativePaywall();
  }

  Future<void> presentPaywall() {
    return purchasesService.presentPaywall();
  }

  Future<SubscriptionInfo> getSubscriptionInfo() async {
    final entitlement = await purchasesService.getCustomerInfo();
    return _mapEntitlementToSubscriptionInfo(entitlement);
  }

  SubscriptionInfo _mapEntitlementToSubscriptionInfo(
    EntitlementInfo? entitlement,
    // User user,
  ) {
    return SubscriptionInfo(
      isPro: entitlement != null && entitlement.isActive,
      isTrial: entitlement?.periodType == PeriodType.trial,
      isForcedPro: false,
      isAboutToExpire: entitlement?.unsubscribeDetectedAt != null,
    );
  }

  Future<String?> getSubscriptionManagementURL() =>
      purchasesService.getSubscriptionManagementURL();

  bool get canPurchaseOnThisDevice => purchasesService.canPurchaseOnThisDevice;

  Future<Offering?> getPaywallData() async {
    final offers = await purchasesService.getOfferings();
    if (offers.all.isEmpty) {
      logger.w("No offerings available");
      return null;
    }

    final offering = offers.current;
    if (offering == null) {
      logger.w("No current offering available");
      return null;
    }

    if (offering.availablePackages.isEmpty) {
      logger.w("No available packages in the current offering");
      return null;
    }

    final packages = offering.availablePackages;

    final subs = [
      for (final package in packages)
        if ({
          PackageType.annual,
          PackageType.monthly,
          PackageType.weekly,
        }.contains(package.packageType))
          Subscription(
            productId: package.identifier,
            price: package.storeProduct.priceString,
            displayName: package.storeProduct.description,
            duration: switch (package.packageType) {
              PackageType.annual => SubscriptionPeriod.year,
              PackageType.monthly => SubscriptionPeriod.month,
              PackageType.weekly => SubscriptionPeriod.week,
              _ => SubscriptionPeriod.year,
            },
            trial: package.storeProduct.introductoryPrice != null
                ? SubscriptionTrial(
                    duration: package
                        .storeProduct
                        .introductoryPrice!
                        .periodNumberOfUnits,
                    periodType: switch (package
                        .storeProduct
                        .introductoryPrice!
                        .periodUnit) {
                      PeriodUnit.day => SubscriptionPeriod.week,
                      PeriodUnit.week => SubscriptionPeriod.week,
                      PeriodUnit.month => SubscriptionPeriod.month,
                      PeriodUnit.year => SubscriptionPeriod.year,
                      _ => SubscriptionPeriod.month,
                    },
                  )
                : null,
          ),
    ];

    return Offering(subscriptions: subs);
  }

  Future<SubscriptionPurchaseStatus> purchaseSubscription(
    Subscription selectedSubscription,
  ) async {
    return purchasesService
        .purchaseSubscription(selectedSubscription)
        .then((_) {
          eventScheduler.trigger(ScheduledEvent.userDidUpdateSubscription);
          return SubscriptionPurchaseStatus.success;
        })
        .onError((error, stackTrace) {
          if (error is PlatformException &&
              error.message?.contains('cancelled') == true) {
            return SubscriptionPurchaseStatus.cancelled;
          }
          logger.e(
            "Error purchasing subscription: $error",
            error: error,
            stackTrace: stackTrace,
          );
          return SubscriptionPurchaseStatus.error;
        });
  }

  Future restorePurchases() async {
    try {
      await purchasesService.restorePurchases();
      final entitlement = await purchasesService.getCustomerInfo();
      final subscriptionInfo = _mapEntitlementToSubscriptionInfo(entitlement);
      _subscriptionInfo$.add(subscriptionInfo);
      notifyListeners();
    } catch (e, s) {
      logger.e("Error restoring purchases: $e", error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> presentCustomerCenter() {
    return purchasesService.presentCustomerCenter();
  }
}

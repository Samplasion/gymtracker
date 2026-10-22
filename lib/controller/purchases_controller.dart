import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/service/purchases.dart';
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/period_unit.dart' show PeriodUnit;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/subjects.dart';

part 'purchases_controller.g.dart';

class PurchasesController {
  final PurchasesService purchasesService;
  final OnlineService onlineService;

  final _subscriptions = <StreamSubscription<dynamic>>[];
  late final EventBus _events;
  bool _disposed = false;
  int _authEpoch = 0;
  bool _switchingAuth = false;
  bool _authReady = true;
  String? _boundUser;
  int _refreshEpoch = 0;
  Future<void> _authWork = Future.value();

  final _subscriptionInfo$ = BehaviorSubject.seeded(SubscriptionInfo.empty);
  late final Stream<SubscriptionInfo> subscriptionInfoStream =
      _subscriptionInfo$.stream;
  SubscriptionInfo get subscriptionInfo => _subscriptionInfo$.value;

  PurchasesController(
    this.purchasesService,
    this.onlineService, {
    required EventBus events,
  }) {
    final eventBus = _events = events;
    _subscriptions.add(
      eventBus.on<GBUserDidLoginEvent>().listen(
        (event) => _authChangeRoutine(event.account),
      ),
    );
    _subscriptions.add(
      eventBus.on<GBUserDidLogoutEvent>().listen(
        (event) => _authChangeRoutine(null),
      ),
    );
    _subscriptions.add(
      eventBus.on<GBUserDidUpdateSubscriptionEvent>().listen((event) {
        if (event.user?.id == onlineService.account?.id) _refreshSubscription();
      }),
    );
    _subscriptions.add(
      purchasesService.entitlementStream.listen((entitlement) {
        if (!_isBoundTo(onlineService.account?.id)) return;
        // A newer stream update takes precedence over an older pending read.
        _refreshEpoch++;
        _subscriptionInfo$.add(
          _mapEntitlementToSubscriptionInfo(entitlement, userID: _boundUser),
        );
      }),
    );
    final account = onlineService.account;
    if (account != null) unawaited(_authChangeRoutine(account));
  }

  bool _isCurrent(int epoch, String? userID) =>
      !_disposed && epoch == _authEpoch && onlineService.account?.id == userID;

  bool _isBoundTo(String? userID) =>
      !_disposed && !_switchingAuth && _authReady && _boundUser == userID;

  Future<void> _authChangeRoutine(OnlineAccount? account) {
    if (_disposed) return Future.value();
    final epoch = ++_authEpoch;
    final userID = account?.id;
    // Invalidate immediately, including while an earlier SDK login is pending.
    _switchingAuth = true;
    _authReady = false;
    _boundUser = null;
    _refreshEpoch++;
    _subscriptionInfo$.add(
      _mapEntitlementToSubscriptionInfo(null, userID: userID),
    );
    _authWork = _authWork.then((_) async {
      if (!_isCurrent(epoch, userID)) return;
      try {
        if (!purchasesService.isInitialized()) await purchasesService.init();
        if (!_isCurrent(epoch, userID)) return;
        if (!purchasesService.isPurchasingEnabled.contains(
          PurchasesCheckType.read,
        )) {
          _switchingAuth = false;
          return;
        }
        if (userID == null) {
          try {
            await purchasesService.logout();
          } on PlatformException catch (e) {
            if (e.message?.contains('the current user is anonymous') != true) {
              rethrow;
            }
          }
        } else {
          await purchasesService.login(userID);
        }
        if (!_isCurrent(epoch, userID)) return;
        _boundUser = userID;
        _authReady = true;
        _switchingAuth = false;
        // Do not hold the authentication queue behind a network read.
        if (userID != null) _refreshSubscription();
      } catch (e, s) {
        if (_isCurrent(epoch, userID)) _switchingAuth = false;
        logger.e(
          'Error binding Purchases account: $e',
          error: e,
          stackTrace: s,
        );
      }
    });
    return _authWork;
  }

  void _refreshSubscription() {
    unawaited(
      _readSubscription(publish: true).catchError((Object e, StackTrace s) {
        logger.e('Error refreshing subscription: $e', error: e, stackTrace: s);
        return SubscriptionInfo.empty;
      }),
    );
  }

  Future<SubscriptionInfo> _readSubscription({bool publish = false}) async {
    final epoch = _authEpoch;
    final userID = onlineService.account?.id;
    await _authWork;
    if (!_isCurrent(epoch, userID) || !_isBoundTo(userID)) {
      return SubscriptionInfo.empty;
    }
    if (!purchasesService.isInitialized()) await purchasesService.init();
    if (!_isCurrent(epoch, userID) ||
        !_isBoundTo(userID) ||
        !purchasesService.isPurchasingEnabled.contains(
          PurchasesCheckType.read,
        )) {
      return SubscriptionInfo.empty;
    }
    final refresh = ++_refreshEpoch;
    final entitlement = await purchasesService.getCustomerInfo();
    if (!_isCurrent(epoch, userID) || !_isBoundTo(userID)) {
      return SubscriptionInfo.empty;
    }
    if (refresh != _refreshEpoch) return subscriptionInfo;
    final info = _mapEntitlementToSubscriptionInfo(entitlement, userID: userID);
    if (publish) _subscriptionInfo$.add(info);
    return info;
  }

  bool canPresentNativePaywall() {
    return purchasesService.canPresentNativePaywall();
  }

  Future<SubscriptionInfo> getSubscriptionInfo() => _readSubscription();

  SubscriptionInfo _mapEntitlementToSubscriptionInfo(
    EntitlementInfo? entitlement, {
    required String? userID,
  }) => SubscriptionInfo(
    userID: userID,
    isPro: entitlement != null && entitlement.isActive,
    isTrial: entitlement?.periodType == PeriodType.trial,
    isForcedPro: false,
    isAboutToExpire: entitlement?.unsubscribeDetectedAt != null,
  );

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
    final epoch = _authEpoch;
    final account = onlineService.account;
    await _authWork;
    if (!_isCurrent(epoch, account?.id) || !_isBoundTo(account?.id)) {
      return SubscriptionPurchaseStatus.error;
    }
    try {
      await purchasesService.purchaseSubscription(selectedSubscription);
      if (_isCurrent(epoch, account?.id)) {
        _events.emit(
          GBUserDidUpdateSubscriptionEvent(
            user: account,
            subscription: selectedSubscription,
          ),
        );
      }
      return SubscriptionPurchaseStatus.success;
    } catch (e, s) {
      if (e is PlatformException && e.message?.contains('cancelled') == true) {
        return SubscriptionPurchaseStatus.cancelled;
      }
      logger.e('Error purchasing subscription: $e', error: e, stackTrace: s);
      return SubscriptionPurchaseStatus.error;
    }
  }

  Future<void> restorePurchases() async {
    final epoch = _authEpoch;
    final userID = onlineService.account?.id;
    await _authWork;
    if (!_isCurrent(epoch, userID) || !_isBoundTo(userID)) return;
    try {
      await purchasesService.restorePurchases();
      if (_isCurrent(epoch, userID)) await _readSubscription(publish: true);
    } catch (e, s) {
      logger.e('Error restoring purchases: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _authEpoch++;
    await Future.wait(
      _subscriptions.map((subscription) => subscription.cancel()),
    );
    _subscriptions.clear();
    await _subscriptionInfo$.close();
  }

  Future<void> presentCustomerCenter() {
    return purchasesService.presentCustomerCenter();
  }
}

@Riverpod(keepAlive: true)
PurchasesController purchasesController(Ref ref) {
  final controller = PurchasesController(
    ref.watch(purchasesServiceProvider),
    ref.watch(onlineProvider.notifier).onlineService,
    events: ref.watch(eventBusProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
}

@riverpod
Stream<SubscriptionInfo> subscriptionInfo(Ref ref) =>
    ref.watch(purchasesControllerProvider).subscriptionInfoStream;

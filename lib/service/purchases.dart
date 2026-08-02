import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide LogLevel;
import 'package:purchases_flutter/purchases_flutter.dart'
    as revenuecat
    show LogLevel;
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:rxdart/rxdart.dart';

const _revenuecatProjectGoogleApiKey = kDebugMode
    ? Env.revenuecatProjectTestStoreApiKey
    : Env.revenuecatProjectGoogleApiKey;
const _revenuecatProjectMacOSApiKey = Env.revenuecatProjectTestStoreApiKey;
const _revenuecatProjectAppleApiKey = Env.revenuecatProjectAppleApiKey;
const _proAccessEntitlementID = Env.revenuecatAccessEntitlementId;

enum PurchasesCheckType { read, write }

class PurchasesService {
  final Coordinator eventScheduler;
  final _customerInfo$ = BehaviorSubject<CustomerInfo?>.seeded(null);

  late final Stream<EntitlementInfo?> entitlementStream = _customerInfo$.map(
    (customerInfo) =>
        customerInfo?.entitlements.active[_proAccessEntitlementID],
  );

  Set<PurchasesCheckType> isPurchasingEnabled = {};

  PurchasesService(this.eventScheduler);

  bool get canPurchaseOnThisDevice =>
      isPurchasingEnabled.isNotEmpty &&
      isPurchasingEnabled.contains(PurchasesCheckType.write);

  Future<void> init() async {
    if (kIsWeb) {
      isPurchasingEnabled = {PurchasesCheckType.read};

      await _RestPurchases.instance.init();
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo$.add(info);
        eventScheduler.trigger(ScheduledEvent.userDidUpdateSubscription);
      });
      return;
    }

    await Purchases.setLogLevel(revenuecat.LogLevel.verbose);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_revenuecatProjectGoogleApiKey);
    } else if (Platform.isIOS || Platform.isMacOS) {
      configuration = PurchasesConfiguration(_revenuecatProjectAppleApiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
    isPurchasingEnabled = {PurchasesCheckType.read, PurchasesCheckType.write};

    eventScheduler.addEventListener(ScheduledEvent.userDidUpdate, () {});

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo$.add(info);
        eventScheduler.trigger(ScheduledEvent.userDidUpdateSubscription);
      });
      Purchases.getCustomerInfo().then(
        (info) {
          _customerInfo$.add(info);
          eventScheduler.trigger(ScheduledEvent.userDidUpdateSubscription);
        },
        onError: (error) {
          logger.e("Error getting customer info: $error", error: error);
          _customerInfo$.add(null);
        },
      );
    });
  }

  void _checkPurchasesEnabled(PurchasesCheckType type) {
    if (!isPurchasingEnabled.contains(type)) {
      throw Exception("Purchases are not enabled for this operation ($type).");
    }
  }

  Future presentPaywall() async {
    _checkPurchasesEnabled(PurchasesCheckType.write);
    try {
      final res = await RevenueCatUI.presentPaywall();
      return res;
    } catch (e) {
      logger.e("Error presenting paywall: $e", error: e);
    }
  }

  Future login(String userId) async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    if (isPurchasingEnabled.contains(PurchasesCheckType.read) &&
        !isPurchasingEnabled.contains(PurchasesCheckType.write)) {
      await _RestPurchases.instance.login(userId);
      return;
    }
    return Purchases.logIn(userId);
  }

  Future logout() async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    if (isPurchasingEnabled.contains(PurchasesCheckType.read) &&
        !isPurchasingEnabled.contains(PurchasesCheckType.write)) {
      await _RestPurchases.instance.logout();
      return;
    }
    return Purchases.logOut();
  }

  Future<EntitlementInfo?> getCustomerInfo() async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    final customerInfo =
        await (isPurchasingEnabled.contains(PurchasesCheckType.read) &&
                !isPurchasingEnabled.contains(PurchasesCheckType.write)
            ? _RestPurchases.instance.getCustomerInfo()
            : Purchases.getCustomerInfo());

    return customerInfo?.entitlements.active[_proAccessEntitlementID];
  }

  Future<String?> getSubscriptionManagementURL() async {
    if (kIsWeb) return null;
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) return null;

    return Purchases.getCustomerInfo().then((info) => info.managementURL);
  }

  bool canPresentNativePaywall() {
    print((
      !kIsWeb,
      !Platform.isMacOS,
      isPurchasingEnabled.contains(PurchasesCheckType.write),
    ));
    return !kIsWeb &&
        !Platform.isMacOS &&
        isPurchasingEnabled.contains(PurchasesCheckType.write);
  }

  Future<Offerings> getOfferings() async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) {
      return Future.value(const Offerings({}));
    }
    return Purchases.getOfferings();
  }

  Future purchaseSubscription(Subscription selectedSubscription) async {
    _checkPurchasesEnabled(PurchasesCheckType.write);
    final offerings = await getOfferings();
    if (offerings.current == null) {
      throw Exception("No current offerings available.");
    }
    final selectedOffering = offerings.current!;
    if (selectedOffering.availablePackages.isEmpty) {
      throw Exception("No available packages in the current offering.");
    }
    final selectedPackage = selectedOffering.availablePackages.firstWhere(
      (package) => package.identifier == selectedSubscription.productId,
      orElse: () => throw Exception(
        "Selected package not found in the current offerings.",
      ),
    );
    return Purchases.purchase(PurchaseParams.package(selectedPackage));
  }

  Future<CustomerInfo> restorePurchases() async {
    _checkPurchasesEnabled(PurchasesCheckType.write);
    return Purchases.restorePurchases();
  }

  Future<void> presentCustomerCenter() async {
    RevenueCatUI.presentCustomerCenter();
  }
}

class _RestPurchases {
  _RestPurchases._();
  static _RestPurchases get instance {
    _instance ??= _RestPurchases._();
    return _instance!;
  }

  static _RestPurchases? _instance;

  // It works with API v1.
  static const revenuecatProjectWebApiKey = _revenuecatProjectAppleApiKey;
  static const base = "https://api.revenuecat.com/v1/";

  // State
  late Dio dio;
  String? userID;
  StreamController<CustomerInfo?>? _customerInfoStreamController;

  Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          "Authorization": "Bearer $revenuecatProjectWebApiKey",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );
  }

  Future<void> login(String userId) async {
    userID = userId;
    _customerInfoStreamController ??=
        StreamController<CustomerInfo?>.broadcast();
    _customerInfoStreamController?.add(null);
    getCustomerInfo()
        .then((customerInfo) {
          _customerInfoStreamController?.add(customerInfo);
        })
        .catchError((error) {
          logger.e("Error getting customer info: $error");
          _customerInfoStreamController?.add(null);
        });
  }

  Future<void> logout() async {
    userID = null;
    _customerInfoStreamController?.add(null);
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (userID == null) {
      throw Exception("User is not logged in");
    }
    final res = await dio.get("subscribers/$userID");
    if (res.statusCode != 200) {
      throw Exception("Error getting customer info: ${res.statusCode}");
    }
    final data =
        (res.data as Map<String, dynamic>)['subscriber']
            as Map<String, dynamic>;

    final entitlements = data['entitlements'] as Map<String, dynamic>;
    final entitlementInfos = entitlements.entries.map((e) {
      final entitlement = e.value as Map<String, dynamic>;
      return EntitlementInfo(
        e.key,
        entitlement['expires_date'] != null
            ? DateTime.parse(
                entitlement['expires_date'],
              ).isAfter(DateTime.now().toUtc())
            : false,
        false,
        DateTime.now().toIso8601String(),
        DateTime.now().toIso8601String(),
        entitlement['product_identifier'],
        false,
      );
    }).toList();

    return CustomerInfo(
      EntitlementInfos(
        {for (var e in entitlementInfos) e.identifier: e},
        {
          for (var e
              in entitlementInfos
                  .where((e) => e.isActive)
                  .toList(growable: false))
            e.identifier: e,
        },
        verification: VerificationResult.notRequested,
      ),
      {},
      [],
      [],
      [],
      data['first_seen'],
      userID!,
      {},
      DateTime.now().toIso8601String(),
    );
  }
}

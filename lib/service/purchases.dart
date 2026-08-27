import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart'
    as revenuecat
    show LogLevel;
import 'package:purchases_flutter/purchases_flutter.dart' hide LogLevel;
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

  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) {
      isPurchasingEnabled = {PurchasesCheckType.read};

      await _RestPurchases.instance.init();
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo$.add(info);
      });

      _isInitialized = true;
      logger.i("Initialized PurchasesService with RevenueCat (web).");
      return;
    }

    await Purchases.setLogLevel(
      kDebugMode ? revenuecat.LogLevel.verbose : revenuecat.LogLevel.warn,
    );

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_revenuecatProjectGoogleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_revenuecatProjectAppleApiKey);
    } else if (Platform.isMacOS) {
      await _RestPurchases.instance.init();
      configuration = PurchasesConfiguration(_revenuecatProjectMacOSApiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
    isPurchasingEnabled = {
      PurchasesCheckType.read,
      if (!Platform.isMacOS) PurchasesCheckType.write,
    };

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo$.add(info);
      });
      Purchases.getCustomerInfo().then(
        (info) {
          _customerInfo$.add(info);
        },
        onError: (error) {
          logger.e("Error getting customer info: $error", error: error);
          _customerInfo$.add(null);
        },
      );
    });

    _isInitialized = true;
    logger.i("Initialized PurchasesService with RevenueCat.");
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
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) {
      logger.w(
        "Called login() on a device that does not support purchases. Using REST API instead.",
      );
      await _RestPurchases.instance.login(userId);
      _RestPurchases.instance
          .getCustomerInfo()
          .then((info) {
            _customerInfo$.add(info);
          })
          .catchError((error) {
            logger.e("Error getting customer info: $error", error: error);
          });
      return;
    }
    return Purchases.logIn(userId);
  }

  Future logout() async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) {
      logger.w(
        "Called logout() on a device that does not support purchases. Using REST API instead.",
      );
      await _RestPurchases.instance.logout();
      return;
    }
    return Purchases.logOut();
  }

  Future<EntitlementInfo?> getCustomerInfo() async {
    _checkPurchasesEnabled(PurchasesCheckType.read);
    final customerInfo =
        await (isPurchasingEnabled.contains(PurchasesCheckType.write)
            ? Purchases.getCustomerInfo()
            : _RestPurchases.instance.getCustomerInfo());

    return customerInfo?.entitlements.active[_proAccessEntitlementID];
  }

  Future<String?> getSubscriptionManagementURL() async {
    if (kIsWeb) return null;
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) return null;

    return Purchases.getCustomerInfo().then((info) => info.managementURL);
  }

  bool canPresentNativePaywall() {
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

  Future<PurchaseResult> purchaseSubscription(
    Subscription selectedSubscription,
  ) async {
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
    final result = await Purchases.purchase(
      PurchaseParams.package(selectedPackage),
    );
    return result;
  }

  Future<CustomerInfo> restorePurchases() async {
    _checkPurchasesEnabled(PurchasesCheckType.write);
    return Purchases.restorePurchases();
  }

  Future<void> presentCustomerCenter() async {
    RevenueCatUI.presentCustomerCenter();
  }

  bool isInitialized() {
    return _isInitialized;
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
  static const revenuecatProjectWebApiKey = _revenuecatProjectMacOSApiKey;
  static const base = "https://api.revenuecat.com/v1/";

  // State
  Dio dio = Dio(
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
  String? userID;
  StreamController<CustomerInfo?>? _customerInfoStreamController;

  Future<void> init() async {}

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
      logger.w(
        "Called getCustomerInfo() without a logged-in user. Returning null.",
      );
      return null;
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

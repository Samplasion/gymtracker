import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/model/subscription.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/request_cache.dart';
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
  final _customerInfo$ = BehaviorSubject<CustomerInfo?>.seeded(null);

  late final Stream<EntitlementInfo?> entitlementStream = _customerInfo$.map(
    (customerInfo) =>
        customerInfo?.entitlements.active[_proAccessEntitlementID],
  );

  Set<PurchasesCheckType> isPurchasingEnabled = {};

  PurchasesService({Dio? restClient})
    : _restPurchases = _RestPurchases(restClient);

  final _RestPurchases _restPurchases;
  Future<void>? _initialization;
  Future<void> _operations = Future.value();
  int _sessionEpoch = 0;
  int _readVersion = 0;
  int _acceptedReadVersion = 0;
  CustomerInfo? _latestInfo;
  bool _switchingAuth = false;
  bool _bindingValid = true;

  bool get _usesRest => kIsWeb || defaultTargetPlatform == TargetPlatform.macOS;

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _operations.then((_) => action());
    _operations = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  bool get canPurchaseOnThisDevice =>
      isPurchasingEnabled.isNotEmpty &&
      isPurchasingEnabled.contains(PurchasesCheckType.write);

  bool _isInitialized = false;
  bool _disposed = false;
  bool _listening = false;
  void _customerInfoListener(CustomerInfo _) => _refreshNativeCustomerInfo();

  void _refreshNativeCustomerInfo() {
    if (_disposed || _switchingAuth || !_bindingValid || _usesRest) return;
    // SDK notifications do not identify the current login session (aliases can
    // have a different originalAppUserId). Re-read after queued identity work.
    unawaited(
      _readCustomerInfo(publish: true).then<void>((_) {}).catchError((
        Object e,
        StackTrace s,
      ) {
        logger.e(
          'Error refreshing native customer info: $e',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _publish(CustomerInfo? info) {
    if (!_disposed) _customerInfo$.add(info);
  }

  void _listenToCustomerInfo() {
    if (_disposed || _listening) return;
    _listening = true;
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _sessionEpoch++;
    _restPurchases.dispose();
    if (_listening) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoListener);
    }
    await _customerInfo$.close();
  }

  Future<void> init() {
    if (_disposed || _isInitialized) return Future.value();
    return _initialization ??= _initialize().catchError((
      Object e,
      StackTrace s,
    ) {
      _initialization = null;
      Error.throwWithStackTrace(e, s);
    });
  }

  Future<void> _initialize() async {
    if (_usesRest) {
      isPurchasingEnabled = {PurchasesCheckType.read};
    } else if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Purchases.setLogLevel(
        kDebugMode ? revenuecat.LogLevel.verbose : revenuecat.LogLevel.warn,
      );
      if (_disposed) return;
      final configuration = PurchasesConfiguration(
        defaultTargetPlatform == TargetPlatform.android
            ? _revenuecatProjectGoogleApiKey
            : _revenuecatProjectAppleApiKey,
      );
      await Purchases.configure(configuration);
      if (_disposed) return;
      isPurchasingEnabled = {PurchasesCheckType.read, PurchasesCheckType.write};
    }
    if (_disposed) return;
    _isInitialized = true;
    if (!_usesRest && canPurchaseOnThisDevice) {
      _listenToCustomerInfo();
      _refreshNativeCustomerInfo();
    }
    logger.i(
      'Initialized PurchasesService with RevenueCat (${_usesRest ? "REST" : "native"}).',
    );
  }

  void _checkPurchasesEnabled(PurchasesCheckType type) {
    if (!isPurchasingEnabled.contains(type)) {
      throw Exception("Purchases are not enabled for this operation ($type).");
    }
  }

  Future<void> presentPaywall() {
    final epoch = _sessionEpoch;
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch || !_bindingValid) return;
      _checkPurchasesEnabled(PurchasesCheckType.write);
      await RevenueCatUI.presentPaywall();
    });
  }

  Future<void> login(String userId) {
    final epoch = ++_sessionEpoch;
    _switchingAuth = true;
    _bindingValid = false;
    _latestInfo = null;
    _publish(null);
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch) return;
      try {
        await init();
        if (_disposed || epoch != _sessionEpoch) return;
        _checkPurchasesEnabled(PurchasesCheckType.read);
        if (_usesRest) {
          await _restPurchases.login(userId);
        } else {
          await Purchases.logIn(userId);
        }
        if (epoch == _sessionEpoch) _bindingValid = true;
      } finally {
        if (epoch == _sessionEpoch) _switchingAuth = false;
      }
    });
  }

  Future<void> logout() {
    final epoch = ++_sessionEpoch;
    _switchingAuth = true;
    _bindingValid = false;
    _latestInfo = null;
    _publish(null);
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch) return;
      try {
        await init();
        if (_disposed || epoch != _sessionEpoch) return;
        _checkPurchasesEnabled(PurchasesCheckType.read);
        if (_usesRest) {
          await _restPurchases.logout();
        } else {
          try {
            await Purchases.logOut();
          } on PlatformException catch (e) {
            if (e.message?.contains('the current user is anonymous') != true) {
              rethrow;
            }
          }
        }
        if (epoch == _sessionEpoch) _bindingValid = true;
      } finally {
        if (epoch == _sessionEpoch) _switchingAuth = false;
      }
    });
  }

  Future<CustomerInfo?> _readCustomerInfo({bool publish = false}) async {
    final epoch = _sessionEpoch;
    await init();
    await _operations;
    if (_disposed ||
        epoch != _sessionEpoch ||
        _switchingAuth ||
        !_bindingValid) {
      return null;
    }
    _checkPurchasesEnabled(PurchasesCheckType.read);
    final version = ++_readVersion;
    final info = await (_usesRest
        ? _restPurchases.getCustomerInfo()
        : Purchases.getCustomerInfo());
    if (_disposed ||
        epoch != _sessionEpoch ||
        _switchingAuth ||
        !_bindingValid) {
      return null;
    }
    // A callback read may overlap a controller read. Never publish an older
    // response after a newer one has already been accepted for this session.
    if (version < _acceptedReadVersion) return _latestInfo;
    _acceptedReadVersion = version;
    _latestInfo = info;
    if (publish) _publish(info);
    return info;
  }

  Future<EntitlementInfo?> getCustomerInfo() async {
    final info = await _readCustomerInfo();
    return info?.entitlements.active[_proAccessEntitlementID];
  }

  Future<String?> getSubscriptionManagementURL() async {
    if (_usesRest) return null;
    if (!isPurchasingEnabled.contains(PurchasesCheckType.write)) return null;

    return (await _readCustomerInfo())?.managementURL;
  }

  bool canPresentNativePaywall() {
    return !_usesRest && isPurchasingEnabled.contains(PurchasesCheckType.write);
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
    final epoch = _sessionEpoch;
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch || !_bindingValid) {
        throw StateError('Account changed before purchase');
      }
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
      if (_disposed || epoch != _sessionEpoch || !_bindingValid) {
        throw StateError('Account changed before purchase');
      }
      final result = await Purchases.purchase(
        PurchaseParams.package(selectedPackage),
      );
      return result;
    });
  }

  Future<CustomerInfo> restorePurchases() {
    final epoch = _sessionEpoch;
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch || !_bindingValid) {
        throw StateError('Account changed before restore');
      }
      _checkPurchasesEnabled(PurchasesCheckType.write);
      return Purchases.restorePurchases();
    });
  }

  Future<void> presentCustomerCenter() {
    final epoch = _sessionEpoch;
    return _enqueue(() async {
      if (_disposed || epoch != _sessionEpoch || !_bindingValid) return;
      _checkPurchasesEnabled(PurchasesCheckType.write);
      await RevenueCatUI.presentCustomerCenter();
    });
  }

  bool isInitialized() {
    return _isInitialized;
  }
}

class _RestPurchases {
  _RestPurchases(Dio? client)
    : dio =
          client ??
          Dio(
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
          ),
      _ownsClient = client == null;

  // It works with API v1.
  static const revenuecatProjectWebApiKey = _revenuecatProjectMacOSApiKey;
  static const base = "https://api.revenuecat.com/v1/";

  final Dio dio;
  final bool _ownsClient;
  String? userID;
  final _cache = RequestCache<String, CustomerInfo?>(
    const Duration(minutes: 5),
  );

  Future<void> login(String userId) async {
    if (userID != userId) _cache.clear();
    userID = userId;
  }

  Future<void> logout() async {
    _cache.clear();
    userID = null;
  }

  void dispose() {
    _cache.clear();
    userID = null;
    if (_ownsClient) dio.close(force: true);
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    if (userID == null) {
      logger.w(
        "Called getCustomerInfo() without a logged-in user. Returning null.",
      );
      return null;
    }
    final owner = userID!;
    final cached = _cache.peek(owner);
    if (cached != null &&
        cached.entitlements.active.values.any(
          (e) =>
              e.expirationDate != null &&
              DateTime.parse(e.expirationDate!).isBefore(DateTime.now()),
        )) {
      _cache.invalidate(owner);
    }
    return _cache.get(owner, () async {
      final res = await dio.get('subscribers/${Uri.encodeComponent(owner)}');
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
          expirationDate: entitlement['expires_date'],
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
        owner,
        {},
        DateTime.now().toIso8601String(),
      );
    });
  }
}

final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  final service = PurchasesService();
  ref.onDispose(service.dispose);
  return service;
});

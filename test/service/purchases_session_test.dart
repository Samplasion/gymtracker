import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/env.dart';
import 'package:gymtracker/service/purchases.dart';

const _channel = MethodChannel('purchases_flutter');

Future<void> _flush() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Map<String, dynamic> _nativeInfo(String owner, {bool pro = false}) {
  final entitlement = {
    'identifier': Env.revenuecatAccessEntitlementId,
    'isActive': true,
    'willRenew': true,
    'latestPurchaseDate': '2026-01-01T00:00:00Z',
    'originalPurchaseDate': '2026-01-01T00:00:00Z',
    'productIdentifier': 'subscription',
    'isSandbox': true,
  };
  final entitlements = {
    if (pro) Env.revenuecatAccessEntitlementId: entitlement,
  };
  return {
    'entitlements': {'all': entitlements, 'active': entitlements},
    'allPurchaseDates': <String, dynamic>{},
    'activeSubscriptions': <String>[],
    'allPurchasedProductIdentifiers': <String>[],
    'nonSubscriptionTransactions': <dynamic>[],
    'firstSeen': '2026-01-01T00:00:00Z',
    'originalAppUserId': owner,
    'allExpirationDates': <String, dynamic>{},
    'requestDate': '2026-10-22T00:00:00Z',
  };
}

Future<void> _nativeUpdate(Map<String, dynamic> info) async {
  final done = Completer<void>();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        'purchases_flutter',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('Purchases-CustomerInfoUpdated', info),
        ),
        (_) => done.complete(),
      );
  await done.future;
  await _flush();
}

class _RestRequest {
  _RestRequest(this.options, this.handler);
  final RequestOptions options;
  final RequestInterceptorHandler handler;

  void complete({bool pro = false}) {
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'subscriber': {
            'first_seen': '2026-01-01T00:00:00Z',
            'entitlements': {
              if (pro)
                Env.revenuecatAccessEntitlementId: {
                  'expires_date': '2099-01-01T00:00:00Z',
                  'product_identifier': 'subscription',
                },
            },
          },
        },
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('REST session', () {
    late PurchasesService service;
    late List<_RestRequest> requests;
    late List<MethodCall> nativeCalls;
    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      requests = [];
      nativeCalls = [];
      final client = Dio(BaseOptions(baseUrl: 'https://example.invalid/v1/'));
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(_RestRequest(options, handler));
          },
        ),
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            nativeCalls.add(call);
            throw StateError('REST must not use native Purchases');
          });
      service = PurchasesService(restClient: client);
      addTearDown(service.dispose);
      await service.init();
    });

    test('REST never configures or reads the native SDK', () async {
      await service.login('A');
      final result = service.getCustomerInfo();
      await _flush();
      expect(requests.single.options.path, 'subscribers/A');
      requests.single.complete(pro: true);
      expect((await result)?.isActive, isTrue);
      expect(nativeCalls, isEmpty);
    });

    test('late A response is rejected after A -> logout -> A', () async {
      await service.login('A');
      final oldRead = service.getCustomerInfo();
      await _flush();
      final oldRequest = requests.single;
      await service.logout();
      await service.login('A');
      final newRead = service.getCustomerInfo();
      await _flush();
      requests.last.complete();
      expect(await newRead, isNull);
      oldRequest.complete(pro: true);
      expect(await oldRead, isNull);
      expect(await service.getCustomerInfo(), isNull);
      expect(requests.length, 2);
    });

    test(
      'separate services do not share REST identity or pending cache',
      () async {
        final otherRequests = <_RestRequest>[];
        final client = Dio(BaseOptions(baseUrl: 'https://example.invalid/v1/'));
        client.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              otherRequests.add(_RestRequest(options, handler));
            },
          ),
        );
        final other = PurchasesService(restClient: client);
        addTearDown(other.dispose);
        await service.login('A');
        await other.login('B');
        final a = service.getCustomerInfo();
        final b = other.getCustomerInfo();
        await _flush();
        expect(requests.single.options.path, 'subscribers/A');
        expect(otherRequests.single.options.path, 'subscribers/B');
        requests.single.complete(pro: true);
        otherRequests.single.complete();
        expect((await a)?.isActive, isTrue);
        expect(await b, isNull);
      },
    );
  });

  group('native session', () {
    late PurchasesService service;
    late List<MethodCall> calls;
    late String currentUser;
    Future<dynamic> Function(MethodCall)? intercept;
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      calls = [];
      currentUser = 'anonymous';
      intercept = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_channel, (call) async {
            calls.add(call);
            if (intercept != null) {
              final result = await intercept!(call);
              if (result != null) return result;
            }
            switch (call.method) {
              case 'logIn':
                currentUser = (call.arguments as Map)['appUserID'] as String;
                return {
                  'customerInfo': _nativeInfo(currentUser),
                  'created': false,
                };
              case 'logOut':
                currentUser = 'anonymous';
                return _nativeInfo(currentUser);
              case 'getCustomerInfo':
                return _nativeInfo(currentUser);
              default:
                return null;
            }
          });
      service = PurchasesService();
      addTearDown(service.dispose);
    });

    test('concurrent initialization configures the SDK once', () async {
      final ready = Completer<dynamic>();
      intercept = (call) async =>
          call.method == 'setupPurchases' ? ready.future : null;
      final first = service.init();
      final second = service.init();
      await _flush();
      expect(calls.where((c) => c.method == 'setupPurchases').length, 1);
      ready.complete(true);
      await Future.wait([first, second]);
      expect(service.isInitialized(), isTrue);
      await _flush();
    });

    test(
      'native callback is re-read for the current user instead of trusting old payload',
      () async {
        await service.init();
        await service.login('B');
        await _flush();
        final values = <bool>[];
        final sub = service.entitlementStream.listen(
          (info) => values.add(info?.isActive ?? false),
        );
        addTearDown(sub.cancel);
        await _nativeUpdate(_nativeInfo('A', pro: true));
        expect(values, isNotEmpty);
        expect(values, everyElement(isFalse));
        expect(currentUser, 'B');
      },
    );

    test('read begun for A cannot finish as A after login B', () async {
      await service.init();
      await service.login('A');
      await _flush();
      final pending = Completer<dynamic>();
      intercept = (call) async =>
          call.method == 'getCustomerInfo' ? pending.future : null;
      final oldRead = service.getCustomerInfo();
      await _flush();
      await service.login('B');
      pending.complete(_nativeInfo('A', pro: true));
      expect(await oldRead, isNull);
    });

    test(
      'late native callback read cannot overwrite a newer explicit read',
      () async {
        await service.init();
        await service.login('A');
        await _flush();
        final old = Completer<dynamic>();
        var reads = 0;
        intercept = (call) async {
          if (call.method != 'getCustomerInfo') return null;
          return ++reads == 1 ? old.future : _nativeInfo('A', pro: true);
        };
        final values = <bool>[];
        final sub = service.entitlementStream.listen(
          (info) => values.add(info?.isActive ?? false),
        );
        addTearDown(sub.cancel);
        await _nativeUpdate(_nativeInfo('A'));
        expect((await service.getCustomerInfo())?.isActive, isTrue);
        values.clear();
        old.complete(_nativeInfo('A'));
        await _flush();
        expect(values, isEmpty);
        expect((await service.getCustomerInfo())?.isActive, isTrue);
      },
    );

    test(
      'failed login keeps old native identity inaccessible until a successful retry',
      () async {
        await service.init();
        await service.login('A');
        await _flush();
        intercept = (call) async {
          if (call.method == 'logIn') {
            throw PlatformException(code: 'login_failed');
          }
          return null;
        };
        await expectLater(
          service.login('B'),
          throwsA(isA<PlatformException>()),
        );
        expect(currentUser, 'A');
        expect(await service.getCustomerInfo(), isNull);
        final count = calls.where((c) => c.method == 'getCustomerInfo').length;
        await _nativeUpdate(_nativeInfo('A', pro: true));
        expect(calls.where((c) => c.method == 'getCustomerInfo').length, count);
        intercept = null;
        await service.login('B');
        expect(currentUser, 'B');
        expect(await service.getCustomerInfo(), isNull);
      },
    );

    test('login waits for an in-progress restore to finish', () async {
      await service.init();
      await service.login('A');
      await _flush();
      final pending = Completer<dynamic>();
      intercept = (call) async =>
          call.method == 'restorePurchases' ? pending.future : null;
      final restore = service.restorePurchases();
      await _flush();
      final login = service.login('B');
      await _flush();
      expect(currentUser, 'A');
      pending.complete(_nativeInfo('A', pro: true));
      await restore;
      await login;
      expect(currentUser, 'B');
    });
  });
}

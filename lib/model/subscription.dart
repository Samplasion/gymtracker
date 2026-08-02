import 'package:equatable/equatable.dart';

class SubscriptionInfo extends Equatable {
  final bool isPro;
  final bool isTrial;
  final bool isForcedPro;
  final bool isAboutToExpire;
  final String? userID;

  static const empty = SubscriptionInfo(
    isPro: false,
    isTrial: false,
    isForcedPro: false,
    isAboutToExpire: false,
    userID: null,
  );

  const SubscriptionInfo({
    required this.isPro,
    required this.isTrial,
    required this.isForcedPro,
    required this.isAboutToExpire,
    this.userID,
  });

  bool get hasProFeatures {
    return isPro || isForcedPro;
  }

  bool get alertUserOfExpiration {
    return isPro && !isTrial && !isForcedPro && isAboutToExpire;
  }

  @override
  List<Object?> get props => [
    isPro,
    isTrial,
    isForcedPro,
    isAboutToExpire,
    userID,
  ];

  @override
  bool get stringify => true;
}

class Subscription extends Equatable {
  final String productId;
  final String price;
  final String displayName;
  final SubscriptionPeriod duration;
  final SubscriptionTrial? trial;

  const Subscription({
    required this.productId,
    required this.price,
    required this.displayName,
    required this.duration,
    this.trial,
  });

  @override
  List<Object?> get props => [productId, price, displayName, duration, trial];

  @override
  bool get stringify => true;
}

class Offering extends Equatable {
  final List<Subscription> subscriptions;

  static const empty = Offering(subscriptions: []);

  const Offering({required this.subscriptions});

  @override
  List<Object?> get props => [subscriptions];

  @override
  bool get stringify => true;
}

enum SubscriptionPeriod { week, month, year }

class SubscriptionTrial extends Equatable {
  final int duration;
  final SubscriptionPeriod periodType;

  const SubscriptionTrial({required this.duration, required this.periodType});

  @override
  List<Object?> get props => [duration, periodType];

  @override
  bool get stringify => true;
}

enum SubscriptionPurchaseStatus { success, cancelled, error }

part of 'events.dart';

class GBUserWillLoginEvent extends GBEvent {}

class GBUserDidLoginEvent extends GBEvent {
  final OnlineAccount? account;

  const GBUserDidLoginEvent(this.account);
}

class GBUserWillLogoutEvent extends GBEvent {
  final OnlineAccount? account;

  const GBUserWillLogoutEvent(this.account);
}

class GBUserDidLogoutEvent extends GBEvent {}

class GBUserDidUpdateSubscriptionEvent extends GBEvent {
  final OnlineAccount? user;
  final Subscription? subscription;

  const GBUserDidUpdateSubscriptionEvent({
    required this.user,
    required this.subscription,
  });
}

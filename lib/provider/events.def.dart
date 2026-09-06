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

class GBSyncStartedEvent extends GBEvent {
  const GBSyncStartedEvent();
}

class GBSyncFinishedEvent extends GBEvent {
  final DateTime? lastSync;

  const GBSyncFinishedEvent({this.lastSync});
}

class GBSyncErrorEvent extends GBEvent {
  final Object error;
  final StackTrace? stackTrace;

  const GBSyncErrorEvent(this.error, [this.stackTrace]);
}

class GBSyncTimestampUpdatedEvent extends GBEvent {
  final DateTime timestamp;

  const GBSyncTimestampUpdatedEvent(this.timestamp);
}

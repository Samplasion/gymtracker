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
  final String? userId;
  const GBSyncStartedEvent({this.userId});
}

class GBSyncFinishedEvent extends GBEvent {
  final DateTime? lastSync;

  final String? userId;
  const GBSyncFinishedEvent({this.lastSync, this.userId});
}

class GBSyncErrorEvent extends GBEvent {
  final Object error;
  final StackTrace? stackTrace;

  final String? userId;
  const GBSyncErrorEvent(this.error, [this.stackTrace, this.userId]);
}

class GBSyncTimestampUpdatedEvent extends GBEvent {
  final DateTime timestamp;

  const GBSyncTimestampUpdatedEvent(this.timestamp);
}

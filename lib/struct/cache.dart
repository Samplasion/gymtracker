/// A generic container that holds fetched data alongside its download timestamp
/// and a time-to-live (TTL) so that callers can decide whether to use the
/// cached value or re-fetch it from the network.
class CachedData<T> {
  /// The moment at which the data was originally fetched.
  final DateTime downloaded;

  /// The cached payload.
  final T data;

  /// How long (in seconds) this cache entry is considered fresh.
  /// Defaults to one hour (3 600 s).
  final int ttl;

  const CachedData(this.downloaded, this.data, {this.ttl = 3600});

  /// Returns `true` when the age of this entry has exceeded [ttl].
  bool get isExpired =>
      DateTime.now().difference(downloaded).inSeconds > ttl;
}

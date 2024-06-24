base class Optional<T> {
  const Optional();

  bool get exists => this is Some<T>;

  T unwrap() {
    if (this is Some<T>) {
      return (this as Some<T>).value;
    } else {
      throw Exception("Tried to unwrap a None");
    }
  }

  T? safeUnwrap() {
    if (this is Some<T>) {
      return (this as Some<T>).value;
    } else {
      return null;
    }
  }
}

final class Some<T> extends Optional<T> {
  final T value;

  const Some(this.value);
}

final class None<T> extends Optional<T> {
  const None();
}

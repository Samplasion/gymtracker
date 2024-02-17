class StopwatchEx extends Stopwatch {
  int _starterMilliseconds = 0;

  StopwatchEx();

  StopwatchEx.fromMilliseconds(int milliseconds) {
    _starterMilliseconds = milliseconds;
  }

  @override
  Duration get elapsed {
    return Duration(
        milliseconds: _starterMilliseconds + super.elapsedMilliseconds);
  }

  @override
  int get elapsedMilliseconds {
    return _starterMilliseconds + super.elapsedMilliseconds;
  }

  @override
  reset() {
    _starterMilliseconds = 0;
    super.reset();
  }
}

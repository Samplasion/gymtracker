class TestService {
  static final _testService = TestService._internal();

  TestService._internal();

  factory TestService() {
    return _testService;
  }

  bool isTest = false;
}

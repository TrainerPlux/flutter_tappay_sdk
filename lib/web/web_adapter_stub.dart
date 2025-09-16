class TapPayWebHelpers {
  TapPayWebHelpers._();
  static final instance = TapPayWebHelpers._();

  Future<void> init({
    required int appId,
    required String appKey,
    required String env,
  }) async =>
      throw UnsupportedError('Web only');
  Future<void> renderField(String hostId) async =>
      throw UnsupportedError('Web only');
  Future<String> getPrime() async => throw UnsupportedError('Web only');
  Future<void> unmountField(String hostId) async =>
      throw UnsupportedError('Web only');
}

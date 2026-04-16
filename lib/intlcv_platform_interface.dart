import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'intlcv_method_channel.dart';

abstract class IntlcvPlatform extends PlatformInterface {
  /// Constructs a IntlcvPlatform.
  IntlcvPlatform() : super(token: _token);

  static final Object _token = Object();

  static IntlcvPlatform _instance = MethodChannelIntlcv();

  /// The default instance of [IntlcvPlatform] to use.
  ///
  /// Defaults to [MethodChannelIntlcv].
  static IntlcvPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IntlcvPlatform] when
  /// they register themselves.
  static set instance(IntlcvPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

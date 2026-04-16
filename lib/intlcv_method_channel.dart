import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'intlcv_platform_interface.dart';

/// An implementation of [IntlcvPlatform] that uses method channels.
class MethodChannelIntlcv extends IntlcvPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('intlcv');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

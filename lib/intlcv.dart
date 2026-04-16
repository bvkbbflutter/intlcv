
import 'intlcv_platform_interface.dart';

class Intlcv {
  Future<String?> getPlatformVersion() {
    return IntlcvPlatform.instance.getPlatformVersion();
  }
}

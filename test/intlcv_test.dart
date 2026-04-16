import 'package:flutter_test/flutter_test.dart';
import 'package:intlcv/intlcv.dart';
import 'package:intlcv/intlcv_platform_interface.dart';
import 'package:intlcv/intlcv_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIntlcvPlatform
    with MockPlatformInterfaceMixin
    implements IntlcvPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IntlcvPlatform initialPlatform = IntlcvPlatform.instance;

  test('$MethodChannelIntlcv is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIntlcv>());
  });

  test('getPlatformVersion', () async {
    Intlcv intlcvPlugin = Intlcv();
    MockIntlcvPlatform fakePlatform = MockIntlcvPlatform();
    IntlcvPlatform.instance = fakePlatform;

    expect(await intlcvPlugin.getPlatformVersion(), '42');
  });
}

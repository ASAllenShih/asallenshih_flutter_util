import 'package:asallenshih_flutter_util/device_info.dart';

class AsallenshihFlutterUtil {
  static Future<void> init() async {
    await DeviceInfo.init();
  }
}

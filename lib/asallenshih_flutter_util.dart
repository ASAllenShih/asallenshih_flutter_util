import 'package:asallenshih_flutter_util/device_info.dart'
    deferred as device_info;
import 'package:asallenshih_flutter_util/package_info.dart'
    deferred as package_info;

class AsallenshihFlutterUtil {
  static Future<void> init({
    bool deviceInfo = false,
    bool packageInfo = false,
    String? packageInfoBaseUrl,
  }) async {
    if (deviceInfo) {
      await device_info.loadLibrary();
      await device_info.DeviceInfo.init();
    }
    if (packageInfo) {
      await package_info.loadLibrary();
      package_info.PackageInfo.baseUrl = packageInfoBaseUrl;
      await package_info.PackageInfo.init();
    }
  }
}

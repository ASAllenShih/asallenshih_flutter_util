import 'package:asallenshih_flutter_util/package_info_data.dart';
import 'package:package_info_plus/package_info_plus.dart'
    deferred as package_info_plus;

class Package {
  static String? baseUrl;
  static PackageInfoData? _data;
  static PackageInfoData? get data => _data;
  static Future<PackageInfoData> getData() async {
    if (_data !=null) {
      return _data!;
    }
    await package_info_plus.loadLibrary();
    final packageInfo = await package_info_plus.PackageInfo.fromPlatform(baseUrl: baseUrl);
    _data = PackageInfoData(
      appName: packageInfo.appName,
      buildNumber: packageInfo.buildNumber,
      version: packageInfo.version,
    );
    return _data!;
  }
}

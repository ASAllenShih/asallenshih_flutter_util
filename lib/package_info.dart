import 'package:package_info_plus/package_info_plus.dart'
    deferred as package_info_plus;

class PackageInfo {
  static String? baseUrl;
  static PackageInfoData? _data;
  static PackageInfoData? get data => _data;
  static Future<void> init() async {
    if (_data == null) {
      await getData();
    }
  }

  static Future<PackageInfoData> getData() async {
    if (_data != null) {
      return _data!;
    }
    await package_info_plus.loadLibrary();
    final packageInfo = await package_info_plus.PackageInfo.fromPlatform(
      baseUrl: baseUrl,
    );
    _data = PackageInfoData(
      appName: packageInfo.appName,
      buildNumber: packageInfo.buildNumber,
      version: packageInfo.version,
    );
    return _data!;
  }
}

class PackageInfoData {
  PackageInfoData({
    required this.appName,
    required this.buildNumber,
    required this.version,
  });
  final String appName;
  final String buildNumber;
  final String version;
}

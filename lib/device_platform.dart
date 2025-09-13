import 'package:asallenshih_flutter_util/device.dart';
import 'package:asallenshih_flutter_util/device_info.dart';

enum DevicePlatform {
  unknown,
  android,
  ios,
  windows,
  macOS,
  linux,
  web(isWeb: true),
  webAndroid(isWeb: true),
  webIOS(isWeb: true),
  webWindows(isWeb: true),
  webMacOS(isWeb: true),
  webLinux(isWeb: true);

  const DevicePlatform({this.isWeb = false});
  final bool isWeb;
  DevicePlatform get system => isWeb
      ? switch (this) {
          DevicePlatform.webAndroid => DevicePlatform.android,
          DevicePlatform.webIOS => DevicePlatform.ios,
          DevicePlatform.webWindows => DevicePlatform.windows,
          DevicePlatform.webMacOS => DevicePlatform.macOS,
          DevicePlatform.webLinux => DevicePlatform.linux,
          _ => DevicePlatform.unknown,
        }
      : this;
  static DevicePlatform get current {
    if (Device.isAndroid) {
      return DevicePlatform.android;
    } else if (Device.isIOS) {
      return DevicePlatform.ios;
    } else if (Device.isWindows) {
      return DevicePlatform.windows;
    } else if (Device.isMacOS) {
      return DevicePlatform.macOS;
    } else if (Device.isLinux) {
      return DevicePlatform.linux;
    } else if (Device.isWeb) {
      final String userAgent = DeviceInfo.data.systemVersion?.toLowerCase() ?? 'unknown';
      if (userAgent.contains('android')) {
        return DevicePlatform.webAndroid;
      } else if (userAgent.contains(RegExp(r'iphone|ipad|ipod'))) {
        return DevicePlatform.webIOS;
      } else if (userAgent.contains('windows')) {
        return DevicePlatform.webWindows;
      } else if (userAgent.contains('macintosh')) {
        return DevicePlatform.webMacOS;
      } else if (userAgent.contains('linux')) {
        return DevicePlatform.webLinux;
      } else {
        return DevicePlatform.web;
      }
    } else {
      return DevicePlatform.unknown;
    }
  }
}

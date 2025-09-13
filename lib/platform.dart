import 'package:asallenshih_flutter_util/device.dart';
import 'package:asallenshih_flutter_util/device_info.dart';

enum Platform {
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

  const Platform({this.isWeb = false});
  final bool isWeb;
  Platform get system => isWeb
      ? switch (this) {
          Platform.webAndroid => Platform.android,
          Platform.webIOS => Platform.ios,
          Platform.webWindows => Platform.windows,
          Platform.webMacOS => Platform.macOS,
          Platform.webLinux => Platform.linux,
          _ => Platform.unknown,
        }
      : this;
  static Platform get current {
    if (Device.isAndroid) {
      return Platform.android;
    } else if (Device.isIOS) {
      return Platform.ios;
    } else if (Device.isWindows) {
      return Platform.windows;
    } else if (Device.isMacOS) {
      return Platform.macOS;
    } else if (Device.isLinux) {
      return Platform.linux;
    } else if (Device.isWeb) {
      final String userAgent = DeviceInfo.data.systemVersion?.toLowerCase() ?? 'unknown';
      if (userAgent.contains('android')) {
        return Platform.webAndroid;
      } else if (userAgent.contains(RegExp(r'iphone|ipad|ipod'))) {
        return Platform.webIOS;
      } else if (userAgent.contains('windows')) {
        return Platform.webWindows;
      } else if (userAgent.contains('macintosh')) {
        return Platform.webMacOS;
      } else if (userAgent.contains('linux')) {
        return Platform.webLinux;
      } else {
        return Platform.web;
      }
    } else {
      return Platform.unknown;
    }
  }
}

import 'dart:async';

import 'package:asallenshih_flutter_util/device.dart';
import 'package:flutter/foundation.dart';

enum Platforms {
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

  const Platforms({this.isWeb = false});
  final bool isWeb;
}

class Platform {
  static Platforms? current;
  static Future<void> init() async {
    if (current != null) {
      return;
    }
    current = await _get();
  }

  static FutureOr<Platforms?> _get() async {
    if (kIsWeb) {
      final String systemVersion = (await Device.systemVersion() ?? '')
          .toLowerCase();
      if (systemVersion.contains('android')) {
        return Platforms.webAndroid;
      } else if (systemVersion.contains('iphone') ||
          systemVersion.contains('ipad') ||
          systemVersion.contains('ipod')) {
        return Platforms.webIOS;
      } else if (systemVersion.contains('windows')) {
        return Platforms.webWindows;
      } else if (systemVersion.contains('macintosh')) {
        return Platforms.webMacOS;
      } else if (systemVersion.contains('linux')) {
        return Platforms.webLinux;
      } else {
        return Platforms.web;
      }
    } else if (Device.isAndroid) {
      return Platforms.android;
    } else if (Device.isIOS) {
      return Platforms.ios;
    } else if (Device.isWindows) {
      return Platforms.windows;
    } else if (Device.isMacOS) {
      return Platforms.macOS;
    } else if (Device.isLinux) {
      return Platforms.linux;
    }
    return null;
  }
}

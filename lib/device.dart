import 'package:flutter/foundation.dart';

class Device {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid =>
      !isWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isWindows =>
      !isWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isLinux =>
      !isWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isFuchsia =>
      !isWeb && defaultTargetPlatform == TargetPlatform.fuchsia;
  static bool get supportedWebView => isAndroid || isIOS || isWindows || isMacOS;
  static bool get supportedWebViewOrIframe => supportedWebView || isWeb;
}

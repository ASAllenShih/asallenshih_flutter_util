import 'dart:async';

import 'package:asallenshih_flutter_util/device.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Webview {
  final Completer<bool> controllerLoad = Completer<bool>();
  InAppWebViewController? webViewController;
  InAppWebView? widget({
    WebViewEnvironment? webViewEnvironment,
    InAppWebViewSettings? webViewSettings,
    Uri? initialUri,
    FutureOr<bool> Function(NavigationAction)? onLoadRequest,
    void Function(WebUri?)? onLoadStart,
    void Function(WebUri?)? onLoadStop,
    void Function(int)? onLoadProgress,
    bool userAgentWV = true,
  }) {
    if (!Device.supportedWebViewOrIframe ||
        (Device.isWindows && webViewEnvironment == null)) {
      if (!controllerLoad.isCompleted) {
        controllerLoad.complete(false);
      }
      return null;
    } else if (Device.isAndroid) {
      InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
    return InAppWebView(
      webViewEnvironment: webViewEnvironment,
      initialSettings: webViewSettings,
      initialUrlRequest:
          initialUri != null && userAgentWV
              ? URLRequest(url: WebUri.uri(initialUri))
              : null,
      onWebViewCreated: (InAppWebViewController controller) async {
        webViewController = controller;
        final InAppWebViewSettings? settings =
            await webViewController?.getSettings();
        if (settings != null && !userAgentWV) {
          settings.userAgent = settings.userAgent?.replaceFirst('; wv', '');
          await webViewController?.setSettings(settings: settings);
          await controllerLoadUri(initialUri);
        }
        if (!controllerLoad.isCompleted) {
          controllerLoad.complete(true);
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        log.d(
          'WebView主控台[${consoleMessage.messageLevel == ConsoleMessageLevel.TIP
              ? '提示'
              : consoleMessage.messageLevel == ConsoleMessageLevel.DEBUG
              ? '調試'
              : consoleMessage.messageLevel == ConsoleMessageLevel.LOG
              ? '日誌'
              : consoleMessage.messageLevel == ConsoleMessageLevel.WARNING
              ? '警告'
              : consoleMessage.messageLevel == ConsoleMessageLevel.ERROR
              ? '錯誤'
              : ''}]: ${consoleMessage.message}',
        );
      },
      shouldOverrideUrlLoading:
          onLoadRequest != null
              ? (controller, navigationAction) async {
                final bool allow = await onLoadRequest(navigationAction);
                if (!allow) {
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              }
              : null,
      onLoadStart:
          onLoadStart != null
              ? (controller, url) {
                onLoadStart(url);
              }
              : null,
      onLoadStop:
          onLoadStop != null
              ? (controller, url) {
                onLoadStop(url);
              }
              : null,
    );
  }

  FutureOr<void> controllerLoadUri(Uri? uri) async {
    if (uri == null) {
      await webViewController?.loadData(data: '');
    } else {
      await webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(uri)),
      );
    }
  }

  static WebViewEnvironment? _webViewEnvironment;
  static FutureOr<WebViewEnvironment?> environment() async {
    if (!Device.isWindows ||
        (await WebViewEnvironment.getAvailableVersion()) == null) {
      return null;
    }
    return _webViewEnvironment ??= await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(),
    );
  }

  static InAppWebViewSettings settings({bool? javaScriptEnabled}) {
    final InAppWebViewSettings inAppWebViewSettings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true,
      javaScriptEnabled: javaScriptEnabled,
    );
    return inAppWebViewSettings;
  }
}

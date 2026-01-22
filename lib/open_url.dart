import 'package:asallenshih_flutter_util/log.dart';
import 'package:asallenshih_flutter_util/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenUrl {
  static Future<bool> _open(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
    Map<String, String>? headers,
  }) async {
    try {
      headers ??= {};
      final PackageInfoData packageInfo = await PackageInfo.getData();
      headers.addAll({'User-Agent': 'AllenAPP/${packageInfo.version}'});
      return await launchUrl(
        Uri.parse(url),
        mode: mode,
        browserConfiguration: BrowserConfiguration(showTitle: true),
        webViewConfiguration: WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
          headers: headers,
        ),
      );
    } catch (e) {
      log.e('無法開啟網址', error: e);
      return false;
    }
  }

  static Future<bool> openAppBrowser(String url) async {
    return await _open(url, mode: LaunchMode.inAppBrowserView);
  }

  static Future<bool> openWebView(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    return await _open(url, mode: LaunchMode.inAppWebView, headers: headers);
  }

  static Future<bool> openExtApp(String url) async {
    return await _open(url, mode: LaunchMode.externalApplication);
  }
}

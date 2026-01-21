import 'package:asallenshih_flutter_util/http/addon.dart';

class HttpAddonRetry extends HttpAddon {
  HttpAddonRetry({this.retryResponseCodes = const [429]});
  final List<int> retryResponseCodes;
  @override
  Future<int?> responseCode(int? codeData) {
    if (codeData != null && retryResponseCodes.contains(codeData)) {
      throw HttpRetryException(codeData);
    }
    return super.responseCode(codeData);
  }
}

class HttpRetryException implements Exception {
  final int code;
  HttpRetryException(this.code);
  @override
  String toString() => 'HttpRetryException: Retry on response code $code';
}

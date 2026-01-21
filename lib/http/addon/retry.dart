import 'package:asallenshih_flutter_util/http.dart';
import 'package:asallenshih_flutter_util/http/addon.dart';

class HttpAddonRetry extends HttpAddon {
  HttpAddonRetry({this.retryResponseCodes = const [429]});
  final List<int> retryResponseCodes;
  @override
  Future<bool?> requestError(Http http, Object error) async {
    if (error is HttpRetryException) {
      return false;
    }
    return super.requestError(http, error);
  }

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

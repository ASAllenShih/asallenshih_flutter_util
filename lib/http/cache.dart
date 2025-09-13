import 'package:asallenshih_flutter_util/http/cache_base.dart';

class HttpCache extends HttpCacheBase {
  HttpCache(
    super.uri, {
    super.method,
    super.headers,
    super.body,
    super.cacheKey,
  });
}

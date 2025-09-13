import 'dart:async';

import 'package:asallenshih_flutter_util/cache.dart';
import 'package:asallenshih_flutter_util/http/base.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:crypto/crypto.dart';

abstract class HttpCacheBase extends HttpBase {
  HttpCacheBase(
    super.uri, {
    super.method,
    super.headers,
    super.body,
    final String? cacheKey,
  }) {
    _cache = Cache(
      key:
          'http.${cacheKey ?? sha1.convert(uri.toString().codeUnits).toString()}.$method',
    );
  }
  late final Cache _cache;
  Map<String, dynamic>? _cached;
  Future<Map<String, dynamic>?> get _cachedGet async {
    _cached ??= await _cache.readJson;
    return _cached;
  }

  @override
  Future<void> request({
    void Function(int downloaded, int total)? onProgress,
  }) async {
    final Map<String, dynamic>? cached = await _cachedGet;
    if (cached != null &&
        cached.containsKey('headers') &&
        cached.containsKey('bytes')) {
      final Map<String, String> headers =
          cached['headers'] as Map<String, String>;
      if (headers.containsKey('last-modified')) {
        this.headers['If-Modified-Since'] = headers['last-modified']!;
      }
      if (headers.containsKey('etag')) {
        this.headers['If-None-Match'] = headers['etag']!;
      }
    }
    return await super.request(onProgress: onProgress);
  }

  @override
  Future<List<int>?> get getBytes async {
    final List<int>? bytes = await super.getBytes;
    if (responseCode == 304) {
      final Map<String, dynamic>? cached = await _cachedGet;
      if (cached != null && cached.containsKey('bytes')) {
        try {
          return cached['bytes'] as List<int>;
        } catch (e) {
          log.e('HTTP get cache bytes error.', error: e);
          return bytes;
        }
      }
    } else if (bytes != null &&
        responseCode != null &&
        responseCode! >= 200 &&
        responseCode! < 300) {
      await _cache.writeJson({
        'code': responseCode,
        'headers': responseHeaders,
        'bytes': bytes,
      });
    }
    return bytes;
  }
}

import 'dart:io';

import 'package:asallenshih_flutter_util/cache.dart';
import 'package:asallenshih_flutter_util/cache/addon.dart';
import 'package:asallenshih_flutter_util/http/addon.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:crypto/crypto.dart';

class HttpAddonCache extends HttpAddon {
  Cache? cache;
  String? key;
  Directory? dir;
  List<CacheAddon> addons;
  String? _method;
  Uri? _uri;
  bool _useCache = false;
  HttpAddonCache({this.cache, this.key, this.dir, this.addons = const []});
  Cache _cache() {
    return cache ??= Cache(
      key: key ??= generateKey(_uri, _method),
      dir: dir,
      addons: addons,
    );
  }

  Map<String, dynamic>? _cachedData;
  Map<String, String>? get _cachedHeaders => _cachedData != null
      ? Map<String, String>.from(_cachedData!['headers'])
      : null;
  String? _cachedHeader(String name) =>
      _cachedHeaders != null ? _cachedHeaders![name.toLowerCase()] : null;
  int? get _cachedCode =>
      _cachedData != null ? _cachedData!['code'] as int? : null;
  List<int>? get _cachedBytes =>
      _cachedData != null && _cachedData!['bytes'] != null
          ? List<int>.from(_cachedData!['bytes'])
          : null;

  int? _saveCode;
  Map<String, String>? _saveHeaders;
  List<int>? _saveBytes;
  Future<void> _saveCache() async {
    if (_saveCode == null || _saveHeaders == null || _saveBytes == null) {
      return;
    }
    final Cache cacheInstance = _cache();
    final Map<String, dynamic> cacheData = {
      'method': _method,
      'uri': _uri.toString(),
      'code': _saveCode,
      'headers': _saveHeaders,
      'bytes': _saveBytes,
    };
    await cacheInstance.writeJson(cacheData);
  }

  @override
  Future<String> method(String methodData) {
    _method = methodData;
    return super.method(methodData);
  }

  @override
  Future<Uri> uri(Uri uriData) {
    _uri = uriData;
    return super.uri(uriData);
  }

  @override
  Future<Map<String, String>> headers(Map<String, String> headersData) async {
    final headers = Map<String, String>.from(headersData);
    final Cache cacheInstance = _cache();
    _cachedData = await cacheInstance.readJson;
    if (_uri != null && _cachedBytes != null && _cachedBytes!.isNotEmpty) {
      if (cacheInstance.expired == false) {
        request = false;
      }
      final String? lastModified = _cachedHeader('last-modified');
      final String? etag = _cachedHeader('etag');
      if (lastModified != null) {
        headers['If-Modified-Since'] = lastModified;
      }
      if (etag != null) {
        headers['If-None-Match'] = etag;
      }
    }
    return super.headers(headers);
  }

  @override
  Future<int?> responseCode(int? codeData) async {
    if (_useCache || codeData == null || codeData == 304) {
      final int? code = _cachedCode;
      if (code != null) {
        _useCache = true;
        log.i('Response code $code from cache: ${_uri?.toString()}');
        return super.responseCode(code);
      }
    } else if (codeData >= 200 && codeData < 300) {
      _saveCode = codeData;
    }
    return super.responseCode(codeData);
  }

  @override
  Future<Map<String, String>?> responseHeaders(
    Map<String, String>? headersData,
  ) async {
    if (_useCache || headersData == null) {
      final Map<String, String>? cachedHeaders = _cachedHeaders;
      if (cachedHeaders != null) {
        _useCache = true;
        log.i('Headers from cache: ${_uri?.toString()}');
        return super.responseHeaders(cachedHeaders);
      }
    } else {
      _saveHeaders = headersData;
    }
    return super.responseHeaders(headersData);
  }

  @override
  Future<List<int>> responseChunks(List<int> chunksData) async {
    log.d('HttpAddonCache responseChunks called');
    if (_useCache || chunksData.isEmpty) {
      final List<int>? cachedBytes = _cachedBytes;
      if (cachedBytes != null) {
        _useCache = true;
        log.i('Data from cache: ${_uri?.toString()}');
        return super.responseChunks(cachedBytes);
      }
    } else {
      _saveBytes = chunksData;
      await _saveCache();
    }
    return super.responseChunks(chunksData);
  }

  static String generateKey(Uri? uriData, String? methodData) {
    if (uriData == null || methodData == null) {
      throw Exception('HTTP Cache Addon uri and method must not be null');
    }
    return 'http.${sha1.convert(uriData.removeFragment().toString().codeUnits).toString()}.$methodData';
  }
}

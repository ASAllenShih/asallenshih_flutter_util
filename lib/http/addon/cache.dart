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
  Map<String, dynamic>? _cachedAll;
  bool _useCache = false;
  HttpAddonCache({this.cache, this.key, this.dir, this.addons = const []});
  Cache _cache() {
    return cache ??= Cache(
      key: key ??= generateKey(_uri, _method),
      dir: dir,
      addons: addons,
    );
  }

  Map<String, dynamic>? get _cached {
    final String? indexKey = _uri?.removeFragment().toString();
    if (_cachedAll != null &&
        indexKey != null &&
        _cachedAll!.containsKey(indexKey) &&
        _cachedAll![indexKey] is Map<String, dynamic>) {
      return _cachedAll![indexKey] as Map<String, dynamic>;
    }
    return null;
  }

  set _cached(Map<String, dynamic>? value) {
    final String? indexKey = _uri?.removeFragment().toString();
    if (indexKey != null && value != null) {
      _cachedAll ??= <String, dynamic>{};
      _cachedAll![indexKey] = value;
    }
  }

  int? get _cachedCode =>
      _cached != null && _cached!.containsKey('code') && _cached!['code'] is int
      ? (_cached!['code'] as int)
      : null;
  set _cachedCode(int? value) {
    if (value != null) {
      _cached ??= <String, dynamic>{};
      _cached!['code'] = value;
    }
  }

  Map<String, String>? get _cachedHeaders =>
      _cached != null &&
          _cached!.containsKey('headers') &&
          _cached!['headers'] is Map<String, String>
      ? (_cached!['headers'] as Map<String, String>?)
      : null;
  set _cachedHeaders(Map<String, String>? value) {
    if (value != null) {
      _cached ??= <String, dynamic>{};
      _cached!['headers'] = value;
    }
  }

  List<int>? get _cachedBytes =>
      _cached != null &&
          _cached!.containsKey('bytes') &&
          _cached!['bytes'] is List<int>
      ? (_cached!['bytes'] as List<int>)
      : null;
  set _cachedBytes(List<int>? value) {
    if (value != null) {
      _cached ??= <String, dynamic>{};
      _cached!['bytes'] = value;
    }
  }

  String? _cachedHeader(String name) =>
      _cachedHeaders != null && _cachedHeaders!.containsKey(name)
      ? _cachedHeaders![name]
      : null;
  Future<void> _saveCache() async {
    if (_cachedCode == null || _cachedCode! < 200 || _cachedCode! >= 300) {
      log.i('Not saving cache for non-2xx response: ${_uri?.toString()}');
      return;
    }
    log.i('Saving cache: ${_uri?.toString()}');
    await _cache().writeJson(_cachedAll);
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
    final cacheData = await cacheInstance.readJson;
    if (_uri != null &&
        cacheData != null &&
        cacheData is Map<String, dynamic>) {
      _cachedAll = cacheData;
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
        log.i('Response code from cache: ${_uri?.toString()}');
        return super.responseCode(code);
      }
    } else {
      _cachedCode = codeData;
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
      _cachedHeaders = headersData;
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
      _cachedBytes = chunksData;
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

import 'dart:async';
import 'dart:convert';

import 'package:asallenshih_flutter_util/http/addon.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:http/http.dart' deferred as http show Client, Request;

class Http {
  Http(
    this.uri, {
    this.method = 'GET',
    this.body,
    this.headers = const {},
    this.addons = const [],
  });
  final Uri uri;
  final String method;
  final Object? body;
  final Map<String, String> headers;
  final List<HttpAddon> addons;
  Map<String, String>? responseHeaders;
  int? responseCode;
  final List<int> _chunks = List<int>.empty(growable: true);
  final Completer<void> _completer = Completer<void>();
  int downloaded = 0;
  int total = 0;

  Future<void> request({
    void Function(int downloaded, int total)? onProgress,
  }) async {
    await http.loadLibrary();
    final String requestMethod = await _loadAddon(
      method,
      (addon, previous) => addon.method(previous),
    );
    final Uri requestUri = await _loadAddon(
      uri,
      (addon, previous) => addon.uri(previous),
    );
    final request = http.Request(requestMethod, requestUri);
    final Object? requestBody = await _loadAddon(
      body,
      (addon, previous) => addon.body(previous),
    );
    if (requestBody != null) {
      if (requestBody is String) {
        request.body = requestBody;
      } else {
        throw Exception('Unsupported body type');
      }
    }
    final Map<String, String> requestHeaders = await _loadAddon(
      headers,
      (addon, previous) => addon.headers(previous),
    );
    request.headers.addAll(requestHeaders);
    try {
      _onProgress(onProgress);
      if (addons.any((addon) => addon.request == false)) {
        _sendResponse();
        _streamOnDone(onProgress: onProgress);
      } else {
        final client = http.Client();
        final response = await client.send(request);
        _sendResponse(
          code: response.statusCode,
          headers: response.headers,
          contentLength: response.contentLength,
        );
        response.stream.listen(
          (List<int> chunk) =>
              _streamChunk(chunk: chunk, onProgress: onProgress),
          onDone: () => _streamOnDone(onProgress: onProgress),
          onError: (Object error) {
            log.e('Download error', error: error);
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      log.e('Download error', error: e);
      _complete();
    }
  }

  Future<T> _loadAddon<T>(
    T value,
    Future<T> Function(HttpAddon addon, T previous) loader,
  ) => addons.fold<Future<T>>(
    Future.value(value),
    (Future<T> previous, HttpAddon addon) async =>
        await loader(addon, await previous),
  );

  void _sendResponse({
    int? code,
    Map<String, String>? headers,
    int? contentLength,
  }) {
    _loadAddon(
      code,
      (addon, previous) => addon.responseCode(previous),
    ).then((value) => responseCode = value);
    _loadAddon(
      headers,
      (addon, previous) => addon.responseHeaders(previous),
    ).then((value) => responseHeaders = value);
    total = contentLength ?? 0;
  }

  void _complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void _streamChunk({
    required List<int> chunk,
    void Function(int downloaded, int total)? onProgress,
  }) {
    _chunks.addAll(chunk);
    downloaded += chunk.length;
    _onProgress(onProgress);
  }

  void _streamOnDone({void Function(int downloaded, int total)? onProgress}) {
    log.i('Download complete: ${uri.toString()}');
    _onProgress(onProgress);
    _complete();
  }

  void _onProgress(void Function(int, int)? onProgress) {
    if (onProgress != null) {
      onProgress(downloaded, total < downloaded ? downloaded : total);
    }
  }

  Future<List<int>?> get getBytes async {
    await _completer.future;
    final List<int> chunks = await _loadAddon(
      _chunks,
      (addon, previous) => addon.responseChunks(previous),
    );
    if (chunks.isEmpty) {
      return null;
    }
    return chunks;
  }

  Future<String?> get getString async {
    final List<int>? bytes = await getBytes;
    if (bytes == null) {
      return null;
    }
    return utf8.decode(bytes);
  }

  Future<dynamic> get getJson async {
    final String? jsonString = await getString;
    if (jsonString == null) {
      return null;
    }
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      log.e('JSON decode error: $jsonString', error: e);
      return null;
    }
  }
}

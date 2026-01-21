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
    final String requestMethod = await addons.fold<Future<String>>(
      Future.value(method),
      (Future<String> previous, HttpAddon addon) async =>
          await addon.method(await previous),
    );
    final Uri requestUri = await addons.fold<Future<Uri>>(
      Future.value(uri),
      (Future<Uri> previous, HttpAddon addon) async =>
          await addon.uri(await previous),
    );
    final request = http.Request(requestMethod, requestUri);
    final Object? requestBody = await addons.fold<Future<Object?>>(
      Future.value(body),
      (Future<Object?> previous, HttpAddon addon) async =>
          await addon.body(await previous),
    );
    if (requestBody != null) {
      if (requestBody is String) {
        request.body = requestBody;
      } else {
        throw Exception('Unsupported body type');
      }
    }
    final Map<String, String> requestHeaders = await addons
        .fold<Future<Map<String, String>>>(
          Future.value(headers),
          (Future<Map<String, String>> previous, HttpAddon addon) async =>
              await addon.headers(await previous),
        );
    request.headers.addAll(requestHeaders);
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
        (List<int> chunk) => _streamChunk(chunk: chunk, onProgress: onProgress),
        onDone: () => _streamOnDone(onProgress: onProgress),
        onError: (Object error) {
          log.e('Download error', error: error);
        },
        cancelOnError: true,
      );
    }
  }

  void _sendResponse({
    int? code,
    Map<String, String>? headers,
    int? contentLength,
  }) {
    addons
        .fold<Future<int?>>(
          Future.value(code),
          (Future<int?> previous, HttpAddon addon) async =>
              await addon.responseCode(await previous),
        )
        .then((value) => responseCode = value);
    addons
        .fold<Future<Map<String, String>?>>(
          Future.value(headers),
          (Future<Map<String, String>?> previous, HttpAddon addon) async =>
              await addon.responseHeaders(await previous),
        )
        .then((value) => responseHeaders = value);
    total += contentLength ?? 0;
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
    final List<int> chunks = await addons.fold<Future<List<int>>>(
      Future.value(_chunks),
      (Future<List<int>> previous, HttpAddon addon) async =>
          await addon.responseChunks(await previous),
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

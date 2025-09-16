import 'dart:async';
import 'dart:convert';

import 'package:asallenshih_flutter_util/log.dart';
import 'package:http/http.dart' deferred as http show Client, Request;

abstract class HttpBase {
  HttpBase(
    this.uri, {
    this.method = 'GET',
    this.headers = const {},
    this.body,
  }) : assert(
         method == 'GET' ||
             method == 'POST' ||
             method == 'PUT' ||
             method == 'DELETE' ||
             method == 'PATCH',
       );
  final Uri uri;
  final String method;
  final Object? body;
  final Map<String, String> headers;
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
    final request = http.Request(method, uri);
    request.headers.addAll(headers);
    if (body != null) {
      if (body is String) {
        request.body = body as String;
      } else if (body is Map<dynamic, dynamic>) {
        if (body is! Map<String, String> &&
            request.headers['Content-Type'] == null) {
          request.headers['Content-Type'] = 'application/json';
        }
        if (request.headers['Content-Type'] != null &&
            request.headers['Content-Type']!.contains('json')) {
          request.body = jsonEncode(body);
        } else {
          request.bodyFields = body as Map<String, String>;
        }
      } else if (body is List<int>) {
        request.bodyBytes = body as List<int>;
      } else {
        throw Exception('Unsupported body type');
      }
    }
    try {
      _onProgress(onProgress);
      final client = http.Client();
      final response = await client.send(request);
      responseCode = response.statusCode;
      responseHeaders = response.headers;
      total = response.contentLength ?? 0;
      if (responseCode == 304) {
        downloaded = total;
        _streamOnDone(onProgress: onProgress);
      } else {
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
      if (!_completer.isCompleted) {
        _completer.complete();
      }
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
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void _onProgress(void Function(int, int)? onProgress) {
    if (onProgress != null) {
      onProgress(downloaded, total < downloaded ? downloaded : total);
    }
  }

  Future<List<int>?> get getBytes async {
    await _completer.future;
    if (_chunks.isEmpty) {
      return null;
    }
    return _chunks;
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

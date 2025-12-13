import 'dart:convert';

import 'package:asallenshih_flutter_util/http/addon.dart';

class HttpAddonBodyJson extends HttpAddon {
  final dynamic json;
  final String Function(dynamic data)? toJson;
  HttpAddonBodyJson({this.json, this.toJson});
  @override
  Future<Object?> body(Object? bodyData) async {
    final dynamic data = bodyData ?? json;
    if (data == null) {
      return null;
    } else if (toJson != null) {
      return toJson!(data);
    }
    return jsonEncode(data);
  }

  @override
  Future<Map<String, String>> headers(Map<String, String> headersData) async {
    final Map<String, String> headers = Map<String, String>.from(headersData);
    headers['Content-Type'] = 'application/json';
    return super.headers(headers);
  }
}

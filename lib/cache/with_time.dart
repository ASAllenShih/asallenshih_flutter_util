import 'dart:convert';
import 'dart:typed_data';

import 'package:asallenshih_flutter_util/cache.dart';
import 'package:asallenshih_flutter_util/log.dart';

class CacheWithTime extends Cache {
  final int expireSeconds;
  CacheWithTime({required super.key, required this.expireSeconds});
  @override
  Future<Uint8List?> get read async {
    Uint8List? bytes = await super.read;
    if (bytes == null) return null;
    final String str = Utf8Decoder().convert(bytes);
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(str);
      final int expire = jsonMap['expire'];
      final bool deleted = await expireDelete(expire);
      if (deleted) {
        return null;
      }
      final String base64 = jsonMap['data'];
      return Base64Decoder().convert(base64);
    } catch (e) {
      log.e('CacheWithTime reading error $str', error: e);
      await delete();
      return null;
    }
  }

  Future<bool> expireDelete(int expire) async {
    final int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (nowSeconds < expire) {
      return false;
    }
    await delete();
    return true;
  }

  @override
  Uint8List? genInputBytes(Uint8List? bytes) {
    final Uint8List? data = super.genInputBytes(bytes);
    if (data == null) return null;
    final String base64 = Base64Encoder().convert(data);
    final DateTime nowDateTime = DateTime.now();
    final int nowSeconds = nowDateTime.millisecondsSinceEpoch ~/ 1000;
    final int expire = nowSeconds + expireSeconds;
    final Map<String, dynamic> jsonMap = {'expire': expire, 'data': base64};
    final String jsonStr = jsonEncode(jsonMap);
    return Utf8Encoder().convert(jsonStr);
  }
}

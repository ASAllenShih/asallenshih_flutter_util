import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asallenshih_flutter_util/device.dart';
import 'package:asallenshih_flutter_util/log.dart';
import 'package:path_provider/path_provider.dart' deferred as path_provider;

class Cache {
  final String key;
  Cache({required this.key});
  static Directory? _cacheDir;
  static Future<Directory?> get cacheDir async {
    if (!Device.isAndroid &&
        !Device.isIOS &&
        !Device.isMacOS &&
        !Device.isWindows &&
        !Device.isLinux) {
      return null;
    }
    await path_provider.loadLibrary();
    _cacheDir ??= await path_provider.getApplicationCacheDirectory();
    return _cacheDir;
  }

  File? _cacheFile;
  Future<File?> cacheFile({bool create = false}) async {
    _cacheFile ??= await _cacheFileInit(create: create);
    return _cacheFile;
  }

  Future<File?> _cacheFileInit({bool create = false}) async {
    Directory? dir = await cacheDir;
    if (dir == null) return null;
    File file = File('${dir.path}/$key');
    if (!(await file.exists())) {
      if (create) {
        await file.create(recursive: true);
      } else {
        return null;
      }
    }
    return file;
  }

  Uint8List? _cacheBytes;
  Future<Uint8List?> get read async {
    _cacheBytes ??= await cacheRead;
    return _cacheBytes;
  }

  Future<Uint8List?> get cacheRead async {
    File? file = await cacheFile();
    if (file == null) {
      return null;
    }
    return await file.readAsBytes();
  }

  Uint8List? genInputBytes(Uint8List? bytes) {
    return bytes;
  }

  Future<String?> get readString async {
    Uint8List? bytes = await read;
    if (bytes == null) return null;
    return Utf8Decoder().convert(bytes);
  }

  Future<dynamic> get readJson async {
    String? str = await readString;
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (e) {
      log.e('Cache reading JSON error $str', error: e);
      return null;
    }
  }

  Future<bool?> write(Uint8List bytes) async {
    bytes = genInputBytes(bytes)!;
    _cacheBytes = bytes;
    File? file = await cacheFile(create: true);
    if (file == null) return null;
    try {
      await file.writeAsBytes(bytes);
    } catch (e) {
      log.e('Cache write error', error: e);
      return false;
    }
    return true;
  }

  Future<bool?> writeString(String str) async {
    final Uint8List bytes = Utf8Encoder().convert(str);
    return await write(bytes);
  }

  Future<bool?> writeJson(Object? json) async {
    try {
      String str = jsonEncode(json);
      return await writeString(str);
    } catch (e) {
      log.e('Cache write JSON error', error: e);
      return false;
    }
  }

  Future<bool?> delete() async {
    _cacheBytes = null;
    File? file = await cacheFile();
    if (file == null) return null;
    try {
      await file.delete();
      _cacheFile = null;
    } catch (e) {
      log.e('Cache delete error', error: e);
      return false;
    }
    return true;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asallenshih_flutter_util/cache/addon.dart';
import 'package:asallenshih_flutter_util/device.dart' deferred as device;
import 'package:asallenshih_flutter_util/log.dart';
import 'package:path_provider/path_provider.dart' deferred as path_provider;

class Cache {
  final String key;
  final List<CacheAddon> addons;
  Directory? dir;
  Cache({required this.key, this.dir, this.addons = const []});
  static Directory? _defaultDir;
  static Future<Directory?> get defaultDirInit async {
    await device.loadLibrary();
    if (!device.Device.isAndroid &&
        !device.Device.isIOS &&
        !device.Device.isMacOS &&
        !device.Device.isWindows &&
        !device.Device.isLinux) {
      return null;
    }
    await path_provider.loadLibrary();
    return await path_provider.getApplicationCacheDirectory();
  }

  static Future<Directory?> get defaultDir async {
    _defaultDir ??= await defaultDirInit;
    return _defaultDir;
  }

  Future<Directory?> cacheDir() async {
    dir ??= await defaultDir;
    return dir;
  }

  File? _cacheFile;
  Future<File?> cacheFile({bool create = false}) async {
    _cacheFile ??= await _cacheFileInit(create: create);
    return _cacheFile;
  }

  Future<File?> _cacheFileInit({bool create = false}) async {
    final Directory? dataDir = await cacheDir();
    if (dataDir == null) {
      return null;
    }
    final File file = File('${dataDir.path}/$key');
    if (!await file.exists()) {
      if (!create) {
        return null;
      }
      await file.create(recursive: true);
    }
    return file;
  }

  Uint8List? _cacheBytes;
  Future<Uint8List?> get _readInit async {
    final File? file = await cacheFile();
    if (file == null || !await file.exists()) {
      return null;
    }
    return await file.readAsBytes();
  }

  Future<Uint8List?> get read async {
    _cacheBytes ??= await _readInit;
    final Uint8List? bytes = await addons.fold<Future<Uint8List?>>(
      Future.value(_cacheBytes),
      (Future<Uint8List?> future, CacheAddon item) async {
        return await item.read(await future);
      },
    );
    if (addons.any((item) => item.cacheDelete)) {
      await delete();
      return null;
    }
    return bytes;
  }

  Future<String?> get readString async {
    final Uint8List? bytes = await read;
    if (bytes == null) return null;
    return Utf8Decoder().convert(bytes);
  }

  Future<dynamic> get readJson async {
    final String? str = await readString;
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (e) {
      log.e('Cache reading JSON error $str', error: e);
      return null;
    }
  }

  Future<bool?> write(Uint8List? bytes) async {
    final Uint8List? dataBytes = await addons.reversed.fold<Future<Uint8List?>>(
      Future.value(bytes),
      (Future<Uint8List?> future, CacheAddon item) async {
        return await item.write(await future);
      },
    );
    if (dataBytes == null) {
      return await delete();
    }
    _cacheBytes = dataBytes;
    final File? file = await cacheFile(create: true);
    if (file == null) return null;
    try {
      await file.writeAsBytes(dataBytes);
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
    final File? file = await cacheFile();
    if (file == null) return null;
    try {
      await file.delete();
      _cacheFile = null;
      _cacheBytes = null;
    } catch (e) {
      log.e('Cache delete error', error: e);
      return false;
    }
    return true;
  }
}

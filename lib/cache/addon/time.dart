import 'dart:typed_data';

import 'package:asallenshih_flutter_util/cache/addon.dart';

class CacheAddonTime extends CacheAddon {
  static const String prefix = 'Time=';
  static const String suffix = ';\n';
  final Duration duration;
  bool ignoreExpire;
  DateTime? expireTime;
  CacheAddonTime({this.duration = Duration.zero, this.ignoreExpire = false});
  @override
  Future<Uint8List?> read(Uint8List? bytes) {
    if (bytes == null) {
      return super.read(bytes);
    }
    final Uint8List prefixBytes = stringToBytes(prefix);
    final Uint8List suffixBytes = stringToBytes(suffix);
    final int prefixLength = prefixBytes.length;
    final int suffixLength = suffixBytes.length;
    if (!bytesStartsWith(bytes, prefixBytes)) {
      return super.read(null);
    }
    final int suffixIndex = bytesIndexOf(
      bytes,
      suffixBytes,
      start: prefixLength,
    );
    if (suffixIndex < 0) {
      return super.read(null);
    }
    final timeBytes = bytes.sublist(prefixLength, suffixIndex);
    final String timeStr = bytesToString(timeBytes);
    expireTime = DateTime.tryParse(timeStr);
    if ((expireTime == null || DateTime.now().isAfter(expireTime!))) {
      cacheExpire = true;
      if (!ignoreExpire) {
        return super.read(null);
      }
    }
    final int dataStartIndex = suffixIndex + suffixLength;
    return super.read(bytes.sublist(dataStartIndex));
  }

  @override
  Future<Uint8List?> write(Uint8List? bytes) {
    if (bytes == null) {
      return super.write(bytes);
    }
    final Uint8List prefixBytes = stringToBytes(prefix);
    final Uint8List suffixBytes = stringToBytes(suffix);
    final DateTime timeAdd = DateTime.now().add(duration);
    final DateTime time = expireTime != null && timeAdd.isBefore(expireTime!)
        ? expireTime!
        : timeAdd;
    final Uint8List timeBytes = stringToBytes(time.toIso8601String());
    return super.write(
      combineBytes([prefixBytes, timeBytes, suffixBytes, bytes]),
    );
  }
}

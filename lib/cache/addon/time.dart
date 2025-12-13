import 'dart:typed_data';

import 'package:asallenshih_flutter_util/cache/addon.dart';

class CacheAddonTime extends CacheAddon {
  static const String prefix = 'Time=';
  static const String suffix = ';\n';
  final Duration duration;
  bool ignoreExpire;
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
    final DateTime? time = DateTime.tryParse(timeStr);
    if ((time == null || DateTime.now().isAfter(time)) && !ignoreExpire) {
      return super.read(null);
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
    final DateTime time = DateTime.now().add(duration);
    final Uint8List timeBytes = stringToBytes(time.toIso8601String());
    return super.write(
      combineBytes([prefixBytes, timeBytes, suffixBytes, bytes]),
    );
  }
}

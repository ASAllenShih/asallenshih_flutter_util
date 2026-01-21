import 'dart:convert';
import 'dart:typed_data';

class CacheAddon {
  bool cacheDelete = false;
  bool cacheExpire = false;
  Future<Uint8List?> read(Uint8List? bytes) async {
    return bytes;
  }

  Future<Uint8List?> write(Uint8List? bytes) async {
    return bytes;
  }
}

Uint8List stringToBytes(String str) {
  return Utf8Encoder().convert(str);
}

String bytesToString(Uint8List bytes) {
  return Utf8Decoder().convert(bytes);
}

bool bytesStartsWith(Uint8List data, Uint8List pattern) {
  if (data.length < pattern.length) {
    return false;
  }
  for (int i = 0; i < pattern.length; i++) {
    if (data[i] != pattern[i]) {
      return false;
    }
  }
  return true;
}

int bytesIndexOf(Uint8List data, Uint8List pattern, {int start = 0}) {
  for (int i = start; i <= data.length - pattern.length; i++) {
    bool match = true;
    for (int j = 0; j < pattern.length; j++) {
      if (data[i + j] != pattern[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

Uint8List combineBytes(List<Uint8List> bytesList) {
  final int totalLength = bytesList.fold(0, (sum, bytes) => sum + bytes.length);
  final Uint8List combinedBytes = Uint8List(totalLength);
  int offset = 0;
  for (final bytes in bytesList) {
    combinedBytes.setRange(offset, offset + bytes.length, bytes);
    offset += bytes.length;
  }
  return combinedBytes;
}

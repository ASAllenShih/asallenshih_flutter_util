import 'package:asallenshih_flutter_util/asallenshih_flutter_util.dart';
import 'package:asallenshih_flutter_util/langs.dart';
import 'package:flutter/widgets.dart';

class Lang {
  static BuildContext? get context =>
      AsallenshihFlutterUtil.navigatorKey.currentContext;
  static Locale? get locale =>
      context == null ? null : Localizations.localeOf(context!);
  static String t(Map<Langs, String?> map) {
    return o<String>(map) ?? '';
  }

  static T? o<T>(Map<Langs, T?> map) {
    final List<MapEntry<Langs, T>> textsList = map.entries
        .where((e) => e.value != null)
        .map((e) => MapEntry<Langs, T>(e.key, e.value as T))
        .toList();
    if (textsList.isEmpty) return null;
    textsList.sort((a, b) => b.key.priority.compareTo(a.key.priority));
    if (locale != null) {
      final String lc = locale?.languageCode ?? 'en';
      final lcMatch = textsList.where((e) => e.key.lc == lc);
      if (lcMatch.isNotEmpty) {
        final String? sc = locale?.scriptCode;
        if (sc != null) {
          final scMatch = lcMatch.where((e) => e.key.sc == sc);
          if (scMatch.isNotEmpty) {
            final String? cc = locale?.countryCode;
            if (cc != null) {
              final ccMatch = scMatch.where((e) => e.key.cc == cc);
              if (ccMatch.isNotEmpty) {
                return ccMatch.first.value;
              }
            }
            return scMatch.first.value;
          }
        }
        final String? cc = locale?.countryCode;
        if (cc != null) {
          final ccMatch = lcMatch.where((e) => e.key.cc == cc);
          if (ccMatch.isNotEmpty) {
            return ccMatch.first.value;
          }
        }
        return lcMatch.first.value;
      }
    }
    return textsList.first.value;
  }
}

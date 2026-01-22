import 'dart:ui';

enum Langs {
  en(locale: Locale('en'), priority: 3),
  zhHantTW(
    locale: Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    ),
    priority: 2,
  ),
  zhHant(
    locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    priority: 1,
  ),
  zh(locale: Locale.fromSubtags(languageCode: 'zh'));

  final Locale locale;
  final int priority;
  const Langs({required this.locale, this.priority = 0});
}

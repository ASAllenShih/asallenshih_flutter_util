enum Langs {
  en(lc: 'en', priority: 3),
  zhHantTW(lc: 'zh', sc: 'Hant', cc: 'TW', priority: 2),
  zhHant(lc: 'zh', sc: 'Hant', priority: 1),
  zh(lc: 'zh');

  final String lc;
  final String? sc;
  final String? cc;
  final int priority;
  const Langs({required this.lc, this.sc, this.cc, this.priority = 0});
}

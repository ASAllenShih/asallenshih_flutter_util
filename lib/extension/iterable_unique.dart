extension IterableUnique<T> on Iterable<T> {
  Iterable<T> unique() {
    final Set<T> seen = <T>{};
    final List<T> uniqueList = <T>[];
    for (final T element in this) {
      if (seen.add(element)) {
        uniqueList.add(element);
      }
    }
    return uniqueList;
  }
}

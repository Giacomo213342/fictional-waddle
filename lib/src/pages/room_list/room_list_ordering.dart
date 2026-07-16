List<T> normalBeforeLowPriority<T>(
  Iterable<T> items, {
  required bool Function(T item) isLowPriority,
}) {
  final normal = <T>[];
  final lowPriority = <T>[];

  for (final item in items) {
    (isLowPriority(item) ? lowPriority : normal).add(item);
  }

  return [...normal, ...lowPriority];
}

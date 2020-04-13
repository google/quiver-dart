part of quiver.iterables;

/// Returns the average of values in [i] or `null` if [i] is empty.
double avg<T extends num>(Iterable<T> i, [Comparator<T> compare]) {
  if (i.isEmpty) return null;
  return i.reduce((a, b) => a + b) / i.length;
}

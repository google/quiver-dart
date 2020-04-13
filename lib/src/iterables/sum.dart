part of quiver.iterables;

/// Returns the sum of values in [i] or `null` if [i] is empty.
T sum<T extends num>(Iterable<T> i) {
  if (i.isEmpty) return null;
  return i.reduce((a, b) => a + b);
}

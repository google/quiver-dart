part of quiver.iterables;

Iterable sort(Iterable iterable, [Comparator compare = Comparable.compare]) {
  List li = new List.from(iterable, growable: false);
  li.sort(compare);
  return li;
}
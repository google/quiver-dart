part of quiver.iterables;

/**
 * Returns an [Iterable] of [Group]s, where each element
 * contains all elements of the [Iterable] which agree on the
 * values returned by the provided key function.
 */
Iterable<Group> groupBy(Iterable iterable, { key(var k) }) {
  if (key == null) {
    key = (x) => x;
  }
  return new _GroupByIterable(iterable, key);
}

class Group<K,E>
extends Object with IterableMixin<E>
implements Iterable<E> {
  final K key;
  final Iterable<E> values;

  Group(this.key, this.values);
  Iterator<E> get iterator => values.iterator;
  String toString() => "($key: $values)";
}

class _GroupByIterable<K,E>
extends Object with IterableMixin<Group<K,E>> {
  final List<_Tuple<K,E>> _keyedIterable;

  _GroupByIterable(Iterable<E> iterable, K key(E value)) :
    _keyedIterable = new List.from(new _TupleZip(iterable.map(key), iterable), growable: false);

  Iterator<Group<K,E>> get iterator =>
      new _GroupByIterator(_keyedIterable);
}

class _GroupByIterator<K,E> implements Iterator<Group<K,E>> {
  final List<_Tuple<K,E>> _keyedIterable;

  int _keyIdx = -1;
  Set<K> _seenKeys;
  Group<K,E> _current;

  _GroupByIterator(List<_Tuple<K,E>> this._keyedIterable) :
    _seenKeys = new Set<K>();

  Group<K,E> get current => _current;

  bool moveNext() {
    var key;
    while (++_keyIdx < _keyedIterable.length) {
      var pair = _keyedIterable[_keyIdx];
      if (!_seenKeys.contains(pair.$1)) {
        key = pair.$1;
        break;
      }
    }
    if (key == null) {
      _current = null;
      return false;
    }
    _seenKeys.add(key);
    //If doing this without tuples, would need to index
    //both the keys and the elements.
    var values = _keyedIterable
        .where((p) => p.$1 == key)
        .map((p) => p.$2);

    _current = new Group(key, values);
    return true;
  }
}

//A fixed length ordered list type to aid efficiency during group by and join.
class _Tuple<T1,T2> {

  final T1 $1;
  final T2 $2;

  _Tuple(this.$1, this.$2);

  bool operator ==(Object o) =>
      o is _Tuple && $1 == o.$1 && $2 == o.$2;
}

class _TupleZip<T1,T2>
extends Object with IterableMixin<_Tuple<T1,T2>> {

  final Iterable<T1> iter1;
  final Iterable<T2> iter2;

  _TupleZip(Iterable<T1> this.iter1, Iterable<T2> this.iter2);

  Iterator get iterator => new _TupleIterator(iter1.iterator, iter2.iterator);
}

class _TupleIterator<T1,T2> implements Iterator<_Tuple<T1,T2>> {
  final Iterator<T1> _iter1;
  final Iterator<T2> _iter2;
  bool _hasNext = true;
  _Tuple<T1,T2> _current;
  _TupleIterator(this._iter1, this._iter2);

  _Tuple<T1,T2> get current => _current;
  bool moveNext() {
    _hasNext = _hasNext && _iter1.moveNext();
    _hasNext = _hasNext && _iter2.moveNext();
    _current = _hasNext ? new _Tuple(_iter1.current, _iter2.current) : null;
    return _hasNext;
  }
}
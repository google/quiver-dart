part of quiver.iterables;

/**
 * Returns an [Iterable] of [Group]s, where each element
 * contains all elements of the [Iterable] which agree on the
 * values returned by the provided key function.
 *
 * The behaviour is undefined if the key function returns different
 * values when passed the same element twice.
 */
Iterable<Group> groupBy(Iterable iterable, {key(var k)}) {
  if (key == null)
    key = (x) => x;
  return new _GroupBy(iterable, key);
}

/**
 * A group is an [Iterable] where all elements match on a given key.s
 */
class Group<K,E> extends IterableBase<E> {
  final K key;
  final Iterable<E> values;

  Group(this.key, this.values);
  Iterator<E> get iterator => values.iterator;
  String toString() => "($key: $values)";
}

typedef K _KeyFunc<K,E>(E element);

class _GroupBy<K,E> extends IterableBase<Group<K,E>> {
  final Iterable _iterable;
  final _KeyFunc<K,E> _keyFunc;

  _GroupBy(Iterable<E> this._iterable, K this._keyFunc(E value));

  Iterator<Group<K,E>> get iterator =>
      new _GroupByIterator(_iterable, _keyFunc);
}

class _Sentinel { const _Sentinel(); }

class _GroupByIterator<K,E> implements Iterator<Group<K,E>> {
  /**
   * Use a sentinel value instead of checking for a null key to end
   * the iteration. This allows key functions to return `null`.
   */
  static const _sentinel = const _Sentinel();

  Iterator<K> _keyIterator;
  Iterable<E> _valueIterable;
  _KeyFunc<K,E> _keyFunc;

  Set<K> _seenKeys;
  Group<K,E> _current;

  _GroupByIterator(Iterable<E> iterable, K keyFunc(E item)) :
    _keyIterator = iterable.map(keyFunc).iterator,
    _keyFunc = keyFunc,
    _valueIterable = iterable,
    _seenKeys = new Set<K>();

  Group<K,E> get current => _current;

  bool moveNext() {
    var key = _sentinel;
    var i = 0;
    while(_keyIterator.moveNext()) {
      if (!_seenKeys.contains(_keyIterator.current)) {
        key = _keyIterator.current;
        break;
      }
    }
    if (key == _sentinel) {
      _current = null;
      return false;
    }

    _seenKeys.add(key);
    _current = new Group<K,E>(key, _valueIterable.where((v) => _keyFunc(v) == key));
    return true;
  }
}
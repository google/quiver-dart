// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of quiver.collection;

/**
 * An associative container that maps a key to multiple values.
 *
 * Key lookups return mutable collections that are views of the multimap.
 * Updates to the multimap are reflected in these collections and similarly,
 * modifications to the returned collections are reflected in the multimap.
 */
abstract class Multimap<K, V> {
  /**
   * Constructs a new list-backed multimap.
   */
  factory Multimap() => new ListMultimap<K, V>();

  /**
   * Returns whether this multimap contains the given [value].
   */
  bool containsValue(Object value);

  /**
   * Returns whether this multimap contains the given [key].
   */
  bool containsKey(Object key);

  /**
   * Returns the values for the given [key]. An empty iterable is returned if
   * [key] is not mapped. The returned collection is a view on the multimap.
   * Updates to the collection modify the multimap and likewise, modifications
   * to the multimap are reflected in the returned collection.
   */
  Iterable<V> operator [](Object key);

  /**
   * Adds an association from the given key to the given value.
   */
  void add(K key, V value);

  /**
   * Adds an association from the given key to each of the given values.
   */
   void addValues(K key, Iterable<V> values);

  /**
   * Adds all associations of [other] to this multimap.
   *
   * The operation is equivalent to doing `this[key] = value` for each key
   * and associated value in other. It iterates over [other], which must
   * therefore not change during the iteration.
   */
  void addAll(Multimap<K, V> other);

  /**
   * Removes the association between the given [key] and [value]. Returns
   * `true` if the association existed, `false` otherwise.
   */
  bool remove(Object key, V value);

  /**
   * Removes the association for the given [key]. Returns the collection of
   * removed values, or an empty iterable if [key] was unmapped.
   */
  Iterable<V> removeAll(Object key);

  /**
   * Removes all data from the multimap.
   */
  void clear();

  /**
   * Applies [f] to each {key, Iterable<value>} pair of the multimap.
   *
   * It is an error to add or remove keys from the map during iteration.
   */
  void forEachKey(void f(K key, Iterable<V> value));

  /**
   * Applies [f] to each {key, value} pair of the multimap.
   *
   * It is an error to add or remove keys from the map during iteration.
   */
  void forEach(void f(K key, V value));

  /**
   * The keys of [this].
   */
  Iterable<K> get keys;

  /**
   * The values of [this].
   */
  Iterable<V> get values;

  /**
   * Returns a copy of this multimap as a map.
   */
  Map<K, Iterable<V>> toMap();

  /**
   * The number of keys in the multimap.
   */
  int get length;

  /**
   * Returns true if there is no key in the multimap.
   */
  bool get isEmpty;

  /**
   * Returns true if there is at least one key in the multimap.
   */
  bool get isNotEmpty;
}

/**
 * Abstract base class for multimap implementations.
 */
abstract class _BaseMultimap<K, V> implements Multimap<K, V> {
  final Map<K, Iterable<V>> _map = new HashMap();

  Iterable<V> _create();
  void _add(Iterable<V> iterable, V value);
  void _addAll(Iterable<V> iterable, Iterable<V> values);
  void _clear(Iterable<V> iterable);
  bool _remove(Iterable<V> iterable, V value);
  Iterable<V> _wrap(Object key, Iterable<V> iterable);

  bool containsValue(Object value) => values.contains(value);
  bool containsKey(Object key) => _map.keys.contains(key);

  Iterable<V> operator [](Object key) {
    var values = _map[key];
    if (values == null) {
      values = _create();
    }
    return _wrap(key, values);
  }

  void add(K key, V value) {
    _map.putIfAbsent(key, _create);
    _add(_map[key], value);
  }

  void addValues(K key, Iterable<V> values) {
    _map.putIfAbsent(key, _create);
    _addAll(_map[key], values);
  }

  /**
   * Adds all associations of [other] to this multimap.
   *
   * The operation is equivalent to doing `this[key] = value` for each key
   * and associated value in other. It iterates over [other], which must
   * therefore not change during the iteration.
   *
   * This implementation iterates through each key of [other] and adds the
   * associated values to this instance via [addValues].
   */
  void addAll(Multimap<K, V> other) => other.forEachKey(addValues);

  bool remove(Object key, V value) {
    if (!_map.containsKey(key)) return false;
    bool removed = _remove(_map[key], value);
    if (removed && _map[key].isEmpty) _map.remove(key);
    return removed;
  }

  Iterable<V> removeAll(Object key) {
    // Cast to dynamic to remove warnings
    var values = _map.remove(key) as dynamic;
    var retValues = _create() as dynamic;
    if (values != null) {
      retValues.addAll(values);
      values.clear();
    }
    return retValues;
  }

  void clear() {
    _map.forEach((K key, Iterable<V> value) => _clear(value));
    _map.clear();
  }

  void forEachKey(void f(K key, Iterable<V> value)) => _map.forEach(f);

  void forEach(void f(K key, V value)) {
    _map.forEach((K key, Iterable<V> values) {
      values.forEach((V value) => f(key, value));
    });
  }

  Iterable<K> get keys => _map.keys;
  Iterable<V> get values => _map.values.expand((x) => x);
  Iterable<Iterable<V>> get _groupedValues => _map.values;
  int get length => _map.length;
  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;
}

/**
 * A multimap implementation that uses [List]s to store the values associated
 * with each key.
 */
class ListMultimap<K, V> extends _BaseMultimap<K, V> {
  ListMultimap() : super();
  List<V> _create() => new List<V>();
  void _add(List<V> iterable, V value) => iterable.add(value);
  void _addAll(List<V> iterable, Iterable<V> value) => iterable.addAll(value);
  void _clear(List<V> iterable) => iterable.clear();
  bool _remove(List<V> iterable, V value) => iterable.remove(value);
  List<V> _wrap(Object key, List<V> iterable) =>
      new _WrappedList(_map, key, iterable);
  List<V> operator [](Object key) => super[key];
  List<V> removeAll(Object key) => super.removeAll(key);
  Map<K, List<V>> toMap() => new _WrappedMap<K, V, List<V>>(this);
}

/**
 * A multimap implementation that uses [Set]s to store the values associated
 * with each key.
 */
class SetMultimap<K, V> extends _BaseMultimap<K, V> {
  SetMultimap() : super();
  Set<V> _create() => new Set<V>();
  void _add(Set<V> iterable, V value) { iterable.add(value); }
  void _addAll(Set<V> iterable, Iterable<V> value) => iterable.addAll(value);
  void _clear(Set<V> iterable) => iterable.clear();
  bool _remove(Set<V> iterable, V value) => iterable.remove(value);
  Set<V> _wrap(Object key, Set<V> iterable) =>
      new _WrappedSet(_map, key, iterable);
  Set<V> operator [](Object key) => super[key];
  Set<V> removeAll(Object key) => super.removeAll(key);
  Map<K, Set<V>> toMap() => new _WrappedMap<K, V, Set<V>>(this);
}

/**
 * A [Map] that delegates its operations to an underlying multimap.
 */
class _WrappedMap<K, V, C extends Iterable<V>> implements Map<K, C> {
  final _BaseMultimap<K, V> _multimap;

  _WrappedMap(this._multimap);

  C operator [](Object key) => _multimap[key];

  void operator []=(K key, C value) {
    throw new UnsupportedError("Insert unsupported on map view");
  }

  void addAll(Map<K, C> other) {
    throw new UnsupportedError("Insert unsupported on map view");
  }

  C putIfAbsent(K key, C ifAbsent()) {
    throw new UnsupportedError("Insert unsupported on map view");
  }

  void clear() => _multimap.clear();
  bool containsKey(Object key) => _multimap.containsKey(key);
  bool containsValue(Object value) => _multimap.containsValue(value);
  void forEach(void f(K key, Iterable<V> value)) => _multimap.forEachKey(f);
  bool get isEmpty => _multimap.isEmpty;
  bool get isNotEmpty => _multimap.isNotEmpty;
  Iterable<K> get keys => _multimap.keys;
  int get length => _multimap.length;
  C remove(Object key) => _multimap.removeAll(key);
  Iterable<C> get values => _multimap._groupedValues;
}

/**
 * Iterable wrapper that syncs to an underlying map.
 */
class _WrappedIterable<K, V> implements Iterable<V> {
  final K _key;
  final Map<K, Iterable<V>> _map;
  Iterable<V> _delegate;

  _WrappedIterable(this._map, this._key, this._delegate);

  _addToMap() => _map[_key] = _delegate;

  /**
   * Ensures we hold an up-to-date delegate. In the case where all mappings for
   * _key are removed from the multimap, the Iterable referenced by _delegate is
   * removed from the underlying map. At that point, any new addition via the
   * multimap triggers the creation of a new Iterable, and the empty delegate
   * we hold would be stale. As such, we check the underlying map and update
   * our delegate when the one we hold is empty.
   */
  _syncDelegate() {
    if (_delegate.isEmpty) {
      var updated = _map[_key];
      if (updated != null) {
        _delegate = updated;
      }
    }
  }

  bool any(bool test(V element)) {
    _syncDelegate();
    return _delegate.any(test);
  }

  bool contains(Object element) {
    _syncDelegate();
    return _delegate.contains(element);
  }

  V elementAt(int index) {
    _syncDelegate();
    return _delegate.elementAt(index);
  }

  bool every(bool test(V element)) {
    _syncDelegate();
    return _delegate.every(test);
  }

  Iterable expand(Iterable f(V element)) {
    _syncDelegate();
    return _delegate.expand(f);
  }

  V get first {
    _syncDelegate();
    return _delegate.first;
  }

  V firstWhere(bool test(V element), {V orElse()}) {
    _syncDelegate();
    return _delegate.firstWhere(test, orElse: orElse);
  }

  fold(initialValue, combine(previousValue, V element)) {
    _syncDelegate();
    return _delegate.fold(initialValue, combine);
  }

  void forEach(void f(V element)) {
    _syncDelegate();
    _delegate.forEach(f);
  }

  bool get isEmpty {
    _syncDelegate();
    return _delegate.isEmpty;
  }

  bool get isNotEmpty {
    _syncDelegate();
    return _delegate.isNotEmpty;
  }

  Iterator<V> get iterator {
    _syncDelegate();
    return _delegate.iterator;
  }

  String join([String separator = ""]) {
    _syncDelegate();
    return _delegate.join(separator);
  }

  V get last {
    _syncDelegate();
    return _delegate.last;
  }

  V lastWhere(bool test(V element), {V orElse()}) {
    _syncDelegate();
    return _delegate.lastWhere(test, orElse: orElse);
  }

  int get length {
    _syncDelegate();
    return _delegate.length;
  }

  Iterable map(f(V element)) {
    _syncDelegate();
    return _delegate.map(f);
  }

  V reduce(V combine(V value, V element)) {
    _syncDelegate();
    return _delegate.reduce(combine);
  }

  V get single {
    _syncDelegate();
    return _delegate.single;
  }

  V singleWhere(bool test(V element)) {
    _syncDelegate();
    return _delegate.singleWhere(test);
  }

  Iterable<V> skip(int n) {
    _syncDelegate();
    return _delegate.skip(n);
  }

  Iterable<V> skipWhile(bool test(V value)) {
    _syncDelegate();
    return _delegate.skipWhile(test);
  }

  Iterable<V> take(int n) {
    _syncDelegate();
    return _delegate.take(n);
  }

  Iterable<V> takeWhile(bool test(V value)) {
    _syncDelegate();
    return _delegate.takeWhile(test);
  }

  List<V> toList({bool growable: true}) {
    _syncDelegate();
    return _delegate.toList(growable: growable);
  }

  Set<V> toSet() {
    _syncDelegate();
    return _delegate.toSet();
  }

  String toString() {
    _syncDelegate();
    return _delegate.toString();
  }

  Iterable<V> where(bool test(V element)) {
    _syncDelegate();
    return _delegate.where(test);
  }
}

class _WrappedList<K, V> extends _WrappedIterable<K, V> implements List<V> {
  _WrappedList(Map<K, Iterable<V>> map, K key, List<V> delegate) :
      super(map, key, delegate);

  V operator [](int index) => elementAt(index);

  void operator []=(int index, V value) {
    _syncDelegate();
    (_delegate as List)[index] = value;
  }

  void add(V value) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as List).add(value);
    if (wasEmpty) _addToMap();
  }

  void addAll(Iterable<V> iterable) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as List).addAll(iterable);
    if (wasEmpty) _addToMap();
  }

  Map<int, V> asMap() {
    _syncDelegate();
    return (_delegate as List).asMap();
  }

  void clear() {
    _syncDelegate();
    (_delegate as List).clear();
    _map.remove(_key);
  }

  void fillRange(int start, int end, [V fillValue]) {
    _syncDelegate();
    (_delegate as List).fillRange(start, end, fillValue);
  }

  Iterable<V> getRange(int start, int end) {
    _syncDelegate();
    return (_delegate as List).getRange(start, end);
  }

  int indexOf(V element, [int start = 0]) {
    _syncDelegate();
    return (_delegate as List).indexOf(element, start);
  }

  void insert(int index, V element) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as List).insert(index, element);
    if (wasEmpty) _addToMap();
  }

  void insertAll(int index, Iterable<V> iterable) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as List).insertAll(index, iterable);
    if (wasEmpty) _addToMap();
  }

  int lastIndexOf(V element, [int start]) {
    _syncDelegate();
    return (_delegate as List).lastIndexOf(element, start);
  }

  void set length(int newLength) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as List).length = newLength;
    if (wasEmpty) _addToMap();
  }

  bool remove(Object value) {
    _syncDelegate();
    bool removed = (_delegate as List).remove(value);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  V removeAt(int index) {
    _syncDelegate();
    V removed = (_delegate as List).removeAt(index);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  V removeLast() {
    _syncDelegate();
    V removed = (_delegate as List).removeLast();
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  void removeRange(int start, int end) {
    _syncDelegate();
    (_delegate as List).removeRange(start, end);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void removeWhere(bool test(V element)) {
    _syncDelegate();
    (_delegate as List).removeWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void replaceRange(int start, int end, Iterable<V> iterable) {
    _syncDelegate();
    (_delegate as List).replaceRange(start, end, iterable);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainWhere(bool test(V element)) {
    _syncDelegate();
    (_delegate as List).retainWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  Iterable<V> get reversed {
    _syncDelegate();
    return (_delegate as List).reversed;
  }

  void setAll(int index, Iterable<V> iterable) {
    _syncDelegate();
    (_delegate as List).setAll(index, iterable);
  }

  void setRange(int start, int end, Iterable<V> iterable, [int skipCount = 0]) {
    _syncDelegate();
  }

  void shuffle([Random random]) {
    _syncDelegate();
    (_delegate as List).shuffle(random);
  }

  void sort([int compare(V a, V b)]) {
    _syncDelegate();
    (_delegate as List).sort(compare);
  }

  List<V> sublist(int start, [int end]) {
    _syncDelegate();
    return (_delegate as List).sublist(start, end);
  }
}

class _WrappedSet<K, V> extends _WrappedIterable<K, V> implements Set<V> {
  _WrappedSet(Map<K, Iterable<V>> map, K key, Iterable<V> delegate) :
      super(map, key, delegate);

  bool add(V value) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    bool wasAdded = (_delegate as Set).add(value);
    if (wasEmpty) _addToMap();
    return wasAdded;
  }

  void addAll(Iterable<V> elements) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    (_delegate as Set).addAll(elements);
    if (wasEmpty) _addToMap();
  }

  void clear() {
    _syncDelegate();
    (_delegate as Set).clear();
    _map.remove(_key);
  }

  bool containsAll(Iterable<Object> other) {
    _syncDelegate();
    return (_delegate as Set).containsAll(other);
  }

  Set<V> difference(Set<V> other) {
    _syncDelegate();
    return (_delegate as Set).difference(other);
  }

  Set<V> intersection(Set<Object> other) {
    _syncDelegate();
    return (_delegate as Set).intersection(other);
  }

  V lookup(Object object) {
    _syncDelegate();
    return (_delegate as Set).lookup(object);
  }

  bool remove(Object value) {
    _syncDelegate();
    bool removed = (_delegate as Set).remove(value);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  void removeAll(Iterable<Object> elements) {
    _syncDelegate();
    (_delegate as Set).removeAll(elements);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void removeWhere(bool test(V element)) {
    _syncDelegate();
    (_delegate as Set).removeWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainAll(Iterable<Object> elements) {
    _syncDelegate();
    (_delegate as Set).retainAll(elements);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainWhere(bool test(V element)) {
    _syncDelegate();
    (_delegate as Set).retainWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  Set<V> union(Set<V> other) {
    _syncDelegate();
    return (_delegate as Set).union(other);
  }
}

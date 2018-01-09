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

/// An associative container that maps a key to multiple values.
///
/// Key lookups return mutable collections that are views of the multimap.
/// Updates to the multimap are reflected in these collections and similarly,
/// modifications to the returned collections are reflected in the multimap.
abstract class Multimap<K, V> {
  /// Constructs a new list-backed multimap.
  factory Multimap() => new ListMultimap<K, V>();

  /// Constructs a new list-backed multimap. For each element e of [iterable],
  /// adds an association from [key](e) to [value](e). [key] and [value] each
  /// default to the identity function.
  factory Multimap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) = ListMultimap<K, V>.fromIterable;

  /// Returns whether this multimap contains the given [value].
  bool containsValue(Object value);

  /// Returns whether this multimap contains the given [key].
  bool containsKey(Object key);

  /// Returns whether this multimap contains the given association between [key]
  /// and [value].
  bool contains(Object key, Object value);

  /// Returns the values for the given [key]. An empty iterable is returned if
  /// [key] is not mapped. The returned collection is a view on the multimap.
  /// Updates to the collection modify the multimap and likewise, modifications
  /// to the multimap are reflected in the returned collection.
  Iterable<V> operator [](Object key);

  /// Adds an association from the given key to the given value.
  void add(K key, V value);

  /// Adds an association from the given key to each of the given values.
  void addValues(K key, Iterable<V> values);

  /// Adds all associations of [other] to this multimap.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key and
  /// associated value in other. It iterates over [other], which must therefore
  /// not change during the iteration.
  void addAll(Multimap<K, V> other);

  /// Removes the association between the given [key] and [value]. Returns
  /// `true` if the association existed, `false` otherwise.
  bool remove(Object key, V value);

  /// Removes the association for the given [key]. Returns the collection of
  /// removed values, or an empty iterable if [key] was unmapped.
  Iterable<V> removeAll(Object key);

  /// Removes all data from the multimap.
  void clear();

  /// Applies [f] to each {key, Iterable<value>} pair of the multimap.
  ///
  /// It is an error to add or remove keys from the map during iteration.
  void forEachKey(void f(K key, Iterable<V> value));

  /// Applies [f] to each {key, value} pair of the multimap.
  ///
  /// It is an error to add or remove keys from the map during iteration.
  void forEach(void f(K key, V value));

  /// The keys of [this].
  Iterable<K> get keys;

  /// The values of [this].
  Iterable<V> get values;

  /// Returns a view of this multimap as a map.
  Map<K, Iterable<V>> asMap();

  /// The number of keys in the multimap.
  int get length;

  /// Returns true if there is no key in the multimap.
  bool get isEmpty;

  /// Returns true if there is at least one key in the multimap.
  bool get isNotEmpty;
}

/// Abstract base class for multimap implementations.
abstract class _BaseMultimap<K, V, C extends Iterable<V>>
    implements Multimap<K, V> {
  static T _id<T>(x) => x;

  _BaseMultimap();

  /// Constructs a new multimap. For each element e of [iterable], adds an
  /// association from [key](e) to [value](e). [key] and [value] each default
  /// to the identity function.
  _BaseMultimap.fromIterable(Iterable iterable,
      {K key(element), V value(element)}) {
    key ??= _id;
    value ??= _id;
    for (var element in iterable) {
      add(key(element), value(element));
    }
  }

  final Map<K, C> _map = {};

  C _create();
  void _add(C iterable, V value);
  void _addAll(C iterable, Iterable<V> value);
  void _clear(C iterable);
  bool _remove(C iterable, Object value);
  Iterable<V> _wrap(Object key, C iterable);

  bool containsValue(Object value) => values.contains(value);
  bool containsKey(Object key) => _map.keys.contains(key);
  bool contains(Object key, Object value) => _map[key]?.contains(value) == true;

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

  /// Adds all associations of [other] to this multimap.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key and
  /// associated value in other. It iterates over [other], which must therefore
  /// not change during the iteration.
  ///
  /// This implementation iterates through each key of [other] and adds the
  /// associated values to this instance via [addValues].
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
    return retValues as Iterable<V>;
  }

  void clear() {
    _map.forEach((K key, Iterable<V> value) => _clear(value));
    _map.clear();
  }

  void forEachKey(void f(K key, C value)) => _map.forEach(f);

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

/// A multimap implementation that uses [List]s to store the values associated
/// with each key.
class ListMultimap<K, V> extends _BaseMultimap<K, V, List<V>> {
  ListMultimap();

  /// Constructs a new list-backed multimap. For each element e of [iterable],
  /// adds an association from [key](e) to [value](e). [key] and [value] each
  /// default to the identity function.
  ListMultimap.fromIterable(Iterable iterable,
      {K key(element), V value(element)})
      : super.fromIterable(iterable, key: key, value: value);

  @override
  List<V> _create() => new List<V>();
  @override
  void _add(List<V> iterable, V value) {
    iterable.add(value);
  }

  @override
  void _addAll(List<V> iterable, Iterable<V> value) => iterable.addAll(value);
  @override
  void _clear(List<V> iterable) => iterable.clear();
  @override
  bool _remove(List<V> iterable, Object value) => iterable.remove(value);
  @override
  List<V> _wrap(Object key, List<V> iterable) =>
      new _WrappedList(_map, key, iterable);
  List<V> operator [](Object key) => super[key];
  List<V> removeAll(Object key) => super.removeAll(key);
  Map<K, List<V>> asMap() => new _WrappedMap<K, V, List<V>>(this);
}

/// A multimap implementation that uses [Set]s to store the values associated
/// with each key.
class SetMultimap<K, V> extends _BaseMultimap<K, V, Set<V>> {
  SetMultimap();

  /// Constructs a new set-backed multimap. For each element e of [iterable],
  /// adds an association from [key](e) to [value](e). [key] and [value] each
  /// default to the identity function.
  SetMultimap.fromIterable(Iterable iterable,
      {K key(element), V value(element)})
      : super.fromIterable(iterable, key: key, value: value);

  @override
  Set<V> _create() => new Set<V>();
  @override
  void _add(Set<V> iterable, V value) {
    iterable.add(value);
  }

  @override
  void _addAll(Set<V> iterable, Iterable<V> value) => iterable.addAll(value);
  @override
  void _clear(Set<V> iterable) => iterable.clear();
  @override
  bool _remove(Set<V> iterable, Object value) => iterable.remove(value);
  @override
  Set<V> _wrap(Object key, Iterable<V> iterable) =>
      new _WrappedSet(_map, key, iterable);
  Set<V> operator [](Object key) => super[key];
  Set<V> removeAll(Object key) => super.removeAll(key);
  Map<K, Set<V>> asMap() => new _WrappedMap<K, V, Set<V>>(this);
}

/// A [Map] that delegates its operations to an underlying multimap.
class _WrappedMap<K, V, C extends Iterable<V>> implements Map<K, C> {
  final _BaseMultimap<K, V, C> _multimap;

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
  void forEach(void f(K key, C value)) => _multimap.forEachKey(f);
  bool get isEmpty => _multimap.isEmpty;
  bool get isNotEmpty => _multimap.isNotEmpty;
  Iterable<K> get keys => _multimap.keys;
  int get length => _multimap.length;
  C remove(Object key) => _multimap.removeAll(key);
  Iterable<C> get values => _multimap._groupedValues;

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> cast<K2, V2>() {
    throw new UnimplementedError("cast");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> retype<K2, V2>() {
    throw new UnimplementedError("retype");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_getter
  Iterable<Null> get entries {
    // Change Iterable<Null> to Iterable<MapEntry<K, V>> when
    // the MapEntry class has been added.
    throw new UnimplementedError("entries");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void addEntries(Iterable<Object> entries) {
    // Change Iterable<Object> to Iterable<MapEntry<K, V>> when
    // the MapEntry class has been added.
    throw new UnimplementedError("addEntries");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> map<K2, V2>(Object transform(K key, C value)) {
    // Change Object to MapEntry<K2, V2> when
    // the MapEntry class has been added.
    throw new UnimplementedError("map");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  C update(K key, C update(C value), {C ifAbsent()}) {
    throw new UnimplementedError("update");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void updateAll(C update(K key, C value)) {
    throw new UnimplementedError("updateAll");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void removeWhere(bool test(K key, C value)) {
    throw new UnimplementedError("removeWhere");
  }
}

/// Iterable wrapper that syncs to an underlying map.
class _WrappedIterable<K, V, C extends Iterable<V>> implements Iterable<V> {
  final K _key;
  final Map<K, C> _map;
  C _delegate;

  _WrappedIterable(this._map, this._key, this._delegate);

  _addToMap() => _map[_key] = _delegate;

  /// Ensures we hold an up-to-date delegate. In the case where all mappings
  /// for _key are removed from the multimap, the Iterable referenced by
  /// _delegate is removed from the underlying map. At that point, any new
  /// addition via the multimap triggers the creation of a new Iterable, and
  /// the empty delegate we hold would be stale. As such, we check the
  /// underlying map and update our delegate when the one we hold is empty.
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

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> cast<T>() {
    throw new UnimplementedError("cast");
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

  Iterable<T> expand<T>(Iterable<T> f(V element)) {
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

  T fold<T>(T initialValue, T combine(T previousValue, V element)) {
    _syncDelegate();
    return _delegate.fold(initialValue, combine);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<V> followedBy(Iterable<V> other) {
    throw new UnimplementedError("followedBy");
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

  Iterable<T> map<T>(T f(V element)) {
    _syncDelegate();
    return _delegate.map(f);
  }

  V reduce(V combine(V value, V element)) {
    _syncDelegate();
    return _delegate.reduce(combine);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  V get single {
    _syncDelegate();
    return _delegate.single;
  }

  V singleWhere(bool test(V element), {V orElse()}) {
    if (orElse != null) throw new UnimplementedError("singleWhere:orElse");
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

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> whereType<T>() {
    throw new UnimplementedError("whereType");
  }
}

class _WrappedList<K, V> extends _WrappedIterable<K, V, List<V>>
    implements List<V> {
  _WrappedList(Map<K, Iterable<V>> map, K key, List<V> delegate)
      : super(map, key, delegate);

  V operator [](int index) => elementAt(index);

  void operator []=(int index, V value) {
    _syncDelegate();
    _delegate[index] = value;
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  List<V> operator +(List<V> other) {
    throw new UnimplementedError("+");
  }

  void add(V value) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.add(value);
    if (wasEmpty) _addToMap();
  }

  void addAll(Iterable<V> iterable) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.addAll(iterable);
    if (wasEmpty) _addToMap();
  }

  Map<int, V> asMap() {
    _syncDelegate();
    return _delegate.asMap();
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  List<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  void clear() {
    _syncDelegate();
    _delegate.clear();
    _map.remove(_key);
  }

  void fillRange(int start, int end, [V fillValue]) {
    _syncDelegate();
    _delegate.fillRange(start, end, fillValue);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_setter
  void set first(V value) {
    if (this.isEmpty) throw new RangeError.index(0, this);
    this[0] = value;
  }

  Iterable<V> getRange(int start, int end) {
    _syncDelegate();
    return _delegate.getRange(start, end);
  }

  int indexOf(V element, [int start = 0]) {
    _syncDelegate();
    return _delegate.indexOf(element, start);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  int indexWhere(bool test(V element), [int start = 0]) {
    throw new UnimplementedError("indexWhere");
  }

  void insert(int index, V element) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.insert(index, element);
    if (wasEmpty) _addToMap();
  }

  void insertAll(int index, Iterable<V> iterable) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.insertAll(index, iterable);
    if (wasEmpty) _addToMap();
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_setter
  void set last(V value) {
    if (this.isEmpty) throw new RangeError.index(0, this);
    this[this.length - 1] = value;
  }

  int lastIndexOf(V element, [int start]) {
    _syncDelegate();
    return _delegate.lastIndexOf(element, start);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  int lastIndexWhere(bool test(V element), [int start]) {
    throw new UnimplementedError("lastIndexWhere");
  }

  void set length(int newLength) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.length = newLength;
    if (wasEmpty) _addToMap();
  }

  bool remove(Object value) {
    _syncDelegate();
    bool removed = _delegate.remove(value);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  V removeAt(int index) {
    _syncDelegate();
    V removed = _delegate.removeAt(index);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  V removeLast() {
    _syncDelegate();
    V removed = _delegate.removeLast();
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  void removeRange(int start, int end) {
    _syncDelegate();
    _delegate.removeRange(start, end);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void removeWhere(bool test(V element)) {
    _syncDelegate();
    _delegate.removeWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void replaceRange(int start, int end, Iterable<V> iterable) {
    _syncDelegate();
    _delegate.replaceRange(start, end, iterable);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainWhere(bool test(V element)) {
    _syncDelegate();
    _delegate.retainWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  List<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  Iterable<V> get reversed {
    _syncDelegate();
    return _delegate.reversed;
  }

  void setAll(int index, Iterable<V> iterable) {
    _syncDelegate();
    _delegate.setAll(index, iterable);
  }

  void setRange(int start, int end, Iterable<V> iterable, [int skipCount = 0]) {
    _syncDelegate();
  }

  void shuffle([Random random]) {
    _syncDelegate();
    _delegate.shuffle(random);
  }

  void sort([int compare(V a, V b)]) {
    _syncDelegate();
    _delegate.sort(compare);
  }

  List<V> sublist(int start, [int end]) {
    _syncDelegate();
    return _delegate.sublist(start, end);
  }
}

class _WrappedSet<K, V> extends _WrappedIterable<K, V, Set<V>>
    implements Set<V> {
  _WrappedSet(Map<K, Iterable<V>> map, K key, Iterable<V> delegate)
      : super(map, key, delegate);

  bool add(V value) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    bool wasAdded = _delegate.add(value);
    if (wasEmpty) _addToMap();
    return wasAdded;
  }

  void addAll(Iterable<V> elements) {
    _syncDelegate();
    var wasEmpty = _delegate.isEmpty;
    _delegate.addAll(elements);
    if (wasEmpty) _addToMap();
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Set<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  void clear() {
    _syncDelegate();
    _delegate.clear();
    _map.remove(_key);
  }

  bool containsAll(Iterable<Object> other) {
    _syncDelegate();
    return _delegate.containsAll(other);
  }

  Set<V> difference(Set<Object> other) {
    _syncDelegate();
    return _delegate.difference(other);
  }

  Set<V> intersection(Set<Object> other) {
    _syncDelegate();
    return _delegate.intersection(other);
  }

  V lookup(Object object) {
    _syncDelegate();
    return _delegate.lookup(object);
  }

  bool remove(Object value) {
    _syncDelegate();
    bool removed = _delegate.remove(value);
    if (_delegate.isEmpty) _map.remove(_key);
    return removed;
  }

  void removeAll(Iterable<Object> elements) {
    _syncDelegate();
    _delegate.removeAll(elements);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void removeWhere(bool test(V element)) {
    _syncDelegate();
    _delegate.removeWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainAll(Iterable<Object> elements) {
    _syncDelegate();
    _delegate.retainAll(elements);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  void retainWhere(bool test(V element)) {
    _syncDelegate();
    _delegate.retainWhere(test);
    if (_delegate.isEmpty) _map.remove(_key);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Set<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  Set<V> union(Set<V> other) {
    _syncDelegate();
    return _delegate.union(other);
  }
}

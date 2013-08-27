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
 * An associative container mapping a key to multiple values.
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
   * Returns the values for the given [key] or null if [key] is not
   * in the multimap.
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
   * Removes the association for the given [key]. Returns the value for
   * [key] in the multimap or null if [key] is not in the multimap.
   */
  Iterable<V> remove(Object key);

  /**
   * Removes all data from the multimap.
   */
  void clear();

  /**
   * Applies [f] to each {key, Iterable<value>} pair of the multimap.
   *
   * It is an error to add or remove keys from the map during iteration.
   */
  void forEachKey(void f(key, value));

  /**
   * Applies [f] to each {key, value} pair of the multimap.
   *
   * It is an error to add or remove keys from the map during iteration.
   */
  void forEach(void f(key, value));

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

abstract class _BaseMultimap<K, V> implements Multimap<K, V> {
  final Map<K, Iterable<V>> _map = new HashMap();

  bool containsValue(Object value) => values.contains(value);
  bool containsKey(Object key) => _map.keys.contains(key);
  Iterable<V> operator [](Object key) => _map[key];

   void addValues(K key, Iterable<V> values) {
     values.forEach((V value) => add(key, value));
   }

  void addAll(Multimap<K, V> other) => other.forEach((k, v) => add(k, v));

  Iterable<V> remove(Object key) => _map.remove(key);
  void clear() => _map.clear();
  void forEachKey(void f(key, value)) => _map.forEach(f);

  void forEach(void f(key, value)) {
    _map.forEach((K key, Iterable<V> values) {
      values.forEach((V value) => f(key, value));
    });
  }

  Iterable<K> get keys => _map.keys;
  Iterable<V> get values => _map.values.expand((x) => x);
  Map<K, Iterable<V>> toMap() => new uc.UnmodifiableMapView(_map);
  int get length => _map.length;
  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;
}

/**
 * A multimap implementation that uses [List]s to store the values associated
 * with each key.
 */
class ListMultimap<K, V> extends _BaseMultimap<K, V> {
  final Function _create = () => new List();
  List<V> operator [](Object key) => _map[key];

  void add(K key, V value) {
    _map.putIfAbsent(key, _create);
    (_map[key] as List).add(value);
  }

  void addValues(K key, Iterable<V> values) {
    _map.putIfAbsent(key, _create);
    (_map[key] as List).addAll(values);
  }

  List<V> remove(Object key) => _map.remove(key);

  Map<K, List<V>> toMap() => new uc.UnmodifiableMapView(_map);
}

/**
 * A multimap implementation that uses [Set]s to store the values associated
 * with each key.
 */
class SetMultimap<K, V> extends _BaseMultimap<K, V> {
  final Function _create = () => new Set();
  Set<V> operator [](Object key) => _map[key];

  void add(K key, V value) {
    _map.putIfAbsent(key, _create);
    (_map[key] as Set).add(value);
  }

  void addValues(K key, Iterable<V> values) {
    _map.putIfAbsent(key, _create);
    (_map[key] as Set).addAll(values);
  }

  Set<V> remove(Object key) => _map.remove(key);

  Map<K, Set<V>> toMap() => new uc.UnmodifiableMapView(_map);
}

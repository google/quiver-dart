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

/// A bi-directional map whose key-value pairs form a one-to-one
/// correspondence.  BiMaps support an `inverse` property which gives access to
/// an inverted view of the map, such that there is a mapping (v, k) for each
/// pair (k, v) in the original map. Since a one-to-one key-value invariant
/// applies, it is an error to insert duplicate values into this map. It is
/// also an error to insert null keys or values into this map.
abstract class BiMap<K, V> implements Map<K, V> {
  /// Creates a BiMap instance with the default implementation.
  factory BiMap() => new HashBiMap();

  /// Adds an association between key and value.
  ///
  /// Throws [ArgumentError] if an association involving [value] exists in the
  /// map; otherwise, the association is inserted, overwriting any existing
  /// association for the key.
  void operator []=(K key, V value);

  /// Replaces any existing associations(s) involving key and value.
  ///
  /// If an association involving [key] or [value] exists in the map, it is
  /// removed.
  void replace(K key, V value);

  /// Returns the inverse of this map, with key-value pairs (v, k) for each pair
  /// (k, v) in this map.
  BiMap<V, K> get inverse;
}

/// A hash-table based implementation of BiMap.
class HashBiMap<K, V> implements BiMap<K, V> {
  final Map<K, V> _map;
  final Map<V, K> _inverse;
  BiMap<V, K> _cached;

  HashBiMap() : this._from(new HashMap(), new HashMap());
  HashBiMap._from(this._map, this._inverse);

  V operator [](Object key) => _map[key];
  void operator []=(K key, V value) {
    _add(key, value, false);
  }

  void replace(K key, V value) {
    _add(key, value, true);
  }

  void addAll(Map<K, V> other) => other.forEach((k, v) => _add(k, v, false));
  bool containsKey(Object key) => _map.containsKey(key);
  bool containsValue(Object value) => _inverse.containsKey(value);
  void forEach(void f(K key, V value)) => _map.forEach(f);
  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;
  Iterable<K> get keys => _map.keys;
  int get length => _map.length;
  Iterable<V> get values => _inverse.keys;

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
  Map<K2, V2> cast<K2, V2>() {
    throw new UnimplementedError("cast");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_getter
  Iterable<Null> get entries {
    // Change Iterable<Null> to Iterable<MapEntry<K, V>> when
    // the MapEntry class has been added.
    throw new UnimplementedError("entries");
  }

  BiMap<V, K> get inverse {
    if (_cached == null) {
      _cached = new HashBiMap._from(_inverse, _map);
    }
    return _cached;
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> map<K2, V2>(Object transform(K key, V value)) {
    // Change Object to MapEntry<K2, V2> when
    // the MapEntry class has been added.
    throw new UnimplementedError("map");
  }

  V putIfAbsent(K key, V ifAbsent()) {
    var value = _map[key];
    if (value != null) return value;
    if (!_map.containsKey(key)) return _add(key, ifAbsent(), false);
    return null;
  }

  V remove(Object key) {
    _inverse.remove(_map[key]);
    return _map.remove(key);
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void removeWhere(bool test(K key, V value)) {
    throw new UnimplementedError("removeWhere");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> retype<K2, V2>() {
    throw new UnimplementedError("retype");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  V update(K key, V update(V value), {V ifAbsent()}) {
    throw new UnimplementedError("update");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void updateAll(V update(K key, V value)) {
    throw new UnimplementedError("updateAll");
  }

  void clear() {
    _map.clear();
    _inverse.clear();
  }

  V _add(K key, V value, bool replace) {
    if (key == null) throw new ArgumentError("null key");
    if (value == null) throw new ArgumentError("null value");
    var oldValue = _map[key];
    if (oldValue == value) return value;
    if (_inverse.containsKey(value)) {
      if (!replace) throw new ArgumentError("Mapping for $value exists");
      _map.remove(_inverse[value]);
    }
    _inverse.remove(oldValue);
    _map[key] = value;
    _inverse[value] = key;
    return value;
  }
}

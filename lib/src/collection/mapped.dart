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
 * An immutable map.
 *
 * Implements all non-modifying methods from [Map] but does not extend it.
 *
 * Adds deep [:hashCode:] and [:equals:].
 *
 * Adds a [:+:] operator.
 */
class Mapped<K, V> {
  LinkedHashMap<K, V> _map;

  Mapped._withMap(this._map);

  Mapped(mapOrList) {
    _map = new LinkedHashMap<K, V>();

    if (mapOrList is Map) {
      for (var key in mapOrList.keys) {
        if (key is! K) throw new ArgumentError("wrong type for key");
      }
      for (var value in mapOrList.values) {
        if (value is! V) throw new ArgumentError("wrong type for value");
      }
      _map.addAll(mapOrList);
    } else if (mapOrList is List) {
      List list = mapOrList as List;

      if (list.length % 2 != 0) throw new ArgumentError("Expected even length list.");

      for (int i = 0; i != list.length / 2; ++i) {
        var key = list[i * 2];
        var value = list[i * 2 + 1];
        if(key is! K) throw new ArgumentError("wrong type for key");
        if(value is! V) throw new ArgumentError("wrong type for value");

        _map[key] = value;
      }
    } else {
      throw new ArgumentError("Create from Map or List of alternating key, value.");
    }
  }

  Mapped<K, V> operator+(o) {
    if (o is List) {
      var map = new LinkedHashMap<K, V>();
      map.addAll(_map);
      if (o.length % 2 != 0) throw new ArgumentError("Expected even length list.");
      for (int i = 0; i != o.length; i += 2) {
        var key = o[i];
        var value = o[i + 1];

        if (key is! K) throw new ArgumentError("wrong type for key");
        if (value is! V) throw new ArgumentError("wrong type for value");

        map[key] = value;
      }
      return new Mapped<K, V>._withMap(map);
    } else if (o is Mapped<K, V>) {
      var map = new LinkedHashMap<K, V>();
      map.addAll(_map);
      map.addAll(o._map);
      return new Mapped<K, V>._withMap(map);
    } else {
      throw new ArgumentError("wrong type");
    }
  }

  bool operator ==(o) {
    if (identical(o, this)) return true;
    if (o is! Mapped) return false;
    if (length != o.length) return false;
    for (var k in keys) {
      if (!o.containsKey(k)) {
        return false;
      }

      if (o[k] != this[k]) {
        return false;
      }
    }
    return true;
  }

  int get hashCode {
    int result = 13;
    for (K key in keys) {
      result += key.hashCode;
    }
    for (V value in values) {
      result += value.hashCode;
    }
    return result;
  }

  String toString() => _map.toString();

  // Non-modifying methods from [Map].
  bool containsValue(V value) => _map.containsValue(value);
  bool containsKey(K key) => _map.containsKey(key);
  V operator [](K key) => _map[key];
  void forEach(void f(K key, V value)) => _map.forEach(f);
  Iterable<K> get keys => _map.keys;
  Iterable<V> get values => _map.values;
  int get length => _map.length;
  bool get isEmpty => _map.isEmpty;
}

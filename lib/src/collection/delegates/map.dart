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

/// An implementation of [Map] that delegates all methods to another [Map].
/// For instance you can create a FruitMap like this :
///
///     class FruitMap extends DelegatingMap<String, Fruit> {
///       final Map<String, Fruit> _fruits = {};
///
///       Map<String, Fruit> get delegate => _fruits;
///
///       // custom methods
///     }
abstract class DelegatingMap<K, V> implements Map<K, V> {
  Map<K, V> get delegate;

  V operator [](Object key) => delegate[key];

  void operator []=(K key, V value) {
    delegate[key] = value;
  }

  void addAll(Map<K, V> other) => delegate.addAll(other);

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

  void clear() => delegate.clear();

  bool containsKey(Object key) => delegate.containsKey(key);

  bool containsValue(Object value) => delegate.containsValue(value);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_getter
  Iterable<Null> get entries {
    // Change Iterable<Null> to Iterable<MapEntry<K, V>> when
    // the MapEntry class has been added.
    throw new UnimplementedError("entries");
  }

  void forEach(void f(K key, V value)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterable<K> get keys => delegate.keys;

  int get length => delegate.length;

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> map<K2, V2>(Object transform(K key, V value)) {
    // Change Object to MapEntry<K2, V2> when
    // the MapEntry class has been added.
    throw new UnimplementedError("map");
  }

  V putIfAbsent(K key, V ifAbsent()) => delegate.putIfAbsent(key, ifAbsent);

  V remove(Object key) => delegate.remove(key);

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

  Iterable<V> get values => delegate.values;
}

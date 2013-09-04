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
 * An implementation of [Map] that delegates all methods to another [Map].
 * For instance you can create a FruitMap like this :
 *
 *     class FruitMap extends DelegatingMap<String, Fruit> {
 *       final Map<String, Fruit> _fruits = {};
 *
 *       Map<String, Fruit> get delegate => _fruits;
 *
 *       // custom methods
 *     }
 */
abstract class DelegatingMap<K, V> implements Map<K, V> {
  Map<K, V> get delegate;

  V operator [](Object key) => delegate[key];

  void operator []=(K key, V value) {
    delegate[key] = value;
  }

  void addAll(Map<K, V> other) => delegate.addAll(other);

  void clear() => delegate.clear();

  bool containsKey(Object key) => delegate.containsKey(key);

  bool containsValue(Object value) => delegate.containsValue(value);

  void forEach(void f(K key, V value)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterable<K> get keys => delegate.keys;

  int get length => delegate.length;

  V putIfAbsent(K key, V ifAbsent()) => delegate.putIfAbsent(key, ifAbsent);

  V remove(Object key) => delegate.remove(key);

  Iterable<V> get values => delegate.values;
}

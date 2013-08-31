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
 *       final Map<String, Fruit> fruits;
 *       FruitMap() : this._(new Map<String, Fruit>());
 *       FruitMap._(Map<String, Fruit> fruits) :
 *         this.fruits = fruits,
 *         super(fruits);
 *
 *       // custom methods
 *     }
 */
class DelegatingMap<K, V> implements Map<K, V> {
  final Map<K, V> _delegate;

  DelegatingMap(this._delegate);

  V operator [](Object key) => _delegate[key];

  void operator []=(K key, V value) {
    _delegate[key] = value;
  }

  void addAll(Map<K, V> other) => _delegate.addAll(other);

  void clear() => _delegate.clear();

  bool containsKey(Object key) => _delegate.containsKey(key);

  bool containsValue(Object value) => _delegate.containsValue(value);

  void forEach(void f(K key, V value)) => _delegate.forEach(f);

  bool get isEmpty => _delegate.isEmpty;

  bool get isNotEmpty => _delegate.isNotEmpty;

  Iterable<K> get keys => _delegate.keys;

  int get length => _delegate.length;

  V putIfAbsent(K key, V ifAbsent()) => _delegate.putIfAbsent(key, ifAbsent);

  V remove(Object key) => _delegate.remove(key);

  Iterable<V> get values => _delegate.values;
}

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
 * Returns the value for [key] in Map [m]. If [m] does not contain the key
 * [key], then [orElse] is invoked to generate a value. The value is not added
 * to the map. If you want to add the new value to the map, consider using
 * [Map.putIfAbsent].
 */
dynamic getOrElse(Map m, key, orElse()) {
  var value = m[key];
  return (value == null && !m.containsKey(key)) ? orElse() : value;
}

/**
 * An implementation of [Map] that has a function [getOrElse] that can generate
 * a value if a key is absent.
 */
abstract class DefaultMap<K, V> implements Map<K, V> {
  /**
   * Creates a new instance. Wraps [map] if provided, otherwise uses
   * [LinkedHashMap].
   */
  factory DefaultMap([Map<K, V> map]) => new _DefaultMapImpl(map);

  V getOrElse(K key, V value());
}

class _DefaultMapImpl<K, V> extends DelegatingMap<K, V> implements DefaultMap<K, V> {
  final Map<K, V> delegate;

  _DefaultMapImpl(this.delegate);

  @override
  V getOrElse(K key, V orElse()) {
    var value = this[key];
    return (value == null && !containsKey(key)) ? orElse() : value;
  }
}

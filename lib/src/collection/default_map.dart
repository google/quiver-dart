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

dynamic getOrElse(Map m, key, value()) =>
    m.containsKey(key) ? m[key] : value();

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
  V getOrElse(K key, V value()) => containsKey(key) ? this[key] : value();
}

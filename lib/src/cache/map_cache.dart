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

part of quiver.cache;

/**
 * A [Cache] that's backed by a [Map].
 */
class MapCache<K, V> implements Cache<K, V> {

  final Map<K, V> _map;

  /**
   * Creates a new [LocalCache], optionally using [map] as the backing [Map].
   */
  MapCache({Map<K, V> map})
      : _map = map != null ? map : new HashMap<K, V>();

  Future<V> get(K key, {Loader<K> ifAbsent}) {
    if (!_map.containsKey(key) && ifAbsent != null) {
      var valOrFuture = ifAbsent(key);
      if (valOrFuture is Future) {
        return valOrFuture.then((v) {
          _map[key] = v;
          return v;
        });
      } else {
        _map[key] = valOrFuture;
        return new Future.value(valOrFuture);
      }
    }
    return new Future.value(_map[key]);
  }

  Future set(K key, V value) {
    _map[key] = value;
    return new Future.value();
  }

  Future invalidate(K key) {
    _map.remove(key);
    return new Future.value();
  }
}

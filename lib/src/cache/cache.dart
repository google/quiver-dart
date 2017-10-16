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

/// A function that produces a value for [key], for when a [Cache] needs to
/// populate an entry.
///
/// The loader function should either return a value synchronously or a
/// [Future] which completes with the value asynchronously.
typedef FutureOr<V> Loader<K, V>(K key);

/// A semi-persistent mapping of keys to values.
///
/// All access to a Cache is asynchronous because many implementations will
/// store their entries in remote systems, isolates, or otherwise have to do
/// async IO to read and write.
abstract class Cache<K, V> {
  /// Returns the value associated with [key].
  Future<V> get(K key, {Loader<K, V> ifAbsent});

  /// Sets the value associated with [key]. The Future completes with null when
  /// the operation is complete.
  Future<Null> set(K key, V value);

  /// Removes the value associated with [key]. The Future completes with null
  /// when the operation is complete.
  Future<Null> invalidate(K key);
}

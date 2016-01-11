// Copyright 2014 Google Inc. All Rights Reserved.
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
 * An implementation of a [Set] which has a maximum size and uses a (Least
 * Recently Used)[http://en.wikipedia.org/wiki/Cache_algorithms#LRU] algorithm
 * to remove items from the [Set] when the [maximumSize] is reached and new
 * items are added.
 *
 * It is safe to access the iterator and contains method without affecting
 * the "used" ordering - as well as using [forEach]. Other types of access,
 * including lookup, promotes the key-value pair to the MRU position.
 */
abstract class LruSet<E> implements Set<E> {
  /**
   * Creates a [LruSet] instance with the default implementation.
   */
  factory LruSet({int maximumSize}) = LinkedLruHashSet;

  /**
   * Maximum size of the [Set]. If [length] exceeds this value at any time,
   * n entries accessed the earliest are removed, where n is [length] -
   * [maximumSize].
   */
  int maximumSize;
}

/**
 * A linked hash-table based implementation of [LruSet].
 */
class LinkedLruHashSet<E> extends SetBase<E> implements LruSet<E> {
  static const _DEFAULT_MAXIMUM_SIZE = 100;

  final LruMap<E, bool> _entries;

  /**
   * Create a new LinkedLruHashSet with a [maximumSize].
   */
  factory LinkedLruHashSet({int maximumSize}) =>
    new LinkedLruHashSet._fromMap(new LruMap<E, bool>(maximumSize: maximumSize));

  LinkedLruHashSet._fromMap(this._entries);

  /**
   * If [element] already exists, promotes it to the MRU position.
   *
   * Otherwise, adds [element] to the MRU position.
   * If [length] exceeds [maximumSize] while adding, removes the LRU position.
   */
  @override
  bool add(E element) {
    bool wasPresent = _entries.containsKey(element);
    _entries[element] = true;
    return !wasPresent;
  }

  @override contains(E element) => _entries.containsKey(element);

  /**
   * If an object equal to object is in the set, return it.
   *
   * Checks if there is an object in the set that is equal to object.
   * If so, that object is returned, otherwise returns null.
   *
   * The [element] will be promoted to the 'Most Recently Used' position.
   */
  @override lookup(E element) {
    bool wasPresent = _entries.containsKey(element);
    if(wasPresent) {
      _entries[element] = true;
    }
    return wasPresent;
  }

  @override
  bool remove(E element) => _entries.remove(element) != null;

  @override
  Iterator<E> get iterator => _entries.keys.iterator;

  @override
  int get length => _entries.length;

  @override
  int get maximumSize => _entries.maximumSize;

  @override
  void set maximumSize(int maximumSize) {
    _entries.maximumSize = maximumSize;
  }

  @override
  Set<E> toSet() => _entries.keys.toSet();
}

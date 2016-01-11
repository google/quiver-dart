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
   * Creates a [LruMap] instance with the default implementation.
   */
  factory LruSet({int maximumSize}) = LinkedLruHashSet;

  /**
   * Maximum size of the [Map]. If [length] exceeds this value at any time,
   * n entries accessed the earliest are removed, where n is [length] -
   * [maximumSize].
   */
  int maximumSize;
}

/**
 * Simple implementation of a linked-list entry that contains a [key] and
 * [element].
 */
class _LinkedSetEntry<E> {
  E element;

  _LinkedSetEntry<E> next;
  _LinkedSetEntry<E> previous;

  _LinkedSetEntry([this.element]);
}

/**
 * A linked hash-table based implementation of [LruSet].
 */
class LinkedLruHashSet<E> extends SetBase<E> implements LruSet<E> {
  static const _DEFAULT_MAXIMUM_SIZE = 100;

  final HashMap<E, _LinkedSetEntry<E>> _entries;

  int _maximumSize;

  _LinkedSetEntry<E> _head;
  _LinkedSetEntry<E> _tail;

  /**
   * Create a new LinkedLruHashMap with a [maximumSize].
   */
  factory LinkedLruHashSet({int maximumSize}) =>
    new LinkedLruHashSet._fromSet(new HashMap<E, _LinkedSetEntry<E>>(),
      maximumSize: maximumSize);

  LinkedLruHashSet._fromSet(
    this._entries, {
    int maximumSize})
  // This pattern is used instead of a default value because we want to
  // be able to respect null values coming in from MapCache.lru.
    : _maximumSize = firstNonNull(maximumSize, _DEFAULT_MAXIMUM_SIZE);

  /**
   * If [element] already exists, promotes it to the MRU position.
   *
   * Otherwise, adds [element] to the MRU position.
   * If [length] exceeds [maximumSize] while adding, removes the LRU position.
   */
  @override
  bool add(E element) {
    bool wasPresent = _entries.containsKey(element);
    _insertMru(_createEntry(element));

    // Remove the LRU item if the size would be exceeded by adding this item.
    if (length > maximumSize) {
      assert(length == maximumSize + 1);
      _removeLru();
    }
    return !wasPresent;
  }

  /**
   * Adds all key-value pairs of [other] to this set.
   *
   * The operation is equivalent to doing this[key] = value for each key and
   * associated value in other. It iterates over other, which must therefore not
   * change during the iteration.
   *
   * If the number of unique keys is greater than [maximumSize] then the least
   * recently use keys are evicted. For items added by [other], the least
   * recently user order is determined by [other]'s iteration order.
   */
  @override
  void addAll(Set<E> other) => other.forEach((v) => this.add(v));

  @override
  void clear() {
    _entries.clear();
    _head = _tail = null;
  }

  /**
   * If an object equal to object is in the set, return it.
   *
   * Checks if there is an object in the set that is equal to object.
   * If so, that object is returned, otherwise returns null.
   *
   * The [element] will be promoted to the 'Most Recently Used' position.
   */
  @override lookup(E element) {
    final entry = _entries[element];
    if (entry != null) {
      _promoteEntry(entry);
      return entry.element;
    } else {
      return null;
    }
  }

  @override
  bool contains(E element) => _entries.containsKey(element);

  @override
  E get first {
    if(isEmpty) throw new StateError("Set is empty");
    return _head.element;
  }

  /**
   * Returns the last element.
   *
   * This operation is performed in constant time.
   */
  @override
  E get last {
    if(isEmpty) throw new StateError("Set is empty");
    return _tail.element;
  }

  /**
   * Applies [action] to each key-value pair of the map in order of MRU to LRU.
   *
   * Calling `action` must not add or remove keys from the map.
   */
  @override
  void forEach(void action(E element)) {
    var head = _head;
    while (head != null) {
      action(head.element);
      head = head.next;
    }
  }

  @override
  int get length => _entries.length;

  @override
  bool get isEmpty => _entries.isEmpty;

  @override
  bool get isNotEmpty => _entries.isNotEmpty;

  @override
  Iterator<E> get iterator => _iterable().map((e) => e.element).iterator;

  /**
   * Creates an [Iterable] around the entries of the map.
   */
  Iterable<_LinkedSetEntry<E>> _iterable() {
    return new GeneratingIterable<_LinkedSetEntry<E>>(
      () => _head, (n) => n.next);
  }

  @override
  int get maximumSize => _maximumSize;

  @override
  void set maximumSize(int maximumSize) {
    if (maximumSize == null) throw new ArgumentError.notNull('maximumSize');
    while (length > maximumSize) {
      _removeLru();
    }
    _maximumSize = maximumSize;
  }

  @override
  bool remove(E element) {
    final _LinkedSetEntry entry = _entries.remove(element);
    if (entry != null) {
      if (entry == _head) {
        _head = _head.next;
      } else if (entry == _tail) {
        _tail.previous.next = null;
        _tail = _tail.previous;
      } else {
        entry.previous.next = entry.next;
      }
      return true;
    }
    return false;
  }

  @override
  Set<E> toSet() => _entries.keys.toSet();



  @override
  String toString() => _entries.keys.toString();

  /**
   * Moves [entry] to the MRU position, shifting the linked list if necessary.
   */
  void _promoteEntry(_LinkedSetEntry<E> entry) {
    if (entry.previous != null) {
      // If already existed in the map, link previous to next.
      entry.previous.next = entry.next;

      // If this was the tail element, assign a new tail.
      if (_tail == entry) {
        _tail = entry.previous;
      }
    }

    // Replace head with this element.
    if (_head != null) {
      _head.previous = entry;
    }
    entry.previous = null;
    entry.next = _head;
    _head = entry;

    // Add a tail if this is the first element.
    if (_tail == null) {
      assert(length == 1);
      _tail = _head;
    }
  }

  /**
   * Creates and returns an entry from [key] and [value].
   */
  _LinkedSetEntry<E> _createEntry(E value) {
    return new _LinkedSetEntry<E>(value);
  }

  /**
   * If [entry] does not exist, inserts it into the backing map.
   * If it does, replaces the existing [_LinkedEntry.value] with [entry.value].
   * Then, in either case, promotes [entry] to the MRU position.
   */
  void _insertMru(_LinkedSetEntry<E> entry) {
    // Insert a new entry if necessary (only 1 hash lookup in entire function).
    // Otherwise, just updates the existing value.
    final value = entry.element;
    _promoteEntry(_entries.putIfAbsent(entry.element, () => entry)..element = value);
  }

  /**
   * Removes the LRU position, shifting the linked list if necessary.
   */
  void _removeLru() {
    // Remove the tail from the internal map.
    _entries.remove(_tail.element);

    // Remove the tail element itself.
    _tail = _tail.previous;
    _tail.next = null;
  }
}

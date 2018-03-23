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

/// An implementation of a [Map] which has a maximum size and uses a (Least
/// Recently Used)[http://en.wikipedia.org/wiki/Cache_algorithms#LRU] algorithm
/// to remove items from the [Map] when the [maximumSize] is reached and new
/// items are added.
///
/// It is safe to access the [keys] and [values] collections without affecting
/// the "used" ordering - as well as using [forEach]. Other types of access,
/// including bracket, and [putIfAbsent], promotes the key-value pair to the
/// MRU position.
abstract class LruMap<K, V> implements Map<K, V> {
  /// Creates a [LruMap] instance with the default implementation.
  factory LruMap({int maximumSize}) = LinkedLruHashMap<K, V>;

  /// Maximum size of the [Map]. If [length] exceeds this value at any time, n
  /// entries accessed the earliest are removed, where n is [length] -
  /// [maximumSize].
  int maximumSize;
}

/// Simple implementation of a linked-list entry that contains a [key] and
/// [value].
class _LinkedEntry<K, V> {
  K key;
  V value;

  _LinkedEntry<K, V> next;
  _LinkedEntry<K, V> previous;

  _LinkedEntry([this.key, this.value]);
}

/// A linked hash-table based implementation of [LruMap].
class LinkedLruHashMap<K, V> implements LruMap<K, V> {
  static const _DEFAULT_MAXIMUM_SIZE = 100;

  final Map<K, _LinkedEntry<K, V>> _entries;

  int _maximumSize;

  _LinkedEntry<K, V> _head;
  _LinkedEntry<K, V> _tail;

  /// Create a new LinkedLruHashMap with a [maximumSize].
  factory LinkedLruHashMap({int maximumSize}) =>
      new LinkedLruHashMap._fromMap(new HashMap<K, _LinkedEntry<K, V>>(),
          maximumSize: maximumSize);

  LinkedLruHashMap._fromMap(this._entries, {int maximumSize})
      // This pattern is used instead of a default value because we want to
      // be able to respect null values coming in from MapCache.lru.
      : _maximumSize = firstNonNull(maximumSize, _DEFAULT_MAXIMUM_SIZE);

  /// Adds all key-value pairs of [other] to this map.
  ///
  /// The operation is equivalent to doing this[key] = value for each key and
  /// associated value in other. It iterates over other, which must therefore
  /// not change during the iteration.
  ///
  /// If a key of [other] is already in this map, its value is overwritten. If
  /// the number of unique keys is greater than [maximumSize] then the least
  /// recently use keys are evicted. For keys written to by [other], the least
  /// recently user order is determined by [other]'s iteration order.
  @override
  void addAll(Map<K, V> other) => other.forEach((k, v) => this[k] = v);

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
  LinkedLruHashMap<K2, V2> cast<K2, V2>() {
    throw new UnimplementedError("cast");
  }

  @override
  void clear() {
    _entries.clear();
    _head = _tail = null;
  }

  @override
  bool containsKey(Object key) => _entries.containsKey(key);

  @override
  bool containsValue(Object value) => values.contains(value);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_getter
  Iterable<Null> get entries {
    // Change Iterable<Null> to Iterable<MapEntry<K, V>> when
    // the MapEntry class has been added.
    throw new UnimplementedError("entries");
  }

  /// Applies [action] to each key-value pair of the map in order of MRU to
  /// LRU.
  ///
  /// Calling `action` must not add or remove keys from the map.
  @override
  void forEach(void action(K key, V value)) {
    var head = _head;
    while (head != null) {
      action(head.key, head.value);
      head = head.next;
    }
  }

  @override
  int get length => _entries.length;

  @override
  bool get isEmpty => _entries.isEmpty;

  @override
  bool get isNotEmpty => _entries.isNotEmpty;

  /// Creates an [Iterable] around the entries of the map.
  Iterable<_LinkedEntry<K, V>> _iterable() {
    return new GeneratingIterable<_LinkedEntry<K, V>>(
        () => _head, (n) => n.next);
  }

  /// The keys of [this] - in order of MRU to LRU.
  ///
  /// The returned iterable does *not* have efficient `length` or `contains`.
  @override
  Iterable<K> get keys => _iterable().map((e) => e.key);

  /// The values of [this] - in order of MRU to LRU.
  ///
  /// The returned iterable does *not* have efficient `length` or `contains`.
  @override
  Iterable<V> get values => _iterable().map((e) => e.value);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Map<K2, V2> map<K2, V2>(Object transform(K key, V value)) {
    // Change Object to MapEntry<K2, V2> when
    // the MapEntry class has been added.
    throw new UnimplementedError("map");
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

  /// Look up the value associated with [key], or add a new value if it isn't
  /// there. The pair is promoted to the MRU position.
  ///
  /// Otherwise calls [ifAbsent] to get a new value, associates [key] to that
  /// [value], and then returns the new [value], with the key-value pair in the
  /// MRU position. If this causes [length] to exceed [maximumSize], then the
  /// LRU position is removed.
  @override
  V putIfAbsent(K key, V ifAbsent()) {
    final entry =
        _entries.putIfAbsent(key, () => _createEntry(key, ifAbsent()));
    if (length > maximumSize) {
      _removeLru();
    }
    _promoteEntry(entry);
    return entry.value;
  }

  /// Get the value for a [key] in the [Map]. The [key] will be promoted to the
  /// 'Most Recently Used' position. *NOTE*: Calling [] inside an iteration
  /// over keys/values is currently unsupported; use [keys] or [values] if you
  /// need information about entries without modifying their position.
  @override
  V operator [](Object key) {
    final entry = _entries[key];
    if (entry != null) {
      _promoteEntry(entry);
      return entry.value;
    } else {
      return null;
    }
  }

  /// If [key] already exists, promotes it to the MRU position & assigns
  /// [value].
  ///
  /// Otherwise, adds [key] and [value] to the MRU position.  If [length]
  /// exceeds [maximumSize] while adding, removes the LRU position.
  @override
  void operator []=(K key, V value) {
    // Add this item to the MRU position.
    _insertMru(_createEntry(key, value));

    // Remove the LRU item if the size would be exceeded by adding this item.
    if (length > maximumSize) {
      assert(length == maximumSize + 1);
      _removeLru();
    }
  }

  @override
  V remove(Object key) {
    final entry = _entries.remove(key);
    if (entry != null) {
      if (entry == _head && entry == _tail) {
        _head = _tail = null;
      } else if (entry == _head) {
        _head = _head.next;
        _head?.previous = null;
      } else if (entry == _tail) {
        _tail = _tail.previous;
        _tail?.next = null;
      } else {
        entry.previous.next = entry.next;
        entry.next.previous = entry.previous;
      }
      return entry.value;
    }
    return null;
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  void removeWhere(bool test(K key, V value)) {
    throw new UnimplementedError("removeWhere");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  LinkedLruHashMap<K2, V2> retype<K2, V2>() {
    throw new UnimplementedError("retype");
  }

  @override
  // TODO: Use the `MapBase.mapToString()` static method when the minimum SDK
  // version of this package has been bumped to 2.0.0 or greater.
  String toString() {
    // Detect toString() cycles.
    if (_isToStringVisiting(this)) {
      return '{...}';
    }

    var result = new StringBuffer();
    try {
      _toStringVisiting.add(this);
      result.write('{');
      bool first = true;
      forEach((k, v) {
        if (!first) {
          result.write(', ');
        }
        first = false;
        result.write('$k: $v');
      });
      result.write('}');
    } finally {
      assert(identical(_toStringVisiting.last, this));
      _toStringVisiting.removeLast();
    }

    return result.toString();
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

  /// Moves [entry] to the MRU position, shifting the linked list if necessary.
  void _promoteEntry(_LinkedEntry<K, V> entry) {
    // If this entry is already in the MRU position we are done.
    if (entry == _head) {
      return;
    }

    if (entry.previous != null) {
      // If already existed in the map, link previous to next.
      entry.previous.next = entry.next;

      // If this was the tail element, assign a new tail.
      if (_tail == entry) {
        _tail = entry.previous;
      }
    }
    // If this entry is not the end of the list then link the next entry to the previous entry.
    if (entry.next != null) {
      entry.next.previous = entry.previous;
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

  /// Creates and returns an entry from [key] and [value].
  _LinkedEntry<K, V> _createEntry(K key, V value) {
    return new _LinkedEntry<K, V>(key, value);
  }

  /// If [entry] does not exist, inserts it into the backing map.  If it does,
  /// replaces the existing [_LinkedEntry.value] with [entry.value].  Then, in
  /// either case, promotes [entry] to the MRU position.
  void _insertMru(_LinkedEntry<K, V> entry) {
    // Insert a new entry if necessary (only 1 hash lookup in entire function).
    // Otherwise, just updates the existing value.
    final value = entry.value;
    _promoteEntry(_entries.putIfAbsent(entry.key, () => entry)..value = value);
  }

  /// Removes the LRU position, shifting the linked list if necessary.
  void _removeLru() {
    // Remove the tail from the internal map.
    _entries.remove(_tail.key);

    // Remove the tail element itself.
    _tail = _tail.previous;
    _tail.next = null;
  }
}

/// A collection used to identify cyclic maps during toString() calls.
final List _toStringVisiting = [];

/// Check if we are currently visiting `o` in a toString() call.
bool _isToStringVisiting(o) => _toStringVisiting.any((e) => identical(o, e));

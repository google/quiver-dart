// Copyright 2019 Google Inc. All Rights Reserved.
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

/// An implementation of [LruMap] that implements a simple Time Based Least
/// Recently Used collection that removes items not only based on a
/// [maximumSize] but also based on the expiration times [expireAfterAccess]
/// and [expireAfterWrite].
///
/// More specifically:
/// - [expireAfterAccess] specifies the time to expire items that have not been
/// accessed (by read or write operations).
/// - [expireAfterWrite] specifies the time to expire items that have not been
/// created or overwritten
///
/// When [expireAfterAccess] or [expireAfterWrite] is specified, entries may
/// be evicted on read or write operations or upon calls to [cleanUp]. This
/// internal maintenance has some overhead so it is not done on all operations.
/// Notice that operations such as [length] may not seem to behave as expected
/// if some entries are expiring but not yet removed.
///
/// Note that [expireAfterAccess] correlates directly to the underlying
/// MRU/LRU order so logic shortcuts are possible. However, when
/// [expireAfterWrite] is enabled, the [cleanUp] operation must visit all
/// entries because it's possible for some entries to be actively used but
/// still expire based on the most recent write operation.
///
/// _The documentation for [LinkedTlruHashMap] has more details about which
/// methods call [cleanUp] or cause access times to be updated._
abstract class TlruMap<K, V> extends LruMap<K, V> {
  /// Creates a [TlruMap] instance with a default configuration.
  factory TlruMap(
      {int maximumSize,
      Duration expireAfterAccess,
      Duration expireAfterWrite,
      Clock clock}) = LinkedTlruHashMap<K, V>;

  /// Removes all expired entries. If [updateLastAccess] is `true` the last
  /// access times for any remaining entries are updated on the same
  /// iteration pass (while keys are iterated for expiration consideration).
  int cleanUp([bool updateLastAccess = false]);
}

/// A subclass of [_LinkedEntry] that adds time tracking properties.
class _ExpiringLinkedEntry<K, V> extends _LinkedEntry<K, V> {
  _ExpiringLinkedEntry(Clock clock, key, value) : super(key, value) {
    final now = clock.now();
    lastWrite = now;
    lastAccess = now;
  }

  /// Last time the entry was created (or written).
  DateTime lastWrite;

  /// Last time the entry was accessed.
  DateTime lastAccess;

  @override
  String toString() {
    return '_ExpiringLinkedEntry{key: $key, value: $value, '
        'lastWrite: $lastWrite, lastAccess: $lastAccess}';
  }
}

/// An implementation of [TlruMap]. This implementation calls [cleanUp] for
/// several collection operations so the expired entries are removed.
///
/// _See method descriptions for more details about which methods perform
/// [cleanUp] or cause the access time to be updated._
class LinkedTlruHashMap<K, V> extends LinkedLruHashMap<K, V>
    implements TlruMap<K, V> {
  /// Create a new [LinkedTlruHashMap].
  factory LinkedTlruHashMap(
          {int maximumSize,
          Duration expireAfterAccess = _defaultExpireAfterAccess,
          Duration expireAfterWrite = _defaultExpireAfterWrite,
          Clock clock = const Clock()}) =>
      LinkedTlruHashMap._fromMap(HashMap<K, _LinkedEntry<K, V>>(),
          maximumSize: maximumSize,
          expireAfterAccess: expireAfterAccess,
          expireAfterWrite: expireAfterWrite,
          clock: clock);

  /// Create a new [LinkedTlruHashMap] from existing [entries].
  LinkedTlruHashMap._fromMap(Map<K, _LinkedEntry<K, V>> entries,
      {int maximumSize,
      this.expireAfterAccess = _defaultExpireAfterAccess,
      this.expireAfterWrite = _defaultExpireAfterWrite,
      final clock = const Clock()})
      : _clock = clock,
        super._fromMap(entries, maximumSize: maximumSize) {
    if (expireAfterWrite != null &&
        expireAfterAccess != null &&
        expireAfterWrite.compareTo(expireAfterAccess) <= 0) {
      // when both are set, the write expiration should be greater than the
      // access expiration, otherwise the write expiration would always cause
      // expiration before access expiration. In that case we might as well
      // not check the access expiration (make it null).
      throw ArgumentError('When both are specified, expireAfterWrite'
          '( $expireAfterWrite ) must be greater than expireAfterAccess'
          '( $expireAfterAccess )');
    }
  }

  /// The clock used for time operations (mostly helps with testing).
  final Clock _clock;

  /// When not `null`, specifies the time after which eviction can be performed
  /// on expired entries when an access operation occurs.
  final Duration expireAfterAccess;
  static const _defaultExpireAfterAccess = null;

  /// When not `null`, specifies the time after which eviction can be performed
  /// on expired entries when a write operation occurs.
  final Duration expireAfterWrite;
  static const _defaultExpireAfterWrite = null;

  /// Returns an entry as a [_ExpiringLinkedEntry]. All entries should be of
  /// this type because [_createEntry] returns entries of this type.
  static _ExpiringLinkedEntry<K, V> _downcastEntry<K, V>(
      _LinkedEntry<K, V> entry) {
    if (entry != null && entry is _ExpiringLinkedEntry) {
      return entry;
    }
    return null;
  }

  /// Try to expire an entry based on the [expireAfterAccess] duration and
  /// last access time or [expireAfterWrite] and last write time.
  /// When [updateLastAccess] is `true`, the last access time will be updated
  /// if the entry did not expire.
  /// Returns `true` if the [key] was removed, `false` otherwise.
  bool _tryToExpireEntry(K key, [bool updateLastAccess = false]) {
    bool didExpire = false;

    final expiringEntry = _downcastEntry(_entries[key]);
    if (expiringEntry != null) {
      final now = _clock.now();

      // first try to expire by last access time
      if (expireAfterAccess != null) {
        final elapsed = now.difference(expiringEntry.lastAccess);
        if (elapsed.compareTo(expireAfterAccess) >= 0) {
          didExpire = true;
        }
      }

      // if nothing expired yet then try to expire by last write time
      if (!didExpire && expireAfterWrite != null) {
        final elapsed = now.difference(expiringEntry.lastWrite);
        if (elapsed.compareTo(expireAfterWrite) >= 0) {
          didExpire = true;
        }
      }

      if (didExpire) {
        // remove the expired entry
        remove(key);
      } else if (updateLastAccess) {
        // if not expired then update the last access time (if requested)
        expiringEntry.lastAccess = now;
      }
    }

    return didExpire;
  }

  /// Overrides [LinkedLruHashMap._createEntry] to create and return a new
  /// [_ExpiringLinkedEntry] for the [key] and [value].
  @override
  _LinkedEntry<K, V> _createEntry(K key, V value) {
    return _ExpiringLinkedEntry<K, V>(_clock, key, value);
  }

  /// Update lastWrite when entries are inserted in case it was an "update"
  /// and not a "create" operation internally. If it was a "create" the new
  /// entry will already have updated times. If it was an "update" the entry
  /// will have an updated lastAccess because of [_promoteEntry] so we just
  /// need to make sure the lastWrite is equal to lastAccess after the super
  /// operation completes.
  @override
  void _insertMru(_LinkedEntry<K, V> entry) {
    // do the create or update logic
    super._insertMru(entry);

    // update lastWrite time in the instance of `entry` that made it into the
    // `_entries` (which may not be this `entry` instance if the key exists.
    final expiringEntry = _downcastEntry(_entries[entry.key]);
    if (expiringEntry != null) {
      expiringEntry.lastWrite = _clock.now();
    }
  }

  /// Update lastAccess time when entries are promoted (recently used).
  /// This covers cases such as `putIfAbsent` or similar in the future even
  /// though other overloads may already do this as part of their logic. In
  /// such cases the other overloads may have additional work to do or might
  /// be accessed from other routes, so we can't really avoid it.
  @override
  void _promoteEntry(_LinkedEntry<K, V> entry) {
    super._promoteEntry(entry);

    final expiringEntry = _downcastEntry(entry);
    if (expiringEntry != null) {
      expiringEntry.lastAccess = _clock.now();
    }
  }

  /// Removes all expired entries. If [updateLastAccess] is `true` the last
  /// access times for any remaining entries are updated on the same
  /// iteration pass (while keys are iterated for expiration consideration).
  @override
  int cleanUp([bool updateLastAccess = false]) {
    // no work to do if the map is empty
    // (and also verifies we have a valid _tail for other logic)
    if (_tail == null) {
      return 0;
    }

    // can we avoid the extra overhead of expiring by lastWrite?
    final doAccessShortcuts =
        expireAfterAccess != null && expireAfterWrite == null;

    // rationalizing short-circuiting when expiring only by access time:
    // - Entries are already stored from MRU to LRU internally
    // - MRU/LRU correlates directly to access times
    // - The tail entry has the oldest lastAccess time
    // - If we're only expiring by lastAccess we don't have to worry about
    //   finding more recently used entries that have expired due to lastWrite

    if (doAccessShortcuts) {
      // If the tail entry has not expired then there is no work to do
      final expiringEntry = _downcastEntry(_tail);
      final tailElapsed = _clock.now().difference(expiringEntry.lastAccess);
      if (tailElapsed.compareTo(expireAfterAccess) < 0) {
        return 0;
      }
    }

    // iterate from oldest access to latest access (LRU to MRU) and
    // use a copy so we're not removing from the collection while iterating
    final iterator =
        GeneratingIterable<_LinkedEntry<K, V>>(() => _tail, (n) => n.previous)
            .map((e) => e.key)
            .toList(growable: false)
            .iterator;

    int expiredCount = 0;
    while (iterator.moveNext()) {
      final key = iterator.current;
      if (_tryToExpireEntry(key, updateLastAccess)) {
        // keep count of how many entries expired
        expiredCount++;
      } else if (doAccessShortcuts) {
        // when only expiring by access we can stop as soon as we see an
        // entry that does not expire (since we're iterating from LRU to MRU)
        break;
      }
    }

    return expiredCount;
  }

  /// Returns the value for the given [key] or `null` if the entry is not in
  /// the map or has expired.
  ///
  /// This operation **does update** the last access time for the entry.
  @override
  V operator [](Object key) {
    // try to expire and update last access time if not expired
    if (_tryToExpireEntry(key, true)) {
      return null;
    }
    return super[key];
  }

  /// Returns `true` if this map contains the given [key], `false` otherwise
  /// or if the entry has expired.
  ///
  /// This operation **does not update** the last access time for the entry.
  @override
  bool containsKey(Object key) {
    // try to expire but do not touch last access times
    if (_tryToExpireEntry(key, false)) {
      return false;
    }
    return super.containsKey(key);
  }

  /// Returns the list of entries in the Map.
  ///
  /// This operation calls [cleanUp] and **updates** the last access times.
  @override
  Iterable<MapEntry<K, V>> get entries {
    // remove expired entries and update last access time for any that remain
    cleanUp(true);
    return super.entries;
  }

  /// Applies [action] to each key/value pair of the map.
  ///
  /// This operation calls [cleanUp] and **updates** the last access times.
  @override
  void forEach(void action(K key, V value)) {
    // remove expired entries and update last access time for any that remain
    cleanUp(true);
    super.forEach(action);
  }

  /// Returns a new map where all entries of this map are transformed by
  /// the given [transform] function.
  ///
  /// This operation calls [cleanUp] and **updates** the last access times.
  @override
  Map<K2, V2> map<K2, V2>(Object transform(K key, V value)) {
    // remove expired entries and update last access time for any that remain
    cleanUp(true);
    return super.map(transform);
  }

  /// Returns the values for this collection.
  ///
  /// This operation calls [cleanUp] and **does not update** the last access
  /// times.
  @override
  Iterable<K> get keys {
    // remove expired entries and update last access time for any that remain
    cleanUp(false);
    return super.keys;
  }

  /// Returns the values for this collection.
  ///
  /// This operation calls [cleanUp] and **updates** the last access times.
  @override
  Iterable<V> get values {
    // remove expired entries and update last access time for any that remain
    cleanUp(true);
    return super.values;
  }
}

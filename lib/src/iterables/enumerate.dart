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

part of quiver.iterables;

/// Returns an [Iterable] of [IndexedValue]s where the nth value holds the nth
/// element of [iterable] and its index.
Iterable<IndexedValue<E>> enumerate<E>(Iterable<E> iterable) =>
    new EnumerateIterable<E>(iterable);

class IndexedValue<V> {
  final int index;
  final V value;

  IndexedValue(this.index, this.value);

  operator ==(o) => o is IndexedValue && o.index == index && o.value == value;
  int get hashCode => index * 31 + value.hashCode;
  String toString() => '($index, $value)';
}

/// An [Iterable] of [IndexedValue]s where the nth value holds the nth
/// element of [iterable] and its index. See [enumerate].
// This was inspired by MappedIterable internal to Dart collections.
class EnumerateIterable<V> extends IterableBase<IndexedValue<V>> {
  final Iterable<V> _iterable;

  EnumerateIterable(this._iterable);

  Iterator<IndexedValue<V>> get iterator =>
      new EnumerateIterator<V>(_iterable.iterator);

  // Length related functions are independent of the mapping.
  int get length => _iterable.length;
  bool get isEmpty => _iterable.isEmpty;

  // Index based lookup can be done before transforming.
  IndexedValue<V> get first => new IndexedValue<V>(0, _iterable.first);
  IndexedValue<V> get last => new IndexedValue<V>(length - 1, _iterable.last);
  IndexedValue<V> get single => new IndexedValue<V>(0, _iterable.single);
  IndexedValue<V> elementAt(int index) =>
      new IndexedValue<V>(index, _iterable.elementAt(index));
}

/// The [Iterator] returned by [EnumerateIterable.iterator].
class EnumerateIterator<V> extends Iterator<IndexedValue<V>> {
  final Iterator<V> _iterator;
  int _index = 0;
  IndexedValue<V> _current;

  EnumerateIterator(this._iterator);

  IndexedValue<V> get current => _current;

  bool moveNext() {
    if (_iterator.moveNext()) {
      _current = new IndexedValue(_index++, _iterator.current);
      return true;
    }
    _current = null;
    return false;
  }
}

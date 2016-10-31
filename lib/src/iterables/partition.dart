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

part of quiver.iterables;

/// Partitions the input iterable into lists of the specified size.
Iterable<List> partition(Iterable iterable, int size) {
  return iterable.isEmpty ? [] : new _Partition(iterable, size);
}

class _Partition extends IterableBase<List> {
  final Iterable _iterable;
  final int _size;

  _Partition(this._iterable, this._size) {
    if (_size <= 0) throw new ArgumentError(_size);
  }

  Iterator<List> get iterator =>
      new _PartitionIterator(_iterable.iterator, _size);
}

class _PartitionIterator implements Iterator<List> {
  final Iterator _iterator;
  final int _size;
  List _current;

  _PartitionIterator(this._iterator, this._size);

  @override
  List get current => _current;

  @override
  bool moveNext() {
    var newValue = [];
    var count = 0;
    for (; count < _size && _iterator.moveNext(); count++) {
      newValue.add(_iterator.current);
    }
    _current = (count > 0) ? newValue : null;
    return _current != null;
  }
}

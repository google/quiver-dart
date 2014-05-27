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

/**
 * Returns an [Iterable] of first item in each iterable, then the second etc. The
 * returned [Iterable] contains number of elements in the shortest [Iterable] times number of
 * [iterables]. If [iterables] is empty, it returns an empty list.
 */
Iterable interleave(Iterable<Iterable> iterables) =>
    (iterables.isEmpty) ? const [] : new _Interleave(iterables);

class _Interleave extends IterableBase {
  final Iterable<Iterable> _iterables;

  _Interleave(this._iterables);

  Iterator get iterator =>
      new _InterleaveIterator(
          _iterables.map((i) => i.iterator).toList(growable: false));

  String toString() => this.toList().toString();
}

class _InterleaveIterator implements Iterator {
  final List<Iterator> _iterators;
  int _iteratorIndex = 0;
  var _current;

  _InterleaveIterator(List<Iterator> this._iterators);

  get current => _current;

  bool moveNext() {
    bool hasNext = true;
    if (_iteratorIndex == 0) {
      for (int i = 0; i < _iterators.length; i++) {
        hasNext = hasNext && _iterators[i].moveNext();
      }
    }
    _current = _iterators[_iteratorIndex].current;
    _iteratorIndex = (_iteratorIndex + 1) % _iterators.length;
    return hasNext;
  }
}

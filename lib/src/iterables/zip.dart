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
 * Returns an [Iterable] of [List]s where the nth element in the returned
 * iterable contains the nth element from every Iterable in [iterables]. The
 * returned Iterable is as long as the shortest Iterable in the argument. If
 * [iterables] is empty, it returns an empty list.
 */
Iterable<List> zip(Iterable<Iterable> iterables) =>
    (iterables.isEmpty) ? const [] : new _Zip(iterables);

class _Zip extends IterableBase<List> {
  final Iterable<Iterable> iterables;

  _Zip(Iterable<Iterable> this.iterables);

  Iterator<List> get iterator =>
      new _ZipIterator(iterables.map((i) => i.iterator).toList(growable: false));
}

class _ZipIterator implements Iterator<List> {
  final List<Iterator> _iterators;
  List _current;

  _ZipIterator(List<Iterator> this._iterators);

  List get current => _current;

  bool moveNext() {
    bool hasNext = true;
    var newValue = new List(_iterators.length);
    for (int i = 0; i < _iterators.length; i++) {
      var iter = _iterators[i];
      hasNext = hasNext && iter.moveNext();
      newValue[i] = iter.current;
    }
    _current = (hasNext) ? newValue : null;
    return hasNext;
  }
}

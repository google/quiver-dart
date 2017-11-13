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

/// Returns the result of merging an [Iterable] of [Iterable]s, according to
/// the order specified by the [compare] function. This function assumes the
/// provided iterables are already sorted according to the provided [compare]
/// function. It will not check for this condition or sort the iterables.
///
/// The compare function must act as a [Comparator]. If [compare] is omitted,
/// [Comparable.compare] is used.
///
/// If any of the [iterables] contain null elements, an exception will be
/// thrown.
Iterable<T> merge<T>(Iterable<Iterable<T>> iterables,
        [Comparator<T> compare]) =>
    iterables.isEmpty
        ? const <Null>[]
        : new _Merge<T>(iterables, compare ?? Comparable.compare);

class _Merge<T> extends IterableBase<T> {
  final Iterable<Iterable<T>> _iterables;
  final Comparator<T> _compare;

  _Merge(this._iterables, this._compare);

  Iterator<T> get iterator => new _MergeIterator<T>(
      _iterables.map((i) => i.iterator).toList(growable: false), _compare);

  String toString() => this.toList().toString();
}

/// Like [Iterator] but one element ahead.
class _IteratorPeeker<T> {
  final Iterator<T> _iterator;
  bool _hasCurrent;

  _IteratorPeeker(Iterator<T> iterator)
      : _iterator = iterator,
        _hasCurrent = iterator.moveNext();

  void moveNext() {
    _hasCurrent = _iterator.moveNext();
  }

  T get current => _iterator.current;
}

class _MergeIterator<T> implements Iterator<T> {
  final List<_IteratorPeeker<T>> _peekers;
  final Comparator<T> _compare;
  T _current;

  _MergeIterator(List<Iterator<T>> iterators, this._compare)
      : _peekers = iterators.map((i) => new _IteratorPeeker(i)).toList();

  bool moveNext() {
    // Pick the peeker that's peeking at the puniest piece
    _IteratorPeeker<T> minIter = null;
    for (var p in _peekers) {
      if (p._hasCurrent) {
        if (minIter == null || _compare(p.current, minIter.current) < 0) {
          minIter = p;
        }
      }
    }

    if (minIter == null) {
      return false;
    }
    _current = minIter.current;
    minIter.moveNext();
    return true;
  }

  T get current => _current;
}

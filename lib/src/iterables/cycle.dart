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

/// Returns an [Iterable] that infinitely cycles through the elements of
/// [iterable]. If [iterable] is empty, the returned Iterable will also be empty.
Iterable<T> cycle<T>(Iterable<T> iterable) => new _Cycle<T>(iterable);

class _Cycle<T> extends InfiniteIterable<T> {
  final Iterable<T> _iterable;

  _Cycle(this._iterable);

  Iterator<T> get iterator => new _CycleIterator(_iterable);

  bool get isEmpty => _iterable.isEmpty;

  bool get isNotEmpty => _iterable.isNotEmpty;

  // TODO(justin): add methods that can be answered by the wrapped iterable
}

class _CycleIterator<T> implements Iterator<T> {
  final Iterable<T> _iterable;
  Iterator<T> _iterator;

  _CycleIterator(Iterable<T> _iterable)
      : _iterable = _iterable,
        _iterator = _iterable.iterator;

  T get current => _iterator.current;

  bool moveNext() {
    if (!_iterator.moveNext()) {
      _iterator = _iterable.iterator;
      return _iterator.moveNext();
    }
    return true;
  }
}

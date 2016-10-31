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

/// Returns an infinite [Iterable] of [num]s, starting from [start] and
/// increasing by [step].
Iterable<num> count([num start = 0, num step = 1]) => new _Count(start, step);

class _Count extends InfiniteIterable<num> {
  final num start, step;

  _Count(num this.start, num this.step);

  Iterator<num> get iterator => new _CountIterator(start, step);

  // TODO(justin): return an infinite list for toList() and a special Set
  // implmentation for toSet()?
}

class _CountIterator implements Iterator<num> {
  final num _start, _step;
  num _current;

  _CountIterator(num this._start, this._step);

  num get current => _current;

  bool moveNext() {
    _current = (_current == null) ? _start : _current + _step;
    return true;
  }
}

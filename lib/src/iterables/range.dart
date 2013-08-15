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
 * Returns an [Iterable] sequence of [num]s.
 *
 * If only one argument is provided, [start_or_stop] is the upper bound for the
 * sequence. If two or more arguments are provided, [stop] is the upper bound.
 *
 * The sequence starts at 0 if one argument is provided, or [start_or_stop] if
 * two or more arguments are provided. The sequence increments by 1, or [step]
 * if provided. [step] can be negative, in which case the sequence counts down
 * from the starting point and [stop] must be less than the starting point so
 * that it becomes the lower bound.
 */
Iterable<num> range(num start_or_stop, [num stop, num step]) =>
    new _Range(start_or_stop, stop, step);

class _Range extends IterableBase<num> {
  final num start, stop, step;

  _Range(num start_or_stop, num _stop, num _step)
      : start = (_stop == null) ? 0 : start_or_stop,
        stop = (_stop == null) ? start_or_stop : _stop,
        step = (_step == null) ? 1 : _step
  {
    if (step == 0) {
      throw new ArgumentError("step cannot be 0");
    }
    if ((step > 0) && (stop < start)) {
      throw new ArgumentError("if step is positive,"
          " stop must be greater than start");
    }
    if ((step < 0) && (stop > start)) {
      throw new ArgumentError("if step is negative,"
          " stop must be less than start");
    }
  }

  Iterator<num> get iterator => new _RangeIterator(start, stop, step);
}

class _RangeIterator implements Iterator<num> {
  final num _stop, _step;
  num _value;
  bool _hasNext;
  bool _inRange;

  _RangeIterator(num start, num stop, this._step)
      : _value = start,
        _stop = stop,
        _hasNext = true,
        _inRange = false;

  num get current => _inRange ? _value : null;

  bool moveNext() {
    if (_hasNext && _inRange) _value += _step;
    _inRange = _hasNext = (_step > 0) ? (_value < _stop) : (_value > _stop);
    return _hasNext;
  }
}

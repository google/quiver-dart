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
Iterable<num> range(num start_or_stop, [num stop, num step]) {
  var start = (stop == null) ? 0 : start_or_stop;
  stop = (stop == null) ? start_or_stop : stop;
  step = (step == null) ? 1 : step;
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
  return _range(start, stop, step);
}

Iterable<num> _range(num start, num stop, num step) sync* {
  while (step < 0 ? start > stop : start < stop) {
    yield start;
    start += step;
  }
}

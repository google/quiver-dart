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

part of quiver.compare;

/**
 * Tests if [iterable] is in increasing order.
 */
bool isOrdered(
    Iterable iterable,
    {Comparator compare : Comparable.compare}) =>
    _isOrdered(iterable, compare, (v) => v > 0);

/**
 * Tests if [iterable] is in strict increasing order.
 */
bool isStrictlyOrdered(
    Iterable iterable,
    {Comparator compare : Comparable.compare}) =>
  _isOrdered(iterable, compare, (v) => v >= 0);

bool _isOrdered(
    Iterable iterable,
    Comparator compare,
    bool ordered(comaratorResult)) {
  var iterator = iterable.iterator;
  if (iterator.moveNext()) {
    var previous = iterator.current;
    while (iterator.moveNext()) {
      if (ordered(compare(previous, iterator.current))) {
        return false;
      }
      previous = iterator.current;
    }
  }
  return true;
}

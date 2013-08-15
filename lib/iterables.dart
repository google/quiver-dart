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

library quiver.iterables;

import 'dart:collection';

part 'src/iterables/count.dart';
part 'src/iterables/cycle.dart';
part 'src/iterables/enumerate.dart';
part 'src/iterables/infinite_iterable.dart';
part 'src/iterables/range.dart';
part 'src/iterables/zip.dart';

int _compare(a, b) => a.compareTo(b);

Object max(Iterable i, [Comparator compare = _compare]) =>
    i.reduce((a, b) => compare(a, b) > 0 ? a : b);

Object min(Iterable i, [Comparator compare = _compare]) =>
    i.reduce((a, b) => compare(a, b) < 0 ? a : b);

Extant extant(Iterable i, [Comparator compare = _compare]) {
  var iterator = i.iterator;
  var hasNext = iterator.moveNext();
  if (!hasNext) return new Extant(null, null);
  var max = iterator.current;
  var min = iterator.current;
  while (iterator.moveNext()) {
    if (compare(max, iterator.current) > 0) max = iterator.current;
    if (compare(min, iterator.current) < 0) min= iterator.current;
  }
  return new Extant(min, max);
}

class Extant {
  final min;
  final max;
  Extant(this.min, this.max);
}

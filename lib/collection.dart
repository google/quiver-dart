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

/// Collection classes and related utilities.
library quiver.collection;

import 'dart:collection';
import 'dart:math';

import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';

part 'src/collection/bimap.dart';
part 'src/collection/lru_map.dart';
part 'src/collection/multimap.dart';
part 'src/collection/treeset.dart';
part 'src/collection/delegates/iterable.dart';
part 'src/collection/delegates/list.dart';
part 'src/collection/delegates/map.dart';
part 'src/collection/delegates/queue.dart';
part 'src/collection/delegates/set.dart';

/// Checks [List]s [a] and [b] for equality.
///
/// Returns `true` if [a] and [b] are both null, or they are the same length
/// and every element of [a] is equal to the corresponding element at the same
/// index in [b].
bool listsEqual(List a, List b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }

  return true;
}

/// Checks [Map]s [a] and [b] for equality.
///
/// Returns `true` if [a] and [b] are both null, or they are the same length
/// and every key `k` in [a] exists in [b] and the values `a[k] == b[k]`.
bool mapsEqual(Map a, Map b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (var k in a.keys) {
    var bValue = b[k];
    if (bValue == null && !b.containsKey(k)) return false;
    if (bValue != a[k]) return false;
  }

  return true;
}

/// Checks [Set]s [a] and [b] for equality.
///
/// Returns `true` if [a] and [b] are both null, or they are the same length and
/// every element in [b] exists in [a].
bool setsEqual(Set a, Set b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  return a.containsAll(b);
}

/// Returns the index of the first item in [elements] where [predicate]
/// evaluates to true.
///
/// Returns -1 if there are no items where [predicate] evaluates to true.
int indexOf<T>(Iterable<T> elements, bool predicate(T element)) {
  if (elements is List<T>) {
    for (int i = 0; i < elements.length; i++) {
      if (predicate(elements[i])) return i;
    }
    return -1;
  }

  int i = 0;
  for (T element in elements) {
    if (predicate(element)) return i;
    i++;
  }
  return -1;
}

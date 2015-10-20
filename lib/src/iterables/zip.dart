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
Iterable<List> zip(Iterable<Iterable> iterables) sync* {
  if (iterables.isEmpty) return;
  var iterators = iterables.map((i) => i.iterator).toList(growable: false);
  while (true) {
    var zipped = new List(iterators.length);
    for (var i = 0; i < zipped.length; i++) {
      if (!iterators[i].moveNext()) return;
      zipped[i] = iterators[i].current;
    }
    yield zipped;
  }
}

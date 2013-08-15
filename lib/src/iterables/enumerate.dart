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
 * Returns an [Iterable] of [IndexedValue]s where the nth value holds the nth
 * element of [iterable] and its index.
 */
Iterable<IndexedValue> enumerate(Iterable iterable) {
  int i = 0;
  return iterable.map((e) => new IndexedValue(i++, e));
}

class IndexedValue<V> {
  final int index;
  final V value;

  IndexedValue(this.index, this.value);
}

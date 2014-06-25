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

library quiver.collection.heap_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('MinHeap', () {
    test('should be a list-backed min heap', () {
      var map = new MinHeap();
      expect(map is ListMinHeap, true);
    });
  });

  group('ListMinHeap', () {
    test('should initialize empty', () {
      var map = new ListMinHeap();
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
    });

    test('should not be empty after adding', () {
      var map = new ListMinHeap<String>()..add('v');
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
    });

    test('should return the number of values as length', () {
      var map = new ListMinHeap<String>();
      expect(map.length, 0);
      map
        ..add('v1')
        ..add('v2')
        ..add('v3');
      expect(map.length, 3);
    });
  });

  group('heapSort', () {
    test('should support weird inputs', () {
      expect(heapSort([]), []);
      expect(heapSort(["a"]), ["a"]);
      // TODO(ochafik): Have [Comparable.compare] to support nulls?
      // expect(heapSort([null]), [null]);
      // expect(heapSort([null, null]), [null, null]);
      // expect(heapSort(["a", null]), ["a", null]);
    });
    test('should sort different values', () {
      expect(heapSort(["a", "b"]), ["a", "b"]);
      expect(heapSort(["b", "a"]), ["a", "b"]);
      expect(heapSort(["a", "b", "c"]), ["a", "b", "c"]);
      expect(heapSort(["a", "c", "b"]), ["a", "b", "c"]);
      expect(heapSort(["c", "b", "a"]), ["a", "b", "c"]);
      expect(heapSort(["d", "c", "b", "a"]), ["a", "b", "c", "d"]);
      expect(heapSort(["e", "d", "c", "b", "a"]), ["a", "b", "c", "d", "e"]);
      expect(heapSort(["f", "e", "d", "c", "b", "a"]), ["a", "b", "c", "d", "e", "f"]);
    });
    test('should respect duplicates values', () {
      expect(heapSort(["a", "a", "b"]), ["a", "a", "b"]);
      expect(heapSort(["a", "b", "a"]), ["a", "a", "b"]);
      expect(heapSort(["b", "b", "a"]), ["a", "b", "b"]);
    });
  });
}
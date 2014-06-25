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
import 'package:quiver/iterables.dart';

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
      map..add('v1')..add('v2')..add('v3');
      expect(map.length, 3);
      map..addAll(['v0']);
      expect(map.length, 4);
      
      map = new ListMinHeap<String>();
      map..addAll(['v1', 'v2', 'v3']);
      expect(map.length, 3);
    });

    test('should remove its min value', () {
      var map = new ListMinHeap<int>()..add(3)..add(1)..add(2);
      expect(map.removeMin(), 1);
      expect(map.removeMin(), 2);
      expect(map.removeMin(), 3);
      
      map = new ListMinHeap<int>()..addAll([3, 1, 2]);
      expect(map.removeAll(), [1, 2, 3]);
    });

    test('should return null / empty when removing from empty heap', () {
      var map = new ListMinHeap<int>();
      expect(map.removeMin(), null);
      expect(map.removeAll(), []);
    });
  });

  group('heapSort', () {
    test('should support empty or singleton inputs', () {
      expect(heapSort([]), []);
      expect(heapSort(["a"]), ["a"]);
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
    test('should handle sequences of arbitrary sizes', () {
      for (int i = 1; i < 100; i++) {
        // Sorted seq should be unchanged.
        var seq = range(0, i);
        expect(heapSort(seq), seq);

        // Reverse seq should be sorted.
        var rseq = range(i - 1, -1, -1);
        expect(heapSort(rseq), seq);
      }
    });
    test('should respect duplicates values', () {
      expect(heapSort(["a", "a", "b"]), ["a", "a", "b"]);
      expect(heapSort(["a", "b", "a"]), ["a", "a", "b"]);
      expect(heapSort(["b", "b", "a"]), ["a", "b", "b"]);
    });
  });
}
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

part of quiver.collection;

/**
 * Minimum heap.
 */
abstract class MinHeap<V> {
  Comparator<V> comparator;

  factory MinHeap({Comparator<V> comparator: Comparable.compare}) =>
      new ListMinHeap(comparator: comparator);

  MinHeap._(this.comparator);

  bool get isEmpty;
  bool get isNotEmpty;
  int get length;

  void add(V value);
  void addAll(Iterable<V> values);
  V min();
  V removeMin();
}

List heapSort(List items, {Comparator comparator: Comparable.compare}) {
  var heap = new MinHeap(comparator: comparator)..addAll(items);
  var n = items.length;
  var result = new List(n); // Avoid growing the list needlessly.
  for (int i = 0; i < n; i++) {
    assert(heap.isNotEmpty);
    result[i] = heap.removeMin();
  }
  assert(heap.isEmpty);
  return result;
}

class ListMinHeap<V> extends MinHeap<V> {
  final List<V> _values = [];

  ListMinHeap({Comparator<V> comparator: Comparable.compare}) : super._(comparator);
  
  @override bool get isEmpty => _values.isEmpty;
  @override bool get isNotEmpty => _values.isNotEmpty;
  @override int get length => _values.length;
    
  @override V min() {
    if (_values.isEmpty) {
      throw new Exception("Heap is empty!");
    }
    return _values[0];
  }

  @override V removeMin() {
    var value = min();
    var last = _values.removeLast();
    if (_values.isNotEmpty) {
      _values[0] = last;
      _bubbleDown(0);
    }
    return value;
  }

  @override void add(V value) {
    var values = _values;
    var index = values.length;
    values.add(value);
    _bubbleUp(index);
  }
  
  @override void addAll(Iterable<V> values) {
    if (values.isNotEmpty) {
      _values.addAll(values);
      for (var i = (_values.length / 2).floor(); i >= 0; i--) {
        _bubbleDown(i);
      }
    }
  }

  _bubbleUp(int i) {
    var values = _values;
    while (i > 0) {
      var j = i >> 1;
      if (comparator(values[j], values[i]) < 0) {
        return;
      }
      _swap(j, i);
      i = j;
    }
  }

  /// A.k.a heapify.
  _bubbleDown(int i) {
    var values = _values;
    var length = values.length;
    var halfLength = (length / 2).floor();
    while (i < halfLength) {
      var value = values[i];
      var offset = i * 2;
      var left = offset + 1;
      var right = offset + 2;
      if (left >= length) {
        // End case: child1 and child2 do not exist.
        return;
      }
      var leftValue = values[left];
      var moreThanChild1 = comparator(value, leftValue) > 0;
      var j;
      if (right >= length) {
        // End case: child2 does not exist.
        if (moreThanChild1) {
          j = left;
        }
      } else {
        var rightValue = values[right];
        if (moreThanChild1) {
          // value > leftValue
          j = comparator(leftValue, rightValue) < 0 ? left : right;
        } else {
          // value <= leftValue
          var moreThanChild2 = comparator(value, rightValue) > 0;
          if (moreThanChild2) {
            // rightValue < value <= leftValue
            j = right;
          }
        }
      }
      if (j == null) {
        // value < leftValue && value < rightValue
        return;
      }
      _swap(i, j);
      i = j;
    }
  }
  
  _swap(int i, int j) {
    var tmp = _values[i];
    _values[i] = _values[j];
    _values[j] = tmp;
  }
}

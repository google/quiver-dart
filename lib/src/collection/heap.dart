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
 * Minimum heap: data structure optimized to add comparable values in linear
 * time and continuously removing their minimum value in logarithmic time.
 * 
 * Uses the elements' natural ordering or a user-provided comparator.
 */
abstract class MinHeap<V> {
  Comparator<V> comparator;

  factory MinHeap({Comparator<V> comparator: Comparable.compare}) =>
      new ListMinHeap(comparator: comparator);

  MinHeap._(this.comparator);

  bool get isEmpty;
  bool get isNotEmpty;
  int get length;

  /**
   * Add a value to the heap. For bulk-adds, please prefer [addAll].
   * 
   * This has a complexity is `O(log(n))`, where n is [length].
   */
  void add(V value);

  /**
   * Add values to the heap.
   * 
   * This is the preferred way of addind multiple values to the heap: it has
   * a complexity of `O(n)` (where n is the final length of the heap), whereas
   * calling [add] repeatedly has a complexity of `O(n * log(n))`.
   */
  void addAll(Iterable<V> values);

  /**
   * Returns the smallest value, or null if [isEmpty].
   * 
   * This has a constant-time complexity.
   */
  V min();
  
  /**
   * Removes the smallest value and returns it, or returns null if [isEmpty].
   * 
   * This has a complexity of `O(log(n))`, where n is [length].
   */
  V removeMin();
  
  /**
   * Removes all the values using [removeMin] and returns a list of sorted values.
   * 
   * This has a complexity of `O(n * log(n))`, where n is [length].
   */
  List<V> removeAll();
}

/**
 * Sort items with a [MinHeap] using their natural ordering
 * (if they extend [Comparable]) or the provided comparator.
 * 
 * This has a complexity of `O(n * log(n))` where n is the number of items.
 */
List heapSort(Iterable items, {Comparator comparator: Comparable.compare}) =>
    (new MinHeap(comparator: comparator)..addAll(items)).removeAll();

/**
 * [List]-backed [MinHeap] implementation.
 * 
 * Assumes [List.removeLast] has a constant-time complexity.
 */
class ListMinHeap<V> extends MinHeap<V> {
  final List<V> _values = [];

  ListMinHeap({Comparator<V> comparator: Comparable.compare}) : super._(comparator);
  
  @override bool get isEmpty => _values.isEmpty;
  @override bool get isNotEmpty => _values.isNotEmpty;
  @override int get length => _values.length;
    
  @override V min() => _values.isEmpty ? null : _values.first;

  @override V removeMin() {
    if (_values.isEmpty) {
      return null;
    } else {
      var value = min();
      var last = _values.removeLast();
      if (_values.isNotEmpty) {
        _values[0] = last;
        _bubbleDown(0);
      }
      return value;
    }
  }
  
  /**
   * Removes all the values using [removeMin] and returns a list of sorted values.
   */ 
  List<V> removeAll() {
    var n = length;
    var result = new List(n); // Avoid growing the list needlessly.
    for (int i = 0; i < n; i++) {
      assert(isNotEmpty);
      result[i] = removeMin();
    }
    return result;
  }

  /// Logarithmic-time single-add.
  @override void add(V value) {
    var values = _values;
    var index = values.length;
    values.add(value);
    _bubbleUp(index);
  }
  
  /// Linear-time bulk-add.
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
        // End case: leftValue and rightValue do not exist.
        return;
      }
      var leftValue = values[left];
      var moreThanChild1 = comparator(value, leftValue) > 0;
      var j;
      if (right >= length) {
        // End case: rightValue does not exist.
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

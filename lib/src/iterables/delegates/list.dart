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
 * This class allows to implement [List] methods by delegating to a given
 * [List].
 * For instance you can create a FruitList like this :
 *
 *     class FruitList extends DelegatedList<Fruit> {
 *       final List<Fruit> fruits;
 *       FruitList() : this._([]);
 *       FruitList._(List<Fruit> fruits) :
 *         this.fruits = fruits,
 *         super(fruits);
 *
 *       // custom methods
 *     }
 */
class DelegatedList<E> extends DelegatedIterable<E> implements List<E> {
  final List<E> _delegate;

  DelegatedList(this._delegate) : super(this._delegate);

  E operator [](int index) => _delegate[index];

  void operator []=(int index, E value) {
    _delegate[index] = value;
  }

  void add(E value) => _delegate.add(value);

  void addAll(Iterable<E> iterable) => _delegate.addAll(iterable);

  Map<int, E> asMap() => _delegate.asMap();

  void clear() => _delegate.clear();

  void fillRange(int start, int end, [E fillValue]) =>
      _delegate.fillRange(start, end, fillValue);

  Iterable<E> getRange(int start, int end) => _delegate.getRange(start, end);

  int indexOf(E element, [int start = 0]) => _delegate.indexOf(element, start);

  void insert(int index, E element) => _delegate.insert(index, element);

  void insertAll(int index, Iterable<E> iterable) =>
      _delegate.insertAll(index, iterable);

  int lastIndexOf(E element, [int start]) =>
      _delegate.lastIndexOf(element, start);

  void set length(int newLength) {
    _delegate.length = newLength;
  }

  bool remove(Object value) => _delegate.remove(value);

  E removeAt(int index) => _delegate.removeAt(index);

  E removeLast() => _delegate.removeLast();

  void removeRange(int start, int end) => _delegate.removeRange(start, end);

  void removeWhere(bool test(E element)) => _delegate.removeWhere(test);

  void replaceRange(int start, int end, Iterable<E> iterable) =>
      _delegate.replaceRange(start, end, iterable);

  void retainWhere(bool test(E element)) => _delegate.retainWhere(test);

  Iterable<E> get reversed => _delegate.reversed;

  void setAll(int index, Iterable<E> iterable) =>
      _delegate.setAll(index, iterable);

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0])
      => _delegate.setRange(start, end, iterable, skipCount);

  void sort([int compare(E a, E b)]) => _delegate.sort(compare);

  List<E> sublist(int start, [int end]) => _delegate.sublist(start, end);
}

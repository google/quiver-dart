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

part of quiver.collection;

/// An implementation of [List] that delegates all methods to another [List].
/// For instance you can create a FruitList like this :
///
///     class FruitList extends DelegatingList<Fruit> {
///       final List<Fruit> _fruits = [];
///
///       List<Fruit> get delegate => _fruits;
///
///       // custom methods
///     }
abstract class DelegatingList<E> extends DelegatingIterable<E>
    implements List<E> {
  List<E> get delegate;

  E operator [](int index) => delegate[index];

  void operator []=(int index, E value) {
    delegate[index] = value;
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  List<E> operator +(List<E> other) {
    throw new UnimplementedError("+");
  }

  void add(E value) => delegate.add(value);

  void addAll(Iterable<E> iterable) => delegate.addAll(iterable);

  Map<int, E> asMap() => delegate.asMap();

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingList<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingList<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  void clear() => delegate.clear();

  void fillRange(int start, int end, [E fillValue]) =>
      delegate.fillRange(start, end, fillValue);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_setter
  void set first(E element) {
    if (this.isEmpty) throw new RangeError.index(0, this);
    this[0] = element;
  }

  Iterable<E> getRange(int start, int end) => delegate.getRange(start, end);

  int indexOf(E element, [int start = 0]) => delegate.indexOf(element, start);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  int indexWhere(bool test(E element), [int start = 0]) {
    throw new UnimplementedError("indexWhere");
  }

  void insert(int index, E element) => delegate.insert(index, element);

  void insertAll(int index, Iterable<E> iterable) =>
      delegate.insertAll(index, iterable);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_setter
  void set last(E element) {
    if (this.isEmpty) throw new RangeError.index(0, this);
    this[this.length - 1] = element;
  }

  int lastIndexOf(E element, [int start]) =>
      delegate.lastIndexOf(element, start);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  int lastIndexWhere(bool test(E element), [int start]) {
    throw new UnimplementedError("lastIndexWhere");
  }

  void set length(int newLength) {
    delegate.length = newLength;
  }

  bool remove(Object value) => delegate.remove(value);

  E removeAt(int index) => delegate.removeAt(index);

  E removeLast() => delegate.removeLast();

  void removeRange(int start, int end) => delegate.removeRange(start, end);

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void replaceRange(int start, int end, Iterable<E> iterable) =>
      delegate.replaceRange(start, end, iterable);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);

  Iterable<E> get reversed => delegate.reversed;

  void setAll(int index, Iterable<E> iterable) =>
      delegate.setAll(index, iterable);

  void setRange(int start, int end, Iterable<E> iterable,
          [int skipCount = 0]) =>
      delegate.setRange(start, end, iterable, skipCount);

  void shuffle([Random random]) => delegate.shuffle(random);

  void sort([int compare(E a, E b)]) => delegate.sort(compare);

  List<E> sublist(int start, [int end]) => delegate.sublist(start, end);
}

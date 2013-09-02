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

/**
 * An implementation of [Iterable] that delegates all methods to another
 * [Iterable].
 * For instance you can create a FruitIterable like this :
 *
 *     class FruitIterable extends DelegatingIterable<Fruit> {
 *       final Iterable<Fruit> _fruits = [];
 *
 *       Iterable<Fruit> get delegate => _fruits;
 *
 *       // custom methods
 *     }
 */
abstract class DelegatingIterable<E> implements Iterable<E> {
  Iterable<E> get delegate;

  bool any(bool test(element)) => delegate.any(test);

  bool contains(Object element) => delegate.contains(element);

  elementAt(int index) => delegate.elementAt(index);

  bool every(bool test(element)) => delegate.every(test);

  Iterable expand(Iterable f(element)) => delegate.expand(f);

  get first => delegate.first;

  firstWhere(bool test(element), {orElse()}) =>
      delegate.firstWhere(test, orElse: orElse);

  fold(initialValue, combine(previousValue, element)) =>
      delegate.fold(initialValue, combine);

  void forEach(void f(element)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterator get iterator => delegate.iterator;

  String join([String separator = ""]) => delegate.join(separator);

  get last => delegate.last;

  lastWhere(bool test(element), {orElse()}) =>
      delegate.lastWhere(test, orElse: orElse);

  int get length => delegate.length;

  Iterable map(f(element)) => delegate.map(f);

  reduce(combine(value, element)) => delegate.reduce(combine);

  get single => delegate.single;

  singleWhere(bool test(element)) => delegate.singleWhere(test);

  Iterable skip(int n) => delegate.skip(n);

  Iterable skipWhile(bool test(value)) => delegate.skipWhile(test);

  Iterable take(int n) => delegate.take(n);

  Iterable takeWhile(bool test(value)) => delegate.takeWhile(test);

  List toList({bool growable: true}) => delegate.toList(growable: growable);

  Set toSet() => delegate.toSet();

  Iterable where(bool test(element)) => delegate.where(test);
}

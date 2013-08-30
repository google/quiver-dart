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
 * This class allows to implement [Iterable] methods by delegating to a given
 * [Iterable].
 * For instance you can create a FruitIterable like this :
 *
 *     class FruitIterable extends DelegatingIterable<Fruit> {
 *       final List<Fruit> fruits;
 *       FruitIterable() : this._([]);
 *       FruitIterable._(List<Fruit> fruits) :
 *         this.fruits = fruits,
 *         super(fruits);
 *
 *       // custom methods
 *     }
 */
class DelegatingIterable<E> implements Iterable<E> {
  final Iterable<E> _delegate;

  DelegatingIterable(this._delegate);

  bool any(bool test(element)) => _delegate.any(test);

  bool contains(Object element) => _delegate.contains(element);

  elementAt(int index) => _delegate.elementAt(index);

  bool every(bool test(element)) => _delegate.every(test);

  Iterable expand(Iterable f(element)) => _delegate.expand(f);

  get first => _delegate.first;

  firstWhere(bool test(element), {orElse()}) =>
      _delegate.firstWhere(test, orElse: orElse);

  fold(initialValue, combine(previousValue, element)) =>
      _delegate.fold(initialValue, combine);

  void forEach(void f(element)) => _delegate.forEach(f);

  bool get isEmpty => _delegate.isEmpty;

  bool get isNotEmpty => _delegate.isNotEmpty;

  Iterator get iterator => _delegate.iterator;

  String join([String separator = ""]) => _delegate.join(separator);

  get last => _delegate.last;

  lastWhere(bool test(element), {orElse()}) =>
      _delegate.lastWhere(test, orElse: orElse);

  int get length => _delegate.length;

  Iterable map(f(element)) => _delegate.map(f);

  reduce(combine(value, element)) => _delegate.reduce(combine);

  get single => _delegate.single;

  singleWhere(bool test(element)) => _delegate.singleWhere(test);

  Iterable skip(int n) => _delegate.skip(n);

  Iterable skipWhile(bool test(value)) => _delegate.skipWhile(test);

  Iterable take(int n) => _delegate.take(n);

  Iterable takeWhile(bool test(value)) => _delegate.takeWhile(test);

  List toList({bool growable: true}) => _delegate.toList(growable: growable);

  Set toSet() => _delegate.toSet();

  Iterable where(bool test(element)) => _delegate.where(test);
}

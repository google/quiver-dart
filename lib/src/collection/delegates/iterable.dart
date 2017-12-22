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

/// An implementation of [Iterable] that delegates all methods to another
/// [Iterable].  For instance you can create a FruitIterable like this :
///
///     class FruitIterable extends DelegatingIterable<Fruit> {
///       final Iterable<Fruit> _fruits = [];
///
///       Iterable<Fruit> get delegate => _fruits;
///
///       // custom methods
///     }
abstract class DelegatingIterable<E> implements Iterable<E> {
  Iterable<E> get delegate;

  bool any(bool test(E element)) => delegate.any(test);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  bool contains(Object element) => delegate.contains(element);

  E elementAt(int index) => delegate.elementAt(index);

  bool every(bool test(E element)) => delegate.every(test);

  Iterable<T> expand<T>(Iterable<T> f(E element)) => delegate.expand(f);

  E get first => delegate.first;

  E firstWhere(bool test(E element), {E orElse()}) =>
      delegate.firstWhere(test, orElse: orElse);

  T fold<T>(T initialValue, T combine(T previousValue, E element)) =>
      delegate.fold(initialValue, combine);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<E> followedBy(Iterable<E> other) {
    throw new UnimplementedError("followedBy");
  }

  void forEach(void f(E element)) => delegate.forEach(f);

  bool get isEmpty => delegate.isEmpty;

  bool get isNotEmpty => delegate.isNotEmpty;

  Iterator<E> get iterator => delegate.iterator;

  String join([String separator = ""]) => delegate.join(separator);

  E get last => delegate.last;

  E lastWhere(bool test(E element), {E orElse()}) =>
      delegate.lastWhere(test, orElse: orElse);

  int get length => delegate.length;

  Iterable<T> map<T>(T f(E e)) => delegate.map(f);

  E reduce(E combine(E value, E element)) => delegate.reduce(combine);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  E get single => delegate.single;

  E singleWhere(bool test(E element), {E orElse()}) {
    if (orElse != null) throw new UnimplementedError("singleWhere:orElse");
    return delegate.singleWhere(test);
  }

  Iterable<E> skip(int n) => delegate.skip(n);

  Iterable<E> skipWhile(bool test(E value)) => delegate.skipWhile(test);

  Iterable<E> take(int n) => delegate.take(n);

  Iterable<E> takeWhile(bool test(E value)) => delegate.takeWhile(test);

  List<E> toList({bool growable: true}) => delegate.toList(growable: growable);

  Set<E> toSet() => delegate.toSet();

  Iterable<E> where(bool test(E element)) => delegate.where(test);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  Iterable<T> whereType<T>() {
    throw new UnimplementedError("whereType");
  }
}

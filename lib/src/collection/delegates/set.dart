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

/// An implementation of [Set] that delegates all methods to another [Set].
/// For instance you can create a FruitSet like this :
///
///     class FruitSet extends DelegatingSet<Fruit> {
///       final Set<Fruit> _fruits = new Set<Fruit>();
///
///       Set<Fruit> get delegate => _fruits;
///
///       // custom methods
///     }
abstract class DelegatingSet<E> extends DelegatingIterable<E>
    implements Set<E> {
  Set<E> get delegate;

  bool add(E value) => delegate.add(value);

  void addAll(Iterable<E> elements) => delegate.addAll(elements);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingSet<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingSet<T> retype<T>() {
    throw new UnimplementedError("retype");
  }

  void clear() => delegate.clear();

  bool containsAll(Iterable<Object> other) => delegate.containsAll(other);

  Set<E> difference(Set<Object> other) => delegate.difference(other);

  Set<E> intersection(Set<Object> other) => delegate.intersection(other);

  E lookup(Object object) => delegate.lookup(object);

  bool remove(Object value) => delegate.remove(value);

  void removeAll(Iterable<Object> elements) => delegate.removeAll(elements);

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void retainAll(Iterable<Object> elements) => delegate.retainAll(elements);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);

  Set<E> union(Set<E> other) => delegate.union(other);
}

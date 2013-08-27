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
 * This class allows to implement [Set] methods by delegating to a given
 * [Set].
 * For instance you can create a FruitSet like this :
 *
 *     class FruitSet extends DelegatedSet<Fruit> {
 *       final Set<Fruit> fruits;
 *       FruitSet() : this._(new Set<Fruit>());
 *       FruitSet._(Set<Fruit> fruits) :
 *         this.fruits = fruits,
 *         super(fruits);
 *
 *       // custom methods
 *     }
 */
class DelegatedSet<E> extends DelegatedIterable<E> implements Set<E> {
  final Set<E> _delegate;

  DelegatedSet(Set<E> _delegate) : _delegate = _delegate, super(_delegate);

  void add(E value) => _delegate.add(value);

  void addAll(Iterable<E> elements) => _delegate.addAll(elements);

  void clear() => _delegate.clear();

  bool containsAll(Iterable<Object> other) => _delegate.containsAll(other);

  Set<E> difference(Set<E> other) => _delegate.difference(other);

  Set<E> intersection(Set<Object> other) => _delegate.intersection(other);

  bool remove(Object value) => _delegate.remove(value);

  void removeAll(Iterable<Object> elements) => _delegate.removeAll(elements);

  void removeWhere(bool test(E element)) => _delegate.removeWhere(test);

  void retainAll(Iterable<Object> elements) => _delegate.retainAll(elements);

  void retainWhere(bool test(E element)) => _delegate.retainWhere(test);

  Set<E> union(Set<E> other) => _delegate.union(other);
}

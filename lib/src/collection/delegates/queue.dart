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

/// An implementation of [Queue] that delegates all methods to another [Queue].
/// For instance you can create a FruitQueue like this :
///
///     class FruitQueue extends DelegatingQueue<Fruit> {
///       final Queue<Fruit> _fruits = new Queue<Fruit>();
///
///       Queue<Fruit> get delegate => _fruits;
///
///       // custom methods
///     }
abstract class DelegatingQueue<E> extends DelegatingIterable<E>
    implements Queue<E> {
  Queue<E> get delegate;

  void add(E value) => delegate.add(value);

  void addAll(Iterable<E> iterable) => delegate.addAll(iterable);

  void addFirst(E value) => delegate.addFirst(value);

  void addLast(E value) => delegate.addLast(value);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingQueue<T> cast<T>() {
    throw new UnimplementedError("cast");
  }

  void clear() => delegate.clear();

  bool remove(Object object) => delegate.remove(object);

  E removeFirst() => delegate.removeFirst();

  E removeLast() => delegate.removeLast();

  void removeWhere(bool test(E element)) => delegate.removeWhere(test);

  void retainWhere(bool test(E element)) => delegate.retainWhere(test);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_method
  DelegatingQueue<T> retype<T>() {
    throw new UnimplementedError("retype");
  }
}

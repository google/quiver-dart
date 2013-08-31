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
 * An implementation of [Queue] that delegates all methods to another [Queue].
 * For instance you can create a FruitQueue like this :
 *
 *     class FruitQueue extends DelegatingQueue<Fruit> {
 *       final Queue<Fruit> fruits;
 *       FruitQueue() : this._(new Queue<Fruit>());
 *       FruitQueue._(Queue<Fruit> fruits) :
 *         this.fruits = fruits,
 *         super(fruits);
 *
 *       // custom methods
 *     }
 */
class DelegatingQueue<E> extends DelegatingIterable<E> implements Queue<E> {
  final Queue<E> _delegate;

  DelegatingQueue(Queue<E> _delegate) : _delegate = _delegate, super(_delegate);

  void add(E value) => _delegate.add(value);

  void addAll(Iterable<E> iterable) => _delegate.addAll(iterable);

  void addFirst(E value) => _delegate.addFirst(value);

  void addLast(E value) => _delegate.addLast(value);

  void clear() => _delegate.clear();

  bool remove(Object object) => _delegate.remove(object);

  E removeFirst() => _delegate.removeFirst();

  E removeLast() => _delegate.removeLast();
}

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

import 'dart:async';

/// An asynchronous callback that returns a value.
typedef AsyncAction<T, E> = Future<T> Function(E e);

/// An asynchronous funcuntion that combines an element [e] with a previous
/// value [previous], for use with [reduceAsync].
typedef AsyncCombiner<T, E> = Future<T> Function(T previous, E e);

/// Reduces a collection to a single value by iteratively combining elements of
/// the collection using the provided [combine] function. Similar to
/// [Iterable.reduce], except that [combine] is an async function that returns
/// a [Future].
Future<S> reduceAsync<S, T>(
        Iterable<T> iterable, S initialValue, AsyncCombiner<S, T> combine) =>
    _reduceAsync(iterable.iterator, initialValue, combine);

Future<S> _reduceAsync<S, T>(
    Iterator<T> iterator, S current, AsyncCombiner<S, T> combine) async {
  if (iterator.moveNext()) {
    var result = await combine(current, iterator.current);
    return _reduceAsync(iterator, result, combine);
  }
  return current;
}

/// Schedules calls to [action] for each element in [iterable]. No more than
/// [maxTasks] calls to [action] will be pending at once.
Future<Null> forEachAsync<T>(Iterable<T> iterable, AsyncAction<Null, T> action,
    {int maxTasks = 1}) {
  // TODO(cbracken): Remove post-NNBD. https://github.com/google/quiver-dart/issues/612
  ArgumentError.checkNotNull(iterable);
  ArgumentError.checkNotNull(maxTasks);
  if (maxTasks < 1) {
    throw ArgumentError('maxTasks must be greater than 0, was: $maxTasks');
  }

  if (iterable.isEmpty) return Future.value();

  var completer = Completer<Null>();
  var iterator = iterable.iterator;
  int pending = 0;
  bool failed = false;

  bool scheduleTask() {
    if (pending < maxTasks && iterator.moveNext()) {
      pending++;
      var item = iterator.current;
      scheduleMicrotask(() {
        var task = action(item);
        task.then((_) {
          pending--;
          if (failed) return;
          if (!scheduleTask() && pending == 0) {
            completer.complete();
          }
        }).catchError((e, stack) {
          if (failed) return;
          failed = true;
          completer.completeError(e, stack);
        });
      });
      return true;
    }
    return false;
  }

  while (scheduleTask()) {}
  return completer.future;
}

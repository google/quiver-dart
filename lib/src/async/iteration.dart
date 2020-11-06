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
/// value [previous].
typedef AsyncCombiner<T, E> = Future<T> Function(T previous, E e);

/// Calls [action] for each item in [iterable] in turn, waiting for the Future
/// returned by action to complete.
///
/// If the Future completes to [true], iteration continues.
///
/// The Future returned completes to [true] if the entire iterable was
/// processed, otherwise [false].
///
/// This is deprecated and will be removed in Quiver 3.0.0. It can be replaced
/// by [Future.doWhile]. For example:
///
///     List<int> myList = ...
///     await doWhileAsync(myList, (int i) {
///       return i != 5;
///     });
///
/// can be replaced by the following code:
///
///     List<int> myList = ...
///     Iterator<int> it = myList.iterator;
///     await Future.doWhile(() {
///       if (it.moveNext()) {
///         return it.current != 5;
///       }
///       return false;
///     });
@Deprecated('Use Future.doWhile from dart:async. Will be removed in 3.0.0.')
Future<bool> doWhileAsync<T>(
        Iterable<T> iterable, AsyncAction<bool, T> action) =>
    _doWhileAsync(iterable.iterator, action);

Future<bool> _doWhileAsync<T>(
    Iterator<T> iterator, AsyncAction<bool, T> action) async {
  if (iterator.moveNext()) {
    return await action(iterator.current)
        ? _doWhileAsync(iterator, action)
        : false;
  }
  return true;
}

/// Reduces a collection to a single value by iteratively combining elements of
/// the collection using the provided [combine] function. Similar to
/// [Iterable.reduce], except that [combine] is an async function that returns
/// a [Future].
///
/// This is deprecated and will be removed in Quiver 3.0.0. It can be replaced
/// with [Future.forEach] as follows:
///
///     List<int> myList = ...
///     int sum = await reduceAsync(myList, 0, (int a, int b) {
///       return a + b;
///     });
///
/// can be replaced by the following code:
///
///     List<int> myList = ...
///     int sum = 0;
///     await Future.forEach(myList, (int i) {
///       sum += i;
///     });
@Deprecated('Use Future.doWhile from dart:async. Will be removed in 3.0.0.')
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
///
/// This is deprecated and will be removed in Quiver 3.0.0. When the [maxTasks]
/// argument is left defaulted, it can be replaced with [Future.forEach] as
/// follows:
///
///     List<int> myList = ...
///     await forEachAsync(myList, (int i) {
///       // do something
///     });
///
/// can be replaced by the following code:
///
///     List<int> myList = ...
///     await Future.forEach(myList, (int i) {
///       // do something
///     });
///
/// In cases where [maxTasks] is specified, package:pool is recommended.
/// See: https://pub.dev/packages/pool
@Deprecated('Use Future.forEach or package:pool. Will be removed in 3.0.0.')
Future<Null> forEachAsync<T>(Iterable<T> iterable, AsyncAction<Null, T> action,
    {int maxTasks = 1}) {
  if (maxTasks == null || maxTasks < 1) {
    throw ArgumentError('maxTasks must be greater than 0, was: $maxTasks');
  }

  if (iterable == null) {
    throw ArgumentError('iterable must not be null');
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

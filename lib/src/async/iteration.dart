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

part of quiver.async;

/**
 * Calls [action] for each item in [iterable] in turn, waiting for the Future
 * returned by action to complete.
 *
 * If the Future completes to [true], iteration continues.
 *
 * The Future returned completes to [true] if the entire iterable was processed,
 * otherwise [false].
 */
Future doWhileAsync(Iterable iterable, Future<bool> action(i)) =>
    _doWhileAsync(iterable.iterator, action);

Future _doWhileAsync(Iterator iterator, Future<bool> action(i)) =>
  (iterator.moveNext())
      ? action(iterator.current).then((bool result) =>
        (result)
            ? _doWhileAsync(iterator, action)
            : new Future.value(false))
      : new Future.value(true);

/**
 * Reduces a collection to a single value by iteratively combining elements
 * of the collection using the provided [combine] function. Similar to
 * [Iterable.reduce], except that [combine] is an async function that returns a
 * [Future].
 */
Future reduceAsync(Iterable iterable, initialValue, combine(previous, element))
    => _reduceAsync(iterable.iterator, initialValue, combine);

Future _reduceAsync(Iterator iterator, currentValue,
                    combine(previous, element)) {
  if (iterator.moveNext()) {
    return combine(currentValue, iterator.current).then((result) =>
        _reduceAsync(iterator, result, combine));
  }
  return new Future.value(currentValue);
}

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
 * A collection of [Future]s that signals when all added Futures complete. New
 * Futures can be added to the group as long as it hasn't completed.
 *
 * FutureGroup is useful for managing a set of async tasks that may spawn new
 * async tasks as they execute.
 */
class FutureGroup<E> {
  static const _FINISHED = -1;

  int _pending = 0;
  Future _failedTask;
  final StreamController<E> _controller = new StreamController<E>();

  /** Gets the task that failed, if any. */
  Future get failedTask => _failedTask;

  /**
   * Wait for [task] to complete.
   *
   * If this group has already been marked as completed, a [StateError] will be
   * thrown.
   *
   * If this group has a [failedTask], new tasks will be ignored, because the
   * error has already been signaled.
   */
  void add(Future task) {
    if (_failedTask != null) return;
    if (_pending == _FINISHED) throw new StateError("Future already completed");

    _pending++;
    task.then((res) {
      _controller.add(res);
    }, onError: (e, s) {
      _controller.addError(e, s);
      if (_failedTask != null) return;
      _failedTask = task;
    }).whenComplete(() {
      _pending--;
      if (_pending == 0) {
        _pending = _FINISHED;
        _controller.close();
      }
    });
  }

  /**
   * A Future that completes with a List of the values from all the added
   * tasks, when they have all completed.
   *
   * The list of values is in the order in which the futures complete.
   *
   * If any task fails, this Future will receive the error. Only the first
   * error will be sent to the Future.
   */
  Future<List<E>> get future => stream.toList();

  /**
   * A Stream of the results of all of the added tasks, in the order in which
   * they completed.
   */
  Stream<E> get stream => _controller.stream;
}

// Copyright 2014 Google Inc. All Rights Reserved.
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
 * A queue to which to add async tasks such that only a maximum of [maxParallel]
 * are ever processed in parallel.
 */
class TaskQueue {

  final Queue _tasks = new Queue();

  /**
   * The maximum number of tasks to process in parallel.
   */
  final int maxParallel;

  /**
   * When `maxParallel > 1`, set this to true to maintain the order of the
   * input futures in the [onResult] stream, which will use buffering as
   * necessary.  Otherwise, when completing a task the result will be sent to
   * [onResult] right when it occurs.
   */
  final bool keepOrder;
  _TaskQueueStream _onResult;
  final _idleController = new StreamController();

  TaskQueue(
      {this.maxParallel: 1,
       bool keepOrder}) :
       this.keepOrder = keepOrder == null ? false : keepOrder {
    if (maxParallel == null || maxParallel < 1) {
      throw new ArgumentError(
          "maxParallel must be greater than 0, was: $maxParallel");
    }
    _onResult = new _TaskQueueStream(this);
  }

  /**
   * Add a task to the queue.  The task will be executed as soon as the
   * number of parallel tasks is below [maxParallel].
   */
  void add(Future task()) => _add(task);

  /**
   * For each item in [all], adds a task to call [task] with the item.
   */
  void addAll(Iterable all, Future task(item)) =>
      all.forEach((item) => _add(() => task(item)));

  /**
   * Add a future to the queue.  The future will be listened to as soon as the
   * number of parallel tasks is below [maxParallel].
   */
  void addFuture(Future task) => _add(task);

  _add(task) {
    _tasks.add(task);
    scheduleMicrotask(() => _onResult._scheduleTask());
  }

  /**
   * A stream of the results of completed tasks.  Successful task completions
   * are sent as data events, task failures are sent as error events.  This
   * stream is never done, since new tasks can always be added later.
   */
  Stream get onResult => _onResult;

  /**
   * A stream which produces events each time this queue becomes idle, which means all
   * previously added tasks have been completed.  The first event is not
   * produced until at least one task has been completed.
   */
  Stream get onIdle => _idleController.stream;

  _idle() => _idleController.add(null);

}

class _TaskQueueStream extends Stream {

  final TaskQueue _taskQueue;

  _TaskQueueStream(this._taskQueue);

  var _scheduleTask = () {};

  StreamSubscription listen(
      void onData(var data),
      {Function onError,
       void onDone(),
       bool cancelOnError}) {

    cancelOnError = true == cancelOnError;
    var paused = false;
    var pending = <_Completion> [];

    StreamController controller;

    handlePending() {
      isComplete(completion) => completion.isComplete;
      var toHandle = _taskQueue.keepOrder ?
          pending.takeWhile(isComplete) :
          pending.where(isComplete);
      toHandle = toHandle.toList();
      toHandle.forEach((completion) {
        if(completion.isError){
          controller.addError(completion.error, completion.stackTrace);
        } else {
          controller.add(completion.value);
        }
        pending.remove(completion);
      });
      if (!_scheduleTask() && pending.isEmpty) {
        _taskQueue._idle();
      }
    }

    _scheduleTask = () {
      if (pending.length + 1 <= _taskQueue.maxParallel &&
          _taskQueue._tasks.isNotEmpty) {
        var item = _taskQueue._tasks.removeFirst();
        if(item is! Future) {
          item = item();
        }
        var completion = new _Completion(item);
        pending.add(completion);
        completion.future.whenComplete(() {
          if(!paused) handlePending();
        });
        return true;
      }
      return false;
    };

    controller = new StreamController(
      sync: true,
      onPause: () {
        paused = true;
      },
      onResume: () {
        paused = false;
        handlePending();
      },
      onCancel: () {
        paused = false;
      });

    while (_scheduleTask()) {}

    return controller.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }
}

class _Completion {
  final Future _future;
  var value;
  var error;
  var stackTrace;
  bool isError;
  bool isComplete = false;

  _Completion(this._future);

  Future get future {
    return _future.then((v) {
      value = v;
      isError = false;
    }, onError: (e, s) {
      error = e;
      stackTrace = s;
      isError = true;
    }).whenComplete(() {
      isComplete = true;
    });
  }
}

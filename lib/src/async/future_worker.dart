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

typedef Future Worker();

/**
 * Managers a [Future] worker poll
 *
 * The purpouse of this class is to help when you need to impose some limit
 * for [Future] calls. You just need to initialize with the limit number of
 * workers, then you call [push] passing a function that returns a [Future]
 * and with that the worker will manage to call this function when the poll
 * has space:
 *
 *     class SimpleJob {
 *       bool started = false;
 *       Completer completer = new Completer();
 *
 *       Future run() {
 *         started = true;
 *
 *         return completer.future;
 *       }
 *     }
 *
 *     FutureWorker worker = new FutureWorker(2);
 *
 *     SimpleJob job1 = new SimpleJob();
 *     SimpleJob job2 = new SimpleJob();
 *     SimpleJob job3 = new SimpleJob();
 *
 *     Future future1 = worker.push(job1.run); // will call right way since the poll is free
 *     Future future2 = worker.push(job2.run); // same as before, still have space
 *     Future future3 = worker.push(job3.run); // will be queued and hold
 *
 *     job1.started; // true
 *     job2.started; // true
 *     job3.started; // false
 *
 *     job1.completer.complete(null);
 *
 *     new Future.microtask(() {
 *       job3.started; // true
 *     });
 *
 *     future3.then((value) {
 *       value; // done, after the job3 completes
 *     });
 *
 *     job3.completer.complete('done');
 *
 * You probably going to use it when you wanna limit calls for a server and stuff
 * like that, so since adding a timeout is a common practice (to avoid the poll to
 * never get free slots) you can send a duration to timeout when constructing the
 * worker.
 *
 *     FutureWorker worker = new FutureWorker(2, timeout: new Duration(seconds: 15));
 */
class FutureWorker {
  int limit;
  Duration timeout;
  int _workingCount = 0;
  Queue<_FutureWorkerTask> _queue = new Queue<_FutureWorkerTask>();

  FutureWorker(this.limit, {this.timeout});

  Future push(Worker worker) {
    if (_workingCount < limit) {
      return _runWorker(worker);
    } else {
      return _queueWorker(worker);
    }
  }

  Future _runWorker(Worker worker) {
    _workingCount++;

    return _wrapFuture(_setTimeout(worker()));
  }

  Future _queueWorker(Worker worker) {
    _FutureWorkerTask task = new _FutureWorkerTask(worker);
    _queue.add(task);

    return task.future;
  }

  Future _setTimeout(Future worker) {
    return timeout == null ? worker : worker.timeout(timeout);
  }

  Future _wrapFuture(Future worker) {
    return worker.then(_workerDone).catchError(_workerError);
  }

  dynamic _workerDone(value) {
    _workingCount--;

    if (_queue.length > 0)
      _processNext();

    return value;
  }

  void _processNext() {
    _FutureWorkerTask task = _queue.removeFirst();

    task.complete(push(task.runner));
  }

  Future _workerError(err) {
    _workerDone(null);

    return new Future.error(err);
  }
}

class _FutureWorkerTask {
  Worker runner;
  Completer _completer = new Completer();

  _FutureWorkerTask(this.runner);

  Future get future => _completer.future;

  void complete(value) {
    _completer.complete(value);
  }
}
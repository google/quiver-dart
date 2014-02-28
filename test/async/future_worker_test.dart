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

import 'package:unittest/unittest.dart';
import 'package:quiver/async.dart';

main() {
  group('FutureWorker', () {

    test('runs a job direct when the worker count is under limit', () {
      FutureWorker worker = new FutureWorker(1);
      SimpleJob job = new SimpleJob();

      Future<String> future = worker.push(job.run);

      expect(job.started, isTrue);

      job.completer.complete('test');

      expect(future, completion('test'));
    });

    test('doesn\'t run if the workers are full', () {
      FutureWorker worker = new FutureWorker(1);

      SimpleJob secondJob = new SimpleJob();

      worker.push(new SimpleJob().run);
      worker.push(secondJob.run);

      expect(secondJob.started, isFalse);
    });

    test('run the job when the queue has added limit', () {
      FutureWorker worker = new FutureWorker(1);

      SimpleJob job = new SimpleJob();
      SimpleJob secondJob = new SimpleJob();

      Future future = worker.push(job.run);
      worker.push(secondJob.run);

      expect(secondJob.started, isFalse);

      job.completer.complete(null);

      return future.then((value) {
        expect(secondJob.started, isTrue);
      });
    });

    test('run the job when the queue has added limit for a failed task', () {
      FutureWorker worker = new FutureWorker(1);

      SimpleJob job = new SimpleJob();
      SimpleJob secondJob = new SimpleJob();

      Future future = worker.push(job.run);
      worker.push(secondJob.run);

      expect(secondJob.started, isFalse);

      job.completer.completeError(new Exception('bla'));

      return future.catchError((err) {
        expect(secondJob.started, isTrue);
      });
    });

    test('run all the jobs', () {
      FutureWorker worker = new FutureWorker(1);

      SimpleJob job = new SimpleJob();
      SimpleJob secondJob = new SimpleJob();

      worker.push(job.run);
      worker.push(secondJob.run);

      job.completer.complete('one');
      secondJob.completer.complete('two');

      expect(secondJob.completer.future, completion('two'));
    });

    test('timeout when asked', () {
      FutureWorker worker = new FutureWorker(1, timeout: new Duration(milliseconds: 10));

      SimpleJob job = new SimpleJob();
      SimpleJob secondJob = new SimpleJob();

      silentError(worker.push(job.run));
      silentError(worker.push(secondJob.run));

      return new Future.delayed(new Duration(milliseconds: 50), () {
        expect(secondJob.started, isTrue);
      });
    });

  });
}

class SimpleJob {
  bool started = false;
  Completer completer = new Completer();

  Future run() {
    started = true;

    return completer.future;
  }
}

Future silentError(Future future) {
  return future.catchError((_) => null);
}
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

library quiver.async.task_queue_test;

import 'dart:async';
import 'dart:math';

import 'package:unittest/unittest.dart';
import 'package:quiver/async.dart';

main() {
  group('TaskQueue', () {

    testResults(Stream getResultStream(TaskQueue queue)) {
      var futures = new Iterable.generate(5, (int i) => i.isEven ?
          new Future.value(i) :
          new Future.error('e$i'));
      var events = [];
      var errors = [];
      var done = new Completer();

      var taskQueue = new TaskQueue();
      futures.forEach(taskQueue.addFuture);

      getResultStream(taskQueue).listen(events.add, onError: errors.add,
          onDone: done.complete);
      return Future.wait(futures)
          .catchError((_) => done.future)
          .then((_) {
            expect(events, [0, 2, 4]);
            expect(errors, ['e1', 'e3']);
          });
    }

    test('should yield results for future completions', () {
      testResults((queue) => queue.onResult.take(3));
    });

    testMaxParallel(maxParallel, expectedMaxParallel) {
      test('should allow $expectedMaxParallel max parallel when '
          'parallel = $maxParallel', () {
        var eventCount = 0;
        var actualMaxParallel = 0;
        var currentParallel = 0;
        var done = new Completer();
        var total = expectedMaxParallel * 3;
        var futures = new Iterable.generate(total, (_) => new Future.value());

        var taskQueue = new TaskQueue(maxParallel: maxParallel);
        taskQueue.addAll(futures, (future) {
          actualMaxParallel = max(++currentParallel, actualMaxParallel);
          return future;
        });

        decrementParallel(_) {
          eventCount++;
          currentParallel--;
        }

        taskQueue.onResult.take(total).listen(decrementParallel,
            onError: decrementParallel, onDone: done.complete);
        return done.future
            .then((_) {
              expect(actualMaxParallel, expectedMaxParallel);
              expect(eventCount, total);
            });
      });
    };

    testMaxParallel(1, 1);
    testMaxParallel(3, 3);

    testKeepOrder(bool keepOrder, List order) {
      test('should${keepOrder ? '' : ' not'} keep order of input futures when '
      'keepOrder = $keepOrder', () {
        var completers = new List<Completer>.generate(4, (_) => new Completer());
                       new Future(() => completers[2].completeError('a'))
          .then((_) => new Future(() => completers[3].complete     ('b')))
          .then((_) => new Future(() => completers[0].completeError('c')))
          .then((_) => new Future(() => completers[1].complete     ('d')));
        var events = [];
        var futures = completers.map((completer) => completer.future);
        var done = new Completer();

        var taskQueue = new TaskQueue(maxParallel: 4, keepOrder: keepOrder);
        futures.forEach(taskQueue.addFuture);

        taskQueue.onResult.take(2).listen(events.add, onError: events.add,
            onDone: done.complete);

        return Future.wait(futures)
            .catchError((_) => done.future)
            .then((_) {
              expect(events, order);
        });
      });
    }

    testKeepOrder(false, ['a', 'b', 'c', 'd']);
    testKeepOrder(true, ['c', 'd', 'a', 'b']);

    test('should not buffer events when paused', () {
        var eventCount = 0;
        var done = new Completer();

        var taskQueue = new TaskQueue();
        taskQueue.addFuture(new Future.value());

        var subscription = taskQueue.onResult.listen((_) => eventCount++,
            onDone: done.complete);

        return new Future(() {
          expect(eventCount, 1);
          subscription.pause();
          taskQueue.addFuture(new Future.value());
          return new Future(() {
            expect(eventCount, 1);
            subscription.resume();
            return new Future(() {
              expect(eventCount, 2);
            });
          });
        });

    });

    group('onIdle', () {

      test('should not produce event before tasks added', () {
        var results = [];
        var idles = [];
        var done = new Completer();

        var taskQueue = new TaskQueue();
        new Future(() => taskQueue.addFuture(new Future.value()));

        taskQueue.onResult.take(1).listen(results.add, onDone: done.complete);
        taskQueue.onIdle.listen(idles.add);

        return done.future.then((_) {
          expect(results, [null]);
          expect(idles, []);
        });
      });

      test('should produce event when all tasks complete', () {
        var results = [];
        var idles = [];
        var taskCount = 5;
        var done = new Completer();

        var taskQueue = new TaskQueue();

        addFuture() => taskQueue.addFuture(new Future.value());
        addFuture();

        taskQueue.onResult.take(taskCount).listen((e) {
          results.add(e);
          new Future(addFuture);
        }, onDone: done.complete);
        taskQueue.onIdle.listen(idles.add);

        return done.future.then((_) {
          expect(results, hasLength(taskCount));
          expect(idles, hasLength(taskCount - 1));
        });
      });

    });

    group('untilIdle', () {

      test('should produce results until idle', () {
        testResults((queue) => queue.untilIdle);
      });

    });

  });

}

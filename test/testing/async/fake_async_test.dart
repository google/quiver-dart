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

library quiver.testing.async.fake_async_test;

import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:unittest/unittest.dart';

main() {
  group('FakeAsync', () {

    var initialTime = new DateTime(2000);
    var elapseBy = const Duration(days: 1);

    test('should set initial time', () {
      expect(new FakeAsync().getClock(initialTime).now(), initialTime);
    });

    group('elapseBlocking', () {

      test('should elapse time without calling timers', () {
        var timerCalled = false;
        new Timer(elapseBy ~/ 2, () => timerCalled = true);
        new FakeAsync().elapseBlocking(elapseBy);
        expect(timerCalled, isFalse);
      });

      test('should elapse time by the specified amount', () {
        var it = new FakeAsync();
        it.elapseBlocking(elapseBy);
        expect(it.getClock(initialTime).now(), initialTime.add(elapseBy));
      });

      test('should throw when called with a negative duration',
          () {
            expect(() {
              new FakeAsync().elapseBlocking(const Duration(days: -1));
            }, throwsA(new isInstanceOf<ArgumentError>()));
          });

    });

    group('elapse', () {

      test('should elapse time by the specified amount', () {
        new FakeAsync().run((async) {
          async.elapse(elapseBy);
          expect(async.getClock(initialTime).now(), initialTime.add(elapseBy));
        });
      });

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(
                () => new FakeAsync().elapse(const Duration(days: -1)),
                throwsA(new isInstanceOf<ArgumentError>()));
          });

      test('should throw when called before previous call is complete', () {
        new FakeAsync().run((async) {
          var error;
          new Timer(elapseBy ~/ 2, () {
            try { async.elapse(elapseBy); }
            catch (e) {
              error = e;
            }
          });
          async.elapse(elapseBy);
          expect(error, new isInstanceOf<StateError>());
        });
      });

      group('when creating timers', () {

        test('should call timers expiring before or at end time', () {
          new FakeAsync().run((async) {
            var beforeCallCount = 0;
            var atCallCount = 0;
            new Timer(elapseBy ~/ 2, () {beforeCallCount++;});
            new Timer(elapseBy, () {atCallCount++;});
            async.elapse(elapseBy);
            expect(beforeCallCount, 1);
            expect(atCallCount, 1);
          });
        });

        test('should call timers expiring due to elapseBlocking', () {
          new FakeAsync().run((async) {
            bool secondaryCalled = false;
            new Timer(elapseBy, () { async.elapseBlocking(elapseBy); });
            new Timer(elapseBy * 2, () { secondaryCalled = true; });
            async.elapse(elapseBy);
            expect(secondaryCalled, isTrue);
            expect(async.getClock(initialTime).now(), initialTime.add(elapseBy * 2));
          });
        });

        test('should call timers at their scheduled time', () {
          new FakeAsync().run((async) {
            DateTime calledAt;
            var periodicCalledAt = <DateTime> [];
            new Timer(elapseBy ~/ 2, () {calledAt = async.getClock(initialTime).now();});
            new Timer.periodic(elapseBy ~/ 2, (_) {
              periodicCalledAt.add(async.getClock(initialTime).now());});
            async.elapse(elapseBy);
            expect(calledAt, initialTime.add(elapseBy ~/ 2));
            expect(periodicCalledAt, [elapseBy ~/ 2, elapseBy]
                .map(initialTime.add));
          });
        });

        test('should not call timers expiring after end time', () {
          new FakeAsync().run((async) {
            var timerCallCount = 0;
            new Timer(elapseBy * 2, () {timerCallCount++;});
            async.elapse(elapseBy);
            expect(timerCallCount, 0);
          });
        });

        test('should not call canceled timers', () {
          new FakeAsync().run((async) {
            int timerCallCount = 0;
            var timer = new Timer(elapseBy ~/ 2, () {timerCallCount++;});
            timer.cancel();
            async.elapse(elapseBy);
            expect(timerCallCount, 0);
          });
        });

        test('should call periodic timers each time the duration elapses', () {
          new FakeAsync().run((async) {
            var periodicCallCount = 0;
            new Timer.periodic(elapseBy ~/ 10, (_) {periodicCallCount++;});
            async.elapse(elapseBy);
            expect(periodicCallCount, 10);
          });
        });

        test('should process microtasks surrounding each timer', () {
          new FakeAsync().run((async) {
            var microtaskCalls = 0;
            var timerCalls = 0;
            scheduleMicrotasks() {
              for(int i = 0; i < 5; i++) {
                scheduleMicrotask(() => microtaskCalls++);
              }
            }
            scheduleMicrotasks();
            new Timer.periodic(elapseBy ~/ 5, (_) {
              timerCalls++;
              expect(microtaskCalls, 5 * timerCalls);
              scheduleMicrotasks();
            });
            async.elapse(elapseBy);
            expect(timerCalls, 5);
            expect(microtaskCalls, 5 * (timerCalls + 1));
          });
        });

        test('should pass the periodic timer itself to callbacks', () {
          new FakeAsync().run((async) {
            Timer passedTimer;
            Timer periodic = new Timer.periodic(elapseBy,
                (timer) {passedTimer = timer;});
            async.elapse(elapseBy);
            expect(periodic, same(passedTimer));
          });
        });

        test('should call microtasks before advancing time', () {
          new FakeAsync().run((async) {
            DateTime calledAt;
            scheduleMicrotask((){
              calledAt = async.getClock(initialTime).now();
            });
            async.elapse(const Duration(minutes: 1));
            expect(calledAt, initialTime);
          });
        });

        test('should add event before advancing time', () {
          return new FakeAsync().run((async) {
            var controller = new StreamController();
            var ret = controller.stream.first.then((_) {
              expect(async.getClock(initialTime).now(), initialTime);
            });
            controller.add(null);
            async.elapse(const Duration(minutes: 1));
            return ret;
          });
        });

        test('should increase negative duration timers to zero duration', () {
          new FakeAsync().run((async) {
            var negativeDuration = const Duration(days: -1);
            DateTime calledAt;
            new Timer(negativeDuration, () {
              calledAt = async.getClock(initialTime).now();
            });
            async.elapse(const Duration(minutes: 1));
            expect(calledAt, initialTime);
          });
        });

        test('should not be additive with elapseBlocking', () {
          new FakeAsync().run((async) {
            new Timer(Duration.ZERO, () => async.elapseBlocking(elapseBy * 5));
            async.elapse(elapseBy);
            expect(async.getClock(initialTime).now(),
                initialTime.add(elapseBy * 5));
          });
        });

        group('isActive', () {

          test('should be false after timer is run', () {
            new FakeAsync().run((async) {
              var timer = new Timer(elapseBy ~/ 2, () {});
              async.elapse(elapseBy);
              expect(timer.isActive, isFalse);
            });
          });

          test('should be true after periodic timer is run', () {
            new FakeAsync().run((async) {
              var timer= new Timer.periodic(elapseBy ~/ 2, (_) {});
              async.elapse(elapseBy);
              expect(timer.isActive, isTrue);
            });
          });

          test('should be false after timer is canceled', () {
            new FakeAsync().run((async) {
              var timer = new Timer(elapseBy ~/ 2, () {});
              timer.cancel();
              expect(timer.isActive, isFalse);
            });
          });

        });

        test('should work with new Future()', () {
          new FakeAsync().run((async) {
            var callCount = 0;
            new Future(() => callCount++);
            async.elapse(Duration.ZERO);
            expect(callCount, 1);
          });
        });

        test('should work with Future.delayed', () {
          new FakeAsync().run((async) {
            int result;
            new Future.delayed(elapseBy, () => result = 5);
            async.elapse(elapseBy);
            expect(result, 5);
          });
        });

        test('should work with Future.timeout', () {
          new FakeAsync().run((async) {
            var completer = new Completer();
            var timed = completer.future.timeout(elapseBy ~/ 2);
            expect(timed, throwsA(new isInstanceOf<TimeoutException>()));
            async.elapse(elapseBy);
            completer.complete();
          });
        });

        // TODO: Pausing and resuming the timeout Stream doesn't work since
        // it uses `new Stopwatch()`.
        //
        // See https://code.google.com/p/dart/issues/detail?id=18149
        test('should work with Stream.periodic', () {
          new FakeAsync().run((async) {
            var events = <int> [];
            StreamSubscription subscription;
            var periodic = new Stream.periodic(const Duration(minutes: 1),
                (i) => i);
            subscription = periodic.listen(events.add, cancelOnError: true);
            async.elapse(const Duration(minutes: 3));
            subscription.cancel();
            expect(events, [0, 1, 2]);
          });

        });

        test('should work with Stream.timeout', () {
          new FakeAsync().run((async) {
            var events = <int> [];
            var errors = [];
            var controller = new StreamController();
            var timed = controller.stream.timeout(const Duration(minutes: 2));
            var subscription = timed.listen(events.add, onError: errors.add,
                cancelOnError: true);
            controller.add(0);
            async.elapse(const Duration(minutes: 1));
            expect(events, [0]);
            async.elapse(const Duration(minutes: 1));
            subscription.cancel();
            expect(errors, hasLength(1));
            expect(errors.first, new isInstanceOf<TimeoutException>());
            return controller.close();
          });

        });

      });

    });

  });

}

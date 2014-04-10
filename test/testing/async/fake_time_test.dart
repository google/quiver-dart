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

library quiver.testing.async.fake_time_test;

import 'dart:async';

import 'package:quiver/testing/async.dart';
import 'package:unittest/unittest.dart';

main() {
  group('FakeTime', () {

    FakeTime unit;
    DateTime initialTime;
    Duration elapseBy;

    setUp(() {
      initialTime = new DateTime(2000);
      unit = new FakeTime(initialTime: initialTime);
      elapseBy = const Duration(days: 1);
    });

    test('should set initial time', () {
      expect(unit.clock.now(), initialTime);
    });

    test('should default initial time to system time', () {
      expect(
          new FakeTime().clock.now().millisecondsSinceEpoch,
          closeTo(new DateTime.now().millisecondsSinceEpoch, 500));
    });

    group('elapseSync', () {

      test('should elapse time synchronously', () {
        unit.elapseSync(elapseBy);
        expect(unit.clock.now(), initialTime.add(elapseBy));
      });

      test('should throw when called with a negative duration',
          () {
            expect(() {
              unit.elapseSync(const Duration(days: -1));
            }, throwsA(new isInstanceOf<ArgumentError>()));
          });

    });

    group('elapse', () {

      test('should elapse time asynchronously', () =>
          unit.run((time) => time.elapse(elapseBy)).then((_) {
            expect(unit.clock.now(), initialTime.add(elapseBy));
          }));

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(
                unit.elapse(const Duration(days: -1)),
                throwsA(new isInstanceOf<ArgumentError>()));
          });

      test('should throw when called before previous call is complete', () {
        unit.run((time) {
          time.elapse(elapseBy);
          expect(time.elapse(elapseBy),
              throwsA(new isInstanceOf<StateError>()));
        });
      });

      group('when creating timers', () {

        test('should call timers expiring before or at end time', () {
          return unit.run((time) {
            var beforeCallCount = 0;
            var atCallCount = 0;
            new Timer(elapseBy ~/ 2, () {beforeCallCount++;});
            new Timer(elapseBy, () {atCallCount++;});
            return time.elapse(elapseBy).then((_) {
              expect(beforeCallCount, 1);
              expect(atCallCount, 1);
            });
          });
        });

        test('should call timers at their scheduled time', () {
          return unit.run((time) {
            DateTime calledAt;
            var periodicCalledAt = <DateTime> [];
            new Timer(elapseBy ~/ 2, () {calledAt = time.clock.now();});
            new Timer.periodic(elapseBy ~/ 2, (_) {
              periodicCalledAt.add(time.clock.now());});
            return time.elapse(elapseBy).then((_) {
              expect(calledAt, initialTime.add(elapseBy ~/ 2));
              expect(periodicCalledAt, [elapseBy ~/ 2, elapseBy]
                  .map(initialTime.add));
            });
          });
        });

        test('should not call timers expiring after end time', () {
          return unit.run((time) {
            var timerCallCount = 0;
            new Timer(elapseBy * 2, () {timerCallCount++;});
            return time.elapse(elapseBy).then((_) {
              expect(timerCallCount, 0);
            });
          });
        });

        test('should not call canceled timers', () {
          return unit.run((time) {
            int timerCallCount = 0;
            var timer = new Timer(elapseBy ~/ 2, () {timerCallCount++;});
            timer.cancel();
            return time.elapse(elapseBy).then((_) {
              expect(timerCallCount, 0);
            });
          });
        });

        test('should call periodic timers each time the duration elapses', () {
          return unit.run((time) {
            var periodicCallCount = 0;
            new Timer.periodic(elapseBy ~/ 10, (_) {periodicCallCount++;});
            return time.elapse(elapseBy).then((_) {
              expect(periodicCallCount, 10);
            });
          });
        });

        test('should pass the periodic timer itself to callbacks', () {
          return unit.run((time) {
            Timer passedTimer;
            Timer periodic = new Timer.periodic(elapseBy,
                (timer) {passedTimer = timer;});
            return time.elapse(elapseBy).then((_) {
              expect(periodic, same(passedTimer));
            });
          });
        });

        test('should call microtasks before advancing time', () {
          return unit.run((time) {
            DateTime calledAt;
            scheduleMicrotask((){ calledAt = time.clock.now(); });
            return time.elapse(const Duration(minutes: 1)).then((_) {
              expect(calledAt, initialTime);
            });
          });
        });

        test('should add event before advancing time', () {
          return unit.run((time) {
            var events = <int> [];
            var controller = new StreamController();
            DateTime heardAt;
            controller.stream.first.then((_) { heardAt = time.clock.now(); });
            controller.add(null);
            var elapsed = time.elapse(const Duration(minutes: 1));
            return Future.wait([controller.close(), elapsed]).then((_) {
              expect(heardAt, initialTime);
            });
          });
        });

        test('should increase negative duration timers to zero duration', () {
          return unit.run((time) {
            var negativeDuration = const Duration(days: -1);
            DateTime calledAt;
            new Timer(negativeDuration, () { calledAt = time.clock.now(); });
            return time.elapse(const Duration(minutes: 1)).then((_) {
              expect(calledAt, initialTime);
            });
          });
        });

        test('should not be additive with elapseSync', () {
          return unit.run((time) {
            var elapsed = time.elapse(elapseBy);
            time.elapseSync(elapseBy * 2);
            return elapsed.then((_) {
              expect(time.clock.now(), initialTime.add(elapseBy * 2));
            });
          });
        });

        group('isActive', () {

          test('should be false after timer is run', () {
            return unit.run((time) {
              var timer = new Timer(elapseBy ~/ 2, () {});
              return time.elapse(elapseBy).then((_) {
                expect(timer.isActive, isFalse);
              });
            });
          });

          test('should be true after periodic timer is run', () {
            return unit.run((time) {
              var timer= new Timer.periodic(elapseBy ~/ 2, (_) {});
              return time.elapse(elapseBy).then((_) {
                expect(timer.isActive, isTrue);
              });
            });
          });

          test('should be false after timer is canceled', () {
            new FakeTime().run((time) {
              var timer = new Timer(elapseBy ~/ 2, () {});
              timer.cancel();
              expect(timer.isActive, isFalse);
            });
          });

        });

        test('should work with new Future()', () {
          return unit.run((time) {
            var callCount = 0;
            new Future(() => callCount++);
            return time.elapse(Duration.ZERO).then((_) {
              expect(callCount, 1);
            });
          });
        });

        test('should work with Future.delayed', () {
          return unit.run((time) {
            int result;
            new Future.delayed(elapseBy, () => result = 5);
            return time.elapse(elapseBy).then((_) {
              expect(result, 5);
            });
          });
        });

        test('should work with Future.timeout', () {
          unit.run((time) {
            var completer = new Completer();
            var timed = completer.future.timeout(elapseBy ~/ 2);
            new Timer(elapseBy, completer.complete);
            var elapsed = time.elapse(elapseBy);
            expect(Future.wait([elapsed, timed]),
                throwsA(new isInstanceOf<TimeoutException>()));
          });
        });

        // TODO: Pausing and resuming the timeout Stream doesn't work since
        // it uses `new Stopwatch()`.
        test('should work with Stream.periodic', () {
          return unit.run((time) {
            var events = <int> [];
            StreamSubscription subscription;
            var periodic = new Stream.periodic(const Duration(minutes: 1),
                (i) => i);
            subscription = periodic.listen(events.add, cancelOnError: true);
            return time.elapse(const Duration(minutes: 3)).then((_) {
              subscription.cancel();
              expect(events, [0, 1, 2]);
            });
          });

        });

        test('should work with Stream.timeout', () {
          return unit.run((time) {
            var events = <int> [];
            var errors = [];
            var controller = new StreamController();
            var timed = controller.stream.timeout(const Duration(minutes: 2));
            var subscription = timed.listen(events.add, onError: errors.add,
                cancelOnError: true);
            controller.add(0);
            return time.elapse(const Duration(minutes: 1)).then((_) {
              expect(events, [0]);
              return time.elapse(const Duration(minutes: 1)).then((_) {
                subscription.cancel();
                expect(errors, hasLength(1));
                expect(errors.first, new isInstanceOf<TimeoutException>());
                return controller.close();
              });

            });

          });

        });

      });

    });

  });

}

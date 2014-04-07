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
    Duration elapseBy;

    setUp(() {
      unit = new FakeTime();
      elapseBy = const Duration(days: 1);
    });

    group('elapseSync', () {

      test('should elapse time synchronously', () {
        unit.elapseSync(elapseBy);
        expect(unit.elapsed, elapseBy);
      });

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(() {
              unit.elapseSync(const Duration(days: -1));
            }, throwsA(new isInstanceOf<ArgumentError>()));
          });

    });

    group('elapse', () {

      test('should elapse time asynchronously', () =>
          unit.run(() => unit.elapse(elapseBy)).then((_) {
            expect(unit.elapsed, elapseBy);
          }));

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(
                unit.elapse(const Duration(days: -1)),
                throwsA(new isInstanceOf<ArgumentError>()));
          });

      test('should throw when called before previous call is complete', () {
        unit.run(() {
          unit.elapse(elapseBy);
          expect(unit.elapse(elapseBy),
              throwsA(new isInstanceOf<StateError>()));
        });
      });

      group('when creating timers', () {

        test('should call timers expiring before or at end time', () {
          var beforeCallCount = 0;
          var atCallCount = 0;
          return unit.run(() {
            new Timer(elapseBy ~/ 2, () {beforeCallCount++;});
            new Timer(elapseBy, () {atCallCount++;});
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(beforeCallCount, 1);
            expect(atCallCount, 1);
          });
        });

        test('should call timers at their scheduled time', () {
          Duration calledAt;
          var periodicCalledAt = <Duration> [];
          return unit.run(() {
            new Timer(elapseBy ~/ 2, () {calledAt = unit.elapsed;});
            new Timer.periodic(elapseBy ~/ 2, (_) {
              periodicCalledAt.add(unit.elapsed);});
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(calledAt, elapseBy ~/ 2);
            expect(periodicCalledAt, [elapseBy ~/ 2, elapseBy]);
          });
        });

        test('should not call timers expiring after end time', () {
          var timerCallCount = 0;
          unit.run(() {
            new Timer(elapseBy * 2, () {timerCallCount++;});
            unit.elapse(elapseBy);
          });
          expect(timerCallCount, 0);
        });

        test('should not call canceled timers', () {
          int timerCallCount = 0;
          return unit.run(() {
            var timer = new Timer(elapseBy ~/ 2, () {timerCallCount++;});
            timer.cancel();
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(timerCallCount, 0);
          });
        });

        test('should call periodic timers each time the duration elapses', () {
          var periodicCallCount = 0;
          return unit.run(() {
            new Timer.periodic(elapseBy ~/ 10, (_) {periodicCallCount++;});
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(periodicCallCount, 10);
          });
        });

        test('should pass the periodic timer itself to callbacks', () {
          var periodicCallCount = 0;
          Timer passedTimer;
          Timer periodic;
          return unit.run(() {
            periodic = new Timer.periodic(elapseBy,
                (timer) {passedTimer = timer;});
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(periodic, same(passedTimer));
          });
        });

        test('should call microtasks before advancing time', () {
          Duration calledAt;
          return unit.run(() {
            scheduleMicrotask((){ calledAt = unit.elapsed; });
            return unit.elapse(const Duration(minutes: 1));
          }).then((_) {
            expect(calledAt, Duration.ZERO);
          });
        });

        test('should add event before advancing time', () {
          var events = <int> [];
          var controller = new StreamController();
          Future elapsed;
          Duration heardAt;
          unit.run(() {
            controller.stream.first.then((_) { heardAt = unit.elapsed; });
            controller.add(null);
            elapsed = unit.elapse(const Duration(minutes: 1));
          });
          return Future.wait([controller.close(), elapsed]).then((_) {
            expect(heardAt, Duration.ZERO);
          });
        });

        test('should increase negative duration timers to zero duration', () {
          var negativeDuration = const Duration(days: -1);
          Duration calledAt;
          return unit.run(() {
            new Timer(negativeDuration, () { calledAt = unit.elapsed; });
            return unit.elapse(const Duration(minutes: 1));
          }).then((_) {
            expect(calledAt, Duration.ZERO);
          });
        });

        test('should not be additive with elapseSync', () {
          return unit.run(() {
            var elapsed = unit.elapse(elapseBy);
            unit.elapseSync(elapseBy * 2);
            return elapsed;
          }).then((_) {
            expect(unit.elapsed, elapseBy * 2);
          });
        });

        group('isActive', () {

          test('should be false after timer is run', () {
            Timer timer;
            return unit.run(() {
              timer = new Timer(elapseBy ~/ 2, () {});
              return unit.elapse(elapseBy);
            }).then((_) {
              expect(timer.isActive, isFalse);
            });
          });

          test('should be true after periodic timer is run', () {
            Timer timer;
            return unit.run(() {
              timer = new Timer.periodic(elapseBy ~/ 2, (_) {});
              return unit.elapse(elapseBy);
            }).then((_) {
              expect(timer.isActive, isTrue);
            });
          });

          test('should be false after timer is canceled', () {
            Timer timer;
            unit.run(() {
              timer = new Timer(elapseBy ~/ 2, () {});
              timer.cancel();
            });
            expect(timer.isActive, isFalse);
          });

        });

        test('should work with new Future()', () {
          var callCount = 0;
          return unit.run(() {
            new Future(() => callCount++);
            return unit.elapse(Duration.ZERO);
          }).then((_) {
            expect(callCount, 1);
          });
        });

        test('should work with Future.delayed', () {
          int result;
          unit.run(() {
            new Future.delayed(elapseBy, () => result = 5);
            return unit.elapse(elapseBy);
          }).then((_) {
            expect(result, 5);
          });
        });

        test('should work with Future.timeout', () {
          var completer = new Completer();
          unit.run(() {
            var timed = completer.future.timeout(elapseBy ~/ 2);
            new Timer(elapseBy, completer.complete);
            var elapsed = unit.elapse(elapseBy);
            expect(Future.wait([elapsed, timed]), throwsA(new isInstanceOf<TimeoutException>()));
          });
        });

        // TODO: Pausing and resuming the timeout Stream doesn't work since
        // it uses `new Stopwatch()`.
        test('should work with Stream.periodic', () {
          var events = <int> [];
          StreamSubscription subscription;
          return unit.run(() {
            var periodic = new Stream.periodic(const Duration(minutes: 1),
                (i) => i);
            subscription = periodic.listen(events.add, cancelOnError: true);
            return unit.elapse(const Duration(minutes: 3));
          }).then((_) {
            subscription.cancel();
            expect(events, [0, 1, 2]);
          });

        });

        test('should work with Stream.timeout', () {
          var events = <int> [];
          var errors = [];
          var controller = new StreamController();
          StreamSubscription subscription;
          return unit.run(() {
            var timed = controller.stream.timeout(const Duration(minutes: 2));
            subscription = timed.listen((event) {
              events.add(event);
            }, onError: errors.add, cancelOnError: true);
            controller.add(0);
            return unit.elapse(const Duration(minutes: 1));
          }).then((_) {
            expect(events, [0]);
            return unit.run(() => unit.elapse(const Duration(minutes: 1))
                .then((_) {
                  subscription.cancel();
                  expect(errors, hasLength(1));
                  expect(errors.first, new isInstanceOf<TimeoutException>());
                  return controller.close();
            }));

          });

        });

      });

    });

  });

}

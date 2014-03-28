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

library quiver.testing.time.fake_time_test;

import 'dart:async';

import 'package:quiver/testing/time.dart';
import 'package:unittest/unittest.dart';

main() {
  group('FakeTime', () {

    FakeTime unit;
    DateTime initialTime;
    Duration advanceBy;

    setUp(() {
      initialTime = new DateTime(2000);
      unit = new FakeTime(initialTime: initialTime);
      advanceBy = const Duration(days: 1);
    });

    test('should set initial time', () {
      expect(unit.now(), initialTime);
    });

    test('should default initial time to system time', () {
      expect(
          new FakeTime().now().millisecondsSinceEpoch,
          closeTo(new DateTime.now().millisecondsSinceEpoch, 500));
    });

    group('advanceSync', () {

      test('should advance time synchronously', () {
        unit.advanceSync(advanceBy);
        expect(unit.now(), initialTime.add(advanceBy));
      });

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(() {
              unit.advanceSync(const Duration(days: -1));
            }, throwsA(new isInstanceOf<ArgumentError>()));
          });

    });

    group('advance', () {

      test('should advance time asynchronously', () =>
          unit.run(() => unit.advance(advanceBy)).then((_) {
            expect(unit.now(), initialTime.add(advanceBy));
          }));

      test('should throw ArgumentError when called with a negative duration',
          () {
            expect(
                unit.advance(const Duration(days: -1)),
                throwsA(new isInstanceOf<ArgumentError>()));
          });

      test('should throw when called before previous call is complete', () {
        unit.run(() {
          unit.advance(advanceBy);
          expect(unit.advance(advanceBy),
              throwsA(new isInstanceOf<StateError>()));
        });
      });

      group('when creating timers', () {

        test('should call timers expiring before or at end time', () {
          var beforeCallCount = 0;
          var atCallCount = 0;
          return unit.run(() {
            new Timer(advanceBy ~/ 2, () {beforeCallCount++;});
            new Timer(advanceBy, () {atCallCount++;});
            return unit.advance(advanceBy);
          }).then((_) {
            expect(beforeCallCount, 1);
            expect(atCallCount, 1);
          });
        });

        test('should call timers at their scheduled time', () {
          DateTime calledAt;
          var periodicCalledAt = <DateTime> [];
          return unit.run(() {
            new Timer(advanceBy ~/ 2, () {calledAt = unit.now();});
            new Timer.periodic(advanceBy ~/ 2, (_) {
              periodicCalledAt.add(unit.now());});
            return unit.advance(advanceBy);
          }).then((_) {
            expect(calledAt, initialTime.add(advanceBy ~/ 2));
            expect(periodicCalledAt, [initialTime.add(advanceBy ~/ 2),
                initialTime.add(advanceBy)]);
          });
        });

        test('should not call timers expiring after end time', () {
          var timerCallCount = 0;
          unit.run(() {
            new Timer(advanceBy * 2, () {timerCallCount++;});
            unit.advance(advanceBy);
          });
          expect(timerCallCount, 0);
        });

        test('should not call canceled timers', () {
          int timerCallCount = 0;
          return unit.run(() {
            var timer = new Timer(advanceBy ~/ 2, () {timerCallCount++;});
            timer.cancel();
            return unit.advance(advanceBy);
          }).then((_) {
            expect(timerCallCount, 0);
          });
        });

        test('should call periodic timers each time the duration elapses', () {
          var periodicCallCount = 0;
          return unit.run(() {
            new Timer.periodic(advanceBy ~/ 10, (_) {periodicCallCount++;});
            return unit.advance(advanceBy);
          }).then((_) {
            expect(periodicCallCount, 10);
          });
        });

        test('should pass the periodic timer itself to callbacks', () {
          var periodicCallCount = 0;
          Timer passedTimer;
          Timer periodic;
          return unit.run(() {
            periodic = new Timer.periodic(advanceBy,
                (timer) {passedTimer = timer;});
            return unit.advance(advanceBy);
          }).then((_) {
            expect(periodic, same(passedTimer));
          });
        });

        test('should call microtasks before advancing time', () {
          DateTime calledAt;
          return unit.run(() {
            scheduleMicrotask((){ calledAt = unit.now(); });
            return unit.advance(const Duration(minutes: 1));
          }).then((_) {
            expect(calledAt, initialTime);
          });
        });

        test('should add event before advancing time', () {
          var events = <int> [];
          var controller = new StreamController();
          Future advanced;
          DateTime heardAt;
          unit.run(() {
            controller.stream.first.then((_) { heardAt = unit.now(); });
            controller.add(null);
            advanced = unit.advance(const Duration(minutes: 1));
          });
          return Future.wait([controller.close(), advanced]).then((_) {
            expect(heardAt, initialTime);
          });
        });

        test('should increase negative duration timers to zero duration', () {
          var negativeDuration = const Duration(days: -1);
          DateTime calledAt;
          return unit.run(() {
            new Timer(negativeDuration, () { calledAt = unit.now(); });
            return unit.advance(const Duration(minutes: 1));
          }).then((_) {
            expect(calledAt, initialTime);
          });
        });

        test('should not be additive with advanceSync', () {
          return unit.run(() {
            var advanced = unit.advance(advanceBy);
            unit.advanceSync(advanceBy * 2);
            return advanced;
          }).then((_) {
            expect(unit.now(), initialTime.add(advanceBy * 2));
          });
        });

        group('isActive', () {

          test('should be false after timer is run', () {
            Timer timer;
            return unit.run(() {
              timer = new Timer(advanceBy ~/ 2, () {});
              return unit.advance(advanceBy);
            }).then((_) {
              expect(timer.isActive, isFalse);
            });
          });

          test('should be true after periodic timer is run', () {
            Timer timer;
            return unit.run(() {
              timer = new Timer.periodic(advanceBy ~/ 2, (_) {});
              return unit.advance(advanceBy);
            }).then((_) {
              expect(timer.isActive, isTrue);
            });
          });

          test('should be false after timer is canceled', () {
            Timer timer;
            unit.run(() {
              timer = new Timer(advanceBy ~/ 2, () {});
              timer.cancel();
            });
            expect(timer.isActive, isFalse);
          });

        });

        test('should work with new Future()', () {
          var callCount = 0;
          return unit.run(() {
            new Future(() => callCount++);
            return unit.advance(Duration.ZERO);
          }).then((_) {
            expect(callCount, 1);
          });
        });

        test('should work with Future.delayed', () {
          int result;
          unit.run(() {
            new Future.delayed(advanceBy, () => result = 5);
            return unit.advance(advanceBy);
          }).then((_) {
            expect(result, 5);
          });
        });

        test('should work with Future.timeout', () {
          var completer = new Completer();
          unit.run(() {
            var timed = completer.future.timeout(advanceBy ~/ 2);
            new Timer(advanceBy, completer.complete);
            var advanced = unit.advance(advanceBy);
            expect(Future.wait([advanced, timed]), throwsA(new isInstanceOf<TimeoutException>()));
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
            return unit.advance(const Duration(minutes: 3));
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
            return unit.advance(const Duration(minutes: 1));
          }).then((_) {
            expect(events, [0]);
            return unit.run(() => unit.advance(const Duration(minutes: 1))
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

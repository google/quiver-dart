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

    const elapseBy = const Duration(days: 1);

    group('elapseSync', () {

      test('should elapse time synchronously', () {
        var unit = new FakeTime();
        unit.elapseSync(elapseBy);
        expect(unit.elapsed, elapseBy);
      });

      test('should throw when called with a negative duration',
          () {
            var unit = new FakeTime();
            expect(() {
              unit.elapseSync(const Duration(days: -1));
            }, throwsA(new isInstanceOf<ArgumentError>()));
          });

    });

    group('elapse', () {

      test('should elapse time asynchronously', () {
        return new FakeTime().run((time) => time.elapse(elapseBy).then((_) {
          expect(time.elapsed, elapseBy);
        }));
      });

      test('should throw when called with a negative duration', () {
        new FakeTime().run((time) {
          expect(
              new FakeTime().elapse(const Duration(days: -1)),
              throwsA(new isInstanceOf<ArgumentError>()));
        });
      });

      test('should throw when called before previous call is complete', () {
        new FakeTime().run((time) {
          time.elapse(elapseBy);
          expect(time.elapse(elapseBy),
              throwsA(new isInstanceOf<StateError>()));
        });
      });

      group('when creating timers', () {

        test('should call timers expiring before or at end time', () {
          return new FakeTime().run((time) {
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
          return new FakeTime().run((time) {
            Duration calledAt;
            var periodicCalledAt = <Duration> [];
            new Timer(elapseBy ~/ 2, () {calledAt = time.elapsed;});
            new Timer.periodic(elapseBy ~/ 2, (_) {
              periodicCalledAt.add(time.elapsed);});
            return time.elapse(elapseBy).then((_) {
              expect(calledAt, elapseBy ~/ 2);
              expect(periodicCalledAt, [elapseBy ~/ 2, elapseBy]);
            });
          });
        });

        test('should not call timers expiring after end time', () {
          return new FakeTime().run((time) {
            var timerCallCount = 0;
            new Timer(elapseBy * 2, () {timerCallCount++;});
            return time.elapse(elapseBy).then((_) {
              expect(timerCallCount, 0);
            });
          });
        });

        test('should not call canceled timers', () {
          return new FakeTime().run((time) {
            int timerCallCount = 0;
            var timer = new Timer(elapseBy ~/ 2, () {timerCallCount++;});
            timer.cancel();
            return time.elapse(elapseBy).then((_) {
              expect(timerCallCount, 0);
            });
          });
        });

        test('should call periodic timers each time the duration elapses', () {
          return new FakeTime().run((time) {
            var periodicCallCount = 0;
            new Timer.periodic(elapseBy ~/ 10, (_) {periodicCallCount++;});
            return time.elapse(elapseBy).then((_) {
              expect(periodicCallCount, 10);
            });
          });
        });

        test('should pass the periodic timer itself to callbacks', () {
          var periodicCallCount = 0;
          Timer passedTimer;
          Timer periodic;
          return new FakeTime().run((time) {
            periodic = new Timer.periodic(elapseBy,
                (timer) {passedTimer = timer;});
            return time.elapse(elapseBy);
          }).then((_) {
            expect(periodic, same(passedTimer));
          });
        });

        test('should call microtasks before advancing time', () {
          return new FakeTime().run((time) {
            Duration calledAt;
            scheduleMicrotask((){ calledAt = time.elapsed; });
            return time.elapse(const Duration(minutes: 1)).then((_) {
              expect(calledAt, Duration.ZERO);
            });
          });
        });

        test('should add event before advancing time', () {
          new FakeTime().run((time) {
            var events = <int> [];
            var controller = new StreamController();
            Duration heardAt;
            controller.stream.first.then((_) { heardAt = time.elapsed; });
            controller.add(null);
            var elapsed = time.elapse(const Duration(minutes: 1));
            return Future.wait([controller.close(), elapsed]).then((_) {
              expect(heardAt, Duration.ZERO);
            });
          });
        });

        test('should increase negative duration timers to zero duration', () {
          return new FakeTime().run((time) {
            var negativeDuration = const Duration(days: -1);
            Duration calledAt;
            new Timer(negativeDuration, () { calledAt = time.elapsed; });
            return time.elapse(const Duration(minutes: 1)).then((_) {
              expect(calledAt, Duration.ZERO);
            });
          });
        });

        test('should not be additive with elapseSync', () {
          return new FakeTime().run((time) {
            var elapsed = time.elapse(elapseBy);
            time.elapseSync(elapseBy * 2);
            return elapsed.then((_) {
              expect(time.elapsed, elapseBy * 2);
            });
          });
        });

        group('isActive', () {

          test('should be false after timer is run', () {
            return new FakeTime().run((time) {
              var timer = new Timer(elapseBy ~/ 2, () {});
              return time.elapse(elapseBy).then((_) {
                expect(timer.isActive, isFalse);
              });
            });
          });

          test('should be true after periodic timer is run', () {
            return new FakeTime().run((time) {
              var timer= new Timer.periodic(elapseBy ~/ 2, (_) {});
              return time.elapse(elapseBy).then((_) {
                expect(timer.isActive, isTrue);
              });
            });
          });

          test('should be false after timer is canceled', () {
            Timer timer;
            new FakeTime().run((time) {
              timer = new Timer(elapseBy ~/ 2, () {});
              timer.cancel();
            });
            expect(timer.isActive, isFalse);
          });

        });

        test('should work with new Future()', () {
          return new FakeTime().run((time) {
            var callCount = 0;
            new Future(() => callCount++);
            return time.elapse(Duration.ZERO).then((_) {
              expect(callCount, 1);
            });
          });
        });

        test('should work with Future.delayed', () {
          return new FakeTime().run((time) {
            int result;
            new Future.delayed(elapseBy, () => result = 5);
            return time.elapse(elapseBy).then((_) {
              expect(result, 5);
            });
          });
        });

        test('should work with Future.timeout', () {
          new FakeTime().run((time) {
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
          return new FakeTime().run((time) {
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
          return new FakeTime().run((time) {
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

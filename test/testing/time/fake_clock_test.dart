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

library quiver.testing.time.fake_clock_test;

import 'dart:async';

import 'package:quiver/testing/time.dart';
import 'package:unittest/unittest.dart';

main() {
  group('FakeClock', () {

    test('should set initial time', () {
      var initialTime = new DateTime(2000);
      var unit = new FakeClock(initialTime: initialTime);
      expect(unit.now(), initialTime);
    });

    test('should default initial time to system clock time', () {
      var systemNow = new DateTime.now();
      var unit = new FakeClock();
      expect(
          unit.now().millisecondsSinceEpoch,
          closeTo(systemNow.millisecondsSinceEpoch, 500));
    });

    group('advance', () {

      test('should advance time', () {
        var initialTime = new DateTime(2000);
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock(initialTime: initialTime);
        unit.advance(advanceBy);
        expect(unit.now(), initialTime.add(advanceBy));
      });

      test('should throw ArgumentError when called with a negative Duration', () {
        var unit = new FakeClock();
        expect(() {
          unit.advance(const Duration(days: -1));
        }, throwsA(new isInstanceOf<ArgumentError>()));
      });

      test('should throw when called before previous call is complete', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        unit.zone.run(() {
          expect(() {
            new Timer(advanceBy ~/ 2, () {unit.advance(advanceBy);});
            unit.advance(advanceBy);
          }, throwsA(new isInstanceOf<StateError>()));
        });
      });

      test('should call timers expiring before or at end time', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        int beforeCallCount = 0;
        int atCallCount = 0;
        unit.zone.run(() {
          var before = new Timer(advanceBy ~/ 2, () {beforeCallCount++;});
          var at = new Timer(advanceBy, () {atCallCount++;});
          unit.advance(advanceBy);
        });
        expect(beforeCallCount, 1);
        expect(atCallCount, 1);
      });

      test('should call periodic timers once each time the duration elapses', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        int periodicCallCount = 0;
        unit.zone.run(() {
          var periodic = new Timer.periodic(const Duration(hours: 1), (_) {periodicCallCount++;});
          unit.advance(advanceBy);
        });
        expect(periodicCallCount, 24);
      });

      test('should pass the periodic timer itself to callbacks', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        int periodicCallCount = 0;
        Timer passedTimer;
        Timer periodic;
        unit.zone.run(() {
          periodic = new Timer.periodic(advanceBy, (timer) {passedTimer = timer;});
          unit.advance(advanceBy);
        });
        expect(passedTimer, periodic);
      });

      test('should not call timers expiring after end time', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        int timerCallCount = 0;
        unit.zone.run(() {
          var timer = new Timer(advanceBy * 2, () {timerCallCount++;});
          unit.advance(advanceBy);
        });
        expect(timerCallCount, 0);
      });

      test('should not call canceled timers', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        int timerCallCount = 0;
        unit.zone.run(() {
          var timer = new Timer(advanceBy ~/ 2, () {timerCallCount++;});
          timer.cancel();
          unit.advance(advanceBy);
        });
        expect(timerCallCount, 0);
      });

      test('should correctly implement isActive', () {
        var advanceBy = const Duration(days: 1);
        var unit = new FakeClock();
        Timer wasRun;
        unit.zone.run(() {
          wasRun = new Timer(advanceBy ~/ 2, () {});
          unit.advance(advanceBy);
        });
        expect(wasRun.isActive, isFalse);
        Timer periodicWasRun;
        unit.zone.run(() {
          periodicWasRun = new Timer.periodic(advanceBy ~/ 2, (_) {});
          unit.advance(advanceBy);
        });
        expect(periodicWasRun.isActive, isTrue);
        Timer wasCanceled;
        unit.zone.run(() {
          wasCanceled = new Timer(advanceBy * 2, () {});
          wasCanceled.cancel();
        });
        expect(wasCanceled.isActive, isFalse);
      });
    });

    test('should work with Future.delayed', () {
      var advanceBy = const Duration(days: 1);
      var unit = new FakeClock();
      Future delayed;
      unit.zone.run(() {
        delayed = new Future.delayed(advanceBy, () => 5);
        unit.advance(advanceBy);
      });
      return delayed.then((e) {
        expect(e, 5);
      });
    });

    // TODO: Pausing and resuming the periodic Stream doesn't work since
    // it uses `new Stopwatch()`.
    test('should work with Stream.periodic', () {
      var unit = new FakeClock();
      var events = <int> [];
      unit.zone.run(() {
        var periodic = new Stream.periodic(const Duration(minutes: 1), (i) => i);
        var subscription = periodic.listen(events.add, cancelOnError: true);
        unit.advance(const Duration(minutes: 3));
        subscription.cancel();
      });
      expect(events, [0, 1, 2]);
    });

  });
}

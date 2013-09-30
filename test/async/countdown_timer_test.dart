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

library quiver.async.countdown_timer_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:quiver/async.dart';
import 'package:quiver/testing/async.dart';
import 'package:quiver/testing/time.dart';

main() {

  group('CountdownTimer', () {

    test('should countdown', () {
      int _now = 0;

      var stopwatch = new FakeStopwatch(() => _now, 1000000);
      var timer = new FakeTimer();

      var timings = new CountdownTimer(
          new Duration(milliseconds: 500),
          new Duration(milliseconds: 100),
          stopwatch: stopwatch,
          createTimerPeriodic: timer.create)
          .map((c) => c.remaining.inMilliseconds);
      var future = timings.toList().then((list) {
        expect(list, [400, 300, 200, 100, 0]);
      });

      expect(timer.duration.inMilliseconds, 100);

      new Future(() {
        _now = 100000;
        timer.callback(timer);
      }).then((_) {
        _now = 200000;
        timer.callback(timer);
      }).then((_) {
        _now = 300000;
        timer.callback(timer);
      }).then((_) {
        _now = 400000;
        timer.callback(timer);
      }).then((_) {
        _now = 500000;
        timer.callback(timer);
      });

      return future;
    });
  });
}

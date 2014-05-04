// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.time.clock_test;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:quiver/time.dart';

main() {
  test( "ClockWatcher works", () {
    List<DateTime> samples = [
      new DateTime.fromMillisecondsSinceEpoch(1000),
      new DateTime.fromMillisecondsSinceEpoch(1*Duration.MILLISECONDS_PER_MINUTE),
      new DateTime.fromMillisecondsSinceEpoch(2*Duration.MILLISECONDS_PER_MINUTE),
      new DateTime.fromMillisecondsSinceEpoch(2*Duration.MILLISECONDS_PER_MINUTE)
    ];

    List<DateTime> expectedClocks = samples.sublist(1);

    List<Duration> expectedDurations = [
      new Duration(seconds: 59),
      new Duration(seconds: 60),
      new Duration(seconds: 60),
    ];
    var clock = new Clock(() => samples.removeAt(0));

    FakeTimer currentTimer;
    ClockWatcher watcher = new ClockWatcher.factory(clock: clock,
        timerFactory: (x,y) {
      expect(x, expectedDurations.removeAt(0));
      currentTimer = new FakeTimer(x,y);
      return currentTimer;
    });

    var sub;
    Completer fin = new Completer();
    sub = watcher.minutes().listen((date) {
      expect(currentTimer.isActive, true);
      expect(date, expectedClocks.removeAt(0));
      if (expectedClocks.isEmpty) fin.complete();
    });
    currentTimer.callback();
    currentTimer.callback();

    fin.future.then((_) {
      expect(currentTimer.isActive, true);
      sub.cancel();
      expect(currentTimer.isActive, false);
    });
  });
}

class FakeTimer implements Timer {

  Duration dur;
  var callback;

  bool closed = false;

  FakeTimer(this.dur, callback()) : this.callback = callback;

  @override
  void cancel() { closed = true; }

  @override
  bool get isActive => !closed;
}

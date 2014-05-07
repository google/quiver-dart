// Copyright 2014 Google Inc. All Rights Reserved.
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

import 'package:quiver/testing/async.dart';
import 'package:quiver/time.dart';
import 'package:unittest/unittest.dart';

main() {
  test("Watched pot does boil, if given enough time", () {
    new FakeAsync().run((async) {
      int callbacks = 0;
      DateTime lastTime;
      var sub = watchClock(aMinute, clock: async.getClock(
          DateTime.parse("2014-05-05 20:00:30"))).listen((d) {
        callbacks++;
        lastTime = d;
      });
      expect(callbacks, 0, reason: "Should be no callbacks at start");
      async.elapse(aSecond*15);
      expect(callbacks, 0, reason: "Should be no callbacks before trigger");
      async.elapse(aSecond*15);
      expect(callbacks, 1, reason: "Calledback on rollover");
      expect(lastTime, DateTime.parse("2014-05-05 20:01:00"),
          reason: "And that time was correct");
      async.elapse(aMinute*1);
      expect(callbacks, 2, reason: "Callback is repeated");
      expect(lastTime, DateTime.parse("2014-05-05 20:02:00"),
          reason: "And that time was correct");
      sub.cancel();
      async.elapse(aMinute*2);
      expect(callbacks, 2, reason: "No callbacks after subscription cancel");
    });
  });
}


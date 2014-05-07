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

part of quiver.time;


/**
 * Stream [DateTime] events synced with wall-clock time.
 *
 * Example:
 *
 *     watchClock(aMinute).listen((d) => print(d));
 *
 * Prints the following stream of events till the stream is canceled:
 *     2014-05-04 14:06:00.000
 *     2014-05-04 14:07:00.000
 *     2014-05-04 14:08:00.000
 *     ...
 */
Stream<DateTime> watchClock(Duration interval, {Clock clock: SYSTEM_CLOCK}) {
  Timer timer;
  StreamController controller;
  int intervalMs = interval.inMilliseconds;
  controller = new StreamController<DateTime>.broadcast(onCancel: () {
    controller.close();
    timer.cancel();
  });

  _startTimer(DateTime now, tick) {
    var delay = intervalMs - (now.millisecondsSinceEpoch % intervalMs);
    timer = new Timer(new Duration(milliseconds: delay), tick);
  }

  tick() {
    if (controller.isClosed) return;
    DateTime now = clock.now();
    controller.add(now);
    _startTimer(now, tick);
  };
  _startTimer(clock.now(), tick);
  return controller.stream;
}


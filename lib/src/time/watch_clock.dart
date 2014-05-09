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
 * Stream isochronous [DateTime] events at [interval]s centered on [anchor].
 *
 * This stream accounts for drift but only guarantees that events are
 * delivered on or after the interval. If the system is busy for longer than
 * two [interval]s, only one will be delivered.
 *
 * [anchor] defaults to the epoch. It can be anchored in the future, but
 * events will be delivered at the first interveral. If anchored at `now`,
 * this forms a self-correcting periodic timer.
 *
 * Examples:
 *
 *     watchClock(aMinute).listen((d) => print(d));
 *
 * Could print the following stream of events, anchored by epoch,
 * till the stream is canceled:
 *     2014-05-04 14:06:00.001
 *     2014-05-04 14:07:00.000
 *     2014-05-04 14:08:00.003
 *     ...
 *
 * Example anchored in the future (now = 2014-05-05 20:06:00)
 *     watchClock(aMinute * 10,
 *         anchorMs: DateTime.parse("2014-05-05 21:07:00"))
 *         .listen((d) => print(d));
 *
 *     2014-05-04 20:07:00.001
 *     2014-05-04 20:17:00.000
 *     2014-05-04 20:27:00.003
 *     ...
 */
Stream<DateTime> watchClock(Duration interval, {Clock clock: SYSTEM_CLOCK,
  DateTime anchor}) {
  Timer timer;
  StreamController controller;
  int intervalMs = interval.inMilliseconds;
  int anchorMs = anchor == null ? 0 : anchor.millisecondsSinceEpoch;

  _startTimer(DateTime now, tick) {
    var delay = intervalMs
        - ((now.millisecondsSinceEpoch - anchorMs) % intervalMs);
    timer = new Timer(new Duration(milliseconds: delay), tick);
  }

  tick() {
    DateTime now = clock.now();
    controller.add(now);
    _startTimer(now, tick);
  };

  controller = new StreamController<DateTime>.broadcast(sync: true,
      onCancel: () {
        timer.cancel();
      }, onListen: () {
        _startTimer(clock.now(), tick);
      });
  return controller.stream;
}

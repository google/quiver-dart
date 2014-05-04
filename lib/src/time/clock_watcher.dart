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

part of quiver.time;

/**
 * Generate multiple [Stream]s of [DateTime] intervals synced with the wall
 * [clock].
 *
 * Example usage:
 *
 *     // Only listen for the next minute
 *     watcher.minutes().first.then((d) {
 *        print("next minute $d"); // 2014-05-04 14:06:30.000
 *     });
 *
 *     // Every minute, do something
 *     watcher.minutesStream().listen((n) {
 *        // update a clock
 *        // play a tune
 *        // whatever your fancy
 *     });
 */

typedef TimerFactory(Duration dur, callback());
class ClockWatcher {

  Map<int, List> _intervals = {};

  static Timer _timerFactory(Duration dur, callback()) =>
      new Timer(dur, callback);

  final TimerFactory timerFactory;
  final Clock clock;


  ClockWatcher({clock: SYSTEM_CLOCK}) : this.factory(clock: clock);

  /**
   * Construct a ClockWatcher with optioanl [timerFactory] to produce [Timer]s

   * This is probably not the constructor you are looking for.
   */
  ClockWatcher.factory({this.clock: SYSTEM_CLOCK,
      this.timerFactory: _timerFactory});

  /**
   * Exposed if you have a specific need to be notified every [intervalMs].
   */
  Stream<DateTime> atInterval(int intervalMs) {
    List pairing = _intervals[intervalMs];
    if (pairing == null) {
      pairing = new List(2);
      _intervals[intervalMs] = pairing;
      pairing[0] = new StreamController.broadcast(onCancel: () {
        _intervals.remove(intervalMs)
            ..[0].close()
            ..[1].cancel();
      });

      tick() {
        DateTime now = clock.now();
        pairing[0].add(now);
        if (pairing[0].isClosed) return;
        var delay = intervalMs - (now.millisecondsSinceEpoch % intervalMs);
        pairing[1] = timerFactory(new Duration(milliseconds: delay), tick);
      };
      var delay = intervalMs - (clock.now().millisecondsSinceEpoch % intervalMs);
      pairing[1] = timerFactory(new Duration(milliseconds: delay), tick);
    }
    return pairing[0].stream;
  }

  Stream<DateTime> seconds() =>
      atInterval(Duration.MILLISECONDS_PER_SECOND);
  Stream<DateTime> minutes() =>
      atInterval(Duration.MILLISECONDS_PER_MINUTE);
  Stream<DateTime> hours() =>
      atInterval(Duration.MILLISECONDS_PER_HOUR);
  Stream<DateTime> days() =>
      atInterval(Duration.MILLISECONDS_PER_DAY);

  Stream<DateTime> quaterMinutes() =>
      atInterval(15*Duration.MILLISECONDS_PER_SECOND);
  Stream<DateTime> halfMinutes() =>
      atInterval(30*Duration.MILLISECONDS_PER_SECOND);

  Stream<DateTime> fiveMinutes() =>
      atInterval(5*Duration.MILLISECONDS_PER_MINUTE);
  Stream<DateTime> tenMinutes() =>
      atInterval(10*Duration.MILLISECONDS_PER_MINUTE);
  Stream<DateTime> fifteenMinutes() =>
      atInterval(15*Duration.MILLISECONDS_PER_MINUTE);
  Stream<DateTime> thirtyMinutes() =>
      atInterval(30*Duration.MILLISECONDS_PER_MINUTE);
}

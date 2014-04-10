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

part of quiver.testing.async;

/// A mechanism to make time-dependent units testable.
///
/// To use this, test code must be run within a [run] callback.  Any [Timer]s
/// created there will be fake.  Calling [elapse] will then manually elapse
/// the time returned by [now], calling any fake timers as they expire.
///
/// Time can also be elapsed synchronously ([elapseSync]) to simulate
/// expensive or blocking calls, in this case timers are not called.
///
/// The unit under test can take a [Clock] as a dependency, and
/// default it to [SYSTEM_CLOCK] in production, but then have tests pass
/// [FakeTime.clock].
///
/// Example:
///
///     test('testedFunc', () => new FakeTime().run((time) {
///       testedFunc(clock: time.clock);
///       return time.elapse(duration).then((_) => expect(...));
///     }));
abstract class FakeTime {

  /// [initialTime] will be the time returned by [now] before any calls to
  /// [elapse] or [elapseSync].
  factory FakeTime({DateTime initialTime}) = _FakeTime;

  FakeTime._();

  /// Returns a fake [Clock] whose time elapses along with this Clock.  Pass
  /// this as a dependency to the unit under test.
  Clock get clock;

  /// Simulate the asynchronous elapsement of time by [duration].
  ///
  /// Important:  This should only be called from inside a [run] callback.
  ///
  /// If [duration] is negative, the returned future completes with an
  /// [ArgumentError].
  ///
  /// If the future from the previous call to [elapse] has not yet completed,
  /// the returned future completes with a [StateError].
  ///
  /// Any Timers created within a [run] callback which are scheduled to expire
  /// at or before the new time after the elapsement, are run, each in their
  /// own event loop frame as normal, except that there is no actual delay
  /// before each timer run.  When a timer is run, `now()` will have been
  /// elapsed by the timer's specified duration, potentially more if there were
  /// calls to [elapseSync] as well.
  ///
  /// When there are no more timers to run, or the next timer is beyond the
  /// end time (time when called + [duration]), `now()` is elapsed to the end
  /// time, and the returned Future is completed.
  Future elapse(Duration duration);

  /// Simulate the synchronous elapsement of this time by [duration].
  ///
  /// If [duration] is negative, throws an [ArgumentError].
  void elapseSync(Duration duration);

  /// Runs [callback] in a [Zone] which implements
  /// [ZoneSpecification.createTimer] and
  /// [ZoneSpecification.createPeriodicTimer] to create timers which will be
  /// called during the completion of Futures returned from [elapse].
  /// [callback] is called with `this`.
  run(callback(FakeTime self));
}

class _FakeTime extends FakeTime {

  DateTime _now;
  DateTime _advancingTo;
  Completer _elapseCompleter;

  _FakeTime({DateTime initialTime}) : super._() {
    _now = initialTime == null ? new DateTime.now() : initialTime;
  }

  Clock get clock => new Clock(() => _now);

  Future elapse(Duration duration) {
    if (duration.inMicroseconds < 0) {
      return new Future.error(
          new ArgumentError('Cannot call elapse with negative duration'));
    }
    if (_advancingTo != null) {
      return new Future.error(
          new StateError('Cannot elapse until previous elapse is complete.'));
    }
    _advancingTo = _now.add(duration);
    _elapseCompleter = new Completer();
    return _elapseCompleter.future;
  }

  void elapseSync(Duration duration) {
    if (duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call elapse with negative duration');
    }
    _now = _now.add(duration);
  }

  run(callback(FakeTime self)) {
    if (_zone == null) {
      _zone = Zone.current.fork(specification: _zoneSpec);
    }
    return _zone.runGuarded(() => callback(this));
  }
  Zone _zone;

  ZoneSpecification get _zoneSpec => new ZoneSpecification(
      createTimer: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Duration duration,
          Function callback) {
        var bound = self.bindCallback(callback, runGuarded: true);
        return _createTimer(duration, bound, false);
      },
      createPeriodicTimer: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Duration duration,
          Function callback) {
        var bound = self.bindUnaryCallback(callback, runGuarded: true);
        return _createTimer(duration, bound, true);
      },
      scheduleMicrotask: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Function microtask) {
        var bound = self.bindCallback(microtask, runGuarded: true);
        parent.scheduleMicrotask(zone, bound);
      },
      run: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Function f) {
        var ret = parent.run(zone, f);
        _scheduleTimer(self, parent, zone);
        return ret;
      },
      runUnary: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Function f,
          arg) {
        var ret = parent.runUnary(zone, f, arg);
        _scheduleTimer(self, parent, zone);
        return ret;
      },
      runBinary: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Function f,
          arg1,
          arg2) {
        var ret = parent.runBinary(zone, f, arg1, arg2);
        _scheduleTimer(self, parent, zone);
        return ret;
      });

  _elapseTo(DateTime to) {
    if (to.millisecondsSinceEpoch > _now.millisecondsSinceEpoch) {
      _now = to;
    }
  }

  Map<int, _FakeTimer> _timers = {};
  var _nextTimerId = 1;
  bool _waitingForTimer = false;

  _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var id = _nextTimerId++;
    return _timers[id] =
        new _FakeTimer._(duration, callback, isPeriodic, this, id);
  }

  _scheduleTimer(Zone self, ZoneDelegate parent, Zone zone) {

    if (!_waitingForTimer && _advancingTo != null) {
      var next = _getNextTimer();
      var completeTimer = next != null ?
          self.bindCallback(() => _runTimer(next), runGuarded: true) :
          () {
            _elapseTo(_advancingTo);
            _advancingTo = null;
            _elapseCompleter.complete();
            _elapseCompleter = null;
          };
      parent.createTimer(zone, Duration.ZERO, () {
        completeTimer();
        _waitingForTimer = false;
      });

      _waitingForTimer = true;
    }
  }

  _FakeTimer _getNextTimer() {
    return min(_timers.values.where((timer) =>
        timer._nextCall.millisecondsSinceEpoch <= _now.millisecondsSinceEpoch ||
        (_advancingTo != null &&
         timer._nextCall.millisecondsSinceEpoch <=
         _advancingTo.millisecondsSinceEpoch)
    ), (timer1, timer2) => timer1._nextCall.compareTo(timer2._nextCall));
  }

  _runTimer(_FakeTimer timer) {
    assert(timer.isActive);
    _elapseTo(timer._nextCall);
    if (timer._isPeriodic) {
      timer._callback(timer);
      timer._nextCall = timer._nextCall.add(timer._duration);
    } else {
      timer._callback();
      _timers.remove(timer._id);
    }
  }

  _cancelTimer(_FakeTimer timer) => _timers.remove(timer._id);

}

class _FakeTimer implements Timer {

  final int _id;
  final Duration _duration;
  final Function _callback;
  final bool _isPeriodic;
  final _FakeTime _time;
  DateTime _nextCall;

  // TODO: In browser JavaScript, timers can only run every 4 milliseconds once
  // sufficiently nested:
  //     http://www.w3.org/TR/html5/webappapis.html#timer-nesting-level
  // Without some sort of delay this can lead to infinitely looping timers.
  // What do the dart VM and dart2js timers do here?
  static const _minDuration = Duration.ZERO;

  _FakeTimer._(Duration duration, this._callback, this._isPeriodic, this._time,
      this._id)
      : _duration = duration < _minDuration ? _minDuration : duration {
    _nextCall = _time.clock.now().add(_duration);
  }

  bool get isActive => _time._timers.containsKey(_id);

  cancel() => _time._cancelTimer(this);
}

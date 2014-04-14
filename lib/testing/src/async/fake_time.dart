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
/// Time can also be elapsed synchronously ([elapseBlocking]) to simulate
/// blocking or expensive calls, in this case timers are not called.
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
  /// [elapse] or [elapseBlocking].
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
  /// calls to [elapseBlocking] as well.
  ///
  /// When there are no more timers to run, or the next timer is beyond the
  /// end time (time when called + [duration]), `now()` is elapsed to the end
  /// time, and the returned Future is completed.
  void elapse(Duration duration);

  /// Simulate a blocking or expensive call, which causes [duration] to elapse.
  ///
  /// If [duration] is negative, throws an [ArgumentError].
  void elapseBlocking(Duration duration);

  /// Runs [callback] in a [Zone] which implements
  /// [ZoneSpecification.createTimer] and
  /// [ZoneSpecification.createPeriodicTimer] to create timers which will be
  /// called during the completion of Futures returned from [elapse].
  /// [callback] is called with `this`.
  run(callback(FakeTime self));
}

class _FakeTime extends FakeTime {

  DateTime _now;
  DateTime _elapsingTo;

  _FakeTime({DateTime initialTime}) : super._() {
    _now = initialTime == null ? new DateTime.now() : initialTime;
  }

  Clock get clock => new Clock(() => _now);

  void elapse(Duration duration) {
    if (duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call elapse with negative duration');
    }
    if (_elapsingTo != null) {
      throw new StateError('Cannot elapse until previous elapse is complete.');
    }
    _elapsingTo = _now.add(duration);
    _drainMicrotasks();
    Timer next;
    while ((next = _getNextTimer()) != null) {
      _runTimer(next);
      _drainMicrotasks();
    }
    _elapseTo(_elapsingTo);
    _elapsingTo = null;
  }

  void elapseBlocking(Duration duration) {
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
          __,
          ___,
          Duration duration,
          Function callback) {
        return _createTimer(duration, callback, false);
      },
      createPeriodicTimer: (
          Zone self,
          __,
          ___,
          Duration duration,
          Function callback) {
        return _createTimer(duration, callback, true);
      },
      scheduleMicrotask: (
          Zone self,
          __,
          ___,
          Function microtask) {
        _microTasks.add(microtask);
      });

  _elapseTo(DateTime to) {
    if (to.millisecondsSinceEpoch > _now.millisecondsSinceEpoch) {
      _now = to;
    }
  }

  Queue<Function> _microTasks = new Queue();

  Set<_FakeTimer> _timers = new Set<_FakeTimer>();
  bool _waitingForTimer = false;

  Timer _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var timer = new _FakeTimer._(duration, callback, isPeriodic, this);
    _timers.add(timer);
    return timer;
  }

  _FakeTimer _getNextTimer() {
    return min(_timers.where((timer) =>
        timer._nextCall.millisecondsSinceEpoch <= _now.millisecondsSinceEpoch ||
        (_elapsingTo != null &&
         timer._nextCall.millisecondsSinceEpoch <=
         _elapsingTo.millisecondsSinceEpoch)
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
      _timers.remove(timer);
    }
  }

  _drainMicrotasks() {
    while(_microTasks.isNotEmpty) {
      _microTasks.removeFirst()();
    }
  }

  _cancelTimer(_FakeTimer timer) => _timers.remove(timer);

}

class _FakeTimer implements Timer {

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

  _FakeTimer._(Duration duration, this._callback, this._isPeriodic, this._time)
      : _duration = duration < _minDuration ? _minDuration : duration {
    _nextCall = _time.clock.now().add(_duration);
  }

  bool get isActive => _time._timers.contains(this);

  cancel() => _time._cancelTimer(this);
}

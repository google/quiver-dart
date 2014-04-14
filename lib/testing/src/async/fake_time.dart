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
/// Test code can be passed as a callback to [run], which causes it to be run in
/// a [Zone] which fakes timer and microtask creation, such that they are run
/// during calls to [elapse] which simulates the asynchronous passage of time.
///
/// The synchronous passage of time (blocking or expensive calls) can also be
/// simulated using [elapseBlocking].
///
/// To allow the unit under test to tell time, it can receive a [Clock] as a
/// dependency, and default it to [SYSTEM_CLOCK] in production, but then use
/// [clock] in test code.
///
/// Example:
///
///     test('testedFunc', () {
///       new FakeTime().run((time) {
///         testedFunc(clock: time.clock);
///         time.elapse(duration);
///         expect(...)
///       });
///     });
abstract class FakeTime {

  /// [initialTime] will be the time returned by [now] before any calls to
  /// [elapse] or [elapseBlocking].
  factory FakeTime({DateTime initialTime}) = _FakeTime;

  FakeTime._();

  /// Returns a fake [Clock] whose time elapses along with this Clock.  Pass
  /// this as a dependency to the unit under test.
  Clock get clock;

  /// Simulates the asynchronous passage of time.
  ///
  /// **This should only be called from within the zone used by [run].**
  ///
  /// If [duration] is negative, the returned future completes with an
  /// [ArgumentError].
  ///
  /// If a previous call to [elapse] has not yet completed, throws a
  /// [StateError].
  ///
  /// Any Timers created within the zone used by [run] which are to expire
  /// at or before the new time after [duration] has elapsed are run.
  /// The microtask queue is processed surrounding each timer.  When a timer is
  /// run, the [clock] will have been advanced by the timer's specified
  /// duration.  Calls to [elapseBlocking] from within these timers and
  /// microtasks which cause the [clock] to elapse more than the specified
  /// [duration], can cause more timers to expire and thus be called.
  ///
  /// Once all expired timers are processed, the [clock] is advanced (if
  /// necessary) to the time this method was called + [duration].
  void elapse(Duration duration);

  /// Simulates the synchronous passage of time, resulting from blocking or
  /// expensive calls.
  ///
  /// Neither timers nor microtasks are run during this call.  Upon return, the
  /// [clock] will have been advanced by [duration].
  ///
  /// If [duration] is negative, throws an [ArgumentError].
  void elapseBlocking(Duration duration);

  /// Runs [callback] in a [Zone] with fake timer and microtask scheduling.
  ///
  /// Uses
  /// [ZoneSpecification.createTimer], [ZoneSpecification.createPeriodicTimer],
  /// and [ZoneSpecification.scheduleMicrotask] to store callbacks for later
  /// execution within the zone via calls to [elapse].
  ///
  /// [callback] is called with `this` as argument.
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
    if (_elapsingTo != null && _now.isAfter(_elapsingTo)) {
      _elapsingTo = _now;
    }
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
          _,
          __,
          ___,
          Duration duration,
          Function callback) {
        return _createTimer(duration, callback, false);
      },
      createPeriodicTimer: (
          _,
          __,
          ___,
          Duration duration,
          Function callback) {
        return _createTimer(duration, callback, true);
      },
      scheduleMicrotask: (
          _,
          __,
          ___,
          Function microtask) {
        _microtasks.add(microtask);
      });

  _elapseTo(DateTime to) {
    if (to.millisecondsSinceEpoch > _now.millisecondsSinceEpoch) {
      _now = to;
    }
  }

  Queue<Function> _microtasks = new Queue();

  Set<_FakeTimer> _timers = new Set<_FakeTimer>();
  bool _waitingForTimer = false;

  Timer _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var timer = new _FakeTimer._(duration, callback, isPeriodic, this);
    _timers.add(timer);
    return timer;
  }

  _FakeTimer _getNextTimer() {
    return min(_timers.where((timer) => !timer._nextCall.isAfter(_elapsingTo)),
        (timer1, timer2) => timer1._nextCall.compareTo(timer2._nextCall));
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
    while (_microtasks.isNotEmpty) {
      _microtasks.removeFirst()();
    }
  }

  _hasTimer(_FakeTimer timer) => _timers.contains(timer);

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

  bool get isActive => _time._hasTimer(this);

  cancel() => _time._cancelTimer(this);
}

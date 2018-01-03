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
/// dependency, and default it to [const Clock()] in production, but then use
/// [clock] in test code.
///
/// Example:
///
///     test('testedFunc', () {
///       new FakeAsync().run((async) {
///         testedFunc(clock: async.getClock(initialTime));
///         async.elapse(duration);
///         expect(...)
///       });
///     });
abstract class FakeAsync {
  factory FakeAsync() = _FakeAsync;

  /// Returns a fake [Clock] whose time can is elapsed by calls to [elapse] and
  /// [elapseBlocking].
  ///
  /// The returned clock starts at [initialTime], and calls to [elapse] and
  /// [elapseBlocking] advance the clock, even if they occured before the call
  /// to this method.
  ///
  /// The clock can be passed as a dependency to the unit under test.
  Clock getClock(DateTime initialTime);

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
  /// Calls [callback] with `this` as argument and returns the result returned
  /// by [callback].
  dynamic run(callback(FakeAsync self));

  /// Runs all remaining microtasks, including those scheduled as a result of
  /// running them, until there are no more microtasks scheduled.
  ///
  /// Does not run timers.
  void flushMicrotasks();

  /// Runs all timers until no timers remain (subject to [flushPeriodicTimers]
  /// option), including those scheduled as a result of running them.
  ///
  /// [timeout] lets you set the maximum amount of time the flushing will take.
  /// Throws a [StateError] if the [timeout] is exceeded. The default timeout
  /// is 1 hour. [timeout] is relative to the elapsed time.
  void flushTimers(
      {Duration timeout: const Duration(hours: 1),
      bool flushPeriodicTimers: true});

  /// The number of created periodic timers that have not been canceled.
  int get periodicTimerCount;

  /// The number of pending non periodic timers that have not been canceled.
  int get nonPeriodicTimerCount;

  /// The number of pending microtasks.
  int get microtaskCount;
}

class _FakeAsync implements FakeAsync {
  Duration _elapsed = Duration.ZERO;
  Duration _elapsingTo;
  Queue<Function> _microtasks = new Queue();
  Set<_FakeTimer> _timers = new Set<_FakeTimer>();

  @override
  Clock getClock(DateTime initialTime) =>
      new Clock(() => initialTime.add(_elapsed));

  @override
  void elapse(Duration duration) {
    if (duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call elapse with negative duration');
    }
    if (_elapsingTo != null) {
      throw new StateError('Cannot elapse until previous elapse is complete.');
    }
    _elapsingTo = _elapsed + duration;
    _drainTimersWhile((_FakeTimer next) => next._nextCall <= _elapsingTo);
    _elapseTo(_elapsingTo);
    _elapsingTo = null;
  }

  @override
  void elapseBlocking(Duration duration) {
    if (duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call elapse with negative duration');
    }
    _elapsed += duration;
    if (_elapsingTo != null && _elapsed > _elapsingTo) {
      _elapsingTo = _elapsed;
    }
  }

  @override
  void flushMicrotasks() {
    _drainMicrotasks();
  }

  @override
  void flushTimers(
      {Duration timeout: const Duration(hours: 1),
      bool flushPeriodicTimers: true}) {
    final absoluteTimeout = _elapsed + timeout;
    _drainTimersWhile((_FakeTimer timer) {
      if (timer._nextCall > absoluteTimeout) {
        throw new StateError(
            'Exceeded timeout ${timeout} while flushing timers');
      }
      if (flushPeriodicTimers) {
        return _timers.isNotEmpty;
      } else {
        // translation: drain every timer (periodic or not) that will occur up
        // until the latest non-periodic timer
        return _timers.any((_FakeTimer timer) =>
            !timer._isPeriodic || timer._nextCall <= _elapsed);
      }
    });
  }

  @override
  run(callback(FakeAsync self)) {
    if (_zone == null) {
      _zone = Zone.current.fork(specification: _zoneSpec);
    }
    var result;
    _zone.runGuarded(() {
      result = callback(this);
    });
    return result;
  }

  Zone _zone;

  @override
  int get periodicTimerCount =>
      _timers.where((_FakeTimer timer) => timer._isPeriodic).length;

  @override
  int get nonPeriodicTimerCount =>
      _timers.where((_FakeTimer timer) => !timer._isPeriodic).length;

  @override
  int get microtaskCount => _microtasks.length;

  ZoneSpecification get _zoneSpec => new ZoneSpecification(
          createTimer: (_, __, ___, Duration duration, Function callback) {
        return _createTimer(duration, callback, false);
      }, createPeriodicTimer:
              (_, __, ___, Duration duration, Function callback) {
        return _createTimer(duration, callback, true);
      }, scheduleMicrotask: (_, __, ___, Function microtask) {
        _microtasks.add(microtask);
      });

  _drainTimersWhile(bool predicate(_FakeTimer timer)) {
    _drainMicrotasks();
    _FakeTimer next;
    while ((next = _getNextTimer()) != null && predicate(next)) {
      _runTimer(next);
      _drainMicrotasks();
    }
  }

  _elapseTo(Duration to) {
    if (to > _elapsed) {
      _elapsed = to;
    }
  }

  Timer _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var timer = new _FakeTimer._(duration, callback, isPeriodic, this);
    _timers.add(timer);
    return timer;
  }

  _FakeTimer _getNextTimer() {
    return _timers.isEmpty
        ? null
        : _timers.reduce((t1, t2) => t1._nextCall <= t2._nextCall ? t1 : t2);
  }

  _runTimer(_FakeTimer timer) {
    assert(timer.isActive);
    _elapseTo(timer._nextCall);
    if (timer._isPeriodic) {
      timer._callback(timer);
      timer._nextCall += timer._duration;
    } else {
      _timers.remove(timer);
      timer._callback();
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
  final _FakeAsync _time;
  Duration _nextCall;

  // TODO: In browser JavaScript, timers can only run every 4 milliseconds once
  // sufficiently nested:
  //     http://www.w3.org/TR/html5/webappapis.html#timer-nesting-level
  // Without some sort of delay this can lead to infinitely looping timers.
  // What do the dart VM and dart2js timers do here?
  static const _minDuration = Duration.ZERO;

  _FakeTimer._(Duration duration, this._callback, this._isPeriodic, this._time)
      : _duration = duration < _minDuration ? _minDuration : duration {
    _nextCall = _time._elapsed + _duration;
  }

  bool get isActive => _time._hasTimer(this);

  cancel() => _time._cancelTimer(this);

  @override
  // TODO: Dart 2.0 requires this method to be implemented.
  // ignore: override_on_non_overriding_getter
  int get tick {
    throw new UnimplementedError("tick");
  }
}

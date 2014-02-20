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

part of quiver.testing.time;

abstract class FakeClock extends Clock {

  factory FakeClock({DateTime initialTime}) = _FakeClock;

  FakeClock._();

  /// Simulate the asynchronous passage of [duration].
  ///
  /// If [duration] is negative, the returned future completes with an
  /// [ArgumentError].
  ///
  /// If the future from the previous call to [advance] has not yet completed,
  /// the returned future completes with a [StateError].
  ///
  /// The advancement of this clock (and the completion of the returned future)
  /// will not occur until some later turn of the event loop (after the
  /// microtask queue has been drained).
  ///
  /// This should only be called when `Zone.current == zone` (or possibly
  /// a fork of [zone]).
  ///
  /// Timers created within [zone] which are scheduled to expire at or before
  /// the new time after the advancement will be run before the returned future
  /// completes.  When these timers are run, `now()` will return a time not
  /// before the scheduled expiration time of the timer, potentially later if
  /// there were calls to `advanceSync`.
  ///
  ///
  Future advance(Duration duration);

  /// Simulate the synchronous passage of [duration].
  ///
  /// If [duration] is negative, throws an ArgumentError.
  void advanceSync(Duration duration);


  /// The valid zone in which to call [advance].  This zone implements
  /// [ZoneSpecification.createTimer] and
  /// [ZoneSpecification.createPeriodicTimer] to create timers which will be
  /// called during the completion of Futures returned from [advance].
  Zone zone;
}

class _FakeClock extends FakeClock {

  DateTime _now;
  DateTime _advancingTo;
  Completer _advanceCompleter;

  _FakeClock({DateTime initialTime}) : super._() {
    _now = initialTime == null ? new DateTime.now() : initialTime;
  }

  DateTime now() => _now;

  Future advance(Duration duration) {
    if(duration.inMicroseconds < 0) {
      return new Future.error(new ArgumentError('Cannot call advance with negative duration'));
    }
    if(_advancingTo != null) {
      return new Future.error(new StateError('Cannot advance until previous advance is complete.'));
    }
    _advancingTo = _now.add(duration);
    _advanceCompleter = new Completer();
    return _advanceCompleter.future;
  }

  void advanceSync(Duration duration) {
    if(duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call advance with negative duration');
    }
    _now = _now.add(duration);
  }

  Zone get zone {
    if(_zone == null) {
      _zone = Zone.current.fork(specification: _zoneSpec);
    }
    return _zone;
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

  _advanceTo(DateTime to) {
    if(to.millisecondsSinceEpoch > _now.millisecondsSinceEpoch) {
      _now = to;
    }
  }

  Map<int, _FakeTimer> _timers = {};
  var _nextTimerId = 1;
  bool _waitingForTimer = false;

  _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var id = _nextTimerId++;
    return _timers[id] = new _FakeTimer._(duration, callback, isPeriodic, this, id);
  }

  _scheduleTimer(Zone self, ZoneDelegate parent, Zone zone) {

    if(!_waitingForTimer && _advancingTo != null) {
      var next = _getNextTimer();
      var completeTimer = next != null ?
          self.bindCallback(() => _runTimer(next), runGuarded: true) :
          () {
            _advanceTo(_advancingTo);
            _advancingTo = null;
            _advanceCompleter.complete();
            _advanceCompleter = null;
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
         timer._nextCall.millisecondsSinceEpoch <= _advancingTo.millisecondsSinceEpoch)
    ), (timer1, timer2) => timer1._nextCall.compareTo(timer2._nextCall));
  }

  _runTimer(_FakeTimer timer) {
    assert(timer.isActive);
    _advanceTo(timer._nextCall);
    if(timer._isPeriodic) {
      timer._callback(timer);
      // Move forward by at least 1 microsecond to avoid infinite loop.
      // TODO: Move forward more (e.g. 15 - 20 milliseconds) ?
      var duration = new Duration(microseconds: math.max(timer._duration.inMicroseconds, 1));
      timer._nextCall = timer._nextCall.add(duration);
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
  final _FakeClock _clock;
  DateTime _nextCall;

  _FakeTimer._(this._duration, this._callback, this._isPeriodic, this._clock, this._id) {
    _nextCall = _clock.now().add(_duration.inMicroseconds.isNegative ? Duration.ZERO : _duration);
  }

  bool get isActive => _clock._timers.containsKey(_id);

  cancel() => _clock._cancelTimer(this);
}

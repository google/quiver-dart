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

part of quiver.testing.time;

class FakeClock extends Clock {

  DateTime _now;

  FakeClock({DateTime initialTime}) {
    _now = initialTime == null ? new DateTime.now() : initialTime;
  }

  DateTime now() => _now;

  static ZoneSpecification get _zoneSpec => new ZoneSpecification(
      createTimer: _getZoneSpecTimerCallback(false),
      createPeriodicTimer: _getZoneSpecTimerCallback(true)
//      ,
//      handleUncaughtError: (
//          Zone self,
//          ZoneDelegate parent,
//          Zone zone,
//          e,
//          StackTrace stackTrace) {
//        print('uncaught: $e');
//        return parent.handleUncaughtError(zone, e, stackTrace);
//      }
      );

  static _getZoneSpecTimerCallback(bool periodic) => (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      Duration duration,
      Function callback) => self[#fakeClock]._createTimer(duration, callback, periodic);

  Zone get zone => Zone.current.fork(specification: _zoneSpec, zoneValues: {#fakeClock: this});

  bool _isAdvancing = false;

  void advance(Duration duration) {

    if(duration.inMicroseconds < 0) {
      throw new ArgumentError('Cannot call advance with negative Duration');
    }
    if(_isAdvancing) {
      throw new StateError('Cannot advance until previous advance is complete.');
    }
    _isAdvancing = true;
    var to = _now.add(duration);
    _FakeTimer next;
    while((next = getNextTimer(_now, to)) != null) {
      _now = next._nextCall;
      _runTimer(next);
    }
    _now = to;
    _isAdvancing = false;
  }

  _FakeTimer getNextTimer(DateTime from, DateTime to) {
    return min(_timers.values.where((timer) {
      return timer._nextCall.millisecondsSinceEpoch >= from.millisecondsSinceEpoch &&
             timer._nextCall.millisecondsSinceEpoch <= to.millisecondsSinceEpoch;
    }), (timer1, timer2) => timer1._nextCall.compareTo(timer2._nextCall));
  }

  static var _nextTimerId = 1;

  Map<int, _FakeTimer> _timers = {};
  _createTimer(Duration duration, Function callback, bool isPeriodic) {
    var id = _nextTimerId++;
    return _timers[id] = new _FakeTimer._(duration, callback, isPeriodic, this, id);
  }
  _runTimer(_FakeTimer timer) {
    assert(timer.isActive);
    if(timer._isPeriodic) {
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
  final FakeClock _clock;
  DateTime _nextCall;

  _FakeTimer._(this._duration, this._callback, this._isPeriodic, this._clock, this._id) {
    _nextCall = _clock.now().add(_duration);
  }

  bool get isActive => _clock._timers.containsKey(_id);

  cancel() => _clock._cancelTimer(this);
}

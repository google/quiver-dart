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

/// Returns the current test time in microseconds.
typedef int Now();

/// A [Stopwatch] implementation that gets the current time in microseconds
/// via a user-supplied function.
class FakeStopwatch implements Stopwatch {
  Now _now;
  int frequency;
  int _start;
  int _stop;

  FakeStopwatch(int now(), int this.frequency)
      : _now = now,
        _start = null,
        _stop = null;

  void start() {
    if (isRunning) return;
    if (_start == null) {
      _start = _now();
    } else {
      _start = _now() - (_stop - _start);
      _stop = null;
    }
  }

  void stop() {
    if (!isRunning) return;
    _stop = _now();
  }

  void reset() {
    if (_start == null) return;
    _start = _now();
    if (_stop != null) {
      _stop = _start;
    }
  }

  int get elapsedTicks {
    if (_start == null) {
      return 0;
    }
    return (_stop == null) ? (_now() - _start) : (_stop - _start);
  }

  Duration get elapsed => new Duration(microseconds: elapsedMicroseconds);

  int get elapsedMicroseconds => (elapsedTicks * 1000000) ~/ frequency;

  int get elapsedMilliseconds => (elapsedTicks * 1000) ~/ frequency;

  bool get isRunning => _start != null && _stop == null;
}

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

/// Provides current time
abstract class TimeProvider {
  DateTime call();
}

class _SystemTimeProvider implements TimeProvider {
  const _SystemTimeProvider();
  DateTime call() => new DateTime.now();
}

/// Same as [TimeProvider] but in the form of a function.
typedef DateTime TimeFunction();

/// Time provider that gets time from a function.
class FunctionTimeProvider implements TimeProvider {
  final TimeFunction _timeFunction;
  FunctionTimeProvider(DateTime this._timeFunction());
  DateTime call() => _timeFunction();
}

/// Always returns time provided by user. Useful in unit-tests.
class FixedTimeProvider implements TimeProvider {
  DateTime time;
  FixedTimeProvider(this.time);
  DateTime call() => time;
}

/// Uses system clock to obtain current time
const TimeProvider SYSTEM_TIME = const _SystemTimeProvider();

/// Provides points in time relative to the current point in time. The current
/// point in time is defined by a [TimeProvider] (see constructors for how to
/// supply time providers).
class Clock {

  final TimeProvider _time;

  /// Creates [Clock] based on the system clock.
  Clock() : _time = SYSTEM_TIME;

  /// Creates [Clock] based on user-defined [TypeProvider].
  Clock.custom(this._time);

  /// Creates [Clock] that uses the time provided by the user as the current
  /// time.
  Clock.fixed(DateTime time) : _time = new FixedTimeProvider(time);

  /// Create [Clock] that gets time from a function.
  Clock.fromFunc(TimeFunction func) : _time = new FunctionTimeProvider(func);

  /// Returns current time.
  DateTime now() => _time();

  /// Returns the point in time [Duration] amount of time ago.
  DateTime ago(Duration duration) => now().subtract(duration);

  /// Returns the point in time [Duration] amount of time from now.
  DateTime fromNow(Duration duration) => now().add(duration);

  /// Return the point in time [micros] microseconds ago.
  DateTime microsAgo(int micros) => ago(new Duration(microseconds: micros));

  /// Return the point in time [micros] microseconds from now.
  DateTime microsFromNow(int micros) => microsAgo(-micros);

  /// Return the point in time [millis] milliseconds ago.
  DateTime millisAgo(int millis) => ago(new Duration(milliseconds: millis));

  /// Return the point in time [millis] milliseconds from now.
  DateTime millisFromNow(int millis) => millisAgo(-millis);

  /// Return the point in time [seconds] ago.
  DateTime secondsAgo(int seconds) => ago(new Duration(seconds: seconds));

  /// Return the point in time [seconds] from now.
  DateTime secondsFromNow(int seconds) => secondsAgo(-seconds);

  /// Return the point in time [minutes] ago.
  DateTime minutesAgo(int minutes) => ago(new Duration(minutes: minutes));

  /// Return the point in time [minutes] from now.
  DateTime minutesFromNow(int minutes) => minutesAgo(-minutes);

  /// Return the point in time [hours] ago.
  DateTime hoursAgo(int hours) => ago(new Duration(hours: hours));

  /// Return the point in time [hours] from now.
  DateTime hoursFromNow(int hours) => hoursAgo(-hours);

  /// Return the point in time [days] ago.
  DateTime daysAgo(int days) => ago(new Duration(days: days));

  /// Return the point in time [days] from now.
  DateTime daysFromNow(int days) => daysAgo(-days);

  /// Return the point in time [weeks] ago.
  DateTime weeksAgo(int weeks) => ago(new Duration(days: 7 * weeks));

  /// Return the point in time [weeks] from now.
  DateTime weeksFromNow(int weeks) => weeksAgo(-weeks);

  /// Return the point in time [months] ago on the same date.
  DateTime monthsAgo(int months) {
    var time = now();
    return new DateTime(
        time.year,
        time.month - months,
        time.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond
    );
  }

  /// Return the point in time [months] from now on the same date.
  DateTime monthsFromNow(int months) => monthsAgo(-months);

  /// Return the point in time [years] ago on the same date.
  DateTime yearsAgo(int years) {
    var time = now();
    return new DateTime(
        time.year - years,
        time.month,
        time.day,
        time.hour,
        time.minute,
        time.second,
        time.millisecond
    );
  }

  /// Return the point in time [years] from now on the same date.
  DateTime yearsFromNow(int years) => yearsAgo(-years);
}

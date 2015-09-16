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

/// Returns current time.
typedef DateTime TimeFunction();

/// Return current system time.
DateTime systemTime() => new DateTime.now();

/// Days in a month. This array uses 1-based month numbers, i.e. January is
/// the 1-st element in the array, not the 0-th.
const _DAYS_IN_MONTH =
    const [ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

int _daysInMonth(int year, int month) => (month == DateTime.FEBRUARY &&
    _isLeapYear(year)) ? 29 : _DAYS_IN_MONTH[month];

bool _isLeapYear(int year) =>
    (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));

/// Takes a [date] that may be outside the allowed range of dates for a given
/// [month] in a given [year] and returns the closest date that is within the
/// allowed range.
///
/// For example:
///
/// February 31, 2013 => February 28, 2013
///
/// When jumping from month to month or from leap year to common year we may
/// end up in a month that has fewer days than the month we are jumping from.
/// In that case it is impossible to preserve the exact date. So we "clamp" the
/// date value to fit within the month. For example, jumping from March 31 one
/// month back takes us to February 28 (or 29 during a leap year), as February
/// doesn't have 31-st date.
int _clampDate(int date, int year, int month) =>
    date.clamp(1, _daysInMonth(year, month));

/// Provides points in time relative to the current point in time, for example:
/// now, 2 days ago, 4 weeks from now, etc.
///
/// This class is designed with testability in mind. The current point in time
/// (or [now()]) is defined by a [TimeFunction]. By supplying your own time
/// function or by using fixed clock (see constructors), you can control
/// exactly what time a [Clock] returns and base your test expectations on
/// that. See specific constructors for how to supply time functions.
class Clock {
  final TimeFunction _time;

  /// Creates a clock based on the given [timeFunc].
  ///
  /// If [timeFunc] is not provided, creates [Clock] based on system clock.
  ///
  /// Custom [timeFunc] can be useful in unit-tests. For example, you might
  /// want to control what time it is now and set date and time expectations in
  /// your test cases.
  const Clock([TimeFunction timeFunc = systemTime]) : _time = timeFunc;

  /// Creates [Clock] that returns fixed [time] value. Useful in unit-tests.
  Clock.fixed(DateTime time) : _time = (() => time);

  /// Returns current time.
  DateTime now() => _time();

  /// Returns the point in time [Duration] amount of time ago.
  DateTime agoBy(Duration duration) => now().subtract(duration);

  /// Returns the point in time [Duration] amount of time from now.
  DateTime fromNowBy(Duration duration) => now().add(duration);

  /// Returns the point in time that's given amount of time ago. The
  /// amount of time is the sum of individual parts. Parts are compatible with
  /// ones defined in [Duration].
  DateTime ago({int days: 0, int hours: 0, int minutes: 0, int seconds: 0,
      int milliseconds: 0, int microseconds: 0}) => agoBy(new Duration(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
          microseconds: microseconds));

  /// Returns the point in time that's given amount of time from now. The
  /// amount of time is the sum of individual parts. Parts are compatible with
  /// ones defined in [Duration].
  DateTime fromNow({int days: 0, int hours: 0, int minutes: 0, int seconds: 0,
      int milliseconds: 0, int microseconds: 0}) => fromNowBy(new Duration(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
          microseconds: microseconds));

  /// Return the point in time [micros] microseconds ago.
  DateTime microsAgo(int micros) => ago(microseconds: micros);

  /// Return the point in time [micros] microseconds from now.
  DateTime microsFromNow(int micros) => fromNow(microseconds: micros);

  /// Return the point in time [millis] milliseconds ago.
  DateTime millisAgo(int millis) => ago(milliseconds: millis);

  /// Return the point in time [millis] milliseconds from now.
  DateTime millisFromNow(int millis) => fromNow(milliseconds: millis);

  /// Return the point in time [seconds] ago.
  DateTime secondsAgo(int seconds) => ago(seconds: seconds);

  /// Return the point in time [seconds] from now.
  DateTime secondsFromNow(int seconds) => fromNow(seconds: seconds);

  /// Return the point in time [minutes] ago.
  DateTime minutesAgo(int minutes) => ago(minutes: minutes);

  /// Return the point in time [minutes] from now.
  DateTime minutesFromNow(int minutes) => fromNow(minutes: minutes);

  /// Return the point in time [hours] ago.
  DateTime hoursAgo(int hours) => ago(hours: hours);

  /// Return the point in time [hours] from now.
  DateTime hoursFromNow(int hours) => fromNow(hours: hours);

  /// Return the point in time [days] ago.
  DateTime daysAgo(int days) => ago(days: days);

  /// Return the point in time [days] from now.
  DateTime daysFromNow(int days) => fromNow(days: days);

  /// Return the point in time [weeks] ago.
  DateTime weeksAgo(int weeks) => ago(days: 7 * weeks);

  /// Return the point in time [weeks] from now.
  DateTime weeksFromNow(int weeks) => fromNow(days: 7 * weeks);

  /// Return the point in time [months] ago on the same date.
  DateTime monthsAgo(int months) {
    var time = now();
    var m = (time.month - months - 1) % 12 + 1;
    var y = time.year - (months + 12 - time.month) ~/ 12;
    var d = _clampDate(time.day, y, m);
    return new DateTime(
        y, m, d, time.hour, time.minute, time.second, time.millisecond);
  }

  /// Return the point in time [months] from now on the same date.
  DateTime monthsFromNow(int months) {
    var time = now();
    var m = (time.month + months - 1) % 12 + 1;
    var y = time.year + (months + time.month - 1) ~/ 12;
    var d = _clampDate(time.day, y, m);
    return new DateTime(
        y, m, d, time.hour, time.minute, time.second, time.millisecond);
  }

  /// Return the point in time [years] ago on the same date.
  DateTime yearsAgo(int years) {
    var time = now();
    var y = time.year - years;
    var d = _clampDate(time.day, y, time.month);
    return new DateTime(y, time.month, d, time.hour, time.minute, time.second,
        time.millisecond);
  }

  /// Return the point in time [years] from now on the same date.
  DateTime yearsFromNow(int years) => yearsAgo(-years);
}

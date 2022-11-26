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

/// Days in a month. This array uses 1-based month numbers, i.e. January is
/// the 1-st element in the array, not the 0-th.
const _daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// Returns the number of days in the specified month.
///
/// This function assumes the use of the Gregorian calendar or the proleptic
/// Gregorian calendar.
int daysInMonth(int year, int month) =>
    (month == DateTime.february && isLeapYear(year)) ? 29 : _daysInMonth[month];

/// Returns true if [year] is a leap year.
///
/// This implements the Gregorian calendar leap year rules wherein a year is
/// considered to be a leap year if it is divisible by 4, excepting years
/// divisible by 100, but including years divisible by 400.
///
/// This function assumes the use of the Gregorian calendar or the proleptic
/// Gregorian calendar.
bool isLeapYear(int year) =>
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
int clampDayOfMonth({
  required int year,
  required int month,
  required int day,
}) =>
    day.clamp(1, daysInMonth(year, month));

///return the day which is xth [weekDay] from yth [week] of zth [month] of a [year]
///eg. DateTime.Friday from 2nd week of DateTime.july of a 2022 year.
/// [weekDay] ranges from 1 to 7. 1 = monday and 7 = sunday.
/// [week] ranges from 1 to 4 or 5 month depending upon the month.
/// [month] ranges from 1 to 12. 1 is january and 12 is december.
/// [year] the year in which you are calculating
/// if the number of week is more than the weeks in specific month day will be from another month
DateTime nthDayOnNthWeekOfAMonth(
  int weekDay,
  int week,
  int month,
  int year,
) {
  final firstDateOfMonth = DateTime(year, month, 1);
  return firstDateOfMonth.add(
    Duration(
      days: 7 * (week - 1) +
          ((firstDateOfMonth.weekday > weekDay ? 7 : 0) +
              weekDay -
              firstDateOfMonth.weekday),
    ),
  );
}

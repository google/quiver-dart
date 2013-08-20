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

library quiver.time.clock_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/time.dart';

main() {
  group('clock', () {
    var subject = new Clock.fixed(new DateTime(2013));

    test("should return time based on system time and not fail", () {
      expect(new Clock(), isNotNull);
    });

    test("should return time provided by custom TimeProvider", () {
      var fixedTimeProvider = new FixedTimeProvider(new DateTime(2013));
      var fixedClock = new Clock.custom(fixedTimeProvider);
      expect(fixedClock.now(), new DateTime(2013));

      fixedTimeProvider.time = new DateTime(2014);
      expect(fixedClock.now(), new DateTime(2014));
    });

    test("should return fixed time", () {
      expect(new Clock.fixed(new DateTime(2013)).now(), new DateTime(2013));
    });

    test("should return time provided by custom TimeFunction", () {
      expect(new Clock.fromFunc(() => new DateTime(2013)).now(),
          new DateTime(2013));
    });

    test("should return time Duration ago", () {
      expect(subject.ago(new Duration(days: 366)), new DateTime(2012));
    });

    test("should return time Duration from now", () {
      expect(subject.fromNow(new Duration(days: 365)), new DateTime(2014));
    });

    test("should return time micros ago", () {
      expect(subject.microsAgo(1000),
          new DateTime(2012, 12, 31, 23, 59, 59, 999));
    });

    test("should return time micros from now", () {
      expect(subject.microsFromNow(1000),
          new DateTime(2013, 1, 1, 0, 0, 0, 1));
    });

    test("should return time millis ago", () {
      expect(subject.millisAgo(1000),
          new DateTime(2012, 12, 31, 23, 59, 59, 000));
    });

    test("should return time millis from now", () {
      expect(subject.millisFromNow(3),
          new DateTime(2013, 1, 1, 0, 0, 0, 3));
    });

    test("should return time seconds ago", () {
      expect(subject.secondsAgo(10),
          new DateTime(2012, 12, 31, 23, 59, 50, 000));
    });

    test("should return time seconds from now", () {
      expect(subject.secondsFromNow(3),
          new DateTime(2013, 1, 1, 0, 0, 3, 0));
    });

    test("should return time minutes ago", () {
      expect(subject.minutesAgo(10),
          new DateTime(2012, 12, 31, 23, 50, 0, 000));
    });

    test("should return time minutes from now", () {
      expect(subject.minutesFromNow(3),
          new DateTime(2013, 1, 1, 0, 3, 0, 0));
    });

    test("should return time hours ago", () {
      expect(subject.hoursAgo(10),
          new DateTime(2012, 12, 31, 14, 0, 0, 000));
    });

    test("should return time hours from now", () {
      expect(subject.hoursFromNow(3),
          new DateTime(2013, 1, 1, 3, 0, 0, 0));
    });

    test("should return time days ago", () {
      expect(subject.daysAgo(10),
          new DateTime(2012, 12, 22, 0, 0, 0, 000));
    });

    test("should return time days from now", () {
      expect(subject.daysFromNow(3),
          new DateTime(2013, 1, 4, 0, 0, 0, 0));
    });

    test("should return time months ago on the same date", () {
      expect(subject.monthsAgo(1),
          new DateTime(2012, 12, 1, 0, 0, 0, 000));
      expect(subject.monthsAgo(2),
          new DateTime(2012, 11, 1, 0, 0, 0, 000));
      expect(subject.monthsAgo(3),
          new DateTime(2012, 10, 1, 0, 0, 0, 000));
      expect(subject.monthsAgo(4),
          new DateTime(2012, 9, 1, 0, 0, 0, 000));
    });

    test("should return time months from now on the same date", () {
      expect(subject.monthsFromNow(1),
          new DateTime(2013, 2, 1, 0, 0, 0, 0));
      expect(subject.monthsFromNow(2),
          new DateTime(2013, 3, 1, 0, 0, 0, 0));
      expect(subject.monthsFromNow(3),
          new DateTime(2013, 4, 1, 0, 0, 0, 0));
      expect(subject.monthsFromNow(4),
          new DateTime(2013, 5, 1, 0, 0, 0, 0));
    });

    test("should return time years ago on the same date", () {
      expect(subject.yearsAgo(1),
          new DateTime(2012, 1, 1, 0, 0, 0, 000));  // leap year
      expect(subject.yearsAgo(2),
          new DateTime(2011, 1, 1, 0, 0, 0, 000));
      expect(subject.yearsAgo(3),
          new DateTime(2010, 1, 1, 0, 0, 0, 000));
      expect(subject.yearsAgo(4),
          new DateTime(2009, 1, 1, 0, 0, 0, 000));
      expect(subject.yearsAgo(5),
          new DateTime(2008, 1, 1, 0, 0, 0, 000));  // leap year
      expect(subject.yearsAgo(6),
          new DateTime(2007, 1, 1, 0, 0, 0, 000));
      expect(subject.yearsAgo(30),
          new DateTime(1983, 1, 1, 0, 0, 0, 000));
      expect(subject.yearsAgo(2013),
          new DateTime(0, 1, 1, 0, 0, 0, 000));
    });

    test("should return time years from now on the same date", () {
      expect(subject.yearsFromNow(1),
          new DateTime(2014, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(2),
          new DateTime(2015, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(3),
          new DateTime(2016, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(4),
          new DateTime(2017, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(5),
          new DateTime(2018, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(6),
          new DateTime(2019, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(30),
          new DateTime(2043, 1, 1, 0, 0, 0, 0));
      expect(subject.yearsFromNow(1000),
          new DateTime(3013, 1, 1, 0, 0, 0, 0));
    });

  });
}

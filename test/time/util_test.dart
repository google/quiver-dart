// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the 'License');
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library quiver.time.util_test;

import 'package:quiver/src/time/util.dart';
import 'package:test/test.dart';

void expectDate(DateTime date, int y, [int m = 1, int d = 1]) {
  expect(date, DateTime(y, m, d));
}

void main() {
  group('util', () {
    test('should return the date of friday from 2nd week of july of 2022', () {
      final calculatedDate =
          nthDayOnNthWeekOfAMonth(DateTime.friday, 2, DateTime.july, 2022);
      expectDate(calculatedDate, 2022, 7, 8);
    });
  });
}

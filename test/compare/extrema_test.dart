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

library quiver.compare.extrema_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/time.dart';
import 'package:quiver/compare.dart';

main() {

  group('min', () {

    test('should return lower when not equal', () {
      expect(min(aSecond, aMinute), aSecond);
    });

    test('should return first argument when equal', () {
      expect(min(aSecond, aSecond * 1), same(aSecond));
    });

    test('should use `compare` to compare items', () {
      expect(min(1, 0, compare: (a, b) => -1), 1);
    });

  });

  group('max', () {

    test('should return upper when not equal', () {
      expect(max(aSecond, aMinute), aMinute);
    });

    test('should return first argument when equal', () {
      expect(max(aSecond, aSecond * 1), same(aSecond));
    });

    test('should use `compare` to compare items', () {
      expect(max(1, 0, compare: (a, b) => -1), 0);
    });

  });

  group('clamp', () {

    test('should return lower when value less than lower', () {
      expect(clamp(aMillisecond, aSecond, aMinute), aSecond);
    });

    test('should return upper when value greater than upper', () {
      expect(clamp(anHour, aSecond, aMinute), aMinute);
    });

    test('should return value when equal to lower', () {
      var aSecondCopy = new Duration(seconds: 1);
      expect(clamp(aSecondCopy, aSecond, aMinute), same(aSecondCopy));
    });

    test('should return value when equal to upper', () {
      var aMinuteCopy = new Duration(minutes: 1);
      expect(clamp(aMinuteCopy, aSecond, aMinute), same(aMinuteCopy));
    });

    test('should use `compare` to compare items', () {
      var d = (a, b) => b.compareTo(a);
      expect(clamp(anHour, aMinute, aSecond, compare: d), aMinute);
      expect(clamp(aMillisecond, aMinute, aSecond, compare: d), aSecond);
      expect(clamp(aMinute, anHour, aSecond, compare: d), aMinute);
    });

  });

  group('minOf', () {

    test('should return the minimum element', () {
      expect(minOf([2,5,1,4]), 1);
    });

    test('should return null if empty', () {
      expect(minOf([]), null);
    });

    test('should return result of orElse if empty and orElse null', () {
      expect(minOf([], orElse: () => 5), 5);
    });

  });

  group('maxOf', () {

    test('should return the maximum element', () {
      expect(maxOf([2,5,1,4]), 5);
    });

    test('should return null if empty and orElse null', () {
      expect(maxOf([]), null);
    });

    test('should return result of orElse if empty and orElse not null', () {
      expect(maxOf([], orElse: () => 5), 5);
    });

  });


}

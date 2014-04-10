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

library quiver.compare.comparators_test;

import 'package:unittest/unittest.dart';
import 'package:quiver/compare.dart';

main() {

  group('by', () {

    test('should return comparator which compares by result of key', () {
      var b = by((s) => s.length);
      expect(b('*', '**'), -1);
      expect(b('*', '*'), 0);
      expect(b('**', '*'), 1);
    });

    test('should use `compare` to compare items', () {
      expect(by((s) => s.length, compare: (a, b) => 0)('*', '**'), 0);
    });

  });

  group('reverse', () {

    test('should return upper when not equal', () {
      var d = reverse();
      expect(d(0, 1), 1);
      expect(d(0, 0), 0);
      expect(d(1, 0), -1);
    });

    test('should use `compare` to compare items', () {
      var d = reverse(compare: (a, b) => 0);
      expect(d(5, 10), 0);
      expect(d(10, 5), 0);
    });

  });

  group('lexicographic', () {

    test('should treat shorter length arg as less when it prefixes other', () {
      expect(lexicographic()([0, 1], [0, 1, 2]), -1);
    });

    test('should ignore length when shorter does not prefix other', () {
      expect(lexicographic()([1, 2], [0, 1, 2]), 1);
    });

    test('should compare equal when same elements', () {
      expect(lexicographic()([0, 1, 2], [0, 1, 2]), 0);
    });

    test('should compare elements pairwise until non-zero result found', () {
      expect(lexicographic()([0, 1, 3], [0, 1, 2]), 1);
      expect(lexicographic()([0, 1, 2], [0, 1, 3]), -1);
    });

    test('should use `compare` to compare elements', () {
      var l = lexicographic(compare: (a, b) => -1);
      expect(l([0], [1]), -1);
      expect(l([1], [0]), -1);
    });

  });

  group('compound', () {

    test('should use tie breaker comparator when zero', () {
      expect(compound((a, b) => -1)(0, 0), -1);
    });

    test('should use base comparator when non-zero', () {
      expect(compound((a, b) => -1)(0, 1), -1);
      expect(compound((a, b) => -1)(1, 0), 1);
    });

    test('should respect custom base comparator', () {
      expect(compound((a, b) => -1, base: (a, b) => 1)(0, 0), 1);
    });

  });

  group('nullsFirst', () {

    test('should consider two nulls equal', () {
      expect(nullsFirst()(null, null), 0);
    });

    test('should order null less than non-nulls', () {
      expect(nullsFirst()(null, 0), -1);
      expect(nullsFirst()(0, null), 1);
    });

    test('should order two non-nulls using `compare`', () {
      expect(nullsFirst()(0, 1), -1);
      expect(nullsFirst()(0, 0), 0);
      expect(nullsFirst()(1, 0), 1);
      expect(nullsFirst(compare: (a, b) => -1)(1, 0), -1);
    });

  });

  group('nullsLast', () {

    test('should consider two nulls equal', () {
      expect(nullsLast()(null, null), 0);
    });

    test('should order null greater than non-nulls', () {
      expect(nullsLast()(null, 0), 1);
      expect(nullsLast()(0, null), -1);
    });

    test('should order two non-nulls using `compare`', () {
      expect(nullsLast()(0, 1), -1);
      expect(nullsLast()(0, 0), 0);
      expect(nullsLast()(1, 0), 1);
      expect(nullsLast(compare: (a, b) => -1)(1, 0), -1);
    });

  });

}

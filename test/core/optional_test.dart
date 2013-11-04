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

library quiver.core.optional_test;

import 'package:quiver/core.dart';
import 'package:unittest/matcher.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Optional', () {
    test('absent should be not present and not gettable', () {
      expect(new Optional<int>.absent().isPresent, isFalse);
      expect(() => new Optional<int>.absent().value, throws);
    });

    test('of should return value', () {
      expect(new Optional<int>.of(7).value, 7);
    });

    test('isPresent should execute only if present', () {
      int value;
      new Optional<int>.of(7).ifPresent((v) { value = v; });
      expect(value, 7);
      new Optional<int>.absent().ifPresent((v) { value = v; });
      expect(value, 7);
    });

    test('isAbsent should execute only if absent', () {
      int value;
      new Optional<int>.of(7).ifAbsent(() { value = 7; });
      expect(value, null);
      new Optional<int>.absent().ifAbsent(() { value = 7; });
      expect(value, 7);
    });

    test('fromNullable should allow present or absent', () {
      expect(new Optional<int>.fromNullable(7).value, 7);
      expect(new Optional<int>.fromNullable(null).isPresent, isFalse);
    });

    test('or should return present and replace absent', () {
      expect(new Optional<int>.fromNullable(7).or(13), 7);
      expect(new Optional<int>.fromNullable(null).or(13), 13);
    });

    test('orNull should return value if present or null if absent', () {
      expect(new Optional<int>.fromNullable(7).orNull, isNotNull);
      expect(new Optional<int>.fromNullable(null).orNull, isNull);
    });

    test('transform should return transformed value or absent', () {
      expect(
          new Optional<int>.fromNullable(7).transform((a) => a + 1),
          equals(new Optional<int>.of(8)));
      expect(
          new Optional<int>.fromNullable(null).transform((a) => a + 1).isPresent,
          isFalse);
    });

    test('hashCode should allow optionals to be in hash sets', () {
      expect(
          new Set.from(
              [new Optional<int>.of(7), new Optional<int>.of(8), new Optional<int>.absent()]),
              equals(new Set.from(
                  [new Optional<int>.of(7), new Optional<int>.of(8), new Optional<int>.absent()])));
      expect(
          new Set.from([new Optional<int>.of(7), new Optional<int>.of(8)]),
          isNot(equals(new Set.from([new Optional<int>.of(7), new Optional<int>.of(9)]))));
    });

    test('== should compare by value', () {
      expect(new Optional<int>.of(7), equals(new Optional<int>.of(7)));
      expect(
          new Optional<int>.fromNullable(null),
          equals(new Optional<int>.fromNullable(null)));
      expect(new Optional<int>.fromNullable(null), isNot(equals(new Optional<int>.of(7))));
      expect(new Optional<int>.of(7), isNot(equals(new Optional<int>.of(8))));
    });

    test('toString should show the value or absent', () {
      expect(new Optional<int>.of(7).toString(), equals('Optional { value: 7 }'));
      expect(
          new Optional<int>.fromNullable(null).toString(),
          equals('Optional { absent }'));
    });
  });
}

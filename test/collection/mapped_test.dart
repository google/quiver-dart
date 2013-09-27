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

library quiver.collection.mapped_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

main() {
  group('Mapped', () {
    test('should be instantiable from a List', () {
      var other = new Map<int, String>();
      other[1] = 'one';
      other[2] = 'two';
      other[3] = 'three';

      var mapped = new Mapped<int, String>(other);

      expect(mapped[2], equals('two'));
      expect(mapped.length, equals(3));
      expect(() => new Mapped<int, String>(["3", "3"]), throws);
      expect(() => new Mapped<int, String>([3, 3]), throws);
    });

    test('should be instantiable from a Map', () {
      var mapped = new Mapped<String, int>({
          'one': 1,
          'two': 2,
          'three': 3,
      });

      expect(mapped['two'], 2);
      expect(mapped.length, 3);

      expect(() => new Mapped<int, int>({
          'one': 1,
          'two': 2,
          'three': 3,
      }), throws);

      expect(() => new Mapped<String, String>({
          'one': 1,
          'two': 2,
          'three': 3,
     }), throws);
    });

    test('should not be modifiable via []=', () {
      var mapped = new Mapped<int, String>([
        1, 'one',
        2, 'two',
        3, 'three'
      ]);

      expect(() => mapped[4] = 'four', throws);
    });

    test('should implement +', () {
      var mapped = new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three'
      ]);

      var mapped2 = mapped + [4, 'four'];
      var mapped3 = mapped2 + [5, 'five', 6, 'six'];
      var mapped4 = mapped3 + new Mapped<int, String>([7, 'seven']);

      expect(mapped4 == new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three',
          4, 'four',
          5, 'five',
          6, 'six',
          7, 'seven']),
          isTrue);
    });

    test('should implement +=', () {
      var mapped = new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three'
      ]);

      mapped += [4, 'four'];
      mapped += [5, 'five', 6, 'six'];
      mapped += new Mapped<int, String>([7, 'seven']);

      expect(mapped == new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three',
          4, 'four',
          5, 'five',
          6, 'six',
          7, 'seven']),
          isTrue);
      expect(mapped[4] == 'four', isTrue);
    });

    test('show throw on wrong type for +', () {
      var mapped = new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three'
      ]);

      expect(() => mapped + 5, throws);
      expect(() => mapped + [5], throws);
      expect(() => mapped + ["5", "5"], throws);
      expect(() => mapped + [5, 5], throws);
      expect(() => mapped + new Mapped<String, String>(["5", "5"]), throws);
    });

    test('should implement deep equals', () {
      var map1 = new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three'
      ]);

      var map2 = new Mapped<int, String>([
          3, 'three',
          2, 'two',
          1, 'one',
      ]);

      var map3 = new Mapped<int, String>([
          7, 'seven',
          2, 'two',
          3, 'three'
      ]);

      expect(map1 == map2, isTrue);
      expect(map1 == map3, isFalse);
    });

    test('should implement deep hashCode', () {
      var map1 = new Mapped<int, String>([
          1, 'one',
          2, 'two',
          3, 'three'
      ]);

      var map2 = new Mapped<int, String>([
          3, 'three',
          2, 'two',
          1, 'one',
      ]);

      var map3 = new Mapped<int, String>([
          7, 'seven',
          2, 'two',
          3, 'three'
      ]);

      expect(map1.hashCode == map2.hashCode, isTrue);
      expect(map1.hashCode == map3.hashCode, isFalse);
    });
  });
}

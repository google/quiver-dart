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

library quiver.core.tuples_test;

import 'package:quiver/core.dart';
import 'package:unittest/unittest.dart';

main() {

  group('Tuple2', () {

    makeIt() => new Tuple2<String, int>('a', 0);

    Tuple2<String, int> it;
    setUp(() {
      it = makeIt();
    });

    test('length should be 2', () {
      expect(it, hasLength(2));
    });

    test('last should be second', () {
      expect(it.last, it.second);
    });

    test('elementAt(0) should yield first', () {
      expect(it.elementAt(0), it.first);
    });

    test('elementAt(1) should yield second', () {
      expect(it.elementAt(1), it.second);
    });

    test('elementAt should throw for invalid indexes', () {
      expect(() => it.elementAt(-1), throws);
      expect(() => it.elementAt(2), throws);
    });

    test('should iterate each item', () {
      expect(it.toList(), [it.first, it.second]);
    });

    test('equals should be true iff key and value are equal', () {
      expect(it, makeIt());
      var differentFirst = 'b';
      expect(it, isNot(equals(new Tuple2(differentFirst, 0))));
      var differentLast = 1;
      expect(it, isNot(equals(new Tuple2('a', differentLast))));
    });

    test('hashCode should be equal if key and value are equal', () {
        expect(it.hashCode, makeIt().hashCode);
    });

  });

  group('Tuple3', () {

    makeIt() => new Tuple3<String, int, int>('a', 0, 1);

    Tuple3<String, int, int> it;
    setUp(() {
      it = makeIt();
    });

    test('length should be 3', () {
      expect(it, hasLength(3));
    });

    test('last should be third', () {
      expect(it.last, it.third);
    });

    test('elementAt(2) should yield third', () {
      expect(it.elementAt(2), it.third);
    });

    test('should iterate each item', () {
      expect(it.toList(), [it.first, it.second, it.third]);
    });

    test('equals should be true iff key and value are equal', () {
      expect(it, makeIt());
      var differentLast = 0;
      expect(it, isNot(equals(new Tuple3('a', 0, differentLast))));
    });

    test('hashCode should be equal if key and value are equal', () {
        expect(it.hashCode, makeIt().hashCode);
    });

  });

  group('Tuple4', () {

    makeIt() => new Tuple4<String, int, int, int>('a', 0, 1, 2);

    Tuple4<String, int, int, int> it;
    setUp(() {
      it = makeIt();
    });

    test('length should be 4', () {
      expect(it, hasLength(4));
    });

    test('last should be fourth', () {
      expect(it.last, it.fourth);
    });

    test('elementAt(3) should yield fourth', () {
      expect(it.elementAt(3), it.fourth);
    });

    test('should iterate each item', () {
      expect(it.toList(), [it.first, it.second, it.third, it.fourth]);
    });

    test('equals should be true iff key and value are equal', () {
      expect(it, makeIt());
      var differentLast = 0;
      expect(it, isNot(equals(new Tuple4('a', 0, 1, differentLast))));
    });

    test('hashCode should be equal if key and value are equal', () {
        expect(it.hashCode, makeIt().hashCode);
    });

  });
}

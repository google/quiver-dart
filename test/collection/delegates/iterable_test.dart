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

library quiver.collection.delegates.iterable_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('DelegatedIterable', () {
    DelegatedIterable<String> delegatedIterable;
    setUp((){
      delegatedIterable = new DelegatedIterable(['a', 'b', 'cc']);
    });
    test('any', () {
      expect(delegatedIterable.any((e) => e == 'b'), isTrue);
      expect(delegatedIterable.any((e) => e == 'd'), isFalse);
    });
    test('contains', () {
      expect(delegatedIterable.contains('b'), isTrue);
      expect(delegatedIterable.contains('d'), isFalse);
    });
    test('elementAt', () {
      expect(delegatedIterable.elementAt(1), equals('b'));
    });
    test('every', () {
      expect(delegatedIterable.every((e) => e is String), isTrue);
      expect(delegatedIterable.every((e) => e == 'b'), isFalse);
    });
    test('expand', () {
      expect(delegatedIterable.expand((e) => e.codeUnits),
          equals([97, 98, 99, 99]));
    });
    test('first', () {
      expect(delegatedIterable.first, equals('a'));
    });
    test('firstWhere', () {
      expect(delegatedIterable.firstWhere((e) => e == 'b'), equals('b'));
      expect(delegatedIterable.firstWhere((e) => e == 'd', orElse: () => 'e'),
          equals('e'));
    });
    test('fold', () {
      expect(delegatedIterable.fold('z', (p, e) => p + e), equals('zabcc'));
    });
    test('forEach', () {
      final s = new StringBuffer();
      delegatedIterable.forEach((e) => s.write(e));
      expect(s.toString(), equals('abcc'));
    });
    test('isEmpty', () {
      expect(delegatedIterable.isEmpty, isFalse);
      expect(new DelegatedIterable([]).isEmpty, isTrue);
    });
    test('isNotEmpty', () {
      expect(delegatedIterable.isNotEmpty, isTrue);
      expect(new DelegatedIterable([]).isNotEmpty, isFalse);
    });
    test('forEach', () {
      final it = delegatedIterable.iterator;
      expect(it.current, isNull);
      expect(it.moveNext(), isTrue);
      expect(it.current, equals('a'));
      expect(it.moveNext(), isTrue);
      expect(it.current, equals('b'));
      expect(it.moveNext(), isTrue);
      expect(it.current, equals('cc'));
      expect(it.moveNext(), isFalse);
      expect(it.current, isNull);
    });
    test('join', () {
      expect(delegatedIterable.join(), equals('abcc'));
      expect(delegatedIterable.join(','), equals('a,b,cc'));
    });
    test('last', () {
      expect(delegatedIterable.last, equals('cc'));
    });
    test('lastWhere', () {
      expect(delegatedIterable.lastWhere((e) => e == 'b'), equals('b'));
      expect(delegatedIterable.lastWhere((e) => e == 'd', orElse: () => 'e'),
          equals('e'));
    });
    test('length', () {
      expect(delegatedIterable.length, equals(3));
    });
    test('map', () {
      expect(delegatedIterable.map((e) => e.toUpperCase()),
          equals(['A','B','CC']));
    });
    test('reduce', () {
      expect(delegatedIterable.reduce((value, element) => value + element),
          equals('abcc'));
    });
    test('single', () {
      expect(() => delegatedIterable.single, throws);
      expect(new DelegatedIterable(['a']).single, equals('a'));
    });
    test('singleWhere', () {
      expect(delegatedIterable.singleWhere((e) => e == 'b'), equals('b'));
      expect(() => delegatedIterable.singleWhere((e) => e == 'd'), throws);
    });
    test('skip', () {
      expect(delegatedIterable.skip(1), equals(['b', 'cc']));
    });
    test('skipWhile', () {
      expect(delegatedIterable.skipWhile((e) => e == 'a'), equals(['b', 'cc']));
    });
    test('take', () {
      expect(delegatedIterable.take(1), equals(['a']));
    });
    test('skipWhile', () {
      expect(delegatedIterable.takeWhile((e) => e == 'a'), equals(['a']));
    });
    test('toList', () {
      expect(delegatedIterable.toList(), equals(['a', 'b', 'cc']));
    });
    test('toSet', () {
      expect(delegatedIterable.toSet(),
          equals(new Set<String>.from(['a', 'b', 'cc'])));
    });
    test('where', () {
      expect(delegatedIterable.where((e) => e.length == 1), equals(['a', 'b']));
    });
  });
}

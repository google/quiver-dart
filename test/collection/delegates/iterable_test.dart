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

class MyIterable extends DelegatingIterable<String> {
  final Iterable<String> _delegate;

  MyIterable(this._delegate);

  Iterable<String> get delegate => _delegate;
}

void main() {
  group('DelegatingIterable', () {
    DelegatingIterable<String> delegatingIterable;

    setUp((){
      delegatingIterable = new MyIterable(['a', 'b', 'cc']);
    });

    test('any', () {
      expect(delegatingIterable.any((e) => e == 'b'), isTrue);
      expect(delegatingIterable.any((e) => e == 'd'), isFalse);
    });

    test('contains', () {
      expect(delegatingIterable.contains('b'), isTrue);
      expect(delegatingIterable.contains('d'), isFalse);
    });

    test('elementAt', () {
      expect(delegatingIterable.elementAt(1), equals('b'));
    });

    test('every', () {
      expect(delegatingIterable.every((e) => e is String), isTrue);
      expect(delegatingIterable.every((e) => e == 'b'), isFalse);
    });

    test('expand', () {
      expect(delegatingIterable.expand((e) => e.codeUnits),
          equals([97, 98, 99, 99]));
    });

    test('first', () {
      expect(delegatingIterable.first, equals('a'));
    });

    test('firstWhere', () {
      expect(delegatingIterable.firstWhere((e) => e == 'b'), equals('b'));
      expect(delegatingIterable.firstWhere((e) => e == 'd', orElse: () => 'e'),
          equals('e'));
    });

    test('fold', () {
      expect(delegatingIterable.fold('z', (p, e) => p + e), equals('zabcc'));
    });

    test('forEach', () {
      final s = new StringBuffer();
      delegatingIterable.forEach((e) => s.write(e));
      expect(s.toString(), equals('abcc'));
    });

    test('isEmpty', () {
      expect(delegatingIterable.isEmpty, isFalse);
      expect(new MyIterable([]).isEmpty, isTrue);
    });

    test('isNotEmpty', () {
      expect(delegatingIterable.isNotEmpty, isTrue);
      expect(new MyIterable([]).isNotEmpty, isFalse);
    });

    test('forEach', () {
      final it = delegatingIterable.iterator;
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
      expect(delegatingIterable.join(), equals('abcc'));
      expect(delegatingIterable.join(','), equals('a,b,cc'));
    });

    test('last', () {
      expect(delegatingIterable.last, equals('cc'));
    });

    test('lastWhere', () {
      expect(delegatingIterable.lastWhere((e) => e == 'b'), equals('b'));
      expect(delegatingIterable.lastWhere((e) => e == 'd', orElse: () => 'e'),
          equals('e'));
    });

    test('length', () {
      expect(delegatingIterable.length, equals(3));
    });

    test('map', () {
      expect(delegatingIterable.map((e) => e.toUpperCase()),
          equals(['A','B','CC']));
    });

    test('reduce', () {
      expect(delegatingIterable.reduce((value, element) => value + element),
          equals('abcc'));
    });

    test('single', () {
      expect(() => delegatingIterable.single, throws);
      expect(new MyIterable(['a']).single, equals('a'));
    });

    test('singleWhere', () {
      expect(delegatingIterable.singleWhere((e) => e == 'b'), equals('b'));
      expect(() => delegatingIterable.singleWhere((e) => e == 'd'), throws);
    });

    test('skip', () {
      expect(delegatingIterable.skip(1), equals(['b', 'cc']));
    });

    test('skipWhile', () {
      expect(delegatingIterable.skipWhile((e) => e == 'a'),
          equals(['b', 'cc']));
    });

    test('take', () {
      expect(delegatingIterable.take(1), equals(['a']));
    });

    test('skipWhile', () {
      expect(delegatingIterable.takeWhile((e) => e == 'a'), equals(['a']));
    });

    test('toList', () {
      expect(delegatingIterable.toList(), equals(['a', 'b', 'cc']));
    });

    test('toSet', () {
      expect(delegatingIterable.toSet(),
          equals(new Set<String>.from(['a', 'b', 'cc'])));
    });

    test('where', () {
      expect(delegatingIterable.where((e) => e.length == 1),
          equals(['a', 'b']));
    });
  });
}

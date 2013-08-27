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

library quiver.collection.delegates.map_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('DelegatedMap', () {
    DelegatedMap<String, int> delegatedMap;
    setUp((){
      delegatedMap = new DelegatedMap({'a': 1, 'bb': 2});
    });
    test('[]', () {
      expect(delegatedMap['a'], equals(1));
      expect(delegatedMap['bb'], equals(2));
      expect(delegatedMap['c'], isNull);
    });
    test('[]=', () {
      delegatedMap['a'] = 3;
      delegatedMap['c'] = 4;
      expect(delegatedMap, equals({'a': 3, 'bb': 2, 'c': 4}));
    });
    test('addAll', () {
      delegatedMap.addAll({'a': 3, 'c': 4});
      expect(delegatedMap, equals({'a': 3, 'bb': 2, 'c': 4}));
    });
    test('clear', () {
      delegatedMap.clear();
      expect(delegatedMap, equals({}));
    });
    test('containsKey', () {
      expect(delegatedMap.containsKey('a'), isTrue);
      expect(delegatedMap.containsKey('b'), isFalse);
    });
    test('containsValue', () {
      expect(delegatedMap.containsValue(1), isTrue);
      expect(delegatedMap.containsValue('b'), isFalse);
    });
    test('forEach', () {
      final s = new StringBuffer();
      delegatedMap.forEach((k,v) => s.write('$k$v'));
      expect(s.toString(), equals('a1bb2'));
    });
    test('isEmpty', () {
      expect(delegatedMap.isEmpty, isFalse);
      expect(new DelegatedMap({}).isEmpty, isTrue);
    });
    test('isNotEmpty', () {
      expect(delegatedMap.isNotEmpty, isTrue);
      expect(new DelegatedMap({}).isNotEmpty, isFalse);
    });
    test('keys', () {
      expect(delegatedMap.keys, equals(['a','bb']));
    });
    test('length', () {
      expect(delegatedMap.length, equals(2));
      expect(new DelegatedMap({}).length, equals(0));
    });
    test('putIfAbsent', () {
      expect(delegatedMap.putIfAbsent('c', () => 4), equals(4));
      expect(delegatedMap.putIfAbsent('c', () => throw ''), equals(4));
    });
    test('remove', () {
      expect(delegatedMap.remove('a'), equals(1));
      expect(delegatedMap, equals({'bb': 2}));
    });
    test('values', () {
      expect(delegatedMap.values, equals([1, 2]));
    });
  });
}

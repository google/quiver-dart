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

library quiver.collection.delegates.set_test;

import 'dart:collection' show LinkedHashSet;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('DelegatedSet', () {
    DelegatedSet<String> delegatedSet;
    setUp((){
      delegatedSet = new DelegatedSet<String>(
          new LinkedHashSet<String>.from(['a', 'b', 'cc']));
    });
    test('add', () {
      delegatedSet.add('d');
      expect(delegatedSet, equals(['a', 'b', 'cc', 'd']));
      delegatedSet.add('d');
      expect(delegatedSet, equals(['a', 'b', 'cc', 'd']));
    });
    test('addAll', () {
      delegatedSet.addAll(['d', 'e']);
      expect(delegatedSet, equals(['a', 'b', 'cc', 'd', 'e']));
    });
    test('clear', () {
      delegatedSet.clear();
      expect(delegatedSet, equals([]));
    });
    test('containsAll', () {
      expect(delegatedSet.containsAll(['a', 'cc']), isTrue);
      expect(delegatedSet.containsAll(['a', 'c']), isFalse);
    });
    // skip because :
    // Test failed: Caught type 'LinkedHashSet<String>' is not a subtype of type
    // 'HashSet<String>' of 'result'.
    skip_test('difference', () {
      expect(delegatedSet.difference(new Set<String>.from(['a', 'cc'])),
          equals(['b']));
      expect(delegatedSet.difference(new Set<String>.from(['cc'])),
          equals(['a', 'b']));
    });
    test('intersection', () {
      expect(delegatedSet.intersection(new Set<String>.from(['a', 'dd'])),
          equals(['a']));
      expect(delegatedSet.intersection(new Set<String>.from(['e'])),
          equals([]));
    });
    test('remove', () {
      expect(delegatedSet.remove('b'), isTrue);
      expect(delegatedSet, equals(['a', 'cc']));
    });
    test('removeAll', () {
      delegatedSet.removeAll(['a', 'cc']);
      expect(delegatedSet, equals(['b']));
    });
    test('removeWhere', () {
      delegatedSet.removeWhere((e) => e.length == 1);
      expect(delegatedSet, equals(['cc']));
    });
    test('retainAll', () {
      delegatedSet.retainAll(['a', 'cc', 'd']);
      expect(delegatedSet, equals(['a', 'cc']));
    });
    test('retainWhere', () {
      delegatedSet.retainWhere((e) => e.length == 1);
      expect(delegatedSet, equals(['a', 'b']));
    });
    test('union', () {
      expect(delegatedSet.union(
          new LinkedHashSet<String>.from(['a', 'cc', 'd'])),
          equals(['a', 'b', 'cc', 'd']));
    });
  });
}

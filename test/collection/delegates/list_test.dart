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

library quiver.collection.delegates.list_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('DelegatedList', () {
    DelegatedList<String> delegatedList;
    setUp((){
      delegatedList = new DelegatedList(['a', 'b', 'cc']);
    });
    test('[]', () {
      expect(delegatedList[0], equals('a'));
      expect(delegatedList[1], equals('b'));
      expect(delegatedList[2], equals('cc'));
      expect(() => delegatedList[3], throws);
    });
    test('[]=', () {
      delegatedList[0] = 'd';
      expect(delegatedList, equals(['d', 'b', 'cc']));
    });
    test('add', () {
      delegatedList.add('d');
      expect(delegatedList, equals(['a', 'b', 'cc', 'd']));
    });
    test('addAll', () {
      delegatedList.addAll(['d', 'e']);
      expect(delegatedList, equals(['a', 'b', 'cc', 'd', 'e']));
    });
    test('asMap', () {
      expect(delegatedList.asMap(), equals({0: 'a', 1: 'b', 2: 'cc'}));
    });
    test('clear', () {
      delegatedList.clear();
      expect(delegatedList, equals([]));
    });
    test('fillRange', () {
      delegatedList.fillRange(0, 2);
      expect(delegatedList, equals([null, null, 'cc']));
      delegatedList.fillRange(0, 2, 'd');
      expect(delegatedList, equals(['d', 'd', 'cc']));
    });
    test('getRange', () {
      expect(delegatedList.getRange(1, 2), equals(['b']));
      expect(delegatedList.getRange(1, 3), equals(['b', 'cc']));
    });
    test('indexOf', () {
      expect(delegatedList.indexOf('b'), equals(1));
      expect(delegatedList.indexOf('a', 1), equals(-1));
      expect(delegatedList.indexOf('cc', 1), equals(2));
    });
    test('insert', () {
      delegatedList.insert(1, 'd');
      expect(delegatedList, equals(['a', 'd', 'b', 'cc']));
    });
    test('insertAll', () {
      delegatedList.insertAll(1, ['d', 'e']);
      expect(delegatedList, equals(['a', 'd', 'e', 'b', 'cc']));
    });
    test('lastIndexOf', () {
      expect(delegatedList.lastIndexOf('b'), equals(1));
      expect(delegatedList.lastIndexOf('a', 1), equals(0));
      expect(delegatedList.lastIndexOf('cc', 1), equals(-1));
    });
    test('set length', () {
      delegatedList.length = 2;
      expect(delegatedList, equals(['a', 'b']));
    });
    test('remove', () {
      delegatedList.remove('b');
      expect(delegatedList, equals(['a', 'cc']));
    });
    test('removeAt', () {
      delegatedList.removeAt(1);
      expect(delegatedList, equals(['a', 'cc']));
    });
    test('removeLast', () {
      delegatedList.removeLast();
      expect(delegatedList, equals(['a', 'b']));
    });
    test('removeRange', () {
      delegatedList.removeRange(1, 2);
      expect(delegatedList, equals(['a', 'cc']));
    });
    test('removeWhere', () {
      delegatedList.removeWhere((e) => e.length == 1);
      expect(delegatedList, equals(['cc']));
    });
    test('replaceRange', () {
      delegatedList.replaceRange(1, 2, ['d', 'e']);
      expect(delegatedList, equals(['a', 'd', 'e', 'cc']));
    });
    test('retainWhere', () {
      delegatedList.retainWhere((e) => e.length == 1);
      expect(delegatedList, equals(['a', 'b']));
    });
    test('reversed', () {
      expect(delegatedList.reversed, equals(['cc', 'b', 'a']));
    });
    test('setAll', () {
      delegatedList.setAll(1, ['d', 'e']);
      expect(delegatedList, equals(['a', 'd', 'e']));
    });
    test('setRange', () {
      delegatedList.setRange(1, 3, ['d', 'e']);
      expect(delegatedList, equals(['a', 'd', 'e']));
    });
    test('sort', () {
      delegatedList.sort((a,b) => b.codeUnitAt(0) - a.codeUnitAt(0));
      expect(delegatedList, equals(['cc', 'b', 'a']));
    });
    test('sublist', () {
      expect(delegatedList.sublist(1), equals(['b', 'cc']));
      expect(delegatedList.sublist(1, 2), equals(['b']));
    });
  });
}

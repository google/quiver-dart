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

library quiver.collection.delegates.queue_test;

import 'dart:collection' show Queue;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('DelegatedQueue', () {
    DelegatedQueue<String> delegatedQueue;
    setUp((){
      delegatedQueue = new DelegatedQueue<String>(
          new Queue<String>.from(['a', 'b', 'cc']));
    });
    test('add', () {
      delegatedQueue.add('d');
      expect(delegatedQueue, equals(['a', 'b', 'cc', 'd']));
    });
    test('addAll', () {
      delegatedQueue.addAll(['d', 'e']);
      expect(delegatedQueue, equals(['a', 'b', 'cc', 'd', 'e']));
    });
    test('addFirst', () {
      delegatedQueue.addFirst('d');
      expect(delegatedQueue, equals(['d', 'a', 'b', 'cc']));
    });
    test('addLast', () {
      delegatedQueue.addLast('d');
      expect(delegatedQueue, equals(['a', 'b', 'cc', 'd']));
    });
    test('clear', () {
      delegatedQueue.clear();
      expect(delegatedQueue, equals([]));
    });
    test('remove', () {
      expect(delegatedQueue.remove('b'), isTrue);
      expect(delegatedQueue, equals(['a', 'cc']));
    });
    test('removeFirst', () {
      expect(delegatedQueue.removeFirst(), 'a');
      expect(delegatedQueue, equals(['b', 'cc']));
    });
    test('removeLast', () {
      expect(delegatedQueue.removeLast(), 'cc');
      expect(delegatedQueue, equals(['a', 'b']));
    });
  });
}

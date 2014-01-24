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

library quiver.collection.multimap_test;

import 'package:quiver/collection.dart';
import 'package:unittest/unittest.dart';

void main() {
  group('Multimap', () {
    test('should be a list-backed multimap', () {
      var map = new Multimap();
      expect(map is ListMultimap, true);
    });
  });

  group('ListMultimap', () {
    test('should initialize empty', () {
      var map = new ListMultimap();
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
    });

    test('should not be empty after adding', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v');
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
    });

    test('should return the number of keys as length', () {
      var map = new ListMultimap<String, String>();
      expect(map.length, 0);
      map
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.length, 2);
    });

    test('should return an empty iterable for unmapped keys', () {
      var map = new ListMultimap<String, String>();
      expect(map['k1'], []);
    });

    test('should support adding values for unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'].add('v1');
      expect(map['k1'], ['v1']);
    });

    test('should support adding multiple values for unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'].addAll(['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support inserting values for unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'].insert(0, 'v1');
      expect(map['k1'], ['v1']);
    });

    test('should support inserting multiple values for unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'].insertAll(0, ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support inserting multiple values for unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'].length = 2;
      expect(map['k1'], [null, null]);
    });

    test('should return unmapped iterables that stay in sync on add', () {
      var map = new ListMultimap<String, String>();
      List values1 = map['k1'];
      List values2 = map['k1'];
      values1.add('v1');
      expect(map['k1'], ['v1']);
      expect(values2, ['v1']);
    });

    test('should return unmapped iterables that stay in sync on addAll', () {
      var map = new ListMultimap<String, String>();
      List values1 = map['k1'];
      List values2 = map['k1'];
      values1.addAll(['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
      expect(values2, ['v1', 'v2']);
    });

    test('should support adding duplicate values for a key', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v1');
      expect(map['k'], ['v1', 'v1']);
    });

    test('should support adding multiple keys', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should support adding multiple values at once', () {
      var map = new ListMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support adding multiple values at once for existing keys', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v1', 'v2']);
    });

    test('should support adding from another multimap', () {
      var from = new ListMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      var map = new ListMultimap<String, String>()
        ..addAll(from);
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should support adding from another multimap with existing keys', () {
      var from = new ListMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v0')
        ..add('k2', 'v3')
        ..addAll(from);
      expect(map['k1'], ['v0', 'v1', 'v2']);
      expect(map['k2'], ['v3', 'v3']);
    });

    test('should return its keys', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.keys, unorderedEquals(['k1', 'k2']));
    });

    test('should return its values', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should support duplicate values', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v1');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v1']));
    });

    test('should return an ordered list of values', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map['k'], ['v1', 'v2']);
    });

    test('should reflect changes to underlying list', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      map['k'].add('v3');
      map['k'].remove('v2');
      expect(map['k'], ['v1', 'v3']);
    });

    test('should return whether it contains a key', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsKey('j'), false);
      expect(map.containsKey('k'), true);
    });

    test('should return whether it contains a value', () {
      var map = new ListMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsValue('v0'), false);
      expect(map.containsValue('v1'), true);
    });

    test('should remove specified key-value associations', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.remove('k1', 'v0'), false);
      expect(map.remove('k1', 'v1'), true);
      expect(map['k1'], ['v2']);
      expect(map.containsKey('k2'), true);
    });

    test('should remove a key when all associated values are removed', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..remove('k1', 'v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.remove', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].remove('v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAt', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].removeAt(0);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAt', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].removeLast();
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeRange', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].removeRange(0, 1);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeWhere', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].removeWhere((_) => true);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.replaceRange', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].replaceRange(0, 1, []);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainWhere', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].retainWhere((_) => false);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
        'via the underlying iterable.clear', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      map['k1'].clear();
      expect(map.containsKey('k1'), false);
    });

    test('should remove all values for a key', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.removeAll('k1'), ['v1', 'v2']);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), true);
    });

    test('should clear underlying iterable on remove', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      List values = map['k1'];
      expect(map.removeAll('k1'), ['v1']);
      expect(values, []);
    });

    test('should return an empty iterable on removeAll of unmapped key', () {
      var map = new ListMultimap<String, String>();
      var removed = map.removeAll('k1');
      expect(removed, []);
    });

    test('should be uncoupled from the iterable returned by removeAll', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      var removed = map.removeAll('k1');
      removed.add('v2');
      map.add('k1', 'v3');
      expect(removed, ['v1', 'v2']);
      expect(map['k1'], ['v3']);
    });

    test('should clear the map', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..clear();
      expect(map.isEmpty, true);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), false);
    });

    test('should clear underlying iterables on clear', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1');
      List values = map['k1'];
      map.clear();
      expect(values, []);
    });

    test('should not add mappings on lookup of unmapped keys', () {
      var map = new ListMultimap<String, String>()
        ..['k1'];
      expect(map.containsKey('k1'), false);
    });

    test('should not remove mappings on clearing mapped values', () {
      var map = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..['v1'].clear();
      expect(map.containsKey('k1'), true);
    });

    test('should return a map view', () {
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      expect(map.keys, unorderedEquals(['k1', 'k2']));
      expect(map.values, hasLength(2));
      expect(map.values, anyElement(unorderedEquals(['v1', 'v2'])));
      expect(map.values, anyElement(unorderedEquals(['v3'])));
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should return an empty iterable on map view unmapped key', () {
      Map map = new ListMultimap<String, String>().toMap();
      expect(map['k1'], []);
    });

    test('should allow addition via unmapped key lookup on map view', () {
      var mmap = new ListMultimap<String, String>();
      Map map = mmap.toMap();
      map['k1'].add('v1');
      map['k2'].addAll(['v1', 'v2']);
      expect(mmap['k1'], ['v1']);
      expect(mmap['k2'], ['v1', 'v2']);
    });

    test('should reflect additions to iterables returned by map view', () {
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], ['v1', 'v2', 'v3']);
    });

    test('should reflect removals of keys in returned map view', () {
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map.remove('k1');
      expect(mmap.containsKey('k1'), false);
    });

    test('should reflect clearing of returned map view', () {
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      map.clear();
      expect(mmap.isEmpty, true);
    });

    test('should support iteration over all {key, value} pairs', () {
      Set s = new Set();
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEach((k, v) => s.add(new Pair(k, v)));
      expect(s, unorderedEquals(
          [new Pair('k1', 'v1'), new Pair('k1', 'v2'), new Pair('k2', 'v3')]));
    });

    test('should support iteration over all {key, Iterable<value>} pairs', () {
      Map map = new Map();
      var mmap = new ListMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEachKey((k, v) => map[k] = v);
      expect(map.length, mmap.length);
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });
  });

  group('SetMultimap', () {
    test('should initialize empty', () {
      var map = new SetMultimap<String, String>();
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
    });

    test('should not be empty after adding', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v');
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
    });

    test('should return the number of keys as length', () {
      var map = new SetMultimap<String, String>();
      expect(map.length, 0);
      map
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.length, 2);
    });

    test('should return an empty iterable for unmapped keys', () {
      var map = new SetMultimap<String, String>();
      expect(map['k1'], []);
    });

    test('should support adding values for unmapped keys', () {
      var map = new SetMultimap<String, String>()
        ..['k1'].add('v1');
      expect(map['k1'], ['v1']);
    });

    test('should support adding multiple values for unmapped keys', () {
      var map = new SetMultimap<String, String>()
        ..['k1'].addAll(['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
    });

    test('should return unmapped iterables that stay in sync on add', () {
      var map = new SetMultimap<String, String>();
      Set values1 = map['k1'];
      Set values2 = map['k1'];
      values1.add('v1');
      expect(map['k1'], ['v1']);
      expect(values2, ['v1']);
    });

    test('should return unmapped iterables that stay in sync on addAll', () {
      var map = new SetMultimap<String, String>();
      Set values1 = map['k1'];
      Set values2 = map['k1'];
      values1.addAll(['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(values2, unorderedEquals(['v1', 'v2']));
    });

    test('should not support adding duplicate values for a key', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v1');
      expect(map['k'], ['v1']);
    });

    test('should support adding multiple keys', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should support adding multiple values at once', () {
      var map = new SetMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support adding multiple values at once for existing keys', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v0')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v0', 'v1', 'v2']));
    });

    test('should support adding multiple values for existing (key,value)', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
    });

    test('should support adding from another multimap', () {
      var from = new SetMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      var map = new SetMultimap<String, String>()
        ..addAll(from);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should support adding from another multimap with existing keys', () {
      var from = new SetMultimap<String, String>()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v0')
        ..add('k2', 'v3')
        ..addAll(from);
      expect(map['k1'], unorderedEquals(['v0', 'v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should return its keys', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.keys, unorderedEquals(['k1', 'k2']));
    });

    test('should return its values', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should support duplicate values', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v1');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v1']));
    });

    test('should return an ordered list of values', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map['k'], unorderedEquals(['v1', 'v2']));
    });

    test('should reflect changes to underlying set', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      map['k'].add('v3');
      map['k'].remove('v2');
      expect(map['k'], unorderedEquals(['v1', 'v3']));
    });

    test('should return whether it contains a key', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsKey('j'), false);
      expect(map.containsKey('k'), true);
    });

    test('should return whether it contains a value', () {
      var map = new SetMultimap<String, String>()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsValue('v0'), false);
      expect(map.containsValue('v1'), true);
    });

    test('should remove specified key-value associations', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.remove('k1', 'v0'), false);
      expect(map.remove('k1', 'v1'), true);
      expect(map['k1'], ['v2']);
      expect(map.containsKey('k2'), true);
    });

    test('should remove a key when all associated values are removed', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..remove('k1', 'v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.remove', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].remove('v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAll', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      map['k1'].removeAll(['v1', 'v2']);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeWhere', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].removeWhere((_) => true);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainAll', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].retainAll([]);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainWhere', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].retainWhere((_) => false);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
        'via the underlying iterable.clear', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      map['k1'].clear();
      expect(map.containsKey('k1'), false);
    });

    test('should remove all values for a key', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.removeAll('k1'), unorderedEquals(['v1', 'v2']));
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), true);
    });

    test('should clear underlying iterable on remove', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      Set values = map['k1'];
      expect(map.removeAll('k1'), ['v1']);
      expect(values, []);
    });

    test('should return an empty iterable on removeAll of unmapped key', () {
      var map = new SetMultimap<String, String>();
      var removed = map.removeAll('k1');
      expect(removed, []);
    });

    test('should be uncoupled from the iterable returned by removeAll', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      var removed = map.removeAll('k1');
      removed.add('v2');
      map.add('k1', 'v3');
      expect(removed, unorderedEquals(['v1', 'v2']));
      expect(map['k1'], ['v3']);
    });

    test('should clear the map', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..clear();
      expect(map.isEmpty, true);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), false);
    });

    test('should clear underlying iterables on clear', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1');
      Set values = map['k1'];
      map.clear();
      expect(values, []);
    });

    test('should not add mappings on lookup of unmapped keys', () {
      var map = new SetMultimap<String, String>()
        ..['k1'];
      expect(map.containsKey('k1'), false);
    });

    test('should not remove mappings on clearing mapped values', () {
      var map = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..['v1'].clear();
      expect(map.containsKey('k1'), true);
    });

    test('should return a map view', () {
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      expect(map.keys, unorderedEquals(['k1', 'k2']));
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should return an empty iterable on map view unmapped key', () {
      Map map = new SetMultimap<String, String>().toMap();
      expect(map['k1'], []);
    });

    test('should allow addition via unmapped key lookup on map view', () {
      var mmap = new SetMultimap<String, String>();
      Map map = mmap.toMap();
      map['k1'].add('v1');
      map['k2'].addAll(['v1', 'v2']);
      expect(mmap['k1'], ['v1']);
      expect(mmap['k2'], unorderedEquals(['v1', 'v2']));
    });

    test('should reflect additions to iterables returned by map view', () {
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should reflect additions to iterables returned by map view', () {
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should reflect removals of keys in returned map view', () {
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map.remove('k1');
      expect(mmap.containsKey('k1'), false);
    });

    test('should reflect clearing of returned map view', () {
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      map.clear();
      expect(mmap.isEmpty, true);
    });

    test('should support iteration over all {key, value} pairs', () {
      Set s = new Set();
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEach((k, v) => s.add(new Pair(k, v)));
      expect(s, unorderedEquals(
          [new Pair('k1', 'v1'), new Pair('k1', 'v2'), new Pair('k2', 'v3')]));
    });

    test('should support iteration over all {key, Iterable<value>} pairs', () {
      Map map = new Map();
      var mmap = new SetMultimap<String, String>()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEachKey((k, v) => map[k] = v);
      expect(map.length, mmap.length);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(map['k2'], unorderedEquals(['v3']));
    });
  });
}

class Pair {
  final x;
  final y;
  Pair(this.x, this.y);
  bool operator ==(Pair other) => (x == other.x && y == other.y);
  String toString() => "($x, $y)";
}

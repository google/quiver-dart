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
      Multimap map = new Multimap();
      expect(map is ListMultimap, true);
    });
  });

  group('ListMultimap', () {
    test('should initialize empty', () {
      Multimap map = new ListMultimap();
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
    });

    test('should not be empty after adding', () {
      Multimap map = new ListMultimap()
        ..add('k', 'v');
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
    });

    test('should return the number of keys as length', () {
      Multimap map = new ListMultimap();
      expect(map.length, 0);
      map
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.length, 2);
    });

    test('should return an empty iterable for unmapped keys', () {
      Multimap map = new ListMultimap();
      expect(map['k1'], []);
    });

    test('should support adding values for unmapped keys', () {
      ListMultimap map = new ListMultimap()
        ..['k1'].add('v1');
      expect(map['k1'], ['v1']);
    });

    test('should support adding multiple values for unmapped keys', () {
      ListMultimap map = new ListMultimap()
        ..['k1'].addAll(['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support inserting values for unmapped keys', () {
      ListMultimap map = new ListMultimap()
        ..['k1'].insert(0, 'v1');
      expect(map['k1'], ['v1']);
    });

    test('should support inserting multiple values for unmapped keys', () {
      ListMultimap map = new ListMultimap()
        ..['k1'].insertAll(0, ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support inserting multiple values for unmapped keys', () {
      ListMultimap map = new ListMultimap()
        ..['k1'].length = 2;
      expect(map['k1'], [null, null]);
    });

    test('should return unmapped iterables that stay in sync on add', () {
      ListMultimap map = new ListMultimap();
      List values1 = map['k1'];
      List values2 = map['k1'];
      values1.add('v1');
      expect(map['k1'], ['v1']);
      expect(values2, ['v1']);
    });

    test('should return unmapped iterables that stay in sync on addAll', () {
      ListMultimap map = new ListMultimap();
      List values1 = map['k1'];
      List values2 = map['k1'];
      values1.addAll(['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
      expect(values2, ['v1', 'v2']);
    });

    test('should support adding duplicate values for a key', () {
      Multimap map = new ListMultimap()
        ..add('k', 'v1')
        ..add('k', 'v1');
      expect(map['k'], ['v1', 'v1']);
    });

    test('should support adding multiple keys', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should support adding multiple values at once', () {
      Multimap map = new ListMultimap()
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support adding multiple values at once for existing keys', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v1', 'v2']);
    });

    test('should support adding from another multimap', () {
      Multimap from = new ListMultimap()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      Multimap map = new ListMultimap()
        ..addAll(from);
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should support adding from another multimap with existing keys', () {
      Multimap from = new ListMultimap()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      Multimap map = new ListMultimap()
        ..add('k1', 'v0')
        ..add('k2', 'v3')
        ..addAll(from);
      expect(map['k1'], ['v0', 'v1', 'v2']);
      expect(map['k2'], ['v3', 'v3']);
    });

    test('should return its keys', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.keys, unorderedEquals(['k1', 'k2']));
    });

    test('should return its values', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should support duplicate values', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v1');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v1']));
    });

    test('should return an ordered list of values', () {
      Multimap map = new ListMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map['k'], ['v1', 'v2']);
    });

    test('should reflect changes to underlying list', () {
      ListMultimap map = new ListMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      map['k'].add('v3');
      map['k'].remove('v2');
      expect(map['k'], ['v1', 'v3']);
    });

    test('should return whether it contains a key', () {
      Multimap map = new ListMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsKey('j'), false);
      expect(map.containsKey('k'), true);
    });

    test('should return whether it contains a value', () {
      Multimap map = new ListMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsValue('v0'), false);
      expect(map.containsValue('v1'), true);
    });

    test('should remove specified key-value associations', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.remove('k1', 'v0'), false);
      expect(map.remove('k1', 'v1'), true);
      expect(map['k1'], ['v2']);
      expect(map.containsKey('k2'), true);
    });

    test('should remove a key when all associated values are removed', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..remove('k1', 'v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.remove', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].remove('v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAt', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].removeAt(0);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAt', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].removeLast();
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeRange', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].removeRange(0, 1);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeWhere', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].removeWhere((_) => true);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.replaceRange', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].replaceRange(0, 1, []);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainWhere', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1');
      map['k1'].retainWhere((_) => false);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
        'via the underlying iterable.clear', () {
      ListMultimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      map['k1'].clear();
      expect(map.containsKey('k1'), false);
    });

    test('should remove all values for a key', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.removeAll('k1'), ['v1', 'v2']);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), true);
    });

    test('should clear underlying iterable on remove', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1');
      List values = map['k1'];
      expect(map.removeAll('k1'), ['v1']);
      expect(values, []);
    });

    test('should clear the map', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..clear();
      expect(map.isEmpty, true);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), false);
    });

    test('should clear underlying iterables on clear', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1');
      List values = map['k1'];
      map.clear();
      expect(values, []);
    });

    test('should not add mappings on lookup of unmapped keys', () {
      Multimap map = new ListMultimap()
        ..['k1'];
      expect(map.containsKey('k1'), false);
    });

    test('should not remove mappings on clearing mapped values', () {
      Multimap map = new ListMultimap()
        ..add('k1', 'v1')
        ..['v1'].clear();
      expect(map.containsKey('k1'), true);
    });

    test('should return a map view', () {
      Multimap mmap = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      expect(map.keys, unorderedEquals(['k1', 'k2']));
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should return an empty iterable on map view unmapped key', () {
      Map map = new ListMultimap().toMap();
      expect(map['k1'], []);
    });

    test('should allow addition via unmapped key lookup on map view', () {
      Multimap mmap = new ListMultimap();
      Map map = mmap.toMap();
      map['k1'].add('v1');
      map['k2'].addAll(['v1', 'v2']);
      expect(mmap['k1'], ['v1']);
      expect(mmap['k2'], ['v1', 'v2']);
    });

    test('should reflect additions to iterables returned by map view', () {
      Multimap mmap = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], ['v1', 'v2', 'v3']);
    });

    test('should reflect removals of keys in returned map view', () {
      Multimap mmap = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map.remove('k1');
      expect(mmap.containsKey('k1'), false);
    });

    test('should reflect clearing of returned map view', () {
      Multimap mmap = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      map.clear();
      expect(mmap.isEmpty, true);
    });

    test('should support iteration over all {key, value} pairs', () {
      Set s = new Set();
      Multimap mmap = new ListMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEach((k, v) => s.add(new Pair(k, v)));
      expect(s, unorderedEquals(
          [new Pair('k1', 'v1'), new Pair('k1', 'v2'), new Pair('k2', 'v3')]));
    });

    test('should support iteration over all {key, Iterable<value>} pairs', () {
      Map map = new Map();
      Multimap mmap = new ListMultimap()
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
      Multimap map = new SetMultimap();
      expect(map.isEmpty, true);
      expect(map.isNotEmpty, false);
    });

    test('should not be empty after adding', () {
      Multimap map = new SetMultimap()
        ..add('k', 'v');
      expect(map.isEmpty, false);
      expect(map.isNotEmpty, true);
    });

    test('should return the number of keys as length', () {
      Multimap map = new SetMultimap();
      expect(map.length, 0);
      map
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.length, 2);
    });

    test('should return an empty iterable for unmapped keys', () {
      Multimap map = new SetMultimap();
      expect(map['k1'], []);
    });

    test('should support adding values for unmapped keys', () {
      SetMultimap map = new SetMultimap()
        ..['k1'].add('v1');
      expect(map['k1'], ['v1']);
    });

    test('should support adding multiple values for unmapped keys', () {
      SetMultimap map = new SetMultimap()
        ..['k1'].addAll(['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
    });

    test('should return unmapped iterables that stay in sync on add', () {
      SetMultimap map = new SetMultimap();
      Set values1 = map['k1'];
      Set values2 = map['k1'];
      values1.add('v1');
      expect(map['k1'], ['v1']);
      expect(values2, ['v1']);
    });

    test('should return unmapped iterables that stay in sync on addAll', () {
      SetMultimap map = new SetMultimap();
      Set values1 = map['k1'];
      Set values2 = map['k1'];
      values1.addAll(['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(values2, unorderedEquals(['v1', 'v2']));
    });

    test('should not support adding duplicate values for a key', () {
      Multimap map = new SetMultimap()
        ..add('k', 'v1')
        ..add('k', 'v1');
      expect(map['k'], ['v1']);
    });

    test('should support adding multiple keys', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should support adding multiple values at once', () {
      Multimap map = new SetMultimap()
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], ['v1', 'v2']);
    });

    test('should support adding multiple values at once for existing keys', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v0')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v0', 'v1', 'v2']));
    });

    test('should support adding multiple values for existing (key,value)', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..addValues('k1', ['v1', 'v2']);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
    });

    test('should support adding from another multimap', () {
      Multimap from = new SetMultimap()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      Multimap map = new SetMultimap()
        ..addAll(from);
      expect(map['k1'], unorderedEquals(['v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should support adding from another multimap with existing keys', () {
      Multimap from = new SetMultimap()
        ..addValues('k1', ['v1', 'v2'])
        ..add('k2', 'v3');
      Multimap map = new SetMultimap()
        ..add('k1', 'v0')
        ..add('k2', 'v3')
        ..addAll(from);
      expect(map['k1'], unorderedEquals(['v0', 'v1', 'v2']));
      expect(map['k2'], ['v3']);
    });

    test('should return its keys', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.keys, unorderedEquals(['k1', 'k2']));
    });

    test('should return its values', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should support duplicate values', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v1');
      expect(map.values, unorderedEquals(['v1', 'v2', 'v1']));
    });

    test('should return an ordered list of values', () {
      Multimap map = new SetMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map['k'], unorderedEquals(['v1', 'v2']));
    });

    test('should reflect changes to underlying set', () {
      SetMultimap map = new SetMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      map['k'].add('v3');
      map['k'].remove('v2');
      expect(map['k'], unorderedEquals(['v1', 'v3']));
    });

    test('should return whether it contains a key', () {
      Multimap map = new SetMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsKey('j'), false);
      expect(map.containsKey('k'), true);
    });

    test('should return whether it contains a value', () {
      Multimap map = new SetMultimap()
        ..add('k', 'v1')
        ..add('k', 'v2');
      expect(map.containsValue('v0'), false);
      expect(map.containsValue('v1'), true);
    });

    test('should remove specified key-value associations', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.remove('k1', 'v0'), false);
      expect(map.remove('k1', 'v1'), true);
      expect(map['k1'], ['v2']);
      expect(map.containsKey('k2'), true);
    });

    test('should remove a key when all associated values are removed', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..remove('k1', 'v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.remove', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1');
      map['k1'].remove('v1');
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeAll', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      map['k1'].removeAll(['v1', 'v2']);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.removeWhere', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1');
      map['k1'].removeWhere((_) => true);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainAll', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1');
      map['k1'].retainAll([]);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
         'via the underlying iterable.retainWhere', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1');
      map['k1'].retainWhere((_) => false);
      expect(map.containsKey('k1'), false);
    });

    test('should remove a key when all associated values are removed' +
        'via the underlying iterable.clear', () {
      SetMultimap map = new SetMultimap()
        ..add('k1', 'v1');
      map['k1'].clear();
      expect(map.containsKey('k1'), false);
    });

    test('should remove all values for a key', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      expect(map.removeAll('k1'), unorderedEquals(['v1', 'v2']));
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), true);
    });

    test('should clear underlying iterable on remove', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1');
      Set values = map['k1'];
      expect(map.removeAll('k1'), ['v1']);
      expect(values, []);
    });

    test('should clear the map', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..clear();
      expect(map.isEmpty, true);
      expect(map.containsKey('k1'), false);
      expect(map.containsKey('k2'), false);
    });

    test('should clear underlying iterables on clear', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1');
      Set values = map['k1'];
      map.clear();
      expect(values, []);
    });

    test('should not add mappings on lookup of unmapped keys', () {
      Multimap map = new SetMultimap()
        ..['k1'];
      expect(map.containsKey('k1'), false);
    });

    test('should not remove mappings on clearing mapped values', () {
      Multimap map = new SetMultimap()
        ..add('k1', 'v1')
        ..['v1'].clear();
      expect(map.containsKey('k1'), true);
    });

    test('should return a map view', () {
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      expect(map.keys, unorderedEquals(['k1', 'k2']));
      expect(map['k1'], ['v1', 'v2']);
      expect(map['k2'], ['v3']);
    });

    test('should return an empty iterable on map view unmapped key', () {
      Map map = new SetMultimap().toMap();
      expect(map['k1'], []);
    });

    test('should allow addition via unmapped key lookup on map view', () {
      Multimap mmap = new SetMultimap();
      Map map = mmap.toMap();
      map['k1'].add('v1');
      map['k2'].addAll(['v1', 'v2']);
      expect(mmap['k1'], ['v1']);
      expect(mmap['k2'], unorderedEquals(['v1', 'v2']));
    });

    test('should reflect additions to iterables returned by map view', () {
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should reflect additions to iterables returned by map view', () {
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map['k1'].add('v3');
      expect(mmap['k1'], unorderedEquals(['v1', 'v2', 'v3']));
    });

    test('should reflect removals of keys in returned map view', () {
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2');
      Map map = mmap.toMap();
      map.remove('k1');
      expect(mmap.containsKey('k1'), false);
    });

    test('should reflect clearing of returned map view', () {
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3');
      Map map = mmap.toMap();
      map.clear();
      expect(mmap.isEmpty, true);
    });

    test('should support iteration over all {key, value} pairs', () {
      Set s = new Set();
      Multimap mmap = new SetMultimap()
        ..add('k1', 'v1')
        ..add('k1', 'v2')
        ..add('k2', 'v3')
        ..forEach((k, v) => s.add(new Pair(k, v)));
      expect(s, unorderedEquals(
          [new Pair('k1', 'v1'), new Pair('k1', 'v2'), new Pair('k2', 'v3')]));
    });

    test('should support iteration over all {key, Iterable<value>} pairs', () {
      Map map = new Map();
      Multimap mmap = new SetMultimap()
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

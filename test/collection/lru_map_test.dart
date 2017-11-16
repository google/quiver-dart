// Copyright 2014 Google Inc. All Rights Reserved.
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

library quiver.collection.lru_map_test;

import 'package:quiver/collection.dart';
import 'package:test/test.dart';

void main() {
  group('LruMap', () {
    /// A map that will be initialize by individual tests.
    LruMap<String, String> lruMap;

    test('the length property reflects how many keys are in the map', () {
      lruMap = new LruMap();
      expect(lruMap, hasLength(0));

      lruMap.addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      expect(lruMap, hasLength(3));
    });

    test('accessing keys causes them to be promoted', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.keys.toList(), ['C', 'B', 'A']);

      lruMap['B'];

      // In a LRU cache, the first key is the one that will be removed if the
      // capacity is reached, so adding keys to the end is considered to be a
      // 'promotion'.
      expect(lruMap.keys.toList(), ['B', 'C', 'A']);
    });

    test('new keys are added at the beginning', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      lruMap['D'] = 'Delta';
      expect(lruMap.keys.toList(), ['D', 'C', 'B', 'A']);
    });

    test('setting values on existing keys works, and promotes the key', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      lruMap['B'] = 'Bravo';
      expect(lruMap.keys.toList(), ['B', 'C', 'A']);
      expect(lruMap['B'], 'Bravo');
    });

    test('the least recently used key is evicted when capacity hit', () {
      lruMap = new LruMap(maximumSize: 3)
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      lruMap['D'] = 'Delta';
      expect(lruMap.keys.toList(), ['D', 'C', 'B']);
    });

    test('setting maximum size evicts keys until the size is met', () {
      lruMap = new LruMap(maximumSize: 5)
        ..addAll({
          'A': 'Alpha',
          'B': 'Beta',
          'C': 'Charlie',
          'D': 'Delta',
          'E': 'Epsilon'
        });

      lruMap.maximumSize = 3;
      expect(lruMap.keys.toList(), ['E', 'D', 'C']);
    });

    test('accessing the `keys` collection does not affect position', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.keys.toList(), ['C', 'B', 'A']);

      lruMap.keys.forEach((_) {});
      lruMap.keys.forEach((_) {});

      expect(lruMap.keys.toList(), ['C', 'B', 'A']);
    });

    test('accessing the `values` collection does not affect position', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);

      lruMap.values.forEach((_) {});
      lruMap.values.forEach((_) {});

      expect(lruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);
    });

    test('clearing removes all keys and values', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.isNotEmpty, isTrue);
      expect(lruMap.keys.isNotEmpty, isTrue);
      expect(lruMap.values.isNotEmpty, isTrue);

      lruMap.clear();

      expect(lruMap.isEmpty, isTrue);
      expect(lruMap.keys.isEmpty, isTrue);
      expect(lruMap.values.isEmpty, isTrue);
    });

    test('`containsKey` returns true if the key is in the map', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.containsKey('A'), isTrue);
      expect(lruMap.containsKey('D'), isFalse);
    });

    test('`containsValue` returns true if the value is in the map', () {
      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.containsValue('Alpha'), isTrue);
      expect(lruMap.containsValue('Delta'), isFalse);
    });

    test('`forEach` returns all key-value pairs without modifying order', () {
      final keys = [];
      final values = [];

      lruMap = new LruMap()
        ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});

      expect(lruMap.keys.toList(), ['C', 'B', 'A']);
      expect(lruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);

      lruMap.forEach((key, value) {
        keys.add(key);
        values.add(value);
      });

      expect(keys, ['C', 'B', 'A']);
      expect(values, ['Charlie', 'Beta', 'Alpha']);
      expect(lruMap.keys.toList(), ['C', 'B', 'A']);
      expect(lruMap.values.toList(), ['Charlie', 'Beta', 'Alpha']);
    });

    test('Re-adding the head entry is a no-op', () {
      // See: https://github.com/google/quiver-dart/issues/357
      lruMap = new LruMap();
      lruMap['A'] = 'Alpha';
      lruMap['A'] = 'Alpha';

      expect(lruMap.keys.toList(), ['A']);
      expect(lruMap.values.toList(), ['Alpha']);
    });

    group('`remove`', () {
      setUp(() {
        lruMap = new LruMap()
          ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      });

      test('returns the value associated with a key, if it exists', () {
        expect(lruMap.remove('A'), 'Alpha');
      });

      test('returns null if the provided key does not exist', () {
        expect(lruMap.remove('D'), isNull);
      });

      test('can remove the last item (head and tail)', () {
        // See: https://github.com/google/quiver-dart/issues/385
        lruMap = new LruMap(maximumSize: 1)
          ..addAll({'A': 'Alpha'})
          ..remove('A');
        lruMap['B'] = 'Beta';
        lruMap['C'] = 'Charlie';
        expect(lruMap.keys.toList(), ['C']);
      });

      test('can remove the head', () {
        lruMap.remove('C');
        expect(lruMap.keys.toList(), ['B', 'A']);
      });

      test('can remove the tail', () {
        lruMap.remove('A');
        expect(lruMap.keys.toList(), ['C', 'B']);
      });

      test('can remove a middle entry', () {
        lruMap.remove('B');
        expect(lruMap.keys.toList(), ['C', 'A']);
      });
    });

    test(
        'Test that the linked list is correctly mutated when promoting an element in the middle',
        () {
      LruMap<String, int> lruMap = new LruMap(maximumSize: 3)
        ..addAll({'C': 1, 'A': 1, 'B': 1});
      lruMap['A'] = 1;
      lruMap['C'];
      expect(lruMap.length, lruMap.keys.length);
    });

    group('`putIfAbsent`', () {
      setUp(() {
        lruMap = new LruMap()
          ..addAll({'A': 'Alpha', 'B': 'Beta', 'C': 'Charlie'});
      });

      test('adds an item if it does not exist, and moves it to the MRU', () {
        expect(lruMap.putIfAbsent('D', () => 'Delta'), 'Delta');
        expect(lruMap.keys.toList(), ['D', 'C', 'B', 'A']);
      });

      test('does not add an item if it exists, but does promote it to MRU', () {
        expect(lruMap.putIfAbsent('B', () => throw 'Oops!'), 'Beta');
        expect(lruMap.keys.toList(), ['B', 'C', 'A']);
      });

      test('removes the LRU item if `maximumSize` exceeded', () {
        lruMap.maximumSize = 3;
        expect(lruMap.putIfAbsent('D', () => 'Delta'), 'Delta');
        expect(lruMap.keys.toList(), ['D', 'C', 'B']);
      });
    });
  });
}
